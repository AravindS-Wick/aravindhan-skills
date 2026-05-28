---
name: planetscale
description: Database schema branching, indexing, N+1 query prevention, query plans, and safe online migrations for MySQL/PostgreSQL databases. Use when working on database schemas, migrations, or query optimization.
---
# PlanetScale Database Development Playbook

This skill enforces strict production-grade standards for relational database development (MySQL, PostgreSQL, serverless DBs), index design, schema branching, and migration workflows.

## Target Triggers
- `/planetscale`
- `"database branch"`
- `"optimize database query"`
- `"database index design"`

## Operational Standards

### 1. Schema Branching Workflow
- Never perform direct DDL modifications or raw schema migrations on the main/production database.
- Always perform database migrations on a dedicated schema branch (e.g. `db branch create feature-name`).
- Once migrations are fully validated in the dev environment, generate a deploy request (similar to a pull request for schemas).

### 2. Query Performance & Indexing
- Avoid database table scans. Ensure queries utilize a defined index.
- Run `EXPLAIN` or query plan analyzer on critical query layouts to check for index hit rates and scanned rows.
- Ensure foreign keys (or logical relationships in serverless DBs) have corresponding indexes on the referencing side to prevent slow join times.

### 3. Preventing N+1 Query Loops
- Audit route handlers and services for database queries executed inside loops (e.g., fetching a list of records and executing a query for each row).
- Replace nested loops with batch selections (using `IN` clauses) or proper database joins.

### 4. Online Schema Migrations
- Write migrations so that they are backward-compatible with running application versions (avoid renaming columns or dropping active tables directly).
- For column additions, provide nullable types or default constraints to prevent application crashes during zero-downtime deployment.
