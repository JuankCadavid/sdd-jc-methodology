# Release Checklist

Use this checklist before publishing `sdd-jc-methodology`.

## Preflight

- [ ] Confirm this update should be published now, not only committed to the repository.
- [ ] Confirm all intended repo changes are committed before running the release script.
- [ ] Confirm `CHANGELOG.md` has meaningful notes under `Unreleased`.
- [ ] Confirm `package.json` version matches the release version.
- [ ] Confirm `CHANGELOG.md` has a dated section for the release.
- [ ] Confirm `releases/vX.Y.Z.md` exists.
- [ ] Confirm npm authentication with `npm whoami --registry=https://registry.npmjs.org/`.
- [ ] Confirm the current npm user is a maintainer for `sdd-jc-methodology`.
- [ ] Confirm package name is available or configured for the intended registry.
- [ ] Confirm license and publishing policy.
- [ ] Confirm no secrets, service account keys, or local config files are included.

## Release Policy

- Repository updates and npm updates are controlled separately.
- Package-affecting repository changes require changelog notes before release preparation.
- npm updates require a version bump, release notes, verification, release commit, publish, and smoke test.
- Never publish from uncommitted changes.
- Never claim npm is updated until publish and post-publish smoke test both succeed.
- If publish fails, keep the release commit and fix the blocker. Do not create a replacement version unless the failed version was actually published.

## Verify Locally

Prepare a version bump from committed changes:

```bash
npm run release:patch
```

Use `release:minor` for new commands or workflow additions and `release:major` for breaking changes.

Then verify:

```bash
npm run verify:cli
node bin/sdd-jc.js install --tool both --dry-run
npm run pack:dry-run
git diff --check
```

## Verify Packed Tarball

```bash
npm pack
npm install -g ./sdd-jc-methodology-<version>.tgz
sdd-jc install --tool both --dry-run
sdd-jc doctor --tool claude
```

Remove the generated tarball after testing unless it is being attached to a release.

## Publish

For public npm publishing:

```bash
npm whoami --registry=https://registry.npmjs.org/
npm publish --access public --registry=https://registry.npmjs.org/
```

If npm requires two-factor authentication, pass the current one-time password:

```bash
npm publish --access public --registry=https://registry.npmjs.org/ --otp=<code>
```

For private registry publishing, configure the registry first and publish using the registry's required access mode.

## Post-Publish Smoke Test

```bash
pnpm dlx sdd-jc-methodology@<version> list
pnpm dlx sdd-jc-methodology@<version> install --tool both --dry-run
npm view sdd-jc-methodology version --registry=https://registry.npmjs.org/
```

## GitHub Release

- [ ] Tag the release, for example `v0.2.0`.
- [ ] Create a GitHub release using `releases/v0.2.0.md`.
- [ ] Include publish/install instructions in the release body.
