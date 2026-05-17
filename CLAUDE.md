# Claude Guidance

This repository packages the SDD JC methodology for reuse in Claude Code and OpenCode.

## Start Here

- Read `AGENTS.md` for repository-wide development and release rules.
- Read `README.md` for installation and methodology usage.
- Read `docs/release-checklist.md` before preparing or publishing a package release.

## Methodology Files

- Commands live in `.claude/commands/`.
- Skills live in `.claude/skills/`.
- The installer lives in `bin/sdd-jc.js`.
- Helper scripts live in `scripts/`.

## Release Discipline

Every user-facing methodology or installer change should be reflected in `CHANGELOG.md` under `Unreleased`.

Do not claim the npm package is updated until a release version has been prepared and published. Use:

```bash
npm run release:patch
npm run verify:cli
npm run pack:dry-run
```

Choose `release:minor` for new commands or install targets and `release:major` for breaking changes.

## Safety

- Never commit npm tokens, service account keys, `.npmrc`, or local MCP secrets.
- Never commit generated `.tgz` package files.
- Installer changes must preserve skip-by-default behavior unless the user passes `--force`.
