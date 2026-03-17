# Architecture Patterns

Reference for detecting and comparing architectural patterns in codebases. Used during Phase 3 (Scan Actual Code) to identify which pattern the code actually follows, and during Phase 4 (Detect Drift) to compare against the declared pattern.

---

## Layered Architecture

**Also known as**: N-tier, horizontal layers

**Core principle**: Code is organized in horizontal layers where each layer only depends on the layer directly below it. No layer skips a level. No layer depends on a layer above it.

**Typical layers** (top to bottom):
1. Presentation / API / Controllers
2. Business logic / Services / Use cases
3. Data access / Repositories / Persistence
4. Infrastructure / External services

**Directory markers**:
```
src/
  controllers/    or  routes/     or  handlers/     or  api/
  services/       or  business/   or  use-cases/    or  logic/
  repositories/   or  data/       or  persistence/  or  dal/
  models/         or  entities/   or  domain/
```

**Import patterns**:
- Controllers import from services (never from repositories)
- Services import from repositories and models
- Repositories import from models and database clients
- Models import nothing (or only other models)
- No circular imports between layers

**Typical boundaries**:
- Controllers must NOT import database clients directly
- Repositories must NOT contain business logic
- Models must NOT know about HTTP or API details

**Detection signals**:
- Files named `*Controller*`, `*Service*`, `*Repository*`
- Import chains flow in one direction (top to bottom)
- Database operations only in repository/data layer

---

## MVC / MVVM

**Also known as**: Model-View-Controller, Model-View-ViewModel

**Core principle**: Separate data (Model), presentation (View), and control flow (Controller/ViewModel). Views never talk to models directly in strict MVC.

**Directory markers**:
```
src/
  models/       or  entities/
  views/        or  templates/   or  pages/     or  components/
  controllers/  or  viewmodels/  or  presenters/
```

Or feature-grouped:
```
src/
  users/
    user.model.ts
    user.view.tsx
    user.controller.ts
```

**Import patterns**:
- Controllers import models and views
- Views may import viewmodels (MVVM) but not models directly (strict MVC)
- Models import nothing from views or controllers

**Typical boundaries**:
- Views must NOT perform database queries
- Models must NOT contain rendering logic
- Controllers should be thin -- delegate to models for logic

**Detection signals**:
- File naming conventions: `*.model.*`, `*.view.*`, `*.controller.*`
- Template engines or component-based UI libraries
- Controller files that handle HTTP verbs (GET, POST, PUT, DELETE)

---

## Microservices / Modular Monolith

**Core principle**: The system is composed of independently deployable services (microservices) or self-contained modules within a single codebase (modular monolith). Each module owns its data and exposes a defined interface.

**Directory markers (monorepo/modular)**:
```
services/
  auth-service/
  billing-service/
  notification-service/

# or
packages/
  auth/
  billing/
  shared/

# or (workspace-based)
apps/
  api/
  worker/
  web/
libs/
  shared/
  db/
```

**Import patterns**:
- Modules import from shared libraries but NOT from each other's internals
- Cross-module communication via defined interfaces (API calls, events, shared types)
- Each module has its own entry point

**Typical boundaries**:
- Module A must NOT import internal files from Module B (only the public API)
- Each module manages its own database schema/tables
- Shared code lives in explicit shared packages

**Detection signals**:
- Multiple `package.json` / `Cargo.toml` files (one per service/package)
- Workspace configuration in root manifest
- Docker Compose or Kubernetes manifests defining multiple services
- Event bus or message queue configuration
- API gateway or service mesh configuration

---

## Event-Driven Architecture

**Core principle**: Components communicate by producing and consuming events rather than direct function calls. Loose coupling through asynchronous event propagation.

**Directory markers**:
```
src/
  events/          or  messages/
  handlers/        or  consumers/  or  subscribers/
  producers/       or  publishers/ or  emitters/
  sagas/           or  workflows/  or  orchestrators/
```

**Import patterns**:
- Producers import event definitions but NOT consumer implementations
- Consumers import event definitions and their own handlers
- Saga/orchestrator modules may import multiple event types
- No direct imports between producer and consumer modules

