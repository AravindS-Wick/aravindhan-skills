---
name: security-sqli
description: Apply SQL injection protection using prepared statements for database queries. Use when generating or modifying code that uses exec, query, queryOne, querySql, etc.; follows .agent/rules/security-sqli.mdc.
---

# Apply SQL Injection Protection
All SQL queries in the codebase MUST use prepared statements.

## Mailchimp Database Classes and Methods
Methods used to query the database are part of the `Avesta_Db_Session` class which can be found here:
`modules/avesta/src/Avesta/Db/Session.php`

Typically, this class will be instantiated by one of the following helper methods:
```
MC::userDB
MC::loginDB
MC::globalDB
```

The `Avesta_Db_Session` methods that are used to execute queries are the following:
- exec
- query
- queryOne
- querySql
- querySqlOne
- querySqlCol
- querySqlColRef
- querySqlRow
- querySqlAll

## Using Prepared Statements
Prepared statements use the question mark `?` placeholder inside the SQL query string for every query parameter.
Always use placeholders instead of string concatenation except for ORDER BY and LIMIT clauses.

When using one of the `Avesta_Db_Session` query functions, the first argument to the function call should always be a SQL query string with placeholders for each query parameter 
and the second argument to the function call should always be an array that contains the values for each query parameter.
The array of values must be ordered in the same order as the placeholders in the query.
For example:
```
$result = MC::loginDB()->querySqlOne('SELECT username FROM login_users WHERE username = ? AND user_class = ?', [$username, $user_class]);
```

## Queries With Variable Number of Arguments
When a query needs to support an arbitrary number of parameters, for example based on the size of a list,
use the `MC_Utils::formatValuesPlaceholderSql` function to generate the correct number of placeholders and insert them into the query.
Pass the parameter values as an array in the second argument:

```
// $categories is an array with an arbitrary number of values
$placeholders = MC_Utils::formatValuesPlaceholderSql($categories);
$count = MC::loginDB()->querySqlOne(
    "SELECT COUNT(*) FROM campaigns WHERE list_id = ? AND email_id = ? AND category NOT IN ($placeholders)",
    array_merge([$list_id, $email_id], $categories)
);
```

## ORDER BY and LIMIT Clauses
`ORDER BY` SQL query clauses cannot be parameterized. If this clause needs to be dynamic, the allowed values must be checked against a hard coded list. For example:
```
$order = $_POST('order_by');
$allowed_ordered = ["date_created", "author_username"];
$sort_dir = $_POST('sort_dir');
// here, we check to make sure that the $order value provided by the user is one of those we explicitly define are okay to use.
// Otherwise, we'll manually set it to something safe.
if (!in_array($order, $allowed_order, true) {
    $order = "date_created";
}
 
// here, we check to make sure that the $sort_dir value provided by the user is one of those we explicitly define are okay to use.
// Otherwise, we'll manually set it to something safe.
$allowed_dir = ["ASC", "DESC"];
if (!in_array($sort_dir, $allowed_dir, true) {
    $sort_dir = "DESC";
}
$campaigns = $db->querySql("SELECT campaign FROM users_campaigns ORDER BY $order $sort_dir");
```

`LIMIT` query clauses also cannot be parameterized. If the LIMIT clause needs to be dynamic, always validate the range and cast it to an int:
```
$limit = (int) $_POST['limit'];
if ($limit > 100) { return "error: maximum limit is 100"; } 
$campaigns = $db->querySql("SELECT campaign FROM users_campaigns LIMIT $limit");
```

