# Drift Categories

Reference for classifying architecture drift items. Each category has a description, detection method, default severity, and example.

---

## Module Boundary Drift

**Description**: Code crosses a boundary that architecture docs explicitly declare. A module imports from, calls into, or directly accesses internals of another module that it should not depend on according to the documented architecture.

**How to detect**:
- Scan import statements in module A for imports from module B
- Compare against the declared dependency graph in architecture docs
- Check for "must not depend on" rules and verify no imports violate them
- Look for re-exports that mask a boundary violation (A imports from B via C when A should not reach B at all)

**Default severity**: CRITICAL

**Example**:
```
[CRITICAL] module-boundary: Auth module imports directly from Billing
  Documented: ARCHITECTURE.md says "Auth communicates with Billing only through the User service"
  Actual: src/auth/verify.ts:14 imports calculateCharge from src/billing/charge.ts
  Impact: Auth changes could silently break billing logic; no isolation between security and payment
  Recommendation: Route the call through src/user/billing-proxy.ts as documented
```

---

## Dependency Drift

**Description**: The actual dependency graph between modules does not match what the architecture documents describe. This includes undeclared dependencies, missing documented dependencies, wrong external package versions, or dependencies that should have been removed.

**How to detect**:
- Build the actual import graph by scanning all import/require statements
- Compare against the dependency table or diagram in architecture docs
- Check package manifests (package.json, Cargo.toml, go.mod) against documented technology choices
- Detect circular dependencies not mentioned in docs

**Default severity**: WARNING

**Example**:
```
[WARNING] dependency: API module depends on CLI module (undocumented)
  Documented: No dependency between api/ and cli/ in the module map
  Actual: src/api/routes/export.ts:3 imports formatOutput from src/cli/formatter.ts
  Impact: Changes to CLI output formatting could break API responses
  Recommendation: Extract shared formatting logic to a shared/ module, or document the dependency
```

---

## Responsibility Drift

**Description**: A module does more or less than its documented purpose. The module's actual behavior has expanded beyond its declared scope, or functionality described in docs has been moved elsewhere without updating the documentation.

**How to detect**:
- Read the documented responsibility for each module
- Scan the module's exports and public API surface
- Check file count and line count relative to the stated responsibility
- Look for business logic in modules documented as "utility" or "infrastructure"
- Look for cross-cutting concerns (logging, auth, validation) in modules that should be domain-focused

**Default severity**: WARNING

**Example**:
```
[WARNING] responsibility: Utils module contains business logic
  Documented: "Shared utility functions -- formatting, date helpers, string manipulation"
  Actual: src/utils/ has 47 exports including validateOrder(), calculateTax(), and applyDiscount()
         which are business logic, not utilities (2,400 lines total)
  Impact: Business rule changes require editing a "utility" module; unclear ownership
  Recommendation: Move business functions to their owning domain modules (orders/, billing/)
```

---

## Pattern Drift

**Description**: The code does not follow the architectural pattern declared in the documentation. The docs say the project uses a specific pattern (MVC, layered, hexagonal, event-driven), but the actual code structure deviates from that pattern's conventions.

**How to detect**:
- Identify the declared pattern in architecture docs
- Compare against the pattern's expected structure (see references/architecture-patterns.md)
- Check whether the pattern is consistently applied or only partially
- Look for modules that violate the pattern's core rules (e.g., views calling the database in an MVC app)

**Default severity**: WARNING

**Example**:
```
[WARNING] pattern: Documented as Clean Architecture but domain imports infrastructure
  Documented: ARCHITECTURE.md declares Clean Architecture with domain at the center
  Actual: src/domain/user.ts:5 imports PostgresClient from src/infrastructure/db.ts
         (domain layer should not know about infrastructure)
  Impact: Domain logic is coupled to PostgreSQL; cannot swap databases or test domain in isolation
  Recommendation: Define a repository interface in domain/ and implement it in infrastructure/
```

---

## Technology Drift

**Description**: The actual technology stack differs from what the architecture documents describe. A framework, library, database, or API style was added, removed, or replaced without updating the docs.

**How to detect**:
- Extract technology declarations from architecture docs (frameworks, databases, API styles, build tools)
- Scan package manifests and config files for actual technologies in use
- Check for deprecated technologies still referenced in docs
- Look for migration artifacts (e.g., both REST routes and GraphQL resolvers when docs say "REST only")

