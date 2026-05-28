---
name: dev-account-create
description: Create a new internal, experimental dev user account in the local Mailchimp dev environment. Automatically marks the account as internal and experimental (Optimizely). Asks for marketing plan, manual activation, feature flags, and account link interactively one at a time. Use when the user says "create a dev account", "create a test user", "spin up a dev user", or runs /dev-account-create.
---
# Dev Account Creator (`dev-account-create`)

Creates a new Mailchimp dev account that is pre-configured as internal and experimental, with optional feature flags and billing plan.

## Prerequisites

- Dev containers running (`up` or `up --fe`)
- Access to `docker exec` into `mc-dev-app`

## Step 1 — Gather Inputs (interactive, sequential)

Ask each question **one at a time** in the order below. Wait for the answer before asking the next. Do not run any commands until all four inputs are collected.

Use the `AskQuestion` tool for questions with fixed options (1a and 1b). Ask 1c and 1d as plain-text messages.

### 1a. Marketing plan

Use `AskQuestion` (single-select) with **all five** options below — do not omit any row:

| # | Label for AskQuestion | `package_id` | `audience_size` |
|---|----------------------|-------------|----------------|
| 1 | Free — 250 contacts *(default)* | `free_monthly_plan_v0` | — (skip `applyPlan`) |
| 2 | Essentials — 1,500 contacts | `essential_monthly_plan_v0` | `1500` |
| 3 | Standard — 5,000 contacts | `standard_monthly_plan_v0` | `5000` |
| 4 | Premium — 15,000 contacts | `premium_monthly_plan_v0` | `15000` |
| 5 | PayGo — pay per send | `paygo_plan` | — (no audience size needed) |

### 1b. Manual activation

Use `AskQuestion` (single-select):

- No — skip setup flow, auto-activate *(default)*
- Yes — send confirmation email, manual activation required

| Selection | Behavior |
|-----------|----------|
| **No** (default) | `email_confirmation = false` — domain auto-verified, setup flow skipped, onboarding disabled |
| Yes | `email_confirmation = true` — confirmation email sent, manual activation required |

### 1c. Feature flags

Ask as plain text:

> "Any feature flags to enable on this account? Enter a comma-separated list, or leave blank for none."

Accept a comma-separated list of flag names (e.g. `team.my_flag, other.flag`). Strip whitespace around each name. If blank, skip.

### 1d. Link to main account

Ask as plain text:

> "Link this new account to your main dev account so it appears in the Switch Account menu? Enter your main account's `user_id`, or leave blank to skip."

Store the answer as `$main_uid` (integer). If blank, set to `0` and skip the linking step. See Notes for how to find your `user_id`.

---

## Step 2 — Confirm Before Running

Present a summary and wait for the user to confirm:

```
I'll create a dev account with:
  • Shard: dev
  • Type: internal + experimental (Optimizely)
  • Setup flow: skipped (auto-activated)      ← or: manual activation (confirmation email sent)
  • Plan: Free (250 contacts)
  • Feature flags: team.my_flag, other.flag   ← or: none
  • Link to main account: user_id 21          ← or: not linked

Shall I proceed?
```

Do not run any commands until the user confirms.

---

## Step 3 — Execute

Run PHP in the dev app container:

```bash
docker exec -i mc-dev-app bash -c 'cd /opt/mailchimp/current && php batch/shell.php --env=dev' <<'EOF'
// generated PHP here
EOF
```

### PHP template

Generate the PHP below, substituting the values from Step 1:

