---
name: optimizely-create
description: Create new Mailchimp A/B experiment (Optimizely) with class and registration. Use when the user asks to create an Optimizely experiment, A/B test, or experiment class.
disable-model-invocation: true
---
# Create Optimizely Experiment

Create new Mailchimp A/B experiment with proper class structure and registration. See `.agent/rules/optimizely.mdc` for complete experiment documentation.

## Steps

1. **Gather & validate inputs**
   - Experiment name (e.g., "my-team-1234-my-feature-experiment")
   - Team/namespace (e.g., "MC\\User\\Experiments", "MC\\Campaigns\\Experiments")
   - Jira ticket (ABC-1234 or full URL)
   - Variant names (defaults: "control", "variant") - can specify additional variants
   - Holdout name (defaults: "FY26H1") - current fiscal holdout period
   - **REQUIRED:** Feature flag to gate eligibility - verify it exists in `config/flags.ini` or prompt to create it
   - Validate: namespace directory exists, experiment name follows convention (kebab-case)
   - **Check working tree:** Verify clean state with no uncommitted changes
   - **If uncommitted changes exist:** STOP and ask user to commit/stash them first

2. **Generate experiment class**
   - Location: `app/lib/{Namespace}/{ClassName}.php`
     - Example: `app/lib/MC/User/Experiments/MyFeatureExperiment.php`
   - Extend `\MC\GlobalHoldout\GlobalHoldoutBaseExperiment`
   - Define constants: `EXPERIMENT_NAME`, `EXPERIMENT_KEY`, `EXPERIMENT_FLAG`, `CONTROL`, `VARIANT` (and additional variants)
   - Implement required methods:
     - `getHoldoutName()` - Return holdout period (REQUIRED override)
     - `getExperimentName()` - Return experiment name
     - `getExperimentKey()` - Return Optimizely ruleset key (same as name)
     - `getControlVariation()` - Return control constant
     - `checkExperimentEligibility()` - Eligibility logic (MUST include flag gate as first check)
   - Add optional helper: `show()` method for variant check
   - Include docblock with purpose, Jira ticket, and usage example

3. **Register in ExperimentKey**
   - File: `app/lib/MC/Experiments/ExperimentKey.php`
   - Add `use` statement for new experiment class
   - Append to `$experiment_classes` array
   - Maintain alphabetical order within namespace groups

