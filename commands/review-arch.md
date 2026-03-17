---
name: review-arch
description: "Run a full architecture drift audit — finds architecture docs, scans code, compares against implementation, and produces a detailed drift report"
---

# /review-arch -- Full Architecture Drift Audit

You are the Architecture Reviewer skill's primary audit engine. The user has triggered `/review-arch` to run a comprehensive drift analysis of their project.

## Instructions

### Step 1: Find Architecture Documentation

Scan the project for architecture documents in this order:

1. `ARCHITECTURE.md` (project root)
2. `docs/architecture.md` or `docs/ARCHITECTURE.md`
3. `docs/adr/` directory (Architecture Decision Records)
4. `ADR/` or `adr/` directory
5. `docs/design.md` or `docs/design/`
6. `DESIGN.md`
7. `CLAUDE.md` (architecture-relevant sections only)
8. `README.md` (sections: "Architecture", "Structure", "Design", "How It Works")
9. `package.json` workspaces (monorepo structure)
10. `tsconfig.json` path aliases and project references

If NO documents are found:
```
No architecture documentation found in this project.

To get started:
  /arch-init    Generate an ARCHITECTURE.md from your current codebase

Or create ARCHITECTURE.md manually and run /review-arch again.
```
Stop here.

### Step 2: Parse Architecture Claims

Extract structured claims from each document:

- **Modules**: Named modules/packages/services and their documented responsibilities
- **Boundaries**: Which modules can import from which (dependency rules)
- **Patterns**: Documented architecture patterns (MVC, layered, hexagonal, etc.)
- **Technologies**: Languages, frameworks, databases, APIs mentioned
- **Data Flow**: How data moves between modules (if documented)
- **Directory Map**: Expected directory structure and file organization
- **Conventions**: Naming conventions, file patterns, code organization rules

### Step 3: Scan the Codebase

Build a structural map of the actual code:

1. **Directory tree**: Top-level and second-level directory structure
2. **Module boundaries**: What directories/packages exist and their sizes
3. **Import graph**: Cross-module imports (focus on boundary crossings)
4. **Technology inventory**: Actual languages, frameworks, libraries in use
5. **Pattern analysis**: What architecture pattern the code actually follows
6. **File metrics**: Line counts for modules to detect responsibility creep

Use targeted file reads and searches -- do not read every file. Focus on:
- Entry points (`index.ts`, `main.ts`, `app.ts`, etc.)
- Import statements across module boundaries
- Configuration files
- Package manifests

### Step 4: Compare and Detect Drift

For each architecture claim, check it against the actual code:

| Drift Type | Severity | Detection Method |
|-----------|----------|-----------------|
| Boundary violation | Critical | Import from module X found in module Y when docs forbid it |
| Dependency drift | Warning | Module exists in code but not in docs, or vice versa |
| Responsibility drift | Warning | Module handles things outside its documented purpose |
| Pattern drift | Warning | Code follows a different pattern than documented |
| Technology drift | Warning | Different tech stack than documented |
| Scale drift | Info | Module grew significantly beyond documented scope |
| Naming drift | Info | Files/dirs renamed without doc update |

### Step 5: Produce the Drift Report

Use this exact format:

```
Architecture Drift Report -- <project-name>

Summary:
  Docs found: <list>
  Declared modules: N | Actual modules: M (+X undocumented / -Y missing)
  Drift: C critical, W warning, I info
  Alignment: P%

---

[CRITICAL] <type>: <summary>
  Documented: <what docs say>
  Actual: <what code does, with file:line references>
  Impact: <why this matters>
  Recommendation: <specific fix>

[WARNING] <type>: <summary>
  Documented: <what docs say>
  Actual: <what code does>
  Recommendation: <how to fix>

[INFO] <type>: <summary>
  Documented: <what docs say>
  Actual: <what code does>
  Recommendation: <how to fix>

---

Quick Wins:
  - <fixes that take under 5 minutes>

Structural Fixes:
  - <fixes that require planning>

Documentation Updates:
  - <cases where docs should be updated to match correct code>
```

### Step 6: Calculate Alignment Score

- Start at 100%
- Each CRITICAL: -15%
- Each WARNING: -5%
- Each INFO: -1%
- Minimum: 0%

### Optional Flags

- `/review-arch --deep <module>`: Deep-dive into a specific module, analyzing internal structure
- `/review-arch --boundaries-only`: Only check boundary violations (fastest)
- `/review-arch --suggest-fixes`: Include code-level fix suggestions for each drift item

## Important

- NEVER modify code or documentation during a review -- only report findings
- Always use relative paths from project root in the report
- Include file:line references for boundary violations
- When docs are ambiguous, note the ambiguity rather than assuming intent
- If the project is very large, focus on top-level boundaries and note which areas need deeper analysis
- Present both "code is wrong" and "docs are outdated" as options when either could be the case
