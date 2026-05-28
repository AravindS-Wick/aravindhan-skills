---
name: codeowners
description: Look up CODEOWNERS information and use batch/owners. Use when the user asks who owns a file, which team to ping, what Slack channel to use for a file or feature, what reviewers to add to a PR, or for any batch/owners command (show, summarize, export report, change, sort, check).
disable-model-invocation: true
---
# Codeowners and `batch/owners`

When the user asks for ownership information or for anything related to CODEOWNERS/capabilities, use **`batch/owners`** in the app container. This skill documents what the CLI provides and how to run it.

For team → Slack channel → Jira project → flag prefix mappings, see `docs/codeowners.md`.

## Running `batch/owners`

PHP must run **inside the app container** (not the host). From the mailchimp repo root:

```bash
docker exec -t mc-dev-app sh -c 'cd /opt/mailchimp/current && php batch/owners <command> [options] [args]'
```

Or with devenv:

```bash
devenv exec -- php batch/owners <command> [options] [args]
```

Use file paths **relative to the repo root** (e.g. `app/lib/MC/CodeOwners/App/Show.php`).

---

## Commands overview

| Command | Description |
|--------|-------------|
| **show** | Show ownership information for path(s) — **JSON** with capabilities, Slack channel, asset_id (use for "who owns this file?") |
| **summarize-ownership** | Summarize ownership of files in the repo (counts, owned vs unowned) |
| **export-ownership-report** | Export ownership report data into a directory |
| **change** | Add an owner to the CODEOWNERS file |
| **sort** | Sort the CODEOWNERS file |
| **check:valid-owners** | Validate that owners in CODEOWNERS are in a GitHub org team |
| **check:valid-path** | Validate that CODEOWNERS rules map to real paths |
| **check:files-owned** | Validates owners are owned by a GitHub org team |
| **check:rule-order** | Validate CODEOWNERS rules placement |
| **check:rule-removal** | Validate rules are not removed without being owned by a codeowner |

List commands: `php batch/owners list`. Help for a command: `php batch/owners <command> --help`.

---

## `show` — ownership for path(s) (primary lookup)

Use for: "Who owns this file?", "Slack channel for this file?", "Asset ID for this file?"

```bash
php batch/owners show [--owners_file=...] [--capabilities_file=...] -- <path> [<path> ...]
```

- **Paths:** One or more repo-relative paths.
- **Options:**  
  - `--owners_file` — CODEOWNERS file (default: repo `/.github/CODEOWNERS`).  
  - `--capabilities_file` — Capabilities file (default: repo `/.github/capabilities.json`).

### JSON output shape

Output is a **JSON array**: one object per path.

**Per path object:**

| Field | Type | When present | Meaning |
|-------|------|--------------|---------|
| **path** | string | always | The path that was looked up |
| **is_owned** | bool | always | Whether a CODEOWNERS rule matched |
| **self_serve** | bool | always | Whether the path has self-serve ownership |
| **pattern** | string | if owned | The matching CODEOWNERS pattern (e.g. `/app/lib/MC/CodeOwners/`) |
| **line** | int | if owned | Line number of the rule in CODEOWNERS |
| **owners** | string[] | if owned | Owner specs (e.g. `@org/team-name`) |
| **owning_capabilities** | array | if owned | All capabilities for the owners (see below) |
| **owning_l1_capabilities** | array | if owned | L1 capabilities only (prefer for "the" owner) |

**Capability object** (each entry in `owning_capabilities` / `owning_l1_capabilities`):

| Field | Meaning |
|-------|--------|
| **name** | Human-readable capability name (e.g. "Development Ecosystem > Operations & Operational Excellence") |
| **github_team** | GitHub team (e.g. `@mailchimp-monolith/platform-operations_and_operational_excellence`) |
| **asset_id** | Dev Portal asset ID (use as-is in URLs or other tools) |
| **slack_channel_for_pr_reviews** | Slack channel for PR reviews (e.g. `#mc-platform-opex`) |
| **level** | Level (1 = L1) |

### How to report back

- **Slack channel:** From the first entry in **owning_l1_capabilities**, or else first in **owning_capabilities**: use **slack_channel_for_pr_reviews**.
- **Asset ID:** Same capability's **asset_id** — use the raw value for Dev Portal URLs or other commands.
- **Owners / team:** Use **owners** and/or **github_team** from the capability.
- If **is_owned** is false or there are no owning capabilities, say the file is **unowned** and omit channel/asset_id.

### Example

```bash
php batch/owners show app/lib/MC/CodeOwners/App/Show.php
```

Example result (abbreviated):

```json
[
  {
    "path": "app/lib/MC/CodeOwners/App/Show.php",
    "is_owned": true,
    "pattern": "/app/lib/MC/CodeOwners/",
    "line": 1617,
    "owners": ["@mailchimp-monolith/platform-operations_and_operational_excellence"],
    "self_serve": false,
    "owning_capabilities": [
      {
        "name": "Development Ecosystem > Operations & Operational Excellence",
        "github_team": "@mailchimp-monolith/platform-operations_and_operational_excellence",
        "asset_id": "7212532396559129450",
        "slack_channel_for_pr_reviews": "#mc-platform-opex",
        "level": 1
      }
    ],
    "owning_l1_capabilities": [ ... ]
  }
]
```

---

## Other commands (when to use)

- **summarize-ownership** — User asks for repo-wide ownership stats (e.g. "how much of the repo is owned?", "ownership summary"). Output is JSON with counts and percentages.
- **export-ownership-report** — User wants to export ownership data to a directory (e.g. for reporting). Requires `--export-dir`.
- **change** — User wants to add an owner to CODEOWNERS; arguments are the changes to apply.
- **sort** — User wants to sort the CODEOWNERS file.
- **check:*** — User asks to validate CODEOWNERS (valid owners, valid paths, rule order, rule removal, files-owned). Run the specific check subcommand and report pass/fail or errors.

For any command, run it with `--help` in the container to see options and arguments.
