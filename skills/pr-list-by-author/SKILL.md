---
name: pr-list-by-author
description: Lists open GitHub pull requests filtered by a user-supplied list of author logins and review state (not draft, not fully approved). Supports per-repo gh pr list or cross-repo gh search prs plus optional reviewDecision post-check, and optional posting to a Slack channel or canvas. Use when the user runs /pr-list-by-author, asks for a daily PR queue, PRs waiting on review, team triage, or sharing that list to Slack across named repos or all visible repos on GitHub Enterprise or GitHub.com.
---
# PR list by author (awaiting merge / not fully approved)

## Overview

Produces a **deduped list of open pull requests** authored by a chosen set of GitHub users, excluding **drafts** and PRs whose **`reviewDecision` is `APPROVED`**. Supports **per-repo** queries (exact review state, low cost) or **cross-repo search** (broad coverage, optional per-PR follow-up). Works on **GitHub Enterprise** or **github.com** when `gh` is authenticated.

**Default:** Mode **A** (enumerated `REPOS`) after collecting `AUTHORS` and repo slugs. **Slack:** if the user sets `share=channel` / `share=canvas`, passes **`canvas=https://…enterprise.slack.com/docs/T…/F…`**, or asks in natural language to post to a channel or canvas.

## When to use

- Daily or ad-hoc triage of **open** PRs from a **team-defined set of GitHub usernames**.
- Criteria: **not draft**, **`reviewDecision` is not `APPROVED`** (includes `REVIEW_REQUIRED`, `CHANGES_REQUESTED`, and empty string).
- Works on **GitHub Enterprise** or **github.com**; set **`GH_HOST`** to the enterprise hostname when not using github.com (omit or `unset GH_HOST` for public GitHub if `gh` default applies).

## Usage

### Interactive (nothing supplied yet)

```
/pr-list-by-author
```

Or natural language, e.g. “What PRs are waiting on review for our team?”

1. Follow **First step: obtain `AUTHORS`** below (prompt if missing).
2. Ask for **`REPOS`** as comma- or space-separated `owner/repo` slugs **unless** the user asks for “all repos” / cross-repo → then use **Mode B** or **C**.

### Authors and repos in one message

```
/pr-list-by-author alice bob carol repos=acme/platform,acme/lib-ui
```

Natural language examples:

- “Open PRs from `alice` and `bob` on `acme/platform` and `acme/lib-ui`.”
- `authors="alice bob" repos="org/repo-a, org/repo-b"` (normalize quotes and spacing).

Normalize `repos=` the same way: split on commas, trim whitespace, **strip a leading `/` from each slug** (e.g. `/mc-content-platform/loom` → `mc-content-platform/loom`).

### GitHub team instead of a manual author list

User says e.g. `team: my-org/my-team` or “use GitHub team **my-org/content-platform**”:

1. Resolve logins: `gh api orgs/ORG/teams/TEAM_SLUG/members --paginate` (with `GH_HOST` if Enterprise).
2. Use the resulting list as **`AUTHORS`**; continue with Mode **A** or **B** as requested.

### Cross-repo or org-scoped search

User asks for PRs **across all repos** they can access:

- **Mode B:** `gh search prs` per author → merge → **`gh pr view` per candidate** for accurate `reviewDecision` (**B1**), unless they explicitly accept approximate `--review` filters (**B2**).
- **Mode C:** Same as B but add `orgs=org1,org2` (maps to repeated `--owner` on `gh search prs`).

Example prompts:

- “Search all my repos for open PRs from these authors that aren’t fully approved.”
- “Limit search to `mailchimp-monolith` and `mc-content-platform` orgs.”

### Share to Slack

```
/pr-list-by-author alice bob repos=org/a share=channel slack=#my-team
```

- “Post the results to `#my-team-channel`.”
- “Put this list in a Slack canvas for the team.”
- **`canvas=https://…enterprise.slack.com/docs/T…/F…`** — treat like `share=canvas` with a **standing canvas URL**; after the in-chat table, build a **markdown block for this run** and **append** it via Slack MCP (or paste) per **Optional — Post to Slack**.