**Typical boundaries**:
- Producers must NOT know who consumes their events
- Consumers must NOT call producers directly
- Event schemas are the contract (changing them is a breaking change)

**Detection signals**:
- Event bus / message broker libraries (Kafka, RabbitMQ, Redis pub/sub, EventEmitter)
- Files with `*Event*`, `*Handler*`, `*Listener*`, `*Subscriber*` naming
- Async processing patterns (queues, workers, background jobs)
- Event schema definitions or DTOs

---

## Clean Architecture / Hexagonal / Ports and Adapters

**Also known as**: Onion Architecture, Hexagonal Architecture

**Core principle**: Dependencies point inward. The domain/business logic is at the center and depends on nothing external. External concerns (database, HTTP, filesystem) are adapters that plug into ports defined by the domain.

**Typical layers** (inside to outside):
1. Domain / Entities (innermost -- no dependencies)
2. Use Cases / Application Services
3. Interface Adapters (controllers, presenters, gateways)
4. Frameworks & Drivers (database, web framework, external APIs)

**Directory markers**:
```
src/
  domain/          or  core/       or  entities/
  application/     or  use-cases/  or  interactors/
  adapters/        or  interfaces/ or  infrastructure/
    http/          or  api/        or  web/
    persistence/   or  db/         or  repositories/
    external/      or  services/
  ports/           or  contracts/  or  interfaces/
```

**Import patterns**:
- Domain imports NOTHING from outer layers
- Application/use-cases import from domain only
- Adapters import from application and domain (implement port interfaces)
- Framework code imports from adapters
- Dependency injection wires adapters to ports at startup

**Typical boundaries**:
- Domain MUST NOT import database, HTTP, or framework code
- Use cases define port interfaces; adapters implement them
- No framework annotations or decorators on domain entities

**Detection signals**:
- Interface files (ports) separate from implementation files (adapters)
- Dependency injection container or manual wiring at entry point
- Domain objects have no framework-specific decorators
- Repository interfaces in domain, implementations in infrastructure
- Test doubles for external services via port interfaces

---

## Monorepo Structure

**Core principle**: Multiple related projects or packages live in a single repository, managed by a workspace tool. Not an architecture pattern per se, but a structural pattern that implies boundaries.

**Directory markers**:
```
packages/        or  libs/        or  modules/
apps/            or  services/
tools/           or  scripts/
```

**Workspace configuration**:
- `package.json` with `"workspaces"` field
- `pnpm-workspace.yaml`
- `lerna.json`
- `nx.json` or `project.json` files
- `turbo.json`
- Cargo workspace in `Cargo.toml` with `[workspace]` section
- Go workspace in `go.work`

**Import patterns**:
- Packages import each other by package name (not relative paths)
- Shared packages are explicit dependencies in each consumer's manifest
- Internal packages may have restricted visibility (e.g., `"private": true`)

**Typical boundaries**:
- Apps depend on libs, not the other way around
- Packages declare their public API through entry points
- Shared packages must not import from app-specific packages
- Build order follows the dependency graph

**Detection signals**:
- Multiple `package.json` or `Cargo.toml` files
- Workspace configuration at the root level
- Build orchestrator (Nx, Turbo, Lerna) configuration
- Shared `tsconfig.json` with path aliases pointing to packages

---

## How to Use This Reference

During Phase 3 of the audit protocol:

1. Scan directory names and file organization for **directory markers** from each pattern
2. Check import statements for **import patterns** that match a specific pattern
3. Look for **detection signals** (framework config, naming conventions, tooling)
4. If the code matches a pattern, compare it against the pattern's **typical boundaries**
5. Score how consistently the pattern is applied (all modules vs. some modules)

During Phase 4 (drift detection):

1. If docs declare Pattern X, check the code against Pattern X's rules from this reference
2. If the code follows Pattern Y instead, that is a `pattern` drift item
3. If the code partially follows Pattern X, note which modules comply and which diverge
4. If no pattern is documented but the code clearly follows one, report it as an `undocumented` item and suggest documenting the pattern
