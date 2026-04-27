# Test SDD Implementation

Run automated tests against a spec path's implementation. Produce `test-report.md` with results, coverage, traceability, and failures.

## Usage

```
/sdd-test <spec-path>
```

**Examples:**

- `/sdd-test loan`
- `/sdd-test enhancements/renewals`

## Arguments

- `$ARGUMENTS` — Relative path under `docs/specs/` that contains `requirements.md`, `design.md`, and `tasks.md`.

---

## Behavior

### Phase 0: Load Context

1. Read:
   - `docs/specs/$ARGUMENTS/requirements.md`
   - `docs/specs/$ARGUMENTS/design.md`
   - `docs/specs/$ARGUMENTS/tasks.md`
2. Read project-level context:
   - `docs/prd.md`
   - `docs/system-design/design.md`
   - `docs/detailed-design/detailed-design.md`
   - root and package-level `CLAUDE.md` files
3. Identify backend, frontend, and end-to-end scope from the design and tasks.

### Phase 1: Unit Tests

- Create or improve backend unit tests where needed.
- Create or improve frontend unit tests where needed.
- Map tests back to requirements.

Use skills as needed:

- `nestjs-expert`
- `systematic-debugging`
- `vercel-react-best-practices`
- `react-doctor`

### Phase 2: Integration Tests

- Create or improve API integration tests where relevant.
- Validate auth, request/response shape, and major flows.

### Phase 3: End-to-End Tests

- Create or improve E2E tests for user-visible workflows.
- If the work is UI-heavy, prefer `ui-ux-pro-max` when available.
- Otherwise use `frontend-design` and the system design doc as the UX reference.

### Phase 4: Coverage & Traceability

Create a requirement-to-test matrix so every key requirement has test evidence or an explicit gap.

### Phase 5: Generate Test Report

Create `docs/specs/$ARGUMENTS/test-report.md`.

The report must include:

1. Document Control
2. Summary
3. Backend Unit Tests
4. Frontend Unit Tests
5. Integration Tests
6. E2E Tests
7. Coverage & Traceability
8. Remediation

### Phase 6: Report to User

Present overall test status, test counts, coverage gaps, and top failures. If failures exist, ask whether to fix failures, add missing tests, fix all, or keep only the report.

---

## UX Testing Guidance

When a spec includes meaningful UI/UX behavior, verify more than raw functionality:

- flow clarity
- responsive behavior
- state transitions
- accessibility basics
- visual consistency with `docs/system-design/design.md`

If `ui-ux-pro-max` is unavailable, use `frontend-design` plus the system design document as the fallback reference.
