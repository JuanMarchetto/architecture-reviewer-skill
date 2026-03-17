# Architecture Reviewer

Your code drifted from your architecture. This skill tells you exactly where.

**Architecture drift detection for AI coding assistants.** Compares your architecture documentation against actual code -- finds boundary violations, undocumented modules, responsibility creep, and stale design docs. Every drift item includes severity, impact, and a specific fix.

## Install

```
/plugin marketplace add JuanMarchetto/agent-skills
/plugin install architecture-reviewer@agent-skills
```

Or via [skills.sh](https://skills.sh):
```bash
npx skills add JuanMarchetto/architecture-reviewer-skill
```

Or manually:
```bash
git clone https://github.com/JuanMarchetto/architecture-reviewer-skill.git
cp -r architecture-reviewer-skill ~/.claude/skills/architecture-reviewer
```

## How It Works

![architecture-reviewer demo](demo/demo.gif)

```
ARCHITECTURE.md + Code  -->  Compare  -->  Drift Report
  (what was designed)      (what was built)   (where they diverge)
```

1. Finds your architecture docs (`ARCHITECTURE.md`, ADRs, design docs)
2. Scans your codebase (directory structure, imports, patterns, technologies)
3. Compares documented design against actual implementation
4. Produces a drift report with severity, impact, and recommendations

No architecture docs yet? `/arch-init` generates one from your code.

## Example

```
Architecture Drift Report -- my-api

Summary:
  Docs found: ARCHITECTURE.md, docs/adr/001-auth-strategy.md
  Declared modules: 5 | Actual modules: 7 (+2 undocumented)
  Drift: 1 critical, 3 warning, 2 info
  Alignment: 72%

[CRITICAL] boundary: Auth module imports from billing directly
  Documented: Auth -> User -> Billing (indirect)
  Actual: Auth -> Billing (direct import at src/auth/verify.ts:14)
  Impact: Violates declared dependency boundary, creates circular risk
  Recommendation: Route through User service as documented

[WARNING] responsibility: Utils module grew to 2,400 lines
  Documented: "Shared utility functions" (expected: small)
  Actual: 47 functions, 2,400 lines, handles logging + validation + formatting
  Recommendation: Split into logging/, validation/, formatting/ per original intent

[WARNING] technology: REST endpoints converted to tRPC without doc update
  Documented: "RESTful API with Express"
  Actual: tRPC router in src/api/router.ts
  Recommendation: Update ARCHITECTURE.md technology section

[WARNING] dependency: payments/ and notifications/ modules not in architecture docs
  Documented: 5 modules (auth, user, billing, api, db)
  Actual: 7 modules (+ payments, notifications)
  Recommendation: Document new modules or consolidate into existing ones

[INFO] naming: "services/" renamed to "modules/"
  Documented: src/services/
  Actual: src/modules/
  Recommendation: Update ARCHITECTURE.md paths

[INFO] scale: Database module tripled in size
  Documented: "Thin data access layer"
  Actual: 1,200 lines across 18 files, includes caching and migrations
  Recommendation: Update docs to reflect current scope or extract caching
```

## Commands

| Command | What it does |
|---------|-------------|
| `/review-arch` | Full drift audit with detailed report |
| `/arch-diff` | Quick summary (counts by severity) |
| `/arch-init` | Generate ARCHITECTURE.md from current code |

### /review-arch

Full architecture drift audit. Finds all architecture documents, scans the entire codebase, compares every documented claim against reality, and produces a detailed report with file:line references.

Optional flags:
- `/review-arch --deep <module>` -- deep-dive into a specific module
- `/review-arch --boundaries-only` -- only check boundary violations (fastest)
- `/review-arch --suggest-fixes` -- include code-level fix suggestions

### /arch-diff

Quick check. Samples key boundaries, counts drift items by severity, shows the top 5 issues in one line each. Takes seconds instead of minutes. Always ends with a prompt to run `/review-arch` for the full report.

### /arch-init

Scans your codebase and generates an ARCHITECTURE.md draft. Shows it for your approval before saving. Detects modules, dependencies, patterns, and technology stack. Useful for projects that never had architecture documentation.

## What It Detects

| Drift Type | Example | Severity |
|-----------|---------|----------|
| Boundary violations | Module imports across declared boundaries | Critical |
| Dependency drift | Undocumented module dependencies | Warning |
| Responsibility drift | Module does more than documented | Warning |
| Pattern drift | Docs say MVC, code is different | Warning |
| Technology drift | Different tech than documented | Warning |
| Scale drift | Module grew 10x beyond scope | Info |
| Naming drift | Files/dirs renamed without doc update | Info |

## The Self-Improving AI Trio

```
learn-by-mistake        -->  Remembers every error
post-run-analysis       -->  Analyzes every run
architecture-reviewer   -->  Catches design drift

Three skills, one philosophy: continuous improvement.
```

[learn-by-mistake](https://github.com/JuanMarchetto/learn-by-mistake-skill) turns errors into permanent lessons. [post-run-analysis](https://github.com/JuanMarchetto/post-run-analysis-skill) reviews what happened after each session. Architecture Reviewer catches the slow drift between what you designed and what you built. Together, they cover mistakes, process, and structure.

## File Structure

```
architecture-reviewer-skill/
  .claude-plugin/
    plugin.json          # Skill metadata
  commands/
    review-arch.md       # /review-arch -- full drift audit
    arch-diff.md         # /arch-diff -- quick summary
    arch-init.md         # /arch-init -- generate ARCHITECTURE.md
  SKILL.md               # Core skill instructions
  LICENSE
  README.md
```

## Requirements

- **Any AI coding assistant** that supports SKILL.md
- **No external dependencies** -- pure markdown, no installs, no build step
- Works best when your project has an `ARCHITECTURE.md` or equivalent docs
- No docs? Use `/arch-init` to generate one

## License

[MIT](LICENSE)
