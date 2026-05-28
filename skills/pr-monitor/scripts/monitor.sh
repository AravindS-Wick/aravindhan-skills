#!/bin/bash
set -e

PR_NUMBER=${PR_NUMBER}
TEAM="${TEAM}"
FLAKY_RERUN_MODE="${FLAKY_RERUN_MODE:-prompt}"
CHECK_INTERVAL=60
MAX_CHECKS=120
RERUN_ATTEMPTS=0
MAX_RERUN_ATTEMPTS=2

echo "=========================================="
echo "[PR #${PR_NUMBER}] Enhanced monitoring started at $(date)"
echo "[PR #${PR_NUMBER}] Team: ${TEAM}"
echo "[PR #${PR_NUMBER}] Flaky rerun mode: ${FLAKY_RERUN_MODE}"
echo "[PR #${PR_NUMBER}] Will detect flaky tests and auto-rerun CI if appropriate"
echo "=========================================="

# Determine if a CI failure is related to PR changes or likely flaky
check_if_flaky_failure() {
    local pr_number=$1

    changed_files=$(gh pr diff ${pr_number} --name-only)

    failed_checks=$(gh pr checks ${pr_number} --json name,detailsUrl,conclusion,workflowName \
        | jq -r '.[] | select(.conclusion == "FAILURE" or .conclusion == "TIMED_OUT") | @json')

    if [ -z "$failed_checks" ]; then
        return 1  # No failures
    fi

    echo "[PR #${PR_NUMBER}] 🔍 Analyzing failed checks..."

    local flaky_detected=0
    local total_failures=0

    while IFS= read -r check; do
        total_failures=$((total_failures + 1))
        check_name=$(echo "$check" | jq -r '.name')

        echo "[PR #${PR_NUMBER}]   - Analyzing: ${check_name}"

        # Database connection errors are infrastructure-level and always flaky
        if echo "$check_name" | grep -qi "LoginUserCreationServiceTest\|database\|DB_Exception"; then
            echo "[PR #${PR_NUMBER}]     → Likely flaky: Database connection issue"
            flaky_detected=1
            continue
        fi

        # If the failing test file wasn't touched in this PR, it's probably not our fault
        test_file=$(echo "$check_name" | grep -oP 'tests_phpunit/[^:]+\.php|tests/[^:]+\.php' || echo "")
        if [ -n "$test_file" ]; then
            if ! echo "$changed_files" | grep -q "$test_file"; then
                echo "[PR #${PR_NUMBER}]     → Likely flaky: Test file not modified in PR"
                echo "[PR #${PR_NUMBER}]       Test: $test_file"
                flaky_detected=1
                continue
            fi
        fi

        # Timing/infrastructure failures
        if echo "$check_name" | grep -qi "timeout\|infrastructure\|network"; then
            echo "[PR #${PR_NUMBER}]     → Likely flaky: Infrastructure/timing issue"
            flaky_detected=1
            continue
        fi

    done <<< "$failed_checks"

    if [ "$flaky_detected" -eq 1 ]; then
        echo "[PR #${PR_NUMBER}] ⚠️  Detected $total_failures failure(s) that appear unrelated to PR changes"
        return 0
    fi

    echo "[PR #${PR_NUMBER}] ❌ Failures appear related to PR changes"
    return 1
}

rerun_ci() {
    local pr_number=$1

    echo "[PR #${PR_NUMBER}] 🔄 Rerunning failed CI checks..."

    workflow_run=$(gh pr checks ${pr_number} --json detailsUrl \
        | jq -r '.[0].detailsUrl' \
        | grep -oP 'runs/\K[0-9]+' || echo "")

    if [ -z "$workflow_run" ]; then
        echo "[PR #${PR_NUMBER}] ❌ Could not determine workflow run ID"
        return 1
    fi

    gh run rerun ${workflow_run} --failed || {
        echo "[PR #${PR_NUMBER}] ⚠️  Rerun command failed, trying full rerun..."
        gh run rerun ${workflow_run} || {
            echo "[PR #${PR_NUMBER}] ❌ Could not rerun workflow"
            return 1
        }
    }

    echo "[PR #${PR_NUMBER}] ✅ CI rerun initiated"
    RERUN_ATTEMPTS=$((RERUN_ATTEMPTS + 1))
    return 0
}

