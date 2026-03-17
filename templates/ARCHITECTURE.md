# Architecture

## Overview

Brief description of the system, its purpose, and the high-level architecture pattern in use.

**Pattern:** (e.g., Layered, MVC, Clean Architecture, Microservices, Event-Driven)

## Modules

| Module | Path | Responsibility | Public Interface |
|--------|------|----------------|------------------|
| | `src/` | | |

## Dependencies

| Dependency | Purpose | Used By |
|------------|---------|---------|
| | | |

## Data Flow

Describe how data moves through the system, from input to storage.

1. Request enters via ...
2. Processed by ...
3. Persisted in ...

## Boundaries

Rules that code must follow. The reviewer checks these.

- [ ] Module X does not import from Module Y directly
- [ ] Database access only through the data layer
- [ ] No framework imports in domain/entity code

## Technology Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Language | | |
| Framework | | |
| Database | | |
| Hosting | | |

## Conventions

- **Naming:** (e.g., kebab-case files, PascalCase components)
- **Testing:** (e.g., co-located `__tests__/`, or top-level `tests/`)
- **Config:** (e.g., environment variables via `.env`, no hardcoded values)
