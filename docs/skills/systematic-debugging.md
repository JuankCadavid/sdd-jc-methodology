# `systematic-debugging`

## Purpose

Enforces root-cause debugging before proposing fixes for bugs, test failures, build failures, integration issues, performance problems, or unexpected behavior.

AKILI-adapted: mapped to the Bug Track (`/akili-propose` Bug Diagnosis), `/akili-specify` Bug Mode, `PRODUCT_BUG` characterization in `/akili-test`, and the Kaizen 5W1H root-cause rule; the unpackaged `superpowers:*` cross-references are covered by AKILI's own regression-test and verification gates. Original by Jesse Vincent (obra/superpowers). Binding: `core`.

## Use When

- Any test, build, or validation check fails.
- Production or local behavior is unexpected.
- A previous fix did not work.
- A multi-component issue needs data-flow tracing.

## Core Rule

No fixes without root-cause investigation first.

## Best Paired Commands

- `/akili-execute` when implementation hits failures.
- `/akili-test` when tests fail or coverage is unclear.
- `/akili-validate` when conformance checks fail.
- `/akili-seo` when GSC or index data is inconsistent.

## Source

- `../../.claude/skills/systematic-debugging/SKILL.md`