```php
$suffix   = substr(md5(uniqid(rand(), true)), 0, 8);
$username = 'dev_user_' . $suffix;
$email    = 'dev_' . $suffix . '@mailchimp-dev.com';
$password = 'DevPass1!' . strtoupper($suffix);

// true = send confirmation email (manual activation); false = auto-verify & skip setup flow
$manual_activation = false; // set to true if user chose Yes in 1a

$uid = null;
try {
    $manager = \MC\AutomatedTestingAPI\ServiceObjects\InternalAccountManager::withNewAccount(
        $email,
        $username,
        $password,
        'dev',               // shard
        $manual_activation,  // email_confirmation
        false                // send_welcome_email
    );
    $uid = $manager->getAccount()->uid;
} catch (Exception $e) {
    // withNewAccount() can throw MC_API30_Exception_BadRequest when the parsimony
    // cache service is unreachable (common in stripped-down dev environments).
    // The user record is already committed at this point — recover via username lookup.
    echo "Note: withNewAccount threw (" . get_class($e) . ") — recovering via username lookup\n";
    // querySqlOne returns a scalar directly when a single column is selected.
    $uid = (int) MC::loginDB()->querySqlOne(
        "SELECT la.user_id FROM login_users lu JOIN login_accounts la ON lu.login_id = la.login_id WHERE lu.username = ?",
        [$username]
    );
    if (!$uid) {
        echo "ERROR: Could not find user '$username' after exception\n";
        return;
    }
    echo "Recovered uid: $uid\n";
    $manager = \MC\AutomatedTestingAPI\ServiceObjects\InternalAccountManager::withExistingAccount($uid);
}

// Account is already marked internal by withNewAccount().
// Mark as experimental to allow Optimizely bucketing.
$manager->setUserExperimental();

// Set theme to Light (data-colorscheme = 'light').
// Valid values: 'light', 'dark'. Default is 'light'.
$manager->setUserSettings(['data-colorscheme' => 'light']);

// Skip onboarding dialogues/checklist unless the user wants to activate manually.
if (!$manual_activation) {
    $manager->onboardUser();
}

// If withNewAccount() threw, the default audience list was never created. Try now;
// skip gracefully if parsimony is still unavailable.
try {
    User::initialize($uid);
    $existing_list = MC::userDB()->queryOne('From MemberList WHERE is_deleted = "N"');
    if (!$existing_list) {
        $manager->createDefaultList();
    }
} catch (Exception $e) {
    echo "Note: default list creation skipped (" . get_class($e) . ") — create an audience manually from the UI\n";
}

// Apply plan — omit entirely for Free (default).
// $manager->applyPlan('standard_monthly_plan_v0', 5000);

$account = $manager->getAccount();
$uid     = $account->uid;

// Enable feature flags — repeat for each flag name provided in 1b.
// $user = User::initialize($uid);
// User_Feature::addOrUpdateFeature($user, 'team.my_flag');

// Link new account to the user's main dev account (if provided in 1d).
// addLoginUser() creates a login_accounts row so the new account appears
// in the Switch Account menu of the main account's login session.
// The contact company field must be set first — addLoginUser uses it as accountname.
$main_uid = 0; // replace with integer from 1d; set to 0 to skip
if ($main_uid > 0) {
    $link_user = User::initialize($uid);
    $link_user->contact->company = $username;
    $link_user->contact->save();
    $manager->addLoginUser($main_uid, 'admin');

    // The experimental flag is stored per login_id. setUserExperimental() stores it
    // under the new account's own login_id (owner context). When the main account
    // switches to this account, their login_id is different — so the badge wouldn't
    // show. Fix: also store it under the main account's login_id.
    $main_user_temp = User::initialize($main_uid);
    $link_user->setSettingForLoginUser($main_user_temp->login_id, 'is_experimental_user', 'on');
}

echo "uid: $uid\n";
echo "username: $username\n";
echo "email: $email\n";
echo "password: $password\n";
echo "apikey: " . $account->apikey . "\n";
echo "linked_to: " . ($main_uid > 0 ? $main_uid : 'none') . "\n";

// If manual_activation is true, print the activation link.
// $link = $manager->getActivationLink();
// if ($link) { echo "activation_link: $link\n"; }
```

**Generation rules:**
- Always generate a random `$suffix`, `$username`, `$email`, and `$password` — do not hardcode.
- For Free plan: omit the `applyPlan` call entirely.
- For non-Free, non-PayGo plans: uncomment and fill `applyPlan` with the correct `package_id` and `audience_size` from the table in Step 1c.
- For PayGo: call `$manager->applyPlan('paygo_plan', 0)` (audience size is ignored). Then immediately follow with `$manager->setEmailsLeft(5000)` to seed a default send credit balance — without this the account cannot send anything.
- For each feature flag: uncomment and duplicate the `User::initialize` + `User_Feature::addOrUpdateFeature` block once per flag. `User::initialize` only needs to be called once; reuse `$user` for subsequent flags.
- For manual activation: set `$manual_activation = true` and uncomment the `getActivationLink` block.
- For account linking: set `$main_uid` to the integer from Step 1d. If the user left it blank, keep `$main_uid = 0` so the `if` block is skipped. The `$main_uid` account must be an `internal` account — dev accounts always are. The contact `company` field must be populated before calling `addLoginUser` because the method uses it as the `accountname` in `login_accounts`; the script sets it to `$username`. Valid roles are `viewer`, `author`, `manager`, `admin` — `admin` is used by default.
- The `withNewAccount()` call is always wrapped in a try-catch. In stripped-down dev environments, the `parsimony` cache service (`dev.parsimony.mailchimp.com`) is often not running, which causes `withNewAccount()` to throw `MC_API30_Exception_BadRequest` after the user record has already been committed. The recovery block looks up the created user by `$username` via `MC::loginDB()->querySqlOne()` — note that `querySqlOne` returns a **scalar** value (not a stdClass) when a single column is selected, so the result is cast directly with `(int)`. After recovery, `withExistingAccount($uid)` is used to rebuild the manager and continue setup. The same parsimony issue can cause `createDefaultList()` to fail, so that call is also wrapped in its own try-catch.