If `share=channel` is set but **`slack`** is missing for the channel, **prompt once** for `#channel` or ID.

### Optional knobs (conversation or `key=value`)

| Knob | Purpose |
|------|---------|
| `limit=N` | Per-author `gh pr list` cap (Mode **A**) or `-L` for search (Mode **B**/`C`); max **1000** for search. |
| `GH_HOST=host` | Enterprise hostname (e.g. `github.your-company.com`); omit for default `github.com` behavior. |
| `share=channel` | After results, post to a Slack **channel** (see **Optional — Post to Slack**). |
| `share=canvas` | After results, update or create a Slack **canvas** (see below). |
| `canvas=https://…/docs/T…/F…` | **Enterprise Slack canvas / docs URL** — same intent as `share=canvas`; **`canvas_id`** = the **`F…`** segment for Slack MCP tools. |
| `slack=#channel` or `slack=C0123…` | Destination channel when `share=channel` (name with `#` or channel ID). |

### Output

Present a **table**: repo, PR `#`, author, `reviewDecision`, title, **clickable URL**. Mention **dedupe** (by URL) and **repos not scanned** if using Mode **A** only.

If the user asked to share to Slack (`share=channel`, `share=canvas`, **`canvas=`** URL, or natural language such as “post to `#team`”, “put this in a canvas”), run **Optional — Post to Slack** after the table.

## First step: obtain `AUTHORS`

**Do not assume a fixed roster.** Before running queries:

1. If the user already gave GitHub logins (message, paste, or `@mentions`), normalize to a **space- or comma-separated list** and trim `@`.
2. If not provided, **prompt once**: e.g. “Paste GitHub usernames to include (space- or comma-separated), or say `team: org/team-slug` if you want members resolved via the GitHub API.”
3. Optional: if the user gives **`org/team-slug`**, resolve members with  
   `gh api orgs/ORG/teams/TEAM_SLUG/members --paginate -q '.[].login'`  
   (adjust host with `GH_HOST` for Enterprise), then use that list as `AUTHORS`.

Proceed only after `AUTHORS` is non-empty.

## Enumerated repos vs cross-repo search

| Approach | Best when | Pros | Cons |
|----------|-----------|------|------|
| **A. Enumerate `REPOS`** | You know which repos the team ships in. | **Exact `reviewDecision`** in one `gh pr list` call per author per repo; predictable; cheap. | Misses PRs in repos you never list. |
| **B. Cross-repo `gh search prs`** | Authors open PRs across many orgs/repos and the list changes often. | Finds **all open PRs by that author** across repos your token can **search** (subject to indexing and permissions). | Search JSON **has no `reviewDecision`** → **`gh pr view` per PR** for accuracy, or approximate `--review` flags. More API calls; search **cap** (~1000). |
| **C. Org-scoped search** | PRs stay inside a few orgs but many repos. | Narrower than global search. | Same `reviewDecision` gap as B unless you post-filter with `gh pr view`. |

**Default recommendation:** use **A** with an explicit **`REPOS`** list the team owns. Add **B** when the user wants “any repo” or PRs keep appearing outside that list.

## Prerequisites