**Default severity**: WARNING

**Example**:
```
[WARNING] technology: REST to tRPC migration not documented
  Documented: ARCHITECTURE.md says "RESTful API using Express.js"
  Actual: src/api/ contains both Express routes (12 files) and tRPC routers (8 files)
         tRPC is in package.json dependencies but not mentioned in any architecture doc
  Impact: New developers follow docs and write REST endpoints; half the team uses tRPC
  Recommendation: Update docs to reflect the tRPC migration. Document whether REST is being phased out
```

---

## Naming Drift

**Description**: Modules, directories, or files were renamed or reorganized without updating the architecture documentation. The docs reference paths, module names, or file names that no longer exist.

**How to detect**:
- Extract all file paths and directory names referenced in architecture docs
- Check whether each referenced path actually exists
- Look for directories with similar names (fuzzy match) that suggest a rename
- Check for import aliases or re-exports that paper over a rename

**Default severity**: INFO

**Example**:
```
[INFO] naming: services/ renamed to modules/ without doc update
  Documented: ARCHITECTURE.md references "services/auth/", "services/billing/", "services/user/"
  Actual: Directory is named "modules/" -- modules/auth/, modules/billing/, modules/user/
  Impact: New developers look for services/ directory that does not exist; minor confusion
  Recommendation: Update all path references in ARCHITECTURE.md from services/ to modules/
```

---

## Scale Drift

**Description**: A module has grown significantly beyond its originally documented scope. The module's file count, line count, or number of exports is disproportionate to its stated responsibility, suggesting it has absorbed responsibilities from other modules or needs to be split.

**How to detect**:
- Count lines of code and files per module
- Compare module sizes against each other (identify outliers)
- Check if a module's size matches the complexity of its documented responsibility
- Flag modules with >500 lines in a single file, >20 files, or >50 exports
- Look for modules that are imported by >50% of other modules (gravity modules)

**Default severity**: INFO

**Example**:
```
[INFO] scale: User module grew 10x beyond documented scope
  Documented: "User authentication and profile management" (implies focused module)
  Actual: src/user/ contains 34 files, 4,200 lines across auth, profiles, preferences,
         notifications, activity tracking, and social features
  Impact: Module is hard to navigate; changes to any user feature risk breaking others
  Recommendation: Split into user-auth/, user-profile/, and user-social/ as separate modules
```

---

## Undocumented

**Description**: A significant part of the codebase has no corresponding entry in any architecture document. The code exists, is used, and matters -- but architecture docs do not acknowledge it. This is not drift (there is nothing to drift from); it is a documentation gap.

**How to detect**:
- List all actual top-level modules/directories
- Cross-reference against modules mentioned in architecture docs
- Flag any module with >5 files and >200 lines that is not documented
- Check for infrastructure code (CI, scripts, tooling) that may warrant documentation

**Default severity**: WARNING (upgrades to CRITICAL if the undocumented module handles security, data access, or external integrations)

**Example**:
```
[WARNING] undocumented: scripts/ directory not mentioned in architecture docs
  Documented: No mention of scripts/ in any architecture document
  Actual: scripts/ contains 12 files including database migration runners, seed scripts,
         and a deployment automation script (deploy.sh) that SSH-es into production
  Impact: Critical operational scripts have no architectural oversight; deployment process undocumented
  Recommendation: Add a "Scripts & Tooling" section to ARCHITECTURE.md documenting purpose and usage
```

---

## Contradictory

**Description**: Two or more architecture documents make conflicting claims about the same aspect of the system. One doc says X, another says Y, and they cannot both be true.

**How to detect**:
- Parse claims from all architecture docs
- Cross-reference claims about the same module, boundary, technology, or pattern
- Flag when ARCHITECTURE.md and README.md describe different structures
- Check ADRs against each other (especially superseded vs. accepted)

**Default severity**: CRITICAL (contradictions actively mislead developers)

**Example**:
```
[CRITICAL] contradictory: ARCHITECTURE.md and README.md disagree on API style
  Documented (ARCHITECTURE.md): "All external communication uses GraphQL via Apollo Server"
  Documented (README.md): "RESTful API built with Express.js"
  Actual: Both REST and GraphQL endpoints exist in the codebase
  Impact: No single source of truth; developers do not know which pattern to follow for new endpoints
  Recommendation: Consolidate architecture documentation into ARCHITECTURE.md as the single authority
```