---

## Step 4 — Report Results

Parse output and display clearly:

```
Done! Dev account created:

  UID:        12345
  Username:   dev_user_abc12345
  Email:      dev_abc12345@mailchimp-dev.com
  Password:   DevPass1!ABC12345
  API Key:    abc123...
  Plan:       Free (250 contacts)
  Activation: Auto-activated (setup flow skipped)
  Theme:      Light
  Flags:      team.my_flag ✓, other.flag ✓
  Linked to:  user_id 21 (appears in Switch Account immediately)
```

If linking was skipped (`$main_uid = 0`), show instead:
```
  Linked to:  (not linked)
```

If `manual_activation = true`, include the activation link:
```
  Activation: Confirmation email sent — manual activation required
  Link:       https://localhost/activate?code=...
```

If any error occurs (exception, "Call to undefined", etc.), show the raw output and suggest checking that containers are running.

---

## Step 5 — Follow-up: Seed Contacts (optional)

After displaying the Step 4 report, ask:

> "Would you like to add contacts to the 'Test Audience'? Choose an option:
>   1. Generate N fake contacts (note: ~500 is a practical limit — larger counts will be slow)
>   2. Upload a CSV file (provide the local path to the file)
>   3. Skip"

- **Skip / blank**: done, no further action.
- **Option 1 (generate)**: ask for N, confirm, then run the fake-contact script below.
- **Option 2 (CSV)**: ask for the local CSV path, confirm, then run the CSV import flow below.

### Option 1 — Fake contact generation

Run as a separate `docker exec` call, substituting the UID and suffix printed in Step 4:

```bash
docker exec -i mc-dev-app bash -c 'cd /opt/mailchimp/current && php batch/shell.php --env=dev' <<'EOF'
User::initialize(UID);

$suffix        = 'SUFFIX'; // reuse suffix from account creation for email uniqueness
$contact_count = N;

$list = MC::userDB()->queryOne('From MemberList WHERE is_deleted = "N" and is_disabled = "N"');
if ($list) {
    for ($i = 1; $i <= $contact_count; $i++) {
        $fake_email = "contact_{$i}_{$suffix}@mailchimp-dev.com";
        $list->subscribeEmail(
            $fake_email,
            null,   // merge data
            'html', // email_type
            false,  // double_optin
            true,   // override
            false,  // update
            true,   // from_import (suppresses welcome email)
            false,  // from_subscriber
            true    // bypass_throttling
        );
    }
    echo "contacts_seeded: $contact_count\n";
    echo "list_id: " . $list->getID() . "\n";
} else {
    echo "contacts_seeded: 0 (no list found)\n";
}
EOF
```

### Option 2 — CSV import

**Expected CSV format** — first row is a header; `email` is required; `first_name` and `last_name` are optional:

```
email,first_name,last_name
alice@example.com,Alice,Smith
bob@example.com,Bob,Jones
```

**Step A** — copy the file into the container:

```bash
docker cp /local/path/to/contacts.csv mc-dev-app:/tmp/mc_contacts.csv
```

**Step B** — run the import PHP:

