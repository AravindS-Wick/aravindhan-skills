---
name: weekly-performance-regression-report
description: Generate a weekly regression report for the Mailchimp monolith by querying Bugsnag (SmartBear MCP) for new errors and correlating them with recent releases and GitHub commits. Use when the user asks to check for performance degradation, find regressions, generate a weekly error report, or investigate what broke recently.
allowed-tools: mcp__smartbear__bugsnag_list_releases, mcp__smartbear__bugsnag_list_project_errors, mcp__smartbear__bugsnag_get_error, Bash, Write
---
# Mailchimp Regression Report Skill

Generate a Markdown regression report for the Mailchimp monolith covering the last 7 days. Cross-reference Bugsnag error data with release history and GitHub commits to surface new regressions and correlate them to likely culprit deploys.

## Project IDs

| Project | Bugsnag ID | GitHub |
|---|---|---|
| Backend (Mailchimp) | `5d40577f2103c00011aa3a7f` | `mailchimp-monolith/mailchimp` |
| Frontend (Mailchimp-React) | `5d38db033c62ae0010f5c561` | `mailchimp-monolith/mailchimp` |

## Workflow

### Step 1: Gather Bugsnag Data (run in parallel)

Fetch the following simultaneously (6 calls, all in one message):

1. **Backend errors — by volume** — `bugsnag_list_project_errors` on project `5d40577f2103c00011aa3a7f`
   - `filters: { "event.since": [{"type": "eq", "value": "7d"}], "error.status": [{"type": "eq", "value": "open"}] }`
   - `sort: events`, `direction: desc`, `perPage: 30`

2. **Backend errors — new only** — `bugsnag_list_project_errors` on project `5d40577f2103c00011aa3a7f`
   - `filters: { "event.since": [{"type": "eq", "value": "7d"}], "error.status": [{"type": "eq", "value": "open"}], "error.first_seen": [{"type": "eq", "value": "7d"}] }`
   - `sort: users`, `direction: desc`, `perPage: 30`
   - This surfaces errors whose `first_seen_unfiltered` is within the window directly, without scanning all 30 volume-sorted results.

3. **Frontend errors — by volume** — same as #1 on project `5d38db033c62ae0010f5c561`

4. **Frontend errors — new only** — same as #2 on project `5d38db033c62ae0010f5c561`

5. **Backend releases** — `bugsnag_list_releases` on project `5d40577f2103c00011aa3a7f`
   - `releaseStage: production`, `perPage: 100`
   - 100 results covers ~4 days of hourly deploys. If any new regression's `first_seen` is older than the oldest release returned, fetch the next page.

6. **Frontend releases** — same call on project `5d38db033c62ae0010f5c561`, `perPage: 100`

### Step 2: Gather GitHub Commits

Use `gh api` via Bash to fetch commits covering the full 7-day window. Use `since` and `until` to avoid getting only today's commits:

```bash
gh api "repos/mailchimp-monolith/mailchimp/commits?sha=main&per_page=100&since=$(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ)" \
  --hostname github.your-company.com \
  | python3 -c "
import json, sys
commits = json.loads(sys.stdin.read())
for c in commits:
    print(c['commit']['author']['date'], c['sha'][:10], c['commit']['message'].split('\n')[0])
" | tee /tmp/commits-7d.txt
```

If a culprit release falls outside this window, do a targeted fetch:
```bash
gh api "repos/mailchimp-monolith/mailchimp/commits?sha=main&per_page=50&until=TIMESTAMP&since=TIMESTAMP_MINUS_2H" \
  --hostname github.your-company.com
```

### Step 3: Identify Regressions

For each error in the results, classify it:

**NEW regression** (high priority) — ALL of the following are true:
- `first_seen_unfiltered` is within the last 7 days (matches or is close to `first_seen`)
- No pre-existing Jira ticket, OR the ticket was opened this week
- Event volume is significant (>1,000 events or >100 users)

**SPIKE** (medium priority) — error exists historically but event count in the 7-day window is anomalously high relative to context.

**ONGOING** (low priority) — long-running known issue with an existing Jira ticket.

### Step 4: Correlate Errors to Releases

For each new regression, find the release deployed just before `first_seen`:
- Scan the releases list for the most recent release with `first_released_at` ≤ `first_seen`
- That release version is the likely culprit deploy

### Step 5: Correlate Releases to Commits