- `gh` CLI authenticated for the target host (`gh auth login`; use `--hostname` for Enterprise).
- `jq` installed.
- **Slack posting (optional):** Cursor **Slack MCP** (`plugin-slack-slack`) when enabled, or another allowed integration; otherwise copy-paste instructions.
- **GitHub Enterprise:** if repos live on **github.your-company.com** (or another enterprise host) but `gh` defaults to **github.com**, set **`GH_HOST=github.your-company.com`** (or the right hostname) for Mode **A**/`gh pr list` and team resolution.

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| **`AUTHORS`** | _(prompt)_ | **Required.** Space- or comma-separated GitHub logins (`@` stripped). Or resolve from `team: org/team-slug`. |
| **`REPOS`** | _(prompt for Mode A)_ | Mode **A**: one or more `owner/repo` slugs; loop **repos × authors**. Omit only if using Mode **B** (global search). |
| **`LIMIT`** | `100` | Mode **A**: per-author `gh pr list --limit`. Mode **B**/**C**: `gh search prs -L` (max **1000**). |
| **`ORGS`** | _(none)_ | Mode **C**: org names for repeated `--owner` on `gh search prs`. |
| **`GH_HOST`** | _(unset / `gh` default)_ | Enterprise hostname when not using github.com. |
| **Mode** | **A** (`list`) | **A** = enumerated repos (`gh pr list`). **B** = cross-repo search. **C** = org-scoped search. |
| **`share`** | `none` | `none` = chat only. `channel` = post to Slack channel. `canvas` = post to Slack canvas (see below). |
| **`canvas`** | _(none)_ | Optional **Slack docs URL** (`…/docs/T…/F…`); same workflow as `share=canvas` (append a run section via MCP or paste). |
| **`slack`** | _(prompt if `share=channel`)_ | Channel `#name` or ID `C…` when posting to a channel. |

## Do not apply (unless the user asks)

- **No** filter on “at least one submitted review”—only `reviewDecision != "APPROVED"`.
- **Do not** guess **which** Slack channel or canvas to use—confirm **`slack=`** / destination (or accept explicit user instruction).
- **Do not** use Slack **membership** to infer author lists unless the user asked for that mapping.

---

## Optional — Post to Slack (channel or canvas)

Run **only** when the user requests Slack sharing (see **Usage** knobs). Complete the PR table **first**, then post a **summary + links**.

### 1. Build the message body

- **Title line:** e.g. `*Open PRs (awaiting approval)* — {date} UTC` or similar.
- **Bullets or short table** in **Slack mrkdwn**: use `<https://…|owner/repo#123>` for each PR; include author and `reviewDecision` if space allows.
- **Footer:** note repos scanned (Mode **A**) or “cross-repo search” (Mode **B**/`C`) and count of PRs (0 is valid).

Keep under Slack message limits; for very long lists, post **top N** plus “+M more in thread” or split across thread replies.

### 2. Post to a **channel** (`share=channel`)