```bash
docker exec -i mc-dev-app bash -c 'cd /opt/mailchimp/current && php batch/shell.php --env=dev' <<'EOF'
User::initialize(UID);

$list  = MC::userDB()->queryOne('From MemberList WHERE is_deleted = "N" and is_disabled = "N"');
$count = 0;

if ($list && ($fh = fopen('/tmp/mc_contacts.csv', 'r')) !== false) {
    $headers       = array_map('strtolower', fgetcsv($fh));
    $email_idx     = array_search('email', $headers);
    $firstname_idx = array_search('first_name', $headers);
    $lastname_idx  = array_search('last_name', $headers);

    while (($row = fgetcsv($fh)) !== false) {
        $email = trim($row[$email_idx] ?? '');
        if (!$email) { continue; }

        $merge = [];
        if ($firstname_idx !== false && isset($row[$firstname_idx])) {
            $merge[1] = $row[$firstname_idx]; // FNAME merge field index
        }
        if ($lastname_idx !== false && isset($row[$lastname_idx])) {
            $merge[2] = $row[$lastname_idx];  // LNAME merge field index
        }

        $list->subscribeEmail(
            $email,
            $merge ?: null,
            'html',
            false, true, false, true, false, true
        );
        $count++;
    }
    fclose($fh);
    echo "contacts_imported: $count\n";
    echo "list_id: " . $list->getID() . "\n";
} else {
    echo "contacts_imported: 0 (list or file not found)\n";
}
EOF
```

**Step C** — clean up the temp file:

```bash
docker exec mc-dev-app rm /tmp/mc_contacts.csv
```

### Step 5 result report

After seeding (either method), display:

```
Done! Contacts added:

  List:     Test Audience (list_id: 3)
  Contacts: 100 added (fake generated)   ← or: "imported from contacts.csv"
```

---

## Notes

- `withNewAccount()` always marks the account as `internal` — no extra step needed.
- **Parsimony resilience**: The `parsimony` cache service (`dev.parsimony.mailchimp.com`) is often absent in stripped-down dev environments. `withNewAccount()` and `createDefaultList()` both attempt to connect to it and will throw if it's unreachable. The PHP template wraps both in try-catch blocks: `withNewAccount()` is recovered via username lookup + `withExistingAccount()`; `createDefaultList()` is skipped with a console note instructing the user to create an audience from the UI. The account is otherwise fully functional.
- **`querySqlOne` scalar return**: When `MC::loginDB()->querySqlOne()` selects a single column, it returns that column's value directly as a scalar — not a stdClass object. Cast it with `(int)` or `(string)` as appropriate rather than accessing it as `->property`.
- `setUserExperimental()` sets `User::USER_EXPERIMENTAL = 'on'` via user settings — requires the account to be internal first (already guaranteed).
- Theme is set via `setUserSettings(['data-colorscheme' => 'light'])`. Valid values are `'light'` and `'dark'`. The setting is stored under the key `data-colorscheme` (see `UserDataAttributeGetter::colorScheme()`). Light is always applied — it is not user-configurable in this skill.
- Feature flags must have a `user` scheme to be applied per-user. If a flag name is rejected, it either doesn't exist or lacks a user scheme.
- The generated `$username` and `$email` are unique per run due to the random suffix — safe to run multiple times.
- **PayGo** uses `AccountConverter::convertToPaygo()` under the hood — no audience size is required. A default send credit of 5,000 emails is applied via `setEmailsLeft()` so the account can send immediately. Adjust as needed for specific test scenarios.
- **Contact seeding** is a post-creation follow-up and does not affect account creation.
- **Fake generation**: emails follow `contact_{i}_{suffix}@mailchimp-dev.com` (using `@example.com` will be rejected by the email validator). Contacts are added one-by-one via `MemberList::subscribeEmail()` with `bypass_throttling = true`. Keep counts under ~500 to avoid slow runtimes in a dev shell.
- **CSV import**: the file is copied into the container via `docker cp`, parsed with `fgetcsv()`, then cleaned up. Required column: `email`. Optional columns: `first_name`, `last_name`. Rows with a blank email are skipped.
- **Finding your `user_id`**: your main account's `user_id` appears in many Mailchimp admin URLs (e.g. `/account/profile` shows it in the page or network requests). Alternatively, run the following in the dev shell and look for your username: `docker exec -i mc-dev-app bash -c 'cd /opt/mailchimp/current && php batch/shell.php --env=dev' <<'EOF'` then `$row = MC::globalDB()->queryOne('SELECT id, username FROM users WHERE username = "your_username"'); echo $row->id . "\n";` `EOF`. The `user_id` is an integer (e.g. `21`).
- **Experimental flag and linked accounts**: `isExperimental()` / `setUserExperimental()` store the `is_experimental_user` setting scoped to the current `login_id`, not globally. When a new account is accessed via Switch Account from the main account, the session carries the main account's `login_id` — so the flag stored under the new account's owner `login_id` isn't found and the "Experimental" badge doesn't appear. The skill fixes this by calling `setSettingForLoginUser($main_login_id, 'is_experimental_user', 'on')` after linking, which writes the flag under the main account's `login_id` on the new account's settings hash.
