---
name: autolyse-list
description: Manage and execute tasks for autolyse-list.
  List all registered Autolyse (gRPC/Twirp) endpoints in the Mailchimp
  monolith in alphabetical order. Use when the engineer asks to list, find,
  browse, or discover Autolyse services, endpoints, or gRPC routes.
disable-model-invocation: true
---
# List Autolyse Endpoints

Display all registered Autolyse service endpoints from the monolith, sorted alphabetically.

## Instructions

### Step 0: Ask the engineer for scope

Before gathering data, use the **AskQuestion** tool with **both** questions in a single call to let the engineer choose scope and detail level:

```
Title: "Autolyse Endpoint List"

Question 1 (id: team_filter):
  Prompt: "Which team's Autolyse endpoints would you like to see?"
  Options:
    - all                                    → "All teams (full list)"
    - composite_app-mailchimp_app_foundations → "composite_app-mailchimp_app_foundations"
    - composite_app-transactional_email      → "composite_app-transactional_email"
    - crm-customer_lifecycle_management      → "crm-customer_lifecycle_management"
    - forms-landing-pages                    → "forms-landing-pages"
    - marketing-audience_organization        → "marketing-audience_organization"
    - marketing-brand_management             → "marketing-brand_management"
    - marketing-customer_communication       → "marketing-customer_communication"
    - marketing-email                        → "marketing-email"
    - marketing-lead_acquisition_management  → "marketing-lead_acquisition_management"
    - marketing-marketing_and_crm_analytics  → "marketing-marketing_and_crm_analytics"
    - marketing-marketing_automation         → "marketing-marketing_automation"
    - multi-channel                          → "multi-channel"
    - platform-billing_and_subscription      → "platform-billing_and_subscription"
    - platform-care_tech_sales_tech          → "platform-care_tech_sales_tech"
    - platform-experience_delivery_platform  → "platform-experience_delivery_platform"
    - platform-globalization                 → "platform-globalization"
    - platform-mailchimp_mobile              → "platform-mailchimp_mobile"
    - platform-marketing_tech                → "platform-marketing_tech"
    - platform-mc_identity                   → "platform-mc_identity"
    - platform-partnerships_and_integrations → "platform-partnerships_and_integrations"
    - security                               → "security"
    - sms-eng                                → "sms-eng"
    - no_owner                               → "Services with no CODEOWNERS entry"
  Allow multiple: false

Question 2 (id: include_descriptions):
  Prompt: "Include a description of what each endpoint does?"
  Options:
    - yes → "Yes — add a Description column"
    - no  → "No — just Service, Twirp Path, and Team"
  Allow multiple: false
```

- If a specific team is selected, only include services owned by that team. If "All teams" is selected, show everything.
- If descriptions are requested, add a **Description** column (see Step 4).

### Step 1: Extract registered services

Search `app/lib/Autolyse/Services.php` for all interface registrations. Registrations appear in two forms:

```php
// Short name (imported via `use` at top of file)
SomeServiceAutolyseInterface::class

// Fully-qualified with leading backslash (not imported)
\Mailchimp\Inbox\V1\ApiServiceAutolyseInterface::class
```

Run **two** Grep passes to capture both forms:

```
Pass 1 — short names:
  Pattern: \w+AutolyseInterface::class
  File: app/lib/Autolyse/Services.php

Pass 2 — fully-qualified names (with namespace separators):
  Pattern: \\[\w\\]+AutolyseInterface::class
  File: app/lib/Autolyse/Services.php
```

Merge the results from both passes. Deduplicate — each interface appears twice per registration (once in `registerLazyInitializer`, once in the inner `register` call). For fully-qualified names, use the last segment as the display name (e.g. `\Mailchimp\Inbox\V1\ApiServiceAutolyseInterface` → `ApiService`) but preserve the full namespace internally for path resolution.

**Important**: The file is 3900+ lines. Paginate Grep results (offset 0, 100, 200, 300) to ensure no services are missed at the end of the file.

### Step 2: Resolve Twirp paths

Each Autolyse interface maps to a Twirp HTTP path. The path follows this convention:

```
/twirp/{proto_package}.{ServiceName}/{MethodName}
```

To find the proto package and methods for each service:

1. The interface class name indicates the proto location. For example:
   - `Mailchimp\Campaign\V1\CampaignServiceAutolyseInterface` maps to `proto/mailchimp/campaign/v1/`
2. Search `app/lib-grpc/` for the interface file to find the `PATH_PREFIX` constant, which contains the full Twirp service path.

Use Grep to extract `PATH_PREFIX` values:

```
Pattern: PATH_PREFIX\s*=\s*
Path: app/lib-grpc/
```

