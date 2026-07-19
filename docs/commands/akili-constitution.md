# `/akili-constitution`

Establish or strengthen the project-wide AKILI foundation and scaffold the multi-agent harness.

## Usage

```text
/akili-constitution
```

## Use When

- Starting a new repository.
- Existing project docs are missing, stale, or inconsistent.
- A major product pivot changed the project's baseline assumptions.
- Agents need stable `CLAUDE.md` and `AGENTS.md` guidance.
- The project does not yet have a `.agents/` directory powering `/akili-execute`.

## Behavior

The command classifies the repository into one of three modes and adjusts its behavior accordingly.

| Mode | Meaning | Constitution Behavior | `.agents/` Behavior |
|---|---|---|---|
| Brand-new (Seed Setup) | No code, no AKILI-SPECS docs | Draft baseline from user intent, chosen stack, assumptions, open questions | Copy default Leader / Implementer / Reviewer personas verbatim |
| Legacy (Discovery Setup) | Real code exists, no AKILI-SPECS baseline | Inspect repository reality (CodeGraph preferred) before drafting; synthesize from evidence | Copy defaults then customize with detected stack, design tokens, lint and test commands |
| Active AKILI-SPECS (Safe Update) | AKILI-SPECS baseline already present, custom `.agents/` may exist | Upgrade weak sections, fill missing files non-destructively | Never overwrite existing personas — only append minimal upgrade blocks |

For Legacy and Active-AKILI-SPECS modes, if `.codegraph/` exists CodeGraph is used for semantic exploration; if it is missing and the CLI is available, the agent asks before initializing it.

## Outputs

Creates or enhances:

- `docs/prd.md`
- `docs/ux-ui/design.md`
- `docs/trd/trd.md`
- `docs/specs/general-setup/requirements.md`
- `docs/specs/general-setup/design.md`
- `docs/specs/general-setup/task.md`
- `CLAUDE.md`
- `AGENTS.md`
- `.agents/leader.md`
- `.agents/implementer.md`
- `.agents/reviewer.md`
- `.agents/tester.md`

Projects created before the TRD naming may still have `docs/system-design/design.md` (UX/UI blueprint) and `docs/detailed-design/detailed-design.md` (technical blueprint). The constitution treats those as the existing UX/UI Design document and TRD, and in Active-AKILI-SPECS mode offers to migrate them to `docs/ux-ui/design.md` and `docs/trd/trd.md`.

The root guides also carry a `## Module Guides` index: modules whose conventions diverge from the root get a thin child `CLAUDE.md`/`AGENTS.md`, and every child guide must be referenced from that index. `/akili-execute` records new-module impact notes and `/akili-archive` syncs the guides and recommends a CodeGraph re-index.

## Multi-Agent Harness Scaffolding

`.agents/` is the source of truth for the multi-agent harness: the loop that `/akili-execute` runs (Leader → Implementer → Reviewer) and the Leader → Tester(s) harness that `/akili-test` runs. The constitution seeds it from the packaged defaults shipped by the installer:

- Claude Code: `~/.claude/akili/templates/{leader,implementer,reviewer,tester}.md`
- OpenCode: `~/.config/opencode/akili/templates/{leader,implementer,reviewer,tester}.md`
- Antigravity: `~/.gemini/config/akili/templates/{leader,implementer,reviewer,tester}.md`

If packaged templates are not available, the constitution drafts equivalent personas inline using the structure documented in `/akili-execute` (rework loop, PASS/FAIL output contract, AKILI commit standard, Pivot Protocol).

The `.agents/` directory is tool-agnostic: pure Markdown + YAML frontmatter, resolved relative to the active workspace, and used by Claude Code, OpenCode, and Google Antigravity (`invoke_subagent`).

## Model Routing Scaffolding

Step 7C adds or upgrades a `## Model Routing` section in the project's root `AGENTS.md` and `CLAUDE.md`: a capability-tier registry that maps each AKILI-SPECS phase to a model **per tool** (Claude Code and OpenCode). It is guidance only — no `model:` frontmatter is added and the installer is unchanged. The registry enforces **author ≠ auditor** (the Reviewer runs on a different model than the Implementer) and, in Active-AKILI-SPECS mode, is non-destructive: an existing customized registry is preserved and only gaps are filled. See [Model Routing](../model-routing.md) for the tiers and the default registry.

- `product-manager-toolkit`
- `ui-ux-pro-max`
- `frontend-design`
- `stitch-design`
- `nestjs-expert`
- `api-design-principles`
- `error-handling-patterns`
- `aws-serverless`
- `shadcn-ui`
- `tailwind-design-system`
- `vercel-react-best-practices`

## Next Step

After approving the baseline and confirming `.agents/` is in place, start a change:

```text
/akili-propose <change-name-or-spec-path>
```

For a small, obvious change, you may start with:

```text
/akili-specify <spec-path>
```
