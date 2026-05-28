---
name: grill-with-docs
description: Forces grounding using live documentation (Redis, Postgres, external API docs, frameworks) fetched via curl or web search before generating integration code or database schemas.
---
# Grounding with Live Docs Playbook

This skill instructs the agent to fetch external or official documentation from official websites or repositories before implementing database schemas, APIs, or libraries. This prevents using outdated schemas or hallucinating options/parameters.

## Target Triggers
- `/grill-with-docs`
- `"ground with latest schema"`
- `"ground with docs"`

## Operational Steps

When executing tasks requiring database configuration, caching integration, or third-party APIs:

### 1. Identify Target APIs/Libraries
- Determine the library versions or service endpoints (e.g., Redis, PostgreSQL, Prisma, Stripe, Firebase, AWS SDK, Next.js).
- Pinpoint specific commands, functions, or schemas that need to be implemented.

### 2. Fetch Documentation Live
- Do not rely entirely on internal model memory if there is ambiguity or a recent version change.
- Use `search_web` to locate official guides or API docs.
- Use `read_url_content` or `read_browser_page` to fetch and parse the target doc page.
- Look specifically for syntax changes, deprecated options, error schemas, and configuration requirements.

### 3. Verify Database/Service Schema Compatibility
- Check that fields, types, and constraints match exactly what the service/database expects.
- Ground database queries against actual schemas defined in migration files, schemas (e.g., `schema.prisma`, SQL init files), or live database inspect outputs.

### 4. Implement Grounded Code
- Write the schema, configuration, or API caller logic based on the extracted rules.
- Document any specific assumptions or external links inside the codebase for developers.