4. **Check and update Jira ticket status**
   - Apply Jira status management (see `.agent/rules/jira-status-management.mdc`)
   - Automatically move ticket to "In Progress" if not already there
   - Gracefully handle MCP unavailability (don't block experiment creation)
   - Show ticket status and any transitions performed

5. **Git operations (batched)** - Request `["git_write", "network"]` permissions upfront
   - Create branch from latest main: `{ticket-prefix}-{ticket-num}-create-experiment-{experiment-name}`
     - Example: `XP-1234-create-experiment-new-feature`
   - Stage ONLY new/modified files: 
     - `git add app/lib/{Namespace}/{ClassName}.php`
     - `git add app/lib/MC/Experiments/ExperimentKey.php`
   - Commit: `"[{TICKET}] create experiment: {experiment_name}"`
   - Push to origin

6. **Create PR**
   - Read `.github/pull_request_template.md` for template structure
   - Create PR: `gh pr create --title "[{TICKET}] Create experiment: {experiment_name}" --body "{populated_template}"`
   - Populate ALL template sections:
     - **Background context:** Feature purpose, what's being tested, hypothesis, related work
     - **Change summary:** 
       - New experiment class with namespace and location
       - Registered in ExperimentKey
       - Eligibility criteria (with mandatory flag gate)
       - Variations defined (control, variant, etc.)
     - **Steps to test:** 
       - "Experiment class created but not yet configured in Optimizely - no user impact"
       - "Next steps: Configure in Optimizely UI, then start experiment"
       - "Feature flag `{flag_name}` will control experiment activation"
     - **Risk mitigation table:**
       - 🚩 Flag/Experiment name: {experiment_name} (not yet active)
       - 🌊 Splatter zone: "No impact - experiment not started in Optimizely"
       - 👀 Monitoring: "Will monitor after Optimizely configuration and launch"
       - 💬 Slack Channel: {team_channel}
       - 🎟️ Jira ticket: https://jira.your-company.com/browse/{TICKET}
   - Apply label: `skill-used`
   - Submit as regular PR (not draft)

7. **Output next steps**
   - Inform user of follow-up actions:
     - Configure experiment in Optimizely UI (create experiment, define variations, set metrics)
     - Test locally with URL override: `?experiments={experiment-name}:variant`
     - Start experiment in Optimizely after deployment

## Validation Rules

- ✅ Experiment name follows convention: `{team}-{ticket-num}-{feature-name}` (kebab-case)
- ✅ Class extends `GlobalHoldoutBaseExperiment` (not `BaseExperiment`)
- ✅ All required methods implemented
- ✅ `getHoldoutName()` is explicitly overridden with current Holdout Name (REQUIRED)
- ✅ Feature flag gate is FIRST check in `checkExperimentEligibility()` (REQUIRED)
- ✅ Registered in `ExperimentKey` with proper `use` statement
- ✅ Constants use SCREAMING_SNAKE_CASE
- ✅ Namespace matches directory structure

## Template Structure

**Generated PHP class should include:**
```php
<?php

namespace {Namespace};

/**
 * {ExperimentName} - {Brief description}
 * 
 * @see https://jira.your-company.com/browse/{TICKET}
 */
class {ClassName} extends \MC\GlobalHoldout\GlobalHoldoutBaseExperiment
{
    const EXPERIMENT_NAME = "{experiment-name}";
    const EXPERIMENT_KEY = "{experiment-name}";
    const EXPERIMENT_FLAG = "{flag_name}";
    const CONTROL = "control";
    const VARIANT = "variant";

    /**
     * {@inheritDoc}
     * REQUIRED: Must explicitly override to set holdout period
     */
    public function getHoldoutName(): string
    {
        return '{holdout_name}';  // Current fiscal holdout period (SEE Inherited Docstring)
    }
    
    public function getExperimentName()
    {
        return self::EXPERIMENT_NAME;
    }
    
    public function getExperimentKey(): string
    {
        return self::EXPERIMENT_KEY;
    }
    
    public function getControlVariation()
    {
        return self::CONTROL;
    }
    
    public function checkExperimentEligibility(): bool
    {
        // REQUIRED: Feature flag gate must be first check
        if (\MC_Flag::isOff(self::EXPERIMENT_FLAG)) {
            return false;
        }
        
        $user = $this->getUser();
        if (is_null($user)) {
            return false;
        }
        
        // Add specific eligibility criteria here:
        // - User role check
        // - Plan type requirement
        // - Account age
        // - Feature access level
        
        return true;
    }
    
    /**
     * Helper method to check if user is in variant
     */
    public function show(): bool
    {
        return $this->getExperimentalValues()["variant"] === self::VARIANT;
    }
}
```

## Common Patterns

**Multiple variants (A/B/C):**
```php
const CONTROL = "control";
const VARIANT_A = "variant_a";
const VARIANT_B = "variant_b";
```

**Additional data per variant:**
```php
protected function getAdditionalValuesForVariant($variant)
{
    return [
        'show_new_ui' => ($variant === self::VARIANT),
        'button_text' => ($variant === self::VARIANT) ? 'Try Now' : 'Learn More',
    ];
}
```

**Complex eligibility:**
```php
public function checkExperimentEligibility(): bool
{
    if (\MC_Flag::isOff('my_team.my_experiment')) {
        return false;
    }
    
    $user = $this->getUser();
    if (is_null($user) || $user->isInternal()) {
        return false;
    }
    
    // Account age check
    $active_date = $user->getData()['active'];
    if (strtotime($active_date) < strtotime('2024-01-01')) {
        return false;
    }
    
    return true;
}
```

## See Also
- `.agent/rules/optimizely.mdc` - Complete Optimizely experiment documentation
- `.agent/skills/flag-create/SKILL.md` - Create feature flag to gate experiment
- `app/lib/MC/GlobalHoldout/ExampleHoldoutExperiment.php` - Reference example
- `app/lib/MC/Experiments/ExperimentKey.php` - Registration location

