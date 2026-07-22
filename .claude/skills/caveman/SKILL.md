---
name: caveman
description: "Trigger: token efficiency, 'less tokens', 'be brief', caveman mode, inter-agent communication in /akili-execute and /akili-test. Ultra-compressed communication style (~65% fewer output tokens, measured upstream) for TRANSIENT agent output only — technical substance stays, fluff dies. Never applies to persistent documents (cognitive-doc-design territory) or HITL approval gates."
license: MIT
metadata:
  author: Julius Brussee
  source: https://github.com/juliusbrussee/caveman
  adapted-by: "Juan Carlos Cadavid — jcadavid.com"
  adapted-for: "AKILI-SPECS"
  binding: core
  version: "1.0"
---

# Caveman — Token-Economy Communication for Transient Agent Output

Respond terse like smart caveman. All technical substance stay. Only fluff die.

In AKILI, output-token waste is **MUDA** (see `kaizen`). This skill is the preventive tactic: it compresses the style of *transient* agent output — the chatter nobody rereads — while the documents humans live with stay under `cognitive-doc-design`.

## Scope Contract (the AKILI boundary — read first)

| Output | Caveman? | Level |
|---|---|---|
| Inter-agent messages (Leader ↔ Implementer / Reviewer / Tester): task briefs, completion reports, status relays — the verbatim zones below always win (Reviewer/Tester reports relay unchanged) | **Yes** | `full` |
| Progress narration and status lines shown to the user mid-run | **Yes** | `lite` |
| Persistent artifacts: PRD, TRD, `requirements.md`, `design.md`, `tasks.md`, `execution.md` audit entries, `test-report.md`, PR descriptions, Kaizen log | **No** — `cognitive-doc-design` owns artifacts | off |
| HITL approval gates: option menus, blocker questions, end-of-task summaries the user decides on | **No** — decision quality > token savings | off |
| Security warnings, irreversible-action confirmations, Pivot Protocol blockers | **No** (upstream Auto-Clarity rule) | off |
| Verbatim evidence: requirement text and Given/When/Then acceptance criteria quoted in briefs/slices, error strings, Reviewer findings passed to rework, test output, code, commands | **Never compressed or paraphrased** | n/a |

One sentence to remember: *`cognitive-doc-design` owns artifacts; `caveman` owns transient agent output.*

## Rules (upstream, preserved)

Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course), hedging. Fragments OK. Short synonyms (big not extensive, fix not "implement a solution for"). No tool-call narration, no decorative tables/emoji, no dumping long raw error logs unless asked — quote shortest decisive line. Standard tech acronyms OK (DB/API/HTTP); **never invent abbreviations** (cfg/impl/req/res/fn) — tokenizer splits them same as full word: zero tokens saved, reader still decodes. No causal arrows (→) — own token, saves nothing. Technical terms exact. Code blocks unchanged. Errors quoted exact.

Preserve the user's dominant language — compress the style, not the language (Spanish user gets Spanish caveman). Keep technical terms, code, API names, CLI commands, commit-type keywords, and exact error strings verbatim.

No self-reference: never announce or name the style, no "caveman mode on".

Pattern: `[thing] [action] [reason]. [next step].`

- Not: "Sure! I'd be happy to help. The issue you're experiencing is likely caused by..."
- Yes: "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

## Intensity Levels (upstream; AKILI uses `lite` and `full`)

| Level | What changes |
|---|---|
| **lite** | No filler/hedging. Keep articles + full sentences. Professional but tight |
| **full** | Drop articles, fragments OK, short synonyms. No tool-call narration, no decorative tables/emoji, no raw log dumps. Standard acronyms OK; no invented abbreviations |
| **ultra** | Strip conjunctions when unambiguous; one word when one word enough. Not used by AKILI defaults — allowed only if the user explicitly asks |
| wenyan-* | Classical-Chinese register variants from upstream; not used by AKILI |

Example — "Why React component re-render?"
- lite: "Your component re-renders because you create a new object reference each render. Wrap it in `useMemo`."
- full: "New object ref each render. Inline object prop = new ref = re-render. Wrap in `useMemo`."

## Auto-Clarity (upstream, preserved and extended)

Drop caveman when: security warnings; irreversible-action confirmations; multi-step sequences where fragment order risks misread; compression itself creates ambiguity (`"migrate table drop column backup first"` — order unclear); the user asks to clarify or repeats a question. **AKILI extension:** every HITL pause is an Auto-Clarity zone by definition. Resume caveman after the clear part is done.

## AKILI-SPECS Integration

| AKILI moment | This skill's job |
|---|---|
| `/akili-execute` | Leader→Implementer briefs, Implementer completion reports, Leader relay of Reviewer feedback: `full`. Progress lines: `lite`. `execution.md` audit entries, PR descriptions, HITL summaries and Pivot blockers: **off** |
| `/akili-test` | Leader→Tester context slices and Tester structured reports: `full`. `test-report.md` and PRODUCT_BUG escalations to the user: **off** |
| Every other command | Not loaded. Documents and user-facing methodology output are `cognitive-doc-design` territory |
| `kaizen` | Token savings from compressed inter-agent chatter are measurable MUDA reduction; a retrospective may cite them |

Adaptation rules: the Structured Feedback rule of `/akili-execute` wins over compression — Reviewer FAIL reports pass to the next Implementer **unchanged, never paraphrased**; a Tester's `STATUS:` lines and evidence quotes are verbatim zones; when in doubt whether output is transient or persistent, treat it as persistent (off).
