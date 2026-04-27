# Validate SDD Implementation

Validate that a spec path's implementation matches its SDD documents. Produce `validation-report.md` with pass, partial, or fail results and remediation steps.

## Usage

```
/sdd-validate <spec-path>
```

**Examples:**

- `/sdd-validate loan`
- `/sdd-validate enhancements/renewals`

## Arguments

- `$ARGUMENTS` — Relative path under `docs/specs/` containing `requirements.md`, `design.md`, `tasks.md`, and optionally `execution.md`.

---

## Behavior

### Phase 0: Load Context

1. Read:
   - `docs/specs/$ARGUMENTS/requirements.md`
   - `docs/specs/$ARGUMENTS/design.md`
   - `docs/specs/$ARGUMENTS/tasks.md`
   - `docs/specs/$ARGUMENTS/execution.md` if present
2. Read constitutional context:
   - `docs/prd.md`
   - `docs/system-design/design.md`
   - `docs/detailed-design/detailed-design.md`
   - `docs/specs/general-setup/`
3. Read root and package-level `CLAUDE.md` files if they exist.

### Phase 1: Task Completion Check

Verify task status coverage and report PASS, WARN, or FAIL per task.

### Phase 2: File Existence Check

Parse the design file tree and verify expected new, modified, and deleted files.

### Phase 3: Build Integrity

Run the project's relevant build, type-check, and lint commands.

Prefer the commands defined by the repo rather than assuming a fixed stack.

### Phase 4: Requirement Coverage Verification

For every requirement in `requirements.md`, verify:

1. it appears in at least one task
2. mapped tasks are complete when full implementation is claimed
3. code evidence exists

### Phase 5: Quality Audit

Use skills as needed:

- `nestjs-expert`
- `react-doctor`
- `api-design-principles`
- `tailwind-design-system`
- `frontend-design`
- `ui-ux-pro-max` if available for UX/UI-heavy validation
- `systematic-debugging` when failures or inconsistencies appear

Check for:

- architecture compliance
- API quality
- frontend quality
- design-system compliance
- UX consistency with the system design document

### Phase 6: Design Conformance

Compare the implementation against the module design and the constitutional docs where relevant.

### Phase 7: Generate Validation Report

Create `docs/specs/$ARGUMENTS/validation-report.md`.

The report must include:

1. Document Control
2. Summary
3. Task Completion
4. File Existence
5. Build Integrity
6. Requirement Coverage
7. Linting & Code Quality
8. Design Conformance
9. Remediation

The report title must be `# Validation Report — {Spec Name}`.

### Phase 8: Report to User

Present overall status, key findings, and remediation count. If issues exist, ask whether to fix all, fix critical only, or keep only the report.

---

## Error Handling

- If SDD documents are missing, report the missing files and stop.
- If build fails, continue other checks when possible.
- If a skill is unavailable, fall back to the next documented skill and note it in the report.
- If no tasks are complete, still allow partial validation but make the incompleteness explicit.
