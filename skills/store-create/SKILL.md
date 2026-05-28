---
name: store-create
description: Create one or more dummy ecommerce stores with promo codes in the CWS dev environment. Prompts the user for store type(s), number of promo codes per store, user ID, and list ID, then executes the creation via docker exec into mc-dev-app. Use when the user wants to seed dev data for Shopify, Wix, Square, or WooCommerce stores.
---

# Dev Store Creation (`store-create`)

Create dummy ecommerce stores and promo codes in the CWS dev environment for testing SMS promo code flows.

## Prerequisites

- CWS containers running (`up` or `up --fe`)
- A dev user account (default user ID: `1`)
- An audience/list created (default list ID: `1`)

## How the PHP shell works in CWS

The app container is named `mc-dev-app`. Use `docker exec` to run PHP directly — **do not use `devenv/script/devenv-gosh`**, it relies on `docker-compose` container naming and does not work in CWS.

To run a one-shot script non-interactively, pipe commands in via heredoc:

```bash
docker exec -i mc-dev-app bash -c 'cd /opt/mailchimp/current && php batch/shell.php --env=dev' <<'EOF'
// your PHP here
EOF
```

---

## Step 1 — Gather Inputs

Ask the user all of the following before proceeding. Do not run any commands until all inputs are confirmed.

### 1a. Store types (multi-select)

> "Which store type(s) would you like to create?"

| Option       | Platform value | Notes                              |
|--------------|---------------|------------------------------------|
| Shopify      | `ShopSync`    | Used for SMS dynamic discount codes |
| Wix          | `Wix`         |                                    |
| Square       | `Square`      |                                    |
| WooCommerce  | `woocommerce` | Lowercase — must be exact          |

Allow the user to select multiple. If they select all, create one of each.

### 1b. Promo codes per store

> "How many promo codes would you like to create for each store? (default: 1)"

- Minimum: 1
- If the user says a number greater than 1, generate unique promo rule IDs and codes using a counter suffix: `PROMO1`, `PROMO2`, etc.
- Default promo type is `percentage` at `20.00`. Ask if they want a different amount or type (`percentage` / `fixed`).

### 1c. User ID and List ID

> "What is your dev user ID? (default: 1)"
> "What is your audience/list ID? (default: 1)"

---

## Step 2 — Confirm Before Running

Present a summary of what will be created and ask the user to confirm:

```
I'll create the following in your dev environment:
  • [Store type] store — platform: [value], list_id: [list_id]
    └─ [N] promo code(s): [CODE1], [CODE2], ...
  • [Store type] store — ...

User ID: [uid]

Shall I proceed?
```

Do not run any commands until the user confirms.

---

## Step 3 — Execute

Use `docker exec` to run PHP directly in the app container. Do **not** use `devenv/script/devenv-gosh` — it does not work in CWS.

```bash
docker exec -i mc-dev-app bash -c 'cd /opt/mailchimp/current && php batch/shell.php --env=dev' <<'EOF'
// generated PHP here
EOF
```

### PHP template

Generate one block like this per store selected:

```php
User::initialize(USER_ID);
$session = Avesta_Db_Session::getSession('default');

// --- STORE_TYPE Store ---
$store = new Ecommerce_Store($session);
$store->store_foreign_id = 'PLATFORM_PREFIX_store_' . time();
$store->list_id = LIST_ID;
$store->name = 'My STORE_TYPE Store';
$store->platform = 'PLATFORM_VALUE';
$store->domain = 'EXAMPLE_DOMAIN';
$store->email = 'store@example.com';
$store->currency = 'USD';
$store->country_code = 'US';
$store->is_active = 'Y';
$store->is_connected = 'Y';
$store->save();
echo "Created store: " . $store->name . " (ID: " . $store->store_id . ")\n";
$store_id_PLATFORM_PREFIX = $store->store_id;
```

Then for each promo code requested for that store:

```php
$rule_N = new Ecommerce_Promo_Rule($session);
$rule_N->store_id = $store_id_PLATFORM_PREFIX;
$rule_N->promo_rule_id = 'PROMO_CODE_ID';
$rule_N->title = 'PROMO_TITLE';  // e.g. "20% Off Everything" for percentage, "$10 Off" for fixed
$rule_N->amount = 'AMOUNT';
$rule_N->type = 'PROMO_TYPE';   // 'percentage' or 'fixed'
$rule_N->target = 'total';
$rule_N->enabled = 'Y';
$rule_N->save();

$code_N = new Ecommerce_Promo_Code($session);
$code_N->store_id = $store_id_PLATFORM_PREFIX;
$code_N->promo_rule_id = 'PROMO_CODE_ID';
$code_N->promo_code_id = 'PROMO_CODE_ID';
$code_N->code = 'PROMO_CODE_ID';
$code_N->enabled = 'Y';
$code_N->save();
echo "Created promo code: PROMO_CODE_ID\n";
```

### Platform substitution table

| Store type  | `PLATFORM_VALUE` | `PLATFORM_PREFIX` | `EXAMPLE_DOMAIN`                 |
|-------------|-----------------|-------------------|----------------------------------|
| Shopify     | `ShopSync`      | `shopify`         | `mystore.myshopify.com`          |
| Wix         | `Wix`           | `wix`             | `myusername.wixsite.com/mystore` |
| Square      | `Square`        | `square`          | `squareup.com/store/mystore`     |
| WooCommerce | `woocommerce`   | `woo`             | `mystore.com`                    |

### Promo code naming

- Single promo code: use `PROMO1` as the code ID.
- Multiple codes: `PROMO1`, `PROMO2`, `PROMO3`, etc.
- If the user requests a custom code name, use that instead.

---

## Step 4 — Report Results

After the command runs, parse the output and report back clearly:

```
Done! Here's what was created:

Shopify store — store_id: 3
  ✓ PROMO1 (20% off)
  ✓ PROMO2 (20% off)

Wix store — store_id: 4
  ✓ PROMO1 (20% off)
```

If any error occurs (exception, "Call to undefined method", etc.), show the raw error and use the troubleshooting guide below.

---

## Notes

- `User::initialize()` is called once at the top of the script, not once per store.
- `store_foreign_id` must be unique — always append `time()` to guarantee uniqueness.
- `promo_rule_id` and `promo_code_id` must also be unique per store. If the user runs the skill twice, the second run will fail on duplicate IDs unless different codes are used.
- Platform values are case-sensitive and must match the constants in `app/models/Ecommerce/Store.php` — `woocommerce` must be lowercase.
- If the user wants to verify the store was created, they can check at `https://localhost/account/connected-sites` in their CWS browser.

---

## Troubleshooting

**`App container does not seem to be running`**
The old `devenv-gosh` script fails in CWS. Use the `docker exec` command instead (see Prerequisites above).

**`docker: command not found` or permission error**
Run `up` first to ensure containers are started, then retry.

**Store saves but doesn't appear in the UI**
Check that `list_id` matches an existing audience for the user. Run this to see available lists:

```bash
docker exec -i mc-dev-app bash -c 'cd /opt/mailchimp/current && php batch/shell.php --env=dev' <<'EOF'
User::initialize(1);
$user = MC::user();
$lists = $user->getLists();
foreach ($lists as $list) { echo $list->list_id . " - " . $list->name . "\n"; }
EOF
```

**Duplicate promo rule ID error on second run**
`promo_rule_id` must be unique per store. Ask the user for different code names, or append a timestamp suffix (e.g. `PROMO1_` . time()).
