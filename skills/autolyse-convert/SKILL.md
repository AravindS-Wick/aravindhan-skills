---
name: autolyse-convert
description: Convert a Controller action to an Autolyse gRPC service. Use when the user asks to convert a controller to Autolyse, create a gRPC service, or migrate an action to Autolyse.
---
# Autolyse convert to service

## Overview
Convert a Controller action to an Autolyse gRPC service. See `.agent/rules/autolyse-migration.mdc` for complete patterns and `.agent/rules/autolyse-quickref.mdc` for quick reference.

## Steps

1. **Gather & validate inputs**
   - Service name (e.g., "MyFeature", "CampaignData")
   - Domain/package (e.g., "campaign", "audience", "reporting")
   - Version (default: "v1")
   - Jira ticket (ABC-1234 or full URL)
   - **Check working tree:** Verify clean state with no uncommitted changes
   - **If uncommitted changes exist:** STOP and ask user to commit/stash them first
   - **Validate:** Service doesn't already exist

2. **Create proto file**
   - Path: `proto/mailchimp/[domain]/[version]/[service].proto`
   - Must include:
     - `syntax = "proto3";`
     - `package mailchimp.[domain].[version];`
     - `import "mailchimp/options.proto";`
     - Service with `option (mailchimp.options.js_callable) = true;`
   - Define request/response messages
   - Define service RPCs
   - See `.agent/rules/autolyse-migration.mdc` for proto templates

3. **Generate code**
   - Run: `script/generate-twirp proto/mailchimp/[domain]/[version]/[service].proto`
   - This creates:
     - PHP: `app/lib-grpc/Mailchimp/[Domain]/[Version]/[Service]*.php`
     - TypeScript: `web/js/src/@mc/autolyse/[Domain]/[Version]/[Service].ts`
   - Verify generated files exist

4. **Create service implementation**
   - Path: `app/lib/MC/[Domain]/[Service]DataProvider.php`
   - Must implement: `[Service]AutolyseInterface`
   - Implement all RPC methods from proto
   - Add error handling with `TwirpError::newError()`
   - Add logging with `Avesta_Log_Logger::get()`
   - See `.agent/rules/autolyse-quickref.mdc` for implementation template

5. **Register service in Services.php**
   - File: `app/lib/Autolyse/Services.php`
   - Add registration method: `private static function register[ServiceName]Service(Server $server): void`
   - Include required middleware:
     - `Convert503` (REQUIRED)
     - `SanitizeErrors(\MC::config()->debug)` (REQUIRED)
     - `ReportErrors` (recommended)
     - `RequireUser` (if authentication needed)
     - `ValidateCSRF` (if state-changing operations)
   - Call registration in `build()` method
   - See `.agent/rules/autolyse-quickref.mdc` for registration templates

6. **Create PHPUnit tests**
   - Path: `tests_phpunit/unit/MC/[Domain]/[Service]DataProviderTest.php`
   - Test each RPC method
   - Test error cases
   - Test validation logic