1. Resolve destination: user-supplied `#channel` or channel ID.
2. Use the **Slack integration available in the environment** (e.g. Slack MCP `plugin-slack-slack`, approved internal bot, or documented webhook). Cursor Slack uses normal sign-in—there is **no** `mcp_auth` on that server.
3. Send the formatted body. Confirm success with the user (permalink or “posted to #…).

If **no** Slack tool is available: paste the formatted mrkdwn into chat and tell the user to copy into Slack, or offer a **snippet file** at `/tmp/open-prs-slack-{date}.txt`.

### 3. Post to a **canvas** (`share=canvas` or **`canvas=`** URL)

**Default behavior:** treat canvas updates as **appends**. Slack MCP **`slack_update_canvas`** with **`content`** typically **adds a new section** to the canvas rather than replacing the entire file—**that is allowed and expected** for this skill. Call it after each run when **`canvas=`** / `share=canvas` is set.

1. **Build one run block:** start with a clear **run header** (e.g. `## Open PRs — {date/time} UTC`) so successive runs stay readable. Include a short line for authors, repos scanned, filters, and PR count. Then sections (e.g. by author) with checklist lines linking each PR—or a compact list if empty. Save the same body to **`/tmp/open-prs-canvas-{YYYY-MM-DD}-{HHMM}Z.md`** (include time so multiple runs the same day do not overwrite) for reference or manual paste.
2. **Slack MCP** (`plugin-slack-slack`): use **`canvas_id`** = **`F…`** from the docs URL (`…/docs/T…/F…`). Call **`slack_update_canvas`** with **`content`** set to that markdown string. **Do not** use a **`markdown`** parameter — that shape can return **`-32603`**. If the tool schema later exposes **full replace / overwrite**, you may use it when the user explicitly asks to replace the whole canvas; otherwise **append** is fine.
3. **Canvas hygiene:** remind the user that the doc **grows** with each automated append; they can archive or delete older sections in Slack when it gets long. If they want a **one-shot full replace** instead, they can **select all → paste** from the latest **`/tmp/open-prs-canvas-*.md`** (replacing everything manually).
4. If **no** canvas tool: post the report as a **channel message** or give paste steps and the **`canvas=`** link.
5. Never fabricate canvas IDs; use the user-supplied **`canvas=`** URL or prompt once.

### 4. Safety

- **No secrets** in the skill (tokens, webhook URLs). Use env vars or Cursor/MCP auth only.
- **Do not** post to public or unrelated channels without explicit destination from the user.

---

## Mode A — Enumerated repos (exact `reviewDecision`)

1. Export host if needed, e.g. `export GH_HOST=github.enterprise.example.com` (or rely on `gh` default for github.com).
2. For **each** `REPO` in `REPOS`, for **each** login in `AUTHORS`:

   ```bash
   gh pr list --repo "$REPO" --author "$login" --state open --limit "$LIMIT" \
     --json number,title,url,author,isDraft,reviewDecision,createdAt
   ```

3. Merge JSON arrays and **dedupe** by URL (or `repository + number`). Single-repo runs can use `unique_by(.number)` if every PR URL shares one repo.
4. Filter: `isDraft == false` and `reviewDecision != "APPROVED"`.
5. Present: `#`, repo, author, `reviewDecision`, title, URL.

**Example (replace `AUTHORS`, `REPO`, and host as needed):**

```bash
export GH_HOST=github.enterprise.example.com   # omit for github.com if default
authors=(alice bob carol)                       # from user or team API
REPO="acme/platform"
args=()
for a in "${authors[@]}"; do
  f=$(mktemp)
  gh pr list --repo "$REPO" --author "$a" --state open --limit 100 \
    --json number,title,url,author,isDraft,reviewDecision,createdAt > "$f"
  args+=("$f")
done
jq -s 'add | unique_by(.number) | map(select(.isDraft == false and .reviewDecision != "APPROVED")) | sort_by(.number)' "${args[@]}"
```

**Multi-repo:** outer loop `for repo in "${repos[@]}"; do` over the same author loop; dedupe by PR URL.

---

## Mode B — All accessible repos (`gh search prs`)

Search returns PRs across repos visible to the user **without** listing each repo. **You still need a second step for `reviewDecision`.**

### B1 — Accurate (recommended): search, then `gh pr view`

1. For each author, collect candidates:

   ```bash
   gh search prs --author "$login" --state open --draft=false -L "$LIMIT" \
     --json repository,number,title,url,author,isDraft
   ```

2. Merge arrays from all authors: `jq -s 'add | unique_by(.url)' ...`
3. For each candidate:

   ```bash
   jq -c '.[]' merged.json | while read -r row; do
     repo=$(echo "$row" | jq -r '.repository.nameWithOwner')
     num=$(echo "$row" | jq -r '.number')
     gh pr view "$num" --repo "$repo" \
       --json number,title,url,author,isDraft,reviewDecision |
       jq 'select(.isDraft == false and .reviewDecision != "APPROVED")'
   done
   ```

4. Deduplicate if needed; present as a table.

**Tradeoff:** one `gh pr view` per candidate (fine for small queues; slow for many).

### B2 — Approximate only (no per-PR view)

`gh search prs` supports `--review {none|required|approved|changes_requested}`. **Not identical** to `reviewDecision`. Use only if the user accepts approximation.

---

## Mode C — Org-scoped search

Same as **B**, but add repeated `--owner org` flags:

```bash
gh search prs --author "$login" --state open --draft=false \
  --owner acme-corp --owner acme-platform -L 100 \
  --json repository,number,title,url,author,isDraft
```

Then apply **B1** or **B2**.

---

## GitHub / `gh` notes

- **`reviewDecision == ""`**: treat as “not fully approved”—**keep** those PRs.
- **Search indexing:** results can lag slightly on some hosts.
- **Caps:** at most **1000** search hits per query.
- **Noise:** global search can include repos the team does not own; **org-scoped search** or **`REPOS`** keeps lists relevant.
