# `seo-audit`

## Purpose

Provides an expert SEO audit framework: crawlability and indexation, technical foundations (Core Web Vitals, mobile, HTTPS), on-page optimization (titles, metas, headings, images, internal linking), international SEO (hreflang, locale canonicals, locale sitemaps), content quality (E-E-A-T), and a standard finding format.

## Use When

- Auditing, reviewing, or diagnosing SEO issues on a site.
- Rankings or organic traffic dropped and the cause is unknown.
- Reviewing meta tags, structured data, page speed, or indexing issues.
- Running the audit phase of `/sdd-seo`.

## Core Rules

- Findings follow the **Issue / Impact / Evidence / Fix / Priority** structure.
- Findings are weighted by priority order: crawlability → technical → on-page → content quality → authority.
- Static fetches (`curl`, `web_fetch`) cannot detect JS-injected JSON-LD; structured data must be validated with a rendering tool or Search Console URL inspection.

## Best Paired Commands

- `/sdd-seo` for the audit phase (index coverage, structured data, render, on-page checks).
- `/sdd-validate` when a spec includes SEO acceptance criteria.

## Source

- `../../.claude/skills/seo-audit/SKILL.md`