7. **Check and update Jira ticket status**
   - Apply Jira status management (see `.agent/rules/jira-status-management.mdc`)
   - Automatically move ticket to "In Progress" if not already there
   - Gracefully handle MCP unavailability (don't block service creation)
   - Show ticket status and any transitions performed

8. **Git operations (batched)** - Request `["git_write"]` permissions upfront
   - Create branch: `{ticket-prefix}-{ticket-num}-autolyse-{service-name}`
     - Example: `XP-1234-autolyse-campaign-service`
   - Stage ALL new files: `git add -A`
     - Proto file
     - Generated PHP/TypeScript files
     - Implementation class
     - Tests
     - Services.php changes
   - Verify ONLY new service files are staged (no unrelated changes)
   - Commit: `"[{TICKET}] Add {ServiceName} Autolyse service"`
   - Push to origin

9. **Create example TypeScript usage**
   - Show how to import and use the client
   - Include error handling
   - Add to PR description

10. **Create PR**
   - Read `.github/pull_request_template.md` for template structure
   - Create PR: `gh pr create --title "[{TICKET}] Add {ServiceName} Autolyse service" --body "{populated_template}"`
   - Populate ALL template sections:
     - **Background context:** Why this service is needed, what problem it solves
     - **Change summary:** Proto definition, implementation details, new RPCs
     - **Steps to test:** How to test each RPC method, expected responses
     - **Risk mitigation table:**
       - 🚩 Flag/Experiment name: Feature flag if gated (or "N/A - no flag")
       - 🌊 Splatter zone: Areas affected by new service
       - 👀 Monitoring: Service logs, error tracking
       - 💬 Slack Channel: {team_channel}
       - 🎟️ Jira ticket: https://jira.your-company.com/browse/{TICKET}
   - Include TypeScript usage example in description
   - Apply label: `skill-used`
   - Submit as draft PR initially

## Validation Rules

- ✅ Proto must have `option (mailchimp.options.js_callable) = true;`
- ✅ All RPC methods must have corresponding implementation
- ✅ Must include `Convert503` and `SanitizeErrors` middleware
- ✅ Service must be registered in `Services.php` and called in `build()`
- ✅ Tests must cover all RPC methods
- ❌ **NEVER** edit generated files in `app/lib-grpc/`
- ❌ **NEVER** reuse proto field numbers

## Proto Template

```protobuf
syntax = "proto3";

package mailchimp.[domain].[version];

import "mailchimp/options.proto";

message GetDataRequest {
    string id = 1;
}

message GetDataResponse {
    repeated Item items = 1;
    int32 total_count = 2;
}

message Item {
    string id = 1;
    string name = 2;
}

service [ServiceName]Service {
    option (mailchimp.options.js_callable) = true;
    
    rpc GetData(GetDataRequest) returns (GetDataResponse);
}
```

## Implementation Template

```php
<?php

namespace MC\[Domain];

use Mailchimp\[Domain]\[Version]\[Service]AutolyseInterface;
use Mailchimp\[Domain]\[Version]\GetDataRequest;
use Mailchimp\[Domain]\[Version]\GetDataResponse;
use Mailchimp\[Domain]\[Version]\TwirpError;
use Twirp\ErrorCode;

class [Service]DataProvider implements [Service]AutolyseInterface
{
    public function GetData(array $ctx, GetDataRequest $req): GetDataResponse
    {
        if (empty($req->getId())) {
            throw TwirpError::newError(ErrorCode::InvalidArgument, 'id is required');
        }
        
        $user = \MC::user();
        
        // Business logic...
        
        $response = new GetDataResponse();
        $response->setTotalCount(0);
        return $response;
    }
}
```

## TypeScript Usage Example

```typescript
import { [ServiceName]ServiceClient } from '@mc/autolyse/[Domain]/[Version]/[ServiceName]Service';

const client = new [ServiceName]ServiceClient();

try {
    const response = await client.GetData({ id: '123' });
    console.log(response.items);
} catch (error) {
    console.error(error.code, error.msg);
}
```

## Checklist

Before submitting PR, verify:
- [ ] Proto file created with `js_callable` option
- [ ] Code generated with `script/generate-twirp`
- [ ] Service implementation class created
- [ ] All RPC methods implemented
- [ ] Error handling added
- [ ] Service registered in `Services.php`
- [ ] Registration called in `build()` method
- [ ] PHPUnit tests created
- [ ] All tests pass: `devenv test tests_phpunit/unit/MC/[Domain]/`
- [ ] TypeScript client imports successfully
- [ ] Branch created and pushed
- [ ] PR created with complete description

## See Also
- `.agent/rules/autolyse-migration.mdc` - Complete migration guide
- `.agent/rules/autolyse-quickref.mdc` - Quick reference card
- `proto/mailchimp/autolyse/example.proto` - Example proto file
- `app/lib/MC/Campaign/CampaignDataProvider.php` - Example implementation

