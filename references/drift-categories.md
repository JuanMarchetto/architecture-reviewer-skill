# Architecture Drift Categories

Reference catalog of common drift types. Each category includes detection heuristics
and default severity used by the reviewer agent.

---

## 1. Module Boundary Drift

**Description:** Code in one module directly accesses internals of another module,
bypassing declared public interfaces. Imports cross boundaries that the architecture
document defines as separate.

**Detection heuristic:** Compare import/require statements against the declared module
map. Flag any import that reaches into a module's internal path (e.g., `import from '../auth/internal/token'`)
when the architecture declares `auth` as a self-contained module.

**Default severity:** High

**Example:** `ARCHITECTURE.md` declares `payments/` and `users/` as independent modules,
but `payments/checkout.ts` imports `users/internal/addressValidator.ts` directly.

---

## 2. Dependency Drift

**Description:** The codebase uses libraries, services, or internal modules that are
not listed in the architecture document's dependency section, or listed dependencies
are no longer used.

**Detection heuristic:** Extract all import sources and external packages from the code.
Diff against the declared dependency list. Flag undeclared externals and unused declared deps.

**Default severity:** Medium

**Example:** `ARCHITECTURE.md` lists PostgreSQL as the database, but `package.json`
includes `mongoose` and code imports `mongodb` drivers.

---

## 3. Responsibility Drift

**Description:** A module performs work outside its documented responsibility, or has
stopped performing its declared purpose. Scope creep or scope abandonment.

**Detection heuristic:** Extract exported functions/classes from each module. Compare
their names and purposes against the documented responsibility. Flag modules where
>30% of exports don't align with the stated role.

**Default severity:** Medium

**Example:** The `logging/` module is documented as "structured log output" but now
contains error recovery logic, retry mechanisms, and alerting integrations.

---

## 4. Pattern Drift

**Description:** Code does not follow the architectural patterns declared in the
documentation. The stated pattern is layered architecture but modules skip layers,
or the stated pattern is event-driven but modules call each other synchronously.

**Detection heuristic:** Identify the declared pattern (layered, MVC, event-driven, etc.).
Check import directions against expected flow. Flag reverse-direction imports or
layer-skipping calls.

**Default severity:** High

**Example:** Architecture declares clean architecture with `usecases/ -> adapters/ -> entities/`
flow, but an adapter directly imports and mutates an entity without going through a use case.

---

## 5. Technology Drift

**Description:** The codebase uses different technologies, frameworks, or languages
than what the architecture document specifies. May indicate an incomplete migration
or an undocumented decision.

**Detection heuristic:** Scan for config files (package.json, Cargo.toml, go.mod, etc.),
file extensions, and framework-specific imports. Compare against the documented tech stack.

**Default severity:** Low (if migration in progress) / High (if undocumented)

**Example:** `ARCHITECTURE.md` says "REST API with Express" but the codebase contains
GraphQL resolvers and an Apollo Server setup with no REST routes remaining.

---

## 6. Naming Drift

**Description:** Files, directories, or modules have been renamed, moved, or
restructured without updating the architecture documentation. References in the
doc point to paths that no longer exist.

**Detection heuristic:** Extract every file/directory path mentioned in the architecture
document. Verify each path exists on disk. Flag missing paths and suggest closest matches
using fuzzy matching.

**Default severity:** Low

**Example:** `ARCHITECTURE.md` references `src/services/auth/` but the directory was
renamed to `src/modules/authentication/` three months ago.

---

## 7. Scale Drift

**Description:** A module has grown significantly beyond its originally documented
scope in terms of file count, line count, or number of exports. What was designed
as a small utility has become a major subsystem without architectural acknowledgment.

**Detection heuristic:** Count files, lines, and exports per module. Compare against
any documented size expectations or against the median module size. Flag modules that
are >3x the median or have grown >50% since last review.

**Default severity:** Medium

**Example:** The `utils/` module was documented as "small shared helpers (< 10 files)"
but now contains 47 files, 12 sub-directories, and has become the most-imported module
in the project.
