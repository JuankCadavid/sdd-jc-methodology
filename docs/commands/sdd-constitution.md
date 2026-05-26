# `/sdd-constitution`

Establish or strengthen the project-wide JCSPECS foundation and scaffold the multi-agent harness.

## Usage

```text
/sdd-constitution
```

## Use When

- Starting a new repository.
- Existing project docs are missing, stale, or inconsistent.
- A major product pivot changed the project's baseline assumptions.
- Agents need stable `CLAUDE.md` and `AGENTS.md` guidance.
- The project does not yet have a `.agents/` directory powering `/sdd-execute`.

## Behavior

The command classifies the repository into one of three modes and adjusts its behavior accordingly.

| Mode | Meaning | Constitution Behavior | `.agents/` Behavior |
|---|---|---|---|
| Brand-new (Seed Setup) | No code, no SDD docs | Draft baseline from user intent, chosen stack, assumptions, open questions | Copy default Leader / Implementer / Reviewer personas verbatim |
| Legacy (Discovery Setup) | Real code exists, no SDD baseline | Inspect repository reality (CodeGraph preferred) before drafting; synthesize from evidence | Copy defaults then customize with detected stack, design tokens, lint and test commands |
| Active SDD (Safe Update) | SDD baseline already present, custom `.agents/` may exist | Upgrade weak sections, fill missing files non-destructively | Never overwrite existing personas — only append minimal upgrade blocks |

For Legacy and Active-SDD modes, if `.codegraph/` exists CodeGraph is used for semantic exploration; if it is missing and the CLI is available, the agent asks before initializing it.

## Outputs

Creates or enhances:

- `docs/prd.md`
- `docs/system-design/design.md`
- `docs/detailed-design/detailed-design.md`
- `docs/specs/general-setup/requirements.md`
- `docs/specs/general-setup/design.md`
- `docs/specs/general-setup/task.md`
- `CLAUDE.md`
- `AGENTS.md`
- `.agents/leader.md`
- `.agents/implementer.md`
- `.agents/reviewer.md`

## Multi-Agent Harness Scaffolding

`.agents/` is the source of truth for the multi-agent loop that `/sdd-execute` runs (Leader → Implementer → Reviewer). The constitution seeds it from the packaged defaults shipped by the installer:

- Claude Code: `~/.claude/sdd-jc/templates/{leader,implementer,reviewer}.md`
- OpenCode: `~/.config/opencode/sdd-jc/templates/{leader,implementer,reviewer}.md`
- Antigravity: `~/.gemini/config/sdd-jc/templates/{leader,implementer,reviewer}.md`

If packaged templates are not available, the constitution drafts equivalent personas inline using the structure documented in `/sdd-execute` (rework loop, PASS/FAIL output contract, JCSPECS commit standard, Pivot Protocol).

The `.agents/` directory is tool-agnostic: pure Markdown + YAML frontmatter, resolved relative to the active workspace, and used by Claude Code, OpenCode, and Google Antigravity (`invoke_subagent`).

## Skills Commonly Used

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
/sdd-propose <change-name-or-spec-path>
```

For a small, obvious change, you may start with:

```text
/sdd-specify <spec-path>
```
