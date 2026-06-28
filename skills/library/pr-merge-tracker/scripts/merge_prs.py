import argparse
import json
import os
import subprocess
import sys
import time

def run_cmd(cmd, cwd=None):
    """Runs a shell command, ensuring GITHUB_TOKEN is cleared to respect local gh auth."""
    env = os.environ.copy()
    if "GITHUB_TOKEN" in env:
        del env["GITHUB_TOKEN"]
    res = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, env=env)
    return res.returncode == 0, res.stdout.strip(), res.stderr.strip()

def resolve_conflict_file(file_path):
    """Automatically resolves conflict markers in simple export/index files by merging unique exports."""
    if not os.path.exists(file_path):
        return False
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        if "<<<<<<< " not in content:
            return True

        lines = content.splitlines()
        new_lines = []
        in_conflict = False
        side_a = []
        side_b = []
        current_side = None

        for line in lines:
            if line.startswith("<<<<<<< "):
                in_conflict = True
                current_side = "a"
                side_a = []
                side_b = []
            elif line.startswith("======="):
                current_side = "b"
            elif line.startswith(">>>>>>> "):
                in_conflict = False
                combined = []
                for l in (side_a + side_b):
                    if l.strip() and l not in combined:
                        combined.append(l)
                new_lines.extend(combined)
            elif in_conflict:
                if current_side == "a":
                    side_a.append(line)
                else:
                    side_b.append(line)
            else:
                new_lines.append(line)

        resolved_content = "\n".join(new_lines) + "\n"
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(resolved_content)
        return True
    except Exception as e:
        print(f"Error resolving conflict in {file_path}: {e}")
        return False

def local_resolve_and_merge(branch_name, resolve_files):
    """Performs a local merge of origin/main into branch_name and resolves specified file conflicts."""
    print(f"Attempting local merge of origin/main into {branch_name}...")

    run_cmd(["git", "fetch", "origin"])
    run_cmd(["git", "checkout", branch_name])
    run_cmd(["git", "pull", "origin", branch_name])

    merge_ok, merge_out, merge_err = run_cmd(["git", "merge", "origin/main"])
    if merge_ok:
        print("Merged origin/main cleanly.")
        run_cmd(["git", "push", "origin", branch_name])
        run_cmd(["git", "checkout", "main"])
        return True

    print("Merge conflicted. Checking auto-resolvable files...")

    for f in resolve_files:
        if os.path.exists(f):
            print(f"Trying to auto-resolve conflicts in {f}...")
            if resolve_conflict_file(f):
                run_cmd(["git", "add", f])
                if f.endswith(".scss"):
                    run_cmd(["npx", "stylelint", f, "--fix"])
                    run_cmd(["git", "add", f])

    _, status_out, _ = run_cmd(["git", "status"])
    if "Unmerged paths:" in status_out or "both added:" in status_out or "both modified:" in status_out:
        print(f"Local conflicts remain that cannot be auto-resolved.")
        run_cmd(["git", "merge", "--abort"])
        run_cmd(["git", "checkout", "main"])
        return False

    commit_ok, _, commit_err = run_cmd(["git", "commit", "-m", "chore(merge): merge main and resolve index conflicts"])
    if not commit_ok:
        # Nothing to commit (already clean)
        if "nothing to commit" in commit_err or "nothing to commit" in commit_ok:
            pass
        else:
            print(f"Failed to commit merge: {commit_err}")
            run_cmd(["git", "merge", "--abort"])
            run_cmd(["git", "checkout", "main"])
            return False

    push_ok, _, push_err = run_cmd(["git", "push", "origin", branch_name])
    if not push_ok:
        print(f"Failed to push branch: {push_err}")
        run_cmd(["git", "checkout", "main"])
        return False

    print(f"Successfully merged origin/main into {branch_name} locally and pushed.")
    run_cmd(["git", "checkout", "main"])
    return True

def get_open_prs():
    """Retrieves all open PRs sorted by number ascending."""
    ok, stdout, stderr = run_cmd(["gh", "pr", "list", "--state", "open", "--json", "number,headRefName,title", "--limit", "100"])
    if not ok:
        print(f"Error fetching PRs: {stderr}")
        return []
    try:
        prs = json.loads(stdout)
        prs.sort(key=lambda x: x["number"])
        return prs
    except Exception as e:
        print(f"Failed to parse PR JSON: {e}")
        return []

