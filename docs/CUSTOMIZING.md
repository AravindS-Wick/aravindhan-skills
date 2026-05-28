# Customizing skills imported from work

Skills built for a specific org often hardcode things that don't make sense elsewhere — internal URLs, company-specific tool names, hardcoded user paths. Before installing a work skill on your personal machine (or sharing it), genericize it.

`./scripts/import_from_dir.sh` already flags the obvious patterns and writes a `CUSTOMIZE.md` inside each skill that needs review. This document is the *how* — what to do when you see a flag.

## The checklist

For every imported skill, walk through:

### 1. Internal URLs and hostnames
**Smell:** `https://jira.acmecorp.internal`, `https://artifactory.corp/...`, `confluence.acme.lan`

**Fix:** Replace with an env var referenced in the SKILL.md:
```markdown
The skill expects `$JIRA_URL` to be set in the environment.
```
For URLs that are part of a script, read from env at runtime:
```bash
JIRA_URL="${JIRA_URL:?set JIRA_URL before using this skill}"
```

### 2. Hardcoded user paths
**Smell:** `/Users/firstname.lastname/...`, `/home/specific-user/...`

**Fix:** Use `$HOME` or relative paths. If a skill genuinely needs a specific path, document it as a required setup step in the SKILL.md.

### 3. Company / project names baked into prose
**Smell:** "When deploying to AcmeCorp's staging cluster..." or "Run the FooProject migration script..."

**Fix:** Generalize the prose. The skill should describe a *kind* of task, not a specific instance. If a project-specific step is unavoidable, factor it into a reference file and note that it should be edited per project.

### 4. Hardcoded credentials, tokens, or API keys
**Smell:** Anything that looks like `api_key = "sk_live_..."`, `password = "..."`, `token = "abc123"`

**Fix:** **Remove immediately.** Replace with env var references. If the skill needs credentials to function, document the required env vars in SKILL.md. Never commit a secret, even an expired one.

### 5. AWS account IDs, internal resource ARNs
**Smell:** `arn:aws:s3:::123456789012:...`, account IDs in CloudFormation or Terraform

**Fix:** Parameterize. Skills should describe the operation, not the account.

### 6. Tool-specific assumptions
**Smell:** Skill assumes a specific CI system (Jenkins on a specific server), a specific issue tracker, a specific chat tool with a specific URL

**Fix:** Either parameterize, or split the skill into a generic version and an org-specific overlay (rare; usually parameterizing is enough).

## What to do once a skill is generic

1. Delete the `CUSTOMIZE.md` inside the skill folder
2. Update `.skill-manifest.json` to mark `customized: true` with a note
3. Run `./scripts/validate_all.sh <skill-name>`
4. Run `./install.sh`

## What if I want to KEEP the work-specific version?

That's fine — don't put it in this repo. Keep it in your `/Users/aravindhan/personal/sk` work folder, and use that as a separate sources directory for that machine only.

Alternatively, tag work-specific skills with a prefix:
```
skills/
├── work-deploy-acmecorp/    ← stays specific
└── deploy-service/          ← generalized version of the same idea
```

The prefix makes it explicit that this version isn't portable.

## Quick checklist (printable)

- [ ] No internal hostnames / URLs
- [ ] No `/Users/<name>` or `/home/<name>` paths
- [ ] No company names in prose
- [ ] No credentials, tokens, or API keys
- [ ] No hardcoded AWS account IDs / ARNs
- [ ] No assumptions about specific internal tooling
- [ ] CUSTOMIZE.md deleted
- [ ] Manifest updated
- [ ] Validates cleanly
- [ ] Installs cleanly
