# Proposal: Delegation Thresholds + Execution Review Lenses

**Status:** Implemented (2026-07-24) — shipped in the release following v2.12.0; see `CHANGELOG.md` → Unreleased
**Date:** 2026-07-24
**Author:** Leader session (reviewed against `gentle-ai` orchestrator→minion pattern)

Adopt two practices observed in a convergent SDD methodology (`gentle-ai` / `sdd-orchestrator`) that AKILI-SPECS currently lacks: **quantified inline-vs-delegate thresholds** for the orchestrating agent, and **concrete review lenses (4R)** layered onto the execution Reviewer. Both are additive — no existing gate, loop guardrail, or persona contract changes.

## Decision summary

| # | Change | Where it lands | Risk |
|---|--------|----------------|------|
| 1 | Delegation Thresholds rule block | `.claude/templates/leader.md`, `/akili-execute`, `/akili-specify`, `/akili-constitution`, `/akili-audit` | Low — codifies existing instinct as numbers |
| 2 | 4R review lenses (readability, reliability, resilience, risk) | `.claude/templates/reviewer.md`, `/akili-execute` Step 2.3, `/akili-validate` | Low–medium — widens Reviewer scope; mitigated by keeping spec-conformance as the only blocking gate by default |

## 1. Delegation Thresholds

### Problem

The Leader triad in `/akili-execute` always delegates, but the methodology gives no numeric guidance for the orchestrator's *own* work in research-heavy commands (`/akili-constitution`, `/akili-specify`, `/akili-audit`). Today the orchestrating agent reads everything inline, polluting its context — exactly the "mega agente leyendo todo" anti-pattern.

### Proposed rule block

Add a shared **Delegation Thresholds** section (single source of truth in `.claude/templates/leader.md`, referenced — not copied — by the commands):

| Situation | Action |
|-----------|--------|
| 1 file, quick check, `git status`, puntual verification | Inline — do it yourself |
| Research requires reading **4+ files** | Spawn a scout/Explore subagent with fresh context; consume its conclusions, not the file dumps |
| Writing **2+ non-trivial files** | Spawn an Implementer (already the rule inside `/akili-execute`; now explicit everywhere) |
| Tests/builds | Subagent (`/akili-test` already complies) |
| Review of a diff/PR | Fresh-context Reviewer, diff-only input (already the rule; restated here for completeness) |
| Parallel writers | Only for fully independent tasks; isolated worktrees if the tool supports them (existing Step 1.4 rule, unchanged) |

### Rationale

- Cheap, actionable heuristic: the agent doesn't have to judge "is my context getting big?" — it counts files.
- CodeGraph note: in codegraph-enabled projects, a `codegraph_context`/`codegraph_search` lookup does **not** count toward the 4-file threshold — that is precisely what the graph is for. The threshold counts full-file reads.

## 2. Execution Review Lenses (4R)

### Problem

The execution Reviewer audits **spec conformance** only. That is stronger than a generic reviewer on traceability, but mono-lens: a diff can pass spec conformance while being unreadable, fragile, or risky. `judgment-day` covers multi-perspective review, but only at design time (`/akili-specify`), not at execution time.

### Proposed design

Two modes, selected by the existing **effort dial** — no new configuration surface:

| Mode | When | Mechanics |
|------|------|-----------|
| **Lens checklist** (default) | Effort `low`/`medium`/`high` | The single Reviewer's brief adds a 4R checklist — readability, reliability, resilience, risk — reported as advisory findings. **Spec conformance remains the only PASS/FAIL gate.** 4R findings that are not spec violations go to `execution.md` as `ADVISORY`, never trigger a rework attempt |
| **Parallel lens reviewers** | Effort `xhigh`/`max`, or task tagged security/migration/data-loss | Spawn 2–4 lens-scoped Reviewers in parallel (each gets the diff + one lens). Any lens may return FAIL; the Leader adjudicates whether a lens FAIL is in-scope for the task before consuming a rework attempt |

### Guardrails (why this won't bloat the loop)

- Advisory findings never consume rework attempts — the 3-attempt ceiling still binds to spec conformance only.
- Parallel mode is opt-in via the effort dial, which the Leader already sets per task; no default token-cost increase.
- The Reviewer stays read-only and diff-only; lenses change *what it looks for*, not *what it receives*.

## Out of scope

- No change to `judgment-day` (design-time review is already multi-perspective).
- No change to the rework loop structure, FATAL_FAIL, or Pivot Protocol.
- No new agent personas — lenses are briefs, not files.

## Implementation checklist

- [x] Add **Delegation Thresholds** section to `.claude/templates/leader.md` (source of truth).
- [x] Reference the thresholds from `/akili-execute` (Multi-Agent Triad section), `/akili-specify`, `/akili-constitution`, `/akili-audit` (research steps).
- [x] Add 4R lens checklist + `ADVISORY` output contract to `.claude/templates/reviewer.md`.
- [x] Update `/akili-execute` Step 2.3 with the two-mode lens table and effort-dial trigger.
- [x] Update `/akili-validate` to include 4R advisory reporting in its final audit (Phase 5 sweep + report section 7).
- [x] `CHANGELOG.md` → `Unreleased` entry (methodology change → next release is **minor**).
- [ ] Smoke: run `/akili-execute` on a sample spec and confirm ADVISORY findings land in `execution.md` without consuming attempts (pending first real-project run).

## Next step

Live-fire smoke on the next real `/akili-execute` run, then release as part of the next **minor** version.