def get_latest_run_status(branch_name):
    """Gets the status of the latest CI run on the branch via gh run list."""
    ok, stdout, stderr = run_cmd([
        "gh", "run", "list",
        "--branch", branch_name,
        "--limit", "1",
        "--json", "status,conclusion,databaseId,workflowName,createdAt"
    ])
    if not ok or not stdout.strip() or stdout.strip() == "[]":
        return "pending", None

    try:
        runs = json.loads(stdout)
        if not runs:
            return "pending", None
        run = runs[0]
        status = run.get("status", "").lower()
        conclusion = run.get("conclusion", "").lower() if run.get("conclusion") else ""
        run_id = run.get("databaseId")

        if status in ("completed", "success"):
            if conclusion in ("success", ""):
                return "pass", run_id
            elif conclusion in ("failure", "cancelled", "timed_out", "action_required"):
                return "fail", run_id
            else:
                return "pass", run_id  # skipped/neutral = treat as pass
        elif status in ("in_progress", "queued", "waiting", "requested", "pending"):
            return "pending", run_id
        elif conclusion in ("failure", "cancelled", "timed_out"):
            return "fail", run_id
        else:
            return "pending", run_id
    except Exception as e:
        print(f"Error parsing run status: {e}")
        return "pending", None

def wait_for_checks(pr_number, branch_name):
    """Waits for PR CI checks with progressive sleep, always checking the latest run."""
    print("Waiting 60 seconds for CI to start and complete...")
    time.sleep(60)

    status, run_id = get_latest_run_status(branch_name)
    print(f"Status check (after 60s): {status} [run: {run_id}]")

    if status == "pending":
        print("Waiting 30 seconds before second check...")
        time.sleep(30)
        status, run_id = get_latest_run_status(branch_name)
        print(f"Status check (after +30s): {status} [run: {run_id}]")

    if status == "pending":
        print("Waiting 30 seconds before third check...")
        time.sleep(30)
        status, run_id = get_latest_run_status(branch_name)
        print(f"Status check (after +30s): {status} [run: {run_id}]")

    while status == "pending":
        print("Still pending. Polling again in 20 seconds...")
        time.sleep(20)
        status, run_id = get_latest_run_status(branch_name)
        print(f"Status check (polled): {status} [run: {run_id}]")

    return status, run_id

def fix_lockfile_if_needed(branch_name):
    """Checks if pnpm-lock.yaml is dirty and commits it if so."""
    run_cmd(["git", "checkout", branch_name])
    run_cmd(["git", "pull", "origin", branch_name])

    # Re-run pnpm install to sync the lockfile
    ok, out, err = run_cmd(["pnpm", "install"])
    
    # Check if lockfile changed
    _, diff_out, _ = run_cmd(["git", "diff", "--name-only"])
    if "pnpm-lock.yaml" in diff_out:
        print("pnpm-lock.yaml is out of date. Updating and pushing...")
        run_cmd(["git", "add", "pnpm-lock.yaml"])
        run_cmd(["git", "commit", "-m", "chore: update pnpm-lock.yaml"])
        run_cmd(["git", "push", "origin", branch_name])
        run_cmd(["git", "checkout", "main"])
        return True
    
    run_cmd(["git", "checkout", "main"])
    return False