### Step 3: Resolve CODEOWNERS teams

Each service maps to an owning team via `.github/CODEOWNERS`. The CODEOWNERS file has entries keyed on `app/lib-grpc/` paths:

```
/app/lib-grpc/Mailchimp/Campaign/ @mailchimp-monolith/multi-channel
/app/lib-grpc/Mailchimp/Billing/ @mailchimp-monolith/platform-billing_and_subscription
```

**Matching rules:**

1. For each service, derive its `app/lib-grpc/` directory path from the namespace (e.g. `Mailchimp\Campaign\V1` → `app/lib-grpc/Mailchimp/Campaign/V1/`).
2. Search CODEOWNERS for all entries whose path is a prefix of the service's directory.
3. Pick the **most specific match** (longest prefix wins). CODEOWNERS entries may or may not have trailing slashes — treat `/app/lib-grpc/Mailchimp/Sms` and `/app/lib-grpc/Mailchimp/Sms/` as equivalent.
4. If a CODEOWNERS entry lists multiple teams (e.g. `@mailchimp-monolith/team-a @mailchimp-monolith/team-b`), use the **first** team listed.
5. Strip the `@mailchimp-monolith/` prefix for readability.

**Edge cases:**
- Services outside the `Mailchimp\` namespace (e.g. `Mcpay\`, `Extensions\`, `Shopchimp\`, `RecsEngine\`) have their own top-level paths in `app/lib-grpc/`. Search CODEOWNERS for those paths too (e.g. `^/app/lib-grpc/Mcpay/`, `^/app/lib-grpc/RecsEngine/`).
- If no CODEOWNERS entry matches at any level, display `(no owner)`.
- Some entries use glob patterns (e.g. `CampaignAutomationsService*`). When a service file name matches a glob entry, prefer that over a shorter directory-level match.

Use Grep to search CODEOWNERS broadly, then filter:

```
Pattern: ^/app/lib-grpc/
File: .github/CODEOWNERS
```

### Step 4: Filter and display the results

Apply the team filter from Step 0. If a specific team was selected, only include rows where the Team column matches. If "no_owner" was selected, only include rows with no CODEOWNERS match.

**If descriptions were NOT requested**, present a three-column table:

```markdown
| Service | Twirp Path | Team |
|---------|-----------|------|
| CampaignService | /twirp/mailchimp.campaign.v1.CampaignService/ | multi-channel |
| CheckoutService | /twirp/mailchimp.billing.CheckoutService/ | platform-billing_and_subscription |
```

**If descriptions WERE requested**, add a fourth **Description** column with a brief explanation of what the service does. To determine the description:

1. Look at the RPC method names in the service's `*AutolyseInterface.php` file (public function signatures).
2. Look at the proto package path and service name for context.
3. Write a concise one-line summary (max ~10 words) describing the service's purpose.

```markdown
| Service | Twirp Path | Team | Description |
|---------|-----------|------|-------------|
| CampaignService | /twirp/mailchimp.campaign.v1.CampaignService/ | multi-channel | CRUD operations for email campaigns |
| CheckoutService | /twirp/mailchimp.billing.CheckoutService/ | platform-billing_and_subscription | Plan purchase and checkout flow |
```

- The **Team** column contains the CODEOWNERS team with the `@mailchimp-monolith/` prefix stripped.
- If no CODEOWNERS entry matches, display `(no owner)`.

After the table, display a summary count:

```
Total: {N} registered Autolyse services across {T} teams
```

If filtered to a single team, adjust the summary:

```
Showing {N} Autolyse services for team: {team_name}
```

### Step 5: Optional further filtering

If the engineer also asks for a specific domain or service name, apply that on top of the team filter. For example:
- "list autolyse endpoints for campaigns" — filter to services with "campaign" in the name or path
- "list autolyse endpoints in audience" — filter to the `audiencemanagement` domain

## Quick Reference

| What | Where |
|------|-------|
| Service registrations | `app/lib/Autolyse/Services.php` |
| Generated interfaces | `app/lib-grpc/Mailchimp/` |
| Proto definitions | `proto/mailchimp/` |
| Generated TS clients | `web/js/src/@mc/autolyse/` |
| Team ownership | `.github/CODEOWNERS` (keyed on `app/lib-grpc/` paths) |
| Avarice (async) services | `app/lib/Avarice/Services.php` |

## Notes

- Services in `Autolyse/Services.php` are UI-facing (browser-callable).
- Services in `Avarice/Services.php` are for async/service-to-service use — list those only if explicitly asked.
- Only proto services with `option (mailchimp.options.js_callable) = true` generate TypeScript clients.
