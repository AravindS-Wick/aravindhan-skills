---
name: security-csrf
description: Apply CSRF protection to state-changing controller actions and Autolyse services. Use when generating Mailchimp controllers or registering Autolyse services; follows .agent/rules/security-csrf.mdc.
---

# Apply CSRF Protection to all state changing controller actions

## Class and Function Conventions
Mailchimp controllers typically use the following class name and function name convention:

```
// Class name ends in Controller and extends a class whose name begins with MC_Controller_
class Account_UsersController extends MC_Controller_Action
{
    // preRun method is optional and always runs first when an Action function is invoked
    public function preRun()
    {
        parent::preRun();
        // logic
    }

    // Conventionally, an action that just returns data, but may change state (GET request)
    public function fooAction() {
        // logic
    }

    // An action that changes state (POST request)
    public function barPostAction() {
        // logic
    }
}
```

## CSRF Protection Methods
The following method calls adds CSRF protection when invoked inside a Mailchimp Controller function:

```
$this->protectCSRF()
```

## Rules for when to apply CSRF Protection
CSRF protection must be applied to any Mailchimp Controller Action method that is state changing.
Determine if the action is state changing using the following rules: 
- Code inside a controller action method whose name ends in PostAction is always state changing.
- Code inside a controller action method whose name does not end in PostAction is generally not state changing. However, to determine if it is state changing, analyze the logic of the method to determine if it is doing any "write" operations, for example, modifying or inserting a database value, or triggering an action, for example sending an email.

If the class contains a `preRun` method, and `$this->protectCSRF()` is already invoked inside that method, Controller Action methods do not need to invoke it again.
Similarly, if the `preRun` method of the class calls `parent::preRun()` or another method that already invokes the `$this->protectCSRF()` method, the Controller Action methods do not need to invoke it again. 

# Apply CSRF Protection to all Autolyse Services by default
When generating an Autolyse service, register it with CSRF Protection enabled by default.

The service registration call in `app/lib/Autolyse/Services.php` should include the `ValidateCSRF` middleware, as in this example:

```php
private static function registerMyService(Server $server): void
{
    $server->registerLazyInitializer(
        MyServiceAutolyseInterface::class,
        fn() => $server->register(
            MyServiceAutolyseInterface::class,
            self::withMiddleware(
                new ValidateCSRF,
            )
        )
    );
}
```
