---
name: security-cmdexe
description: Convert PHP exec, shell_exec, system, passthru, or backticks to the ShellBuilder pattern. Use when PHP code contains those builtins; follows .agent/rules/security-cmdexe.mdc.
---

# Convert Shell Commands to ShellBuilder

Any PHP code that contains references to the following builtin PHP functions should be converted to use the ShellBuilder pattern instead:
- exec
- shell_exec
- system
- passthru
- `` (backticks)

Convert that code to the ShellBuilder equivalent. The ShellBuilder class uses the builder pattern to prepare a system command
to be executed.

## Converting Code
First, understand the ShellBuilder and ShellExpression classes by reading the following files:
- modules/avesta/src/Avesta/Console/ShellBuilder.php
- modules/avesta/src/Avesta/Console/ShellExpression.php

The ShellBuilder constructor takes a single command to execute as an argument to its constructor, and arguments are added using the `withArguments` function. For example:
```php
$sh = (new ShellBuilder("cat"))
    ->withArguments("foo", "bar")
    ->shell_exec();
```

This is the ShellBuilder equivalent of the following native PHP code:
`shell_exec("cat foo bar");`

PHP backticks (``) are the equivalent of calling `shell_exec`. For example:
'whoami' should be converted to `(new ShellBuilder('whoami'))->shell_exec()`

## Additional arguments
If there are more arguments to the `exec`, `shell_exec`, `system`, or `passthru` calls being converted than the first command argument,
use the `withEnvironmentVariable`, `withOutputArg` or `withReturnCodeArg` functions based on the name of the argument in the function signature.

## Input/Output Redirection & Complex Commands
Complex commands that require use of pipes, wildcards, or input/output redirection need to be built using the functions
defined in the ShellExpression class. For example:

```php
<?php
use Avesta\Console\ShellBuilder;
use Avesta\Console\ShellExpression;

// shell_exec version
$count = shell_exec('ls -l test* | wc -l > out.txt);

// ShellBuilder version
$count = (new ShellBuilder('ls'))
            ->withArguments('-l', ShellExpression::raw('test*'), ShellExpression::PIPE(), 'wc', '-l', ShellExpression::REDIR_STDOUT(), 'out.txt')
            ->exec();
```
