# Personal Setup Guide

## Setting Your Default Team

To avoid specifying your team every time, set a personal environment variable:

### For zsh users (most devs)
```bash
echo 'export MC_PR_MONITOR_TEAM="@mailchimp-monolith/YOUR-TEAM"' >> ~/.zshrc
source ~/.zshrc
```

### For bash users
```bash
echo 'export MC_PR_MONITOR_TEAM="@mailchimp-monolith/YOUR-TEAM"' >> ~/.bashrc
source ~/.bashrc
```

### Common team handles

Replace `YOUR-TEAM` with your team:

- `@mailchimp-monolith/platform-service_delivery`
- `@mailchimp-monolith/frontend`
- `@mailchimp-monolith/backend`
- `@mailchimp-monolith/ads-team`
- `@mailchimp-monolith/marketing-lead_acquisition_management`
- `@mailchimp-monolith/audience-management`
- `@mailchimp-monolith/campaigns`
- `@mailchimp-monolith/automations`

Not sure what your team handle is? Check `.github/CODEOWNERS` or ask your team lead.

## Verification

Check if it's set correctly:
```bash
echo $MC_PR_MONITOR_TEAM
```

Should output your team handle like: `@mailchimp-monolith/platform-service_delivery`

## Using the skill

Once configured, just ask naturally:
```
"Monitor this PR and add my team as reviewers when CI passes"
"Watch PR #12345 for CI completion and request reviews"
```

Cursor will automatically use your configured team!

## Overriding per request

You can always override by mentioning a different team:
```
"Monitor this PR and add @mailchimp-monolith/frontend as reviewers when done"
```