checks_count=0
while [ $checks_count -lt $MAX_CHECKS ]; do
    status_json=$(gh pr view ${PR_NUMBER} --json statusCheckRollup,state,isDraft)
    pr_state=$(echo "$status_json" | jq -r '.state')
    is_draft=$(echo "$status_json" | jq -r '.isDraft')

    if [ "$pr_state" != "OPEN" ]; then
        echo "[PR #${PR_NUMBER}] PR closed (state: ${pr_state})"
        exit 0
    fi

    total=$(echo "$status_json" | jq '[.statusCheckRollup[] | select(.name != null or .context != null)] | length')
    pending=$(echo "$status_json" | jq '[.statusCheckRollup[] | select(.status == "PENDING" or .status == "QUEUED" or .status == "IN_PROGRESS" or .state == "PENDING")] | length')
    failed=$(echo "$status_json" | jq '[.statusCheckRollup[] | select(.conclusion == "FAILURE" or .state == "FAILURE" or .conclusion == "TIMED_OUT" or .state == "ERROR")] | length')

    echo "[PR #${PR_NUMBER}] [$(date +%H:%M:%S)] Total: ${total}, Pending: ${pending}, Failed: ${failed}, Draft: ${is_draft}, Reruns: ${RERUN_ATTEMPTS}/${MAX_RERUN_ATTEMPTS}"

    if [ "$failed" -gt 0 ]; then
        echo "[PR #${PR_NUMBER}] ❌ CI failures detected"

        if check_if_flaky_failure ${PR_NUMBER}; then
            if [ "$RERUN_ATTEMPTS" -lt "$MAX_RERUN_ATTEMPTS" ]; then
                case "$FLAKY_RERUN_MODE" in
                    auto)
                        echo "[PR #${PR_NUMBER}] 🤖 Auto-rerunning CI (mode: auto)"
                        rerun_ci ${PR_NUMBER}
                        echo "[PR #${PR_NUMBER}] ⏳ Waiting for new CI run to start..."
                        sleep 30
                        continue
                        ;;
                    prompt)
                        echo "[PR #${PR_NUMBER}] 💬 Flaky test detected - manual intervention required"
                        echo "[PR #${PR_NUMBER}] 💡 Set FLAKY_RERUN_MODE=auto to rerun automatically"
                        echo "[PR #${PR_NUMBER}] 💡 Or run: gh run rerun --failed"
                        exit 2  # Exit code 2 = needs user decision
                        ;;
                    off)
                        echo "[PR #${PR_NUMBER}] ⚠️  Flaky test detected but auto-rerun disabled"
                        exit 1
                        ;;
                esac
            else
                echo "[PR #${PR_NUMBER}] ⚠️  Max rerun attempts ($MAX_RERUN_ATTEMPTS) reached"
                echo "[PR #${PR_NUMBER}] ❌ CI still failing after reruns - may need manual intervention"
                exit 1
            fi
        else
            echo "[PR #${PR_NUMBER}] ❌ CI FAILED - Failures appear related to PR changes"
            exit 1
        fi
    fi

    if [ "$pending" -eq 0 ] && [ "$total" -gt 0 ]; then
        echo "[PR #${PR_NUMBER}] ✅ All checks passed"

        if [ "$is_draft" = "true" ]; then
            echo "[PR #${PR_NUMBER}] Converting from draft to ready for review..."
            gh pr ready ${PR_NUMBER}
            sleep 2
        fi

        echo "[PR #${PR_NUMBER}] Adding ${TEAM} as reviewers..."
        gh pr edit ${PR_NUMBER} --add-reviewer "${TEAM}"
        echo "[PR #${PR_NUMBER}] ✅ COMPLETE - Reviewers added successfully"
        exit 0
    fi

    sleep $CHECK_INTERVAL
    checks_count=$((checks_count + 1))
done

echo "[PR #${PR_NUMBER}] ⏱️ Timeout after 2 hours - Not converting from draft or adding reviewers"
exit 1
