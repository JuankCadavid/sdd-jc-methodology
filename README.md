# sdd-jc-methodology

<img src="assets/jc-methodology-badge.png" alt="JC Methodology Badge" width="420">

Portable Claude configuration for the SDD JC methodology.

## Repository Structure

- `.claude/commands/` — custom SDD command prompts
- `.claude/skills/` — required and preferred skills used by the methodology
- `scripts/` — helper scripts referenced by commands (e.g. `gsc_verify.py`)
- `.mcp.json.example` — reference MCP server configuration (e.g. `gsc`)
- `dotfiles/` — environment snapshots for Neovim and tmux

## Contents

- `.claude/commands/`
  - `sdd-constitution.md`
  - `sdd-specify.md`
  - `sdd-execute.md`
  - `sdd-validate.md`
  - `sdd-test.md`
  - `sdd-seo.md`
- `.claude/skills/`
  - `api-design-principles`
  - `aws-serverless`
  - `brainstorming`
  - `error-handling-patterns`
  - `frontend-design`
  - `nestjs-expert`
  - `product-manager-toolkit`
  - `react-doctor`
  - `shadcn-ui`
  - `stitch-design`
  - `systematic-debugging`
  - `tailwind-design-system`
  - `ui-ux-pro-max`
  - `vercel-react-best-practices`

## Install

Copy the repository `.claude/commands` and `.claude/skills` folders into your Claude configuration location.

Typical global install target:

- `~/.claude/commands/`
- `~/.claude/skills/`

Example:

```bash
cp -R .claude/commands/* ~/.claude/commands/
cp -R .claude/skills/* ~/.claude/skills/
```

## Dotfiles

The repository also includes editor and terminal configuration snapshots under `dotfiles/`:

- `dotfiles/.config/nvim/`
- `dotfiles/.tmux/`
- `dotfiles/.tmux.conf`

These are stored as portable references or backup material for the environment used with this methodology.

### Restore Neovim

```bash
mkdir -p ~/.config
cp -R dotfiles/.config/nvim ~/.config/
```

### Restore tmux

```bash
cp dotfiles/.tmux.conf ~/.tmux.conf
cp -R dotfiles/.tmux ~/.tmux
```

If you prefer a lighter restore, keep `~/.tmux.conf` and reinstall plugins separately instead of copying the full plugin snapshot.

## Workflow

Recommended command order:

1. `/sdd-constitution`
2. `/sdd-specify <spec-path>`
3. `/sdd-execute <spec-path>`
4. `/sdd-test <spec-path>`
5. `/sdd-validate <spec-path>`

Use `/sdd-constitution` first in a new repository or when the documentation baseline is incomplete. Use `/sdd-specify` only after the constitutional docs and `docs/specs/general-setup/` templates exist.

### Auxiliary commands

- `/sdd-seo <site-domain>` — SEO setup & audit via Google Search Console. Verifies a domain through DNS TXT using a service account, adds the property to GSC, then audits index coverage, sitemaps, structured data, search analytics, server-side render, and internal linking. Produces `seo-setup-report.md` and `seo-audit-report.md` under `docs/specs/seo/<domain>/`, including a copy-paste implementation prompt for fixing every High-severity finding.

  Dependencies bundled with this repo:

  - `scripts/gsc_verify.py` — Site Verification API helper (token + verify), because the `gsc` MCP only wraps Search Console, not Site Verification.
  - `.mcp.json.example` — reference MCP server entry for `@mikusnuz/gsc-mcp`.

  Setup once per environment:

  1. Enable **Site Verification API** and **Search Console API** in your Google Cloud project.
  2. Create a service account, download its JSON key, store outside the repo.
  3. Install Python deps: `pip install google-auth google-api-python-client`.
  4. Copy the `gsc` block from `.mcp.json.example` into your global `~/.claude.json` (or a project `.mcp.json`) and set `GSC_SERVICE_ACCOUNT_KEY_PATH` to the absolute path of the key.

## Spec Paths

Commands accept a relative path under `docs/specs/`, not only a flat module name.

Examples:

- `loan`
- `enhancements/renewals`
- `admin/user-management`

## Dependencies

Included skills cover the default methodology path, including `ui-ux-pro-max`.

Fallback rule:

- when `ui-ux-pro-max` is unavailable, use `frontend-design` + `stitch-design` for system-design work and `frontend-design` for UI validation/testing support.

## Methodology Contract

- `/sdd-constitution` establishes the project baseline docs and `docs/specs/general-setup/` templates.
- `/sdd-specify` must follow those templates when generating module specs.
- `/sdd-execute` implements tasks from an approved spec path.
- `/sdd-test` validates requirement-to-test traceability.
- `/sdd-validate` audits implementation conformance against the spec and constitutional baseline.
- `/sdd-seo` operates outside the main spec lifecycle: it provisions Google Search Console ownership for a domain and produces a standalone SEO audit under `docs/specs/seo/<domain>/`. Run it any time after deployment; rerun after major content or schema changes.

## Host Assumptions

- The host Claude environment can ask follow-up questions to the user during command execution.
- The host environment can load local skills referenced by the commands.
- Repository-specific build, lint, and test commands should be preferred over hardcoded stack assumptions.

## Notes

- Commands were sourced from the current global Claude command setup.
- Skills were copied with their bundled references and helper assets.
- This repository stores the current methodology baseline so it can be reused or versioned independently.
- Dotfiles are snapshots of the working environment and may include plugin source copies for portability.
