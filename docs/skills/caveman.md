# `caveman`

**Author:** Julius Brussee — [github.com/juliusbrussee/caveman](https://github.com/juliusbrussee/caveman) (MIT)
**Adapted for AKILI-SPECS by:** Juan Carlos Cadavid — [jcadavid.com](https://jcadavid.com)

## Purpose

Ultra-compressed communication style (~65% fewer output tokens in upstream benchmarks): drop filler, keep substance, fragments OK, code and errors byte-for-byte exact. In AKILI it is the preventive tactic against output-token **MUDA** — scoped strictly to *transient* agent output, the chatter nobody rereads.

## The Scope Contract (the AKILI adaptation)

> `cognitive-doc-design` owns artifacts; `caveman` owns transient agent output.

| Output | Caveman |
|---|---|
| Inter-agent messages (Leader ↔ Implementer/Reviewer/Tester) | `full` |
| User-visible progress narration mid-run | `lite` |
| Persistent artifacts (PRD, TRD, specs, `execution.md`, `test-report.md`, PRs, Kaizen log) | off |
| HITL approval gates, Pivot blockers, `PRODUCT_BUG` escalations | off |
| Verbatim evidence: error strings, Reviewer FAIL reports, test output, code | never touched |

Upstream Auto-Clarity is preserved and extended: security warnings, irreversible-action confirmations, and every HITL pause drop compression automatically. When in doubt whether output is transient or persistent, treat it as persistent (off).

## Use When

- `/akili-execute` — automatic: inter-agent briefs/reports/feedback relays at `full`, progress lines at `lite`; the Structured Feedback rule wins (Reviewer reports pass unchanged).
- `/akili-test` — automatic: Leader→Tester slices and Tester structured reports at `full`.
- The user asks for token efficiency ("less tokens", "be brief", "caveman mode") in any context — respecting the Scope Contract.

## Best Paired Commands

- `/akili-execute`, `/akili-test` — where the multi-agent fan-out burns most output tokens.
- `kaizen` — compressed inter-agent chatter is measurable MUDA reduction; retrospectives may cite the savings.

## Source

- `../../.claude/skills/caveman/SKILL.md`
- Upstream: https://github.com/juliusbrussee/caveman
