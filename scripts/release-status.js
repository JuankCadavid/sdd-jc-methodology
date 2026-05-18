#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..");
const PACKAGE_PATH = path.join(ROOT, "package.json");
const CHANGELOG_PATH = path.join(ROOT, "CHANGELOG.md");
const RELEASES_DIR = path.join(ROOT, "releases");
const REGISTRY = "https://registry.npmjs.org/";

function run(command, args) {
  return execFileSync(command, args, {
    cwd: ROOT,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();
}

function tryRun(command, args) {
  try {
    return { ok: true, output: run(command, args) };
  } catch (error) {
    return {
      ok: false,
      output: error.stderr ? String(error.stderr).trim() : error.message,
    };
  }
}

function hasChangelogSection(version) {
  const changelog = fs.readFileSync(CHANGELOG_PATH, "utf8");
  return changelog.includes(`## [${version}]`);
}

function hasReleaseNotes(version) {
  return fs.existsSync(path.join(RELEASES_DIR, `v${version}.md`));
}

function hasRemoteTag(version) {
  const tag = `v${version}`;
  const result = tryRun("git", ["ls-remote", "--tags", "origin", `refs/tags/${tag}`]);
  return result.ok && result.output.length > 0;
}

function hasLocalTag(version) {
  const tag = `refs/tags/v${version}`;
  return tryRun("git", ["rev-parse", "--verify", tag]).ok;
}

function getGitHubRelease(version) {
  const tag = `v${version}`;
  const result = tryRun("gh", [
    "release",
    "view",
    tag,
    "--repo",
    getGitHubRepo(),
    "--json",
    "tagName,url",
  ]);
  if (!result.ok) return { ok: false };
  return { ok: true, release: JSON.parse(result.output) };
}

function getGitHubRepo() {
  const pkg = JSON.parse(fs.readFileSync(PACKAGE_PATH, "utf8"));
  const repositoryUrl = typeof pkg.repository === "string" ? pkg.repository : pkg.repository.url;
  const match = repositoryUrl.match(/github\.com[:/]([^/]+\/[^/.]+)(?:\.git)?$/);
  if (!match) {
    throw new Error(`Unable to derive GitHub repo from repository URL: ${repositoryUrl}`);
  }
  return match[1];
}

function getNpmMetadata(packageName) {
  const result = tryRun("npm", [
    "view",
    packageName,
    "versions",
    "version",
    "dist-tags",
    "--json",
    `--registry=${REGISTRY}`,
  ]);
  if (!result.ok) return { ok: false, error: result.output };

  const metadata = JSON.parse(result.output);
  const versions = Array.isArray(metadata.versions)
    ? metadata.versions
    : metadata.version
      ? [metadata.version]
      : [];

  return {
    ok: true,
    versions,
    latest: metadata.version,
    distTags: metadata["dist-tags"] || {},
  };
}

function getNpmUser() {
  const result = tryRun("npm", ["whoami", `--registry=${REGISTRY}`]);
  return result.ok ? result.output : "not authenticated";
}

function printStatus(label, ok, detail) {
  const status = ok ? "OK" : "MISSING";
  console.log(`  ${status} ${label}${detail ? ` - ${detail}` : ""}`);
}

function checkVersion(version, published) {
  const checks = {
    changelog: hasChangelogSection(version),
    notes: hasReleaseNotes(version),
    localTag: hasLocalTag(version),
    remoteTag: hasRemoteTag(version),
    githubRelease: getGitHubRelease(version),
  };

  console.log(`\n${published ? "Published" : "Current"} version ${version}:`);
  printStatus("CHANGELOG section", checks.changelog);
  printStatus("release notes", checks.notes, `releases/v${version}.md`);
  printStatus("local tag", checks.localTag, `v${version}`);
  printStatus("remote tag", checks.remoteTag, `v${version}`);
  printStatus(
    "GitHub Release",
    checks.githubRelease.ok,
    checks.githubRelease.ok ? checks.githubRelease.release.url : `v${version}`
  );

  if (!published) return [];

  const failures = [];
  if (!checks.changelog) failures.push(`${version}: missing CHANGELOG section`);
  if (!checks.notes) failures.push(`${version}: missing release notes`);
  if (!checks.remoteTag) failures.push(`${version}: missing remote tag`);
  if (!checks.githubRelease.ok) failures.push(`${version}: missing GitHub Release`);
  return failures;
}

function main() {
  const pkg = JSON.parse(fs.readFileSync(PACKAGE_PATH, "utf8"));
  const npmMetadata = getNpmMetadata(pkg.name);
  if (!npmMetadata.ok) {
    console.error(`ERROR: Unable to read npm metadata for ${pkg.name}.`);
    console.error(npmMetadata.error);
    process.exit(1);
  }

  const gitStatus = tryRun("git", ["status", "--short"]);
  const currentPublished = npmMetadata.versions.includes(pkg.version);
  const failures = [];

  console.log(`Release status for ${pkg.name}`);
  console.log(`Local package version: ${pkg.version}`);
  console.log(`npm latest: ${npmMetadata.distTags.latest || npmMetadata.latest || "unknown"}`);
  console.log(`npm versions: ${npmMetadata.versions.join(", ") || "none"}`);
  console.log(`npm auth: ${getNpmUser()}`);
  console.log(`Working tree: ${gitStatus.ok && !gitStatus.output ? "clean" : "dirty"}`);

  failures.push(...checkVersion(pkg.version, currentPublished));

  const publishedVersions = npmMetadata.versions.filter((version) => version !== pkg.version);
  for (const version of publishedVersions) {
    failures.push(...checkVersion(version, true));
  }

  if (!currentPublished) {
    console.log(`\nPENDING: ${pkg.version} is not published to npm yet.`);
    console.log("After publishing, create/push the tag and GitHub Release, then run this check again.");
  }

  if (failures.length > 0) {
    console.log("\nRelease drift detected:");
    failures.forEach((failure) => console.log(`  - ${failure}`));
    process.exit(1);
  }

  console.log("\nNo published release drift detected.");
}

main();
