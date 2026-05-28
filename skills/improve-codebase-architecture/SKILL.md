---
name: improve-codebase-architecture
description: Reorganizes backend codebases to enforce clean architectural patterns (Controllers, Services, Repositories/Data Access Objects) to reduce token bloat and maintain codebase longevity.
---
# Clean Codebase Architecture Playbook

This skill instructs the agent to systematically refactor monolithic, coupled, or chaotic backend code into a structured, scalable design.

## Target Triggers
- `/improve-codebase-architecture`
- `"refactor to clean architecture"`
- `"clean controller service repository"`

## Design Standards

To prevent context bloat and ensure separation of concerns, the backend code should follow the standard layer separation:

### 1. Controllers (Routing / Transport Layer)
- Handles HTTP requests, parses query/body params, manages status codes, and responds (JSON/HTML).
- **Rule**: Controllers must NOT execute database operations or complex business logic. They should only validate input shapes (e.g. using Pydantic, Zod, or Joi) and delegate to services.

### 2. Services (Business Logic Layer)
- Orqestrates domain logic, workflows, external APIs (payment gates, search clients), and coordinates repositories.
- **Rule**: Services must be transport-agnostic (should not know about `req`, `res`, `HttpExchange`, or specific route details). They should receive native data types/DTOs.

### 3. Repositories / DAOs (Data Access Layer)
- Directly interacts with database APIs, ORMs (Prisma, EF Core, SQLAlchemy, Hibernate), or cache layers.
- **Rule**: Repositories must NOT execute business rules. They only query and persist data.

## Step-by-Step Refactoring Process

1. **Audit current files**: Map out the controllers/endpoints that have bloated business logic or raw inline database calls.
2. **Define Data Transfer Objects (DTOs)**: Determine the interfaces/schemas for data flowing between layers.
3. **Extract Repositories**: Create repository functions or classes with clean database APIs (e.g. `UserRepository.find_by_email()`).
4. **Extract Services**: Pull out the core business operations (e.g. `AuthService.register_user()`) and inject/use the repository.
5. **Clean the Controller**: Simplify the route handler to call the service method, handle errors, and return response codes.
6. **Verify and Test**: Re-run existing unit and integration tests to ensure logic is preserved.
