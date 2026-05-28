---
name: autodoc
description: Manage and execute tasks for autodoc.
  Generate deep documentation for undocumented or poorly-documented areas of the Mailchimp
  monolith codebase. Use this skill whenever the user asks to document code, understand legacy
  code and write it up, produce a reference doc, create a current-state analysis, or says things
  like "document this", "write docs for", "I need docs on", "explain and document", or points at
  a file/directory/system and wants it documented. Works with file paths, directory paths, or
  natural language descriptions like "the campaign sending system" or "how automations work".
  Always use this skill rather than ad-hoc documentation — it produces docs that match this
  repo's conventions and places them correctly in docs/.
---
# autodoc

Generate thorough, well-placed documentation for undocumented or legacy code in this codebase.
The goal is docs a new engineer could actually use — not a code dump, but a clear explanation
of what exists, how it works, and what to watch out for.

## What the user gives you

The user will point at something in one of these ways:

- **A path**: `app/lib/MC/Campaigns/` or `app/lib/MC/Billing/TaxCalculator.php`
- **Natural language**: "the campaign sending system", "how billing handles EU tax"
- **Both**: "document the retry logic in batch/process_automations.php"

If they're vague, ask one clarifying question before proceeding. Don't ask multiple questions at once.

---

## Step 1: Locate the code

If given a path, verify it exists and read it. If given natural language, find the relevant
files first using search and glob before reading anything deeply.

Good search strategies:
- Grep for class/function names matching the concept
- Glob directories that match the domain (e.g. `app/lib/MC/Campaign*/**/*.php`)
- Check `app/controllers/`, `app/lib/MC/`, `batch/`, `web/js/src/` depending on context
- Look at `app/lib/Autolyse/Services.php` or `app/lib/Avarice/Services.php` to find gRPC service registrations

Cast a wide net first, then narrow. A legacy system often spans multiple files and directories.

---

## Step 2: Read deeply

Don't skim. Read the actual code — the class structure, method signatures, database calls,
service dependencies, flag checks, and comments. Things to specifically look for:

**Understand the shape:**
- What does this system do at a high level?
- What are the main entry points (controller actions, gRPC RPCs, batch scripts, queue consumers)?
- What does it read from and write to (DB tables, caches, external services)?
- What other systems does it call or depend on?

**Spot the debt signals:**
- `// TODO`, `// FIXME`, `// HACK`, `// legacy`, `// deprecated` comments
- Dojo frontend code (being migrated to React)
- PHP 7.4-style code patterns in a PHP 8.3 migration context
- Duplicated logic across files (same thing done multiple ways)
- Deep inheritance chains or abstract classes (anti-pattern here)
- Named arrays passed as data (should be classes)
- Missing observability (no logging, no traces)
- Flag checks that suggest the system is mid-migration

The presence and density of debt signals determines the doc format (see Step 3).

---

## Step 3: Choose the doc format

### Use **reference/how-to** when:
- The system is reasonably stable and well-structured
- The main value is "here's how to use this / work with this"
- Examples: `docs/autolyse.md`, `docs/feature-flags.md`, `docs/automations.md`

**Structure:**
```
# [System Name]

## Overview
One paragraph explaining what this is and why it exists.

## [Core concept / main components]
What the key pieces are.

## How it works
The flow — entry points, data path, outputs.

## Common tasks
How to do the 2-3 most common things an engineer would need to do.

## Gotchas
Things that will bite you if you don't know them.

## See also
Links to related code and docs.
```

### Use **current-state analysis** when:
- There are significant debt signals or known divergence
- The system is pre-refactor or mid-migration
- The main value is "here's what we have and what's wrong with it"
- Examples: `docs/audience/current_state/*.md`

**Structure:**
```
# [System]: Current State

## Overview
What this system does today.

## Architecture
How it's structured — key files, classes, data flows.

## Problem areas
Each major issue, with evidence from the code. Be specific — file paths, line numbers, method names.

## Compliance / risk notes
If any GDPR, CAN-SPAM, or sharding concerns are visible.

## Recommended next steps
What would improve this — not a full redesign, just the highest-leverage changes.
```

### Offer an ADR as well when:
- You see evidence of a significant architectural decision that isn't documented
- Something exists in a non-obvious way and the "why" isn't clear from the code

---

## Step 4: Infer where the doc should live

Map the code's domain to the right location in `docs/`:

| Code location | Doc location |
|---|---|
| `app/lib/MC/Campaign*/` | `docs/campaigns/` |
| `app/lib/MC/AudienceManagement*/` | `docs/audience/` |
| `app/lib/MC/Billing*/` | `docs/billing/` |
| `app/lib/MC/Automations*/` | `docs/automations/` (or `docs/automations.md` if small) |
| `app/lib/MC/API30/` | `docs/api/` |
| `batch/` | `docs/batch-jobs/` |
| `web/js/src/Main/[Feature]/` | `docs/[feature]/` or flat file if small |
| Cross-cutting / platform | flat file in `docs/` |

If the target subdirectory doesn't exist, create it with a `README.md` index.

For current-state analysis, place in `docs/[domain]/current_state/[topic].md`.
For reference docs, place as `docs/[domain]/[topic].md` or a flat file if small.

---

## Step 5: Write the doc

Write the full document using this repo's conventions:

- **Tables** for mapping relationships, directory structure, or option comparisons
- **Code blocks** with language tags for all code examples — use real examples from the code you read, not invented ones
- **Headers** to divide sections (H2 for major sections, H3 for subsections)
- **Bold** for key terms on first use
- **Trailing newline** at end of file
- Cross-reference other docs in `docs/` where relevant using relative links
- For current-state docs, cite specific file paths and line numbers as evidence — this makes the doc credible and actionable
- If the system has a meaningful data flow or architecture that benefits from a diagram, note it as a PlantUML block (don't render it, just include the `.puml` source inline)

Write for a new engineer who knows PHP and React but hasn't touched this part of the codebase.
Don't write for yourself or for someone who already knows — explain the non-obvious things.

---

## Step 6: Confirm placement, then write

Before writing the file, tell the user:

> "I'll write this to `docs/[path]/[filename].md` as a [reference doc / current-state analysis]. Does that location work?"

If they say yes (or don't object), write the file. Don't commit it — leave that to the author
after they've reviewed and edited.

After writing, tell the user the file path and suggest they review it before committing.
If you produced a current-state analysis, offer to also draft an ADR if an architectural
decision was evident.

---

## Reference: doc conventions in this repo

If you're unsure about tone or structure, read an existing doc first:
- Reference/how-to example: `docs/autolyse.md`
- Domain analysis example: `docs/audience/current_state/am_sms_duplication.md`
- ADR example: `docs/audience/decisions/contact_profile_service/ADR-001-labels-separate-from-properties.md`
