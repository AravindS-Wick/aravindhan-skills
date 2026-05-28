---
name: jira-transition
description: Manage and execute tasks for jira-transition.
  Transition a Jira issue to any target status (e.g. "In Progress", "Closed", "Blocked").
  Use this skill whenever the user asks to move, transition, update the status of, or mark a
  Jira ticket as something — "move XP-1234 to In Progress", "close AORG-5678", "mark this
  ticket as blocked", "set the ticket status to done". Also invoked when finishing work-on
  or pr-create-from-commits flows where a ticket status update is the last step.
  Handles Jira's quirky workflow validators by discovering required screen fields upfront,
  assigns the ticket to the current user, and posts a comment confirming the transition.
---
# Jira Transition Skill

Transition a Jira issue to a target status reliably — including Jira projects that have
hidden required fields on transition screens (like XP's effort estimate validator).

## Steps

### 1. Resolve inputs

You need:
- **Issue key** — e.g. `XP-6930`. Extract from branch name, conversation, or ask.
- **Target status** — e.g. "In Progress", "Closed". If not specified, ask.
- **Cloud ID** — use `getAccessibleAtlassianResources` if not yet known. For this Intuit
  Jira instance the cloud ID is typically `f8519793-3215-4b8b-9f9a-3c66dd15afc5`, but
  verify with `getAccessibleAtlassianResources` if a call fails with an auth error.

### 2. Get current user's account ID

Call `atlassianUserInfo` to get the current user's `accountId`. You'll need this for
the `assignee` field and the comment author context.

### 3. Discover the transition and its required fields

Call `getTransitionsForJiraIssue` with `expand=transitions.fields`:

```
getTransitionsForJiraIssue(
  cloudId=...,
  issueIdOrKey=...,
  expand="transitions.fields"
)
```

Find the transition whose `name` matches the target status (case-insensitive, fuzzy-ok —
"in progress" matches "In Progress"). Note its `id` and inspect its `fields` map.

### 4. Build the fields payload and transition

**Only include fields that appear in the transition's `fields` map** — never send fields
speculatively. Iterate over the map and apply these defaults:

| Field type | Default value |
|---|---|
| `number` / `float` | `0` |
| `user` / `assignee` | `{"accountId": "<current user>"}` |
| `string` / `textarea` | omit (don't send empty strings) |
| `date` / `datetime` | omit |
| `array` (sprint, versions) | omit |
| `resolution` | `{"id": "10041"}` (Fixed/Finished) — for Closed/Done transitions |

Then call `transitionJiraIssue`:

```
transitionJiraIssue(
  cloudId=...,
  issueIdOrKey=...,
  transition={"id": "<id>"},
  fields={<only fields present in the transition's fields map, with defaults above>}
)
```

**If the call fails**, read the error carefully and retry once:
- `"field is required"` — add that field with its default from the table
- `"field cannot be set"` — remove that field from the payload
- Any other error — report it to the user without retrying

**Note:** Jira's API marks many required fields as `required: false` in the schema
response, but the workflow validator still enforces them at runtime. The retry-on-failure
approach handles this gracefully without needing project-specific hardcoding.

### 5. Verify success

Call `getJiraIssue` and confirm `status.name` matches the target. If it doesn't match,
report the failure with the error details rather than silently succeeding.

### 6. Post a comment

After a successful transition, post a brief comment using `addCommentToJiraIssue`:

- For "In Progress": `"Starting work on this ticket."`
- For "Closed" / "Done" / "Resolved": `"Ticket closed."`
- For "Blocked": `"Marking as blocked — see PR/conversation for context."`
- For any other status: `"Status updated to {target_status}."`

### 7. Report to the user

Show a one-line confirmation:

```
✅ XP-6930 → In Progress
```

If anything failed, show the error and suggest checking the ticket directly.

---

## Known project quirks

Some Jira projects have workflow validators that enforce fields the schema doesn't flag as
required. The fields-map-driven approach above handles most cases automatically. The
following are cases where a field is enforced but genuinely absent from the `fields` map
(so the retry loop won't catch it on its own):

| Project | Issue type | Transition | Notes |
|---|---|---|---|
| XP | Story | In Progress | `customfield_10134` (Story Points) enforced by validator but absent from fields map — pass `0` proactively |
