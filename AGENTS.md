# Agent Guidance

This repository packages the SDD JC methodology for Claude Code and OpenCode.

## Repository Purpose

- `.claude/commands/` contains installable SDD command prompts.
- `.claude/skills/` contains installable methodology skills.
- `bin/sdd-jc.js` installs commands, skills, and helper resources into Claude and/or OpenCode config directories.
- `scripts/release.js` prepares controlled npm package releases.
- `docs/release-checklist.md` documents the release process.

## Development Rules

- Keep command prompts readable and tool-agnostic where possible.
- Do not add project-specific assumptions to reusable commands.
- Keep installer behavior safe: skip existing files by default and require `--force` to overwrite.
- Do not commit generated `.tgz` files or `node_modules/`.
- Do not commit service account keys, npm tokens, `.npmrc`, or local MCP config containing secrets.

## Release Rules

Repository changes do not automatically update the npm package. A package update requires a version bump and publish.

Use this flow:

1. Add change notes under `CHANGELOG.md` > `Unreleased`.
2. Commit feature, documentation, or fix changes.
3. Run one of:
   - `npm run release:patch`
   - `npm run release:minor`
   - `npm run release:major`
4. Run verification:
   - `npm run verify:cli`
   - `npm run pack:dry-run`
5. Commit the release version update.
6. Publish explicitly with `npm publish --access public --registry=https://registry.npmjs.org/`.

Use patch for small docs/fixes, minor for new commands or install targets, and major for breaking changes.

## Verification

Before committing package or installer changes, run:

```bash
npm run verify:cli
npm run pack:dry-run
git diff --check
```

When installer behavior changes, also test temporary targets:

```bash
node bin/sdd-jc.js install --tool both --dry-run
node bin/sdd-jc.js doctor --tool both
```
