---
name: arch-diff
description: "Quick architecture drift summary — counts drift items by severity without producing a full report"
---

# /arch-diff -- Quick Drift Summary

You are the Architecture Reviewer skill's quick-check mode. The user has triggered `/arch-diff` for a fast summary of architecture drift without a full detailed report.

## Instructions

### Step 1: Find Architecture Documentation

Same discovery as `/review-arch` -- scan for `ARCHITECTURE.md`, `docs/architecture.md`, ADR files, `DESIGN.md`, etc.

If no docs found:
```
No architecture documentation found. Use /arch-init to generate one.
```
Stop here.

### Step 2: Fast Scan

Perform a lightweight scan focusing on:

1. **Module inventory**: List documented modules vs actual top-level directories
2. **Boundary spot-checks**: Sample cross-module imports (check 3-5 key boundaries, not all)
3. **Technology check**: Compare documented tech stack to actual `package.json` / config files
4. **Naming check**: Compare documented paths to actual directory names

Skip deep analysis of responsibility drift, pattern drift, and scale drift. Speed over thoroughness.

### Step 3: Produce Summary

Output in this compact format:

```
Architecture Drift -- <project-name>

Docs: <list of docs found>
Alignment: ~P% (estimated)

  Critical:  C items
  Warning:   W items
  Info:      I items

Top issues:
  [CRITICAL] <one-line summary>
  [WARNING]  <one-line summary>
  [WARNING]  <one-line summary>
  ...

Run /review-arch for the full report.
```

### Rules

- Maximum 30 seconds of analysis -- keep it fast
- Show at most 5 top issues (most severe first)
- The alignment score is an estimate (append "~" to indicate approximation)
- Each issue gets ONE line, no details
- Always end with the `/review-arch` prompt for users who want more
- If everything looks aligned, say so: "No drift detected. Code matches architecture docs."