Look through the GitHub commits list for merges that occurred around the same time as the culprit release (within ~1 hour before). Flag any commits whose subject line mentions areas related to the error (e.g., segmentation, search, editor, audience, analytics).

### Step 5.5: Look Up Code Owners

**Primary method — Bugsnag event metadata (free, no extra call):**

Call `bugsnag_get_error` for each confirmed new regression. The response includes
`latest_event.metaData.Custom.codeowners_json` — a pre-populated JSON array of owning
teams at event time. Extract from the first entry:
- `github_team` → owner
- `slack_channel_for_pr_reviews` → Slack channel

Example path in response: `latest_event → metaData → Custom → codeowners_json`

**Fallback — docker exec (only if Bugsnag metadata is missing):**

```bash
docker exec -t mc-dev-app sh -c 'cd /opt/mailchimp/current && php batch/owners show <file_path>' \
  | python3 -c "
import json, sys
data = json.loads(sys.stdin.read())
entry = data[0] if isinstance(data, list) else data
l1 = entry.get('owning_l1_capabilities', [])
caps = entry.get('owning_capabilities', [])
cap = l1[0] if l1 else (caps[0] if caps else None)
print('team:', cap.get('github_team','') if cap else 'Unowned')
print('slack:', cap.get('slack_channel_for_pr_reviews','') if cap else '')
"
```

Note: The output is a JSON **array** (not object) — always access `data[0]`.

### Step 6: Write the Report

Create a gist of this file named `regression-report-YYYY-MM-DD.md` in https://github.your-company.com/gist

## Report Template

```markdown
# Regression Report — Last 7 Days (DATE_RANGE)

Both the frontend (**Mailchimp-React**) and backend (**Mailchimp**) are deploying
roughly hourly (currently at **vX.X.XXXX**). Error timelines from Bugsnag were
cross-referenced with release and commit history to identify likely regressions.

---

## Critical New Regressions

### N. [Backend/Frontend] — [Short Error Name]

| Field | Value |
|---|---|
| **Error** | `error message` in `file.php` |
| **Endpoint** | `METHOD /path/to/endpoint` |
| **First seen** | YYYY-MM-DD HH:MM UTC |
| **Volume** | X,XXX events, X,XXX users affected |
| **Jira** | None filed yet / TICKET-ID |
| **Code Owner** | `@org/team-name` (Slack: `#channel`) |

**Correlation:** Release **vX.X.XXXX** was deployed at YYYY-MM-DD HH:MM UTC — N
minutes before this error appeared. [Describe the likely cause based on the error
class, file, and any correlated commits.]

---

## Significant New Issues (No Prior History)

[Same table format as above for medium-priority new errors]

---

## Ongoing High-Volume Issues (Pre-existing)

| Error | Volume (7d) | Users | Jira |
|---|---|---|---|
| `ErrorClass: message` | X,XXX | X,XXX | TICKET-ID |

---

## Summary of Likely Culprit Commits

| Error | Release | Suspected Commit/PR |
|---|---|---|
| [short error name] | vX.X.XXXX (HH:MM UTC Mon DD) | PR #XXXXX — [commit subject] |

---

## Recommended Actions

1. **Immediate:** [action for critical regressions]
2. **Investigate:** [action for medium issues]
3. **Monitor:** [action for ongoing ramps / partial fixes]
```

## Triage Heuristics

- **`first_seen_unfiltered` == `first_seen`**: Definitively new this week.
- **`first_seen_unfiltered` matches a release timestamp exactly**: High confidence the release caused it.
- **No Jira + high user count**: Definitely needs a ticket filed — call this out.
- **Error in a ProSegmentation / segmentation endpoint + recent flag ramp to >0%**: Likely the flag ramp triggered a new code path.
- **`PHP Fatal Error: Allowed memory size exhausted`**: Check for a memory flag ramp in recent commits.
- **`ChunkLoadError`**: Frontend JS chunk missing — likely a deploy artifact issue, not a code regression.
- **Errors with `first_seen` at the very start of the 7-day window**: Could be longer-running; note uncertainty.
- **Companion errors on the same endpoint**: Group them as one regression (e.g., a TwirpError + its underlying cause).

## Output

- Print a brief summary to the user (bullet list of regressions found)
- Save the full Markdown report to `regression-report-YYYY-MM-DD.md`
- Tell the user the filename when done
