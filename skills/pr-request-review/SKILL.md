---
name: pr-request-review
description: Request a code review for a PR by finding the right Slack channel (from PR CODEOWNERS comment or capabilities.json), checking if a bot thread already exists in that channel, and bumping the thread or posting fresh. Use when the user runs /pr-request-review, asks to request a review, wants to ping a team for their PR, or says "bump my PR".
---

# Request Review

Ping the right Slack channel for a PR review — finds the channel from the PR's CODEOWNERS comment or `capabilities.json`, checks for an existing bot thread in that channel, and replies to it (with channel broadcast) or posts fresh if none exists.

## Message format

Mirror the style from real review requests in the channel:
- Lead with a `:pr-{number}:` emoji if a custom PR emoji is available, otherwise omit
- One-sentence ask: "Hey {team short name}, could I get a code review on this PR? Thank you in advance!"
- PR link on its own line
- Bullet list of files the team is tagged as CODEOWNER on (from the PR diff, filtered to that team's owned paths only)
- Prefix with `🤖: ` when sending on behalf of the user

Example:
```
🤖: Hey platform services delivery, could I get a code review on this PR? Thank you in advance!
https://github.your-company.com/.../pull/12345

These are the files you were tagged codeowner on:
• app/lib/MC/Foo/Bar.php
• app/lib/MC/Foo/Baz.php
```

## Steps

### 1. Resolve the PR

- If a PR URL or number was provided as an argument, use it.
- Otherwise check the current branch: `gh pr view --json number,url,headRefName,title` — use that PR.
- If neither yields a PR, ask: "Which PR would you like to request a review for?"

### 2. Fetch PR metadata

Run:
```bash
gh pr view <number> --repo mailchimp-monolith/mailchimp \
  --json number,url,title,headRefName,additions,deletions
```

Also get the changed files:
```bash
gh pr diff <number> --repo mailchimp-monolith/mailchimp --name-only
```

### 3. Find the Slack channel

**Preferred: read the CODEOWNERS bot comment on the PR**

```bash
gh api repos/mailchimp-monolith/mailchimp/issues/<number>/comments \
  --jq '[.[] | select(.body | contains("CODEOWNER_SLACK_CHANNELS"))] | last | .body'
```

Parse the markdown table from that comment — each row maps a GitHub team to a Slack channel.

**Fallback: look up via `capabilities.json`**

If no CODEOWNERS comment exists, determine the owning team(s) from the changed files using `batch/owners show` (see `codeowners` skill), then look up the matching entry in `.github/capabilities.json` by `github_team` to get `slack_channel_for_pr_reviews`.

If multiple distinct teams/channels are found, list them and ask the user which channel(s) to notify.

### 4. Resolve the Slack channel ID

Use `slack_search_channels` with the channel name (strip the `#` prefix) to get the channel ID.

### 5. Check for an existing PR bot thread

Search the channel for an existing automated PR request thread:

```
slack_search_public_and_private(query="pull/<number>", channel=<channel_id>)
```

Also try reading recent messages in the channel with `slack_read_channel` looking for a message whose body contains the PR URL or PR number.

- If a thread is found: **reply to it** with `thread_ts` set to the parent message's `ts`, and set `reply_broadcast: true` so it also appears in the channel.
- If no thread is found: post a fresh message to the channel.

### 6. Filter owned files for the message

From the list of changed files (step 2), identify which are owned by the target team. Use the CODEOWNERS comment table or `batch/owners show` output to filter. Only list files owned by that specific team.

If there are more than 8 owned files, list the first 8 and append `• (and N more…)`.

### 7. Draft and confirm

Show the user the draft message and ask: "Send this to {#channel}?" before posting.

### 8. Post the message

Use `slack_send_message` (not draft) with the confirmed message.

Return the message link to the user.

## Edge cases

- **No CODEOWNERS comment and `batch/owners` unavailable (not in devenv):** Read `.github/CODEOWNERS` directly and match changed file paths against patterns to infer the team, then cross-reference `capabilities.json`.
- **Channel not found:** Show the raw channel name and ask the user to confirm or provide the correct channel.
- **Multiple teams on a PR:** Notify all channels, or ask the user which ones to ping.
- **Channel has no bot thread:** Always acceptable to post fresh — do not skip just because no thread was found.
