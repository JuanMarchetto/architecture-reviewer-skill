# Architecture Patterns Reference

Detection signatures for common architecture patterns. Used by the reviewer agent
to identify the intended pattern and validate adherence.

---

## 1. Layered Architecture

**Flow:** Presentation -> Business Logic -> Data Access

**Directory markers:**
- `routes/` or `controllers/` or `api/` (presentation)
- `services/` or `logic/` or `domain/` (business)
- `repositories/` or `dal/` or `db/` (data)

**Import pattern:** Each layer only imports from the layer directly below it.
Presentation imports services, services import repositories. No reverse imports.

**Typical boundaries:**
- Presentation never imports database drivers directly
- Data layer never references HTTP/request objects
- Business layer has no framework-specific imports

---

## 2. MVC / MVVM

**Flow:** Model <-> Controller <-> View (MVC) | Model <-> ViewModel <-> View (MVVM)

**Directory markers:**
- `models/` or `entities/` or `schemas/`
- `controllers/` or `viewmodels/` or `handlers/`
- `views/` or `templates/` or `components/`

**Import pattern:** Controllers import models and reference views. Views do not
import models directly (in strict MVC). ViewModels bridge model data to view format.

**Typical boundaries:**
- Views contain no business logic or direct data queries
- Models have no knowledge of views or controllers
- Controllers orchestrate but hold minimal state

---

## 3. Microservices

**Flow:** Independent services communicate via network (HTTP, gRPC, messaging)

**Directory markers:**
- Separate `package.json` / `go.mod` / `Cargo.toml` per service
- `services/<name>/` each with their own entry point
- `docker-compose.yml` or `k8s/` deployment configs
- `proto/` or `api/` shared contract definitions

**Import pattern:** No cross-service file imports. Services share only through
API contracts, message schemas, or shared libraries published as packages.

**Typical boundaries:**
- Each service owns its own database / data store
- No shared mutable state between services
- Inter-service communication only via declared contracts

---

## 4. Event-Driven

**Flow:** Producers -> Event Bus/Queue -> Consumers

**Directory markers:**
- `events/` or `messages/` or `handlers/`
- `publishers/` or `producers/` and `subscribers/` or `consumers/`
- Queue config files (RabbitMQ, Kafka, SQS, Redis Streams)

**Import pattern:** Producers import event definitions but not consumers.
Consumers import event definitions but not producers. Decoupled via event contracts.

**Typical boundaries:**
- Producers never call consumers directly
- Event schemas defined in a shared location
- Handlers are idempotent and independently deployable
- No synchronous request/response between event-connected modules

---

## 5. Clean Architecture

**Flow:** Frameworks -> Adapters -> Use Cases -> Entities (dependency points inward)

**Directory markers:**
- `entities/` or `domain/` (innermost, no external deps)
- `usecases/` or `interactors/` or `application/`
- `adapters/` or `interfaces/` or `infrastructure/`
- `frameworks/` or `drivers/` (outermost)

**Import pattern:** Strict inward dependency. Entities import nothing. Use cases
import entities. Adapters import use cases. Frameworks import adapters. Never outward.

**Typical boundaries:**
- Entities have zero external imports (no frameworks, no libraries)
- Use cases define port interfaces; adapters implement them
- Database, HTTP, and UI details live only in the outer rings
- Inner layers are testable without any infrastructure