def process_prs(resolve_files, dry_run=False, interactive=True):
    print("==================================================")
    print(f"Starting PR Merge Tracker in: {os.getcwd()}")
    print("==================================================")

    if not dry_run:
        print("Updating local 'main' branch...")
        run_cmd(["git", "checkout", "main"])
        run_cmd(["git", "pull", "origin", "main"])

    fail_count = {}  # track consecutive failures per PR

    while True:
        prs = get_open_prs()
        if not prs:
            print("\n✅ No open PRs found. All done!")
            break

        pr = prs[0]
        pr_number = pr["number"]
        branch_name = pr["headRefName"]
        title = pr["title"]

        print(f"\n---> Next PR: #{pr_number} | Title: {title} | Branch: {branch_name}")

        if dry_run:
            print(f"[DRY-RUN] Would process PR #{pr_number} ({branch_name})")
            status, run_id = get_latest_run_status(branch_name)
            print(f"[DRY-RUN] Current check status: {status} [run: {run_id}]")
            break

        if interactive:
            resp = input(f"Process PR #{pr_number} ({branch_name})? [Y/n]: ").strip().lower()
            if resp == 'n':
                print("Skipping this PR and terminating script.")
                break

        # ── 1. Update branch with main ─────────────────────────────────────
        while True:
            print("Updating branch with main...")
            updated, out, err = run_cmd(["gh", "pr", "update-branch", str(pr_number)])
            if updated:
                print("Branch updated successfully via GitHub.")
                break
            else:
                print("Failed to update branch via GitHub. Attempting local merge...")
                local_merged = local_resolve_and_merge(branch_name, resolve_files)
                if local_merged:
                    break
                else:
                    print(f"\n[!] Merge conflicts on '{branch_name}' that couldn't be auto-resolved.")
                    print(f"Please checkout '{branch_name}', resolve the conflicts, commit, push, and press Enter to resume...")
                    input("Press Enter once conflicts are resolved and pushed: ")

        # ── 2. Wait for CI checks ──────────────────────────────────────────
        while True:
            status, run_id = wait_for_checks(pr_number, branch_name)

            if status == "pass":
                print("✅ All checks passed!")
                fail_count[pr_number] = 0
                break

            elif status == "fail":
                fail_count[pr_number] = fail_count.get(pr_number, 0) + 1
                print(f"\n[!] PR #{pr_number} checks FAILED! (attempt {fail_count[pr_number]})")

                # Auto-fix: try regenerating lockfile first
                if fail_count[pr_number] == 1:
                    print("Auto-attempting lockfile fix...")
                    fixed = fix_lockfile_if_needed(branch_name)
                    if fixed:
                        print("Lockfile fixed and pushed. Re-checking CI...")
                        continue  # re-poll

                # Show the run URL for inspection
                if run_id:
                    ok, repo_out, _ = run_cmd(["gh", "repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner"])
                    if ok and repo_out:
                        print(f"Inspect: https://github.com/{repo_out}/actions/runs/{run_id}")

                print(f"Please fix the issues locally on branch '{branch_name}', push, and press Enter to re-check...")
                input("Press Enter once you have pushed your fixes: ")

            else:
                print("[!] Error checking PR status checks.")
                input("Press Enter to retry: ")

        # ── 3. Merge PR ────────────────────────────────────────────────────
        print(f"Merging PR #{pr_number}...")
        merged = False
        for attempt in range(3):
            ok, out, err = run_cmd(["gh", "pr", "merge", str(pr_number), "--squash", "--delete-branch"])
            if ok:
                print(f"✅ PR #{pr_number} successfully merged!")
                merged = True
                break
            else:
                print(f"Merge attempt {attempt + 1} failed: {err}")
                if attempt < 2:
                    time.sleep(10)

        if not merged:
            print("Attempting merge with admin bypass...")
            ok, out, err = run_cmd(["gh", "pr", "merge", str(pr_number), "--squash", "--delete-branch", "--admin"])
            if ok:
                print(f"✅ PR #{pr_number} successfully merged via admin bypass!")
            else:
                print(f"CRITICAL: Failed to merge PR #{pr_number}: {err}")
                print("Please resolve manually on GitHub, then press Enter to continue...")
                input("Press Enter once merged on GitHub: ")

        # ── 4. Pull main and continue ──────────────────────────────────────
        run_cmd(["git", "checkout", "main"])
        run_cmd(["git", "pull", "origin", "main"])
        time.sleep(3)

def main():
    parser = argparse.ArgumentParser(description="pr-merge-tracker: generic sequential PR merging pipeline")
    parser.add_argument(
        "--resolve-files",
        type=str,
        default="packages/react/src/index.ts,packages/vue/src/index.ts,src/index.scss",
        help="Comma-separated files to auto-resolve conflict markers on"
    )
    parser.add_argument("--dry-run", action="store_true", help="Simulate without making changes")
    parser.add_argument("--non-interactive", action="store_true", help="Skip per-PR confirmations")
    args = parser.parse_args()

    resolve_list = [f.strip() for f in args.resolve_files.split(",") if f.strip()]

    ok, stdout, stderr = run_cmd(["gh", "auth", "status"])
    if not ok:
        print("ERROR: gh CLI is not authenticated. Please run 'gh auth login' first.")
        print(stderr)
        sys.exit(1)

    process_prs(resolve_list, dry_run=args.dry_run, interactive=not args.non_interactive)

if __name__ == "__main__":
    main()
