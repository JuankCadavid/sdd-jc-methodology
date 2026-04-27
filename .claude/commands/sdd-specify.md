# Generate SDD for Module

Generate a complete Spec-Driven Development document set for a module or feature path inside `docs/specs/`.

## Usage

```
/sdd-specify <spec-path>
```

**Examples:**

- `/sdd-specify loan`
- `/sdd-specify enhancements/renewals`
- `/sdd-specify admin/user-management`

## Arguments

- `$ARGUMENTS` — Relative path under `docs/specs/` where the spec should live. It may be a flat module name or a nested taxonomy path.

## Behavior

### Step 0: Setup

1. Create directory `docs/specs/$ARGUMENTS/` if it does not exist.
2. Read the constitutional templates in `docs/specs/general-setup/`:
   - `requirements.md`
   - `design.md`
   - `task.md`
3. Read project-level reference context:
   - `docs/prd.md`
   - `docs/system-design/design.md`
   - `docs/detailed-design/detailed-design.md`
   - Root `CLAUDE.md`
   - Package-level `CLAUDE.md` files if they exist
4. Read nearby or dependent specs under `docs/specs/` that overlap with the requested path.
5. Respect the repository's current package layout and naming conventions instead of assuming a fixed stack.

---

### Phase 1: Requirements (`requirements.md`)

**Role:** Product Owner — define what is being built and why.

#### Step 1.1 — Explore

Use `brainstorming` and, when helpful, `product-manager-toolkit` to clarify:

- user problem and target actors
- scope boundaries and dependencies
- primary flows and feature areas
- success metrics and constraints

#### Step 1.2 — Write

Generate `requirements.md` using `docs/specs/general-setup/requirements.md` as the format source.

Minimum content:

1. Document Control
2. Executive Summary
3. Glossary
4. System Context & Scope
5. Stakeholders / Personas
6. Functional Requirements
7. Non-Functional Requirements
8. Requirement ID Index

Guidelines:

- follow the repo's established requirement ID pattern from `general-setup`
- align with `docs/prd.md`
- reference existing specs when this work extends another feature
- use measurable, testable language
- separate goals from requirements

#### Step 1.3 — Present & Approve

Present a summary and ask the user to approve or request changes before moving on.

---

### Phase 2: Design (`design.md`)

**Role:** System Architect — define how the feature will be built.

#### Step 2.1 — Explore

Use `brainstorming` to explore trade-offs before writing.

If the work includes meaningful UI/UX impact, use this skill preference:

- `ui-ux-pro-max` if available
- otherwise `frontend-design` + `stitch-design`

Use additional technical skills as needed:

- `nestjs-expert`
- `api-design-principles`
- `shadcn-ui`
- `tailwind-design-system`
- `vercel-react-best-practices`
- `error-handling-patterns`
- `aws-serverless`

#### Step 2.2 — Write

Generate `design.md` using `docs/specs/general-setup/design.md` as the format source.

Minimum content:

1. Document Control
2. Executive Summary
3. Architecture Overview
4. Extended Directory Structure
5. Data Model
6. API Design
7. Backend Module Design
8. Frontend / UX Component Architecture
9. Shared Contracts or Package Extensions
10. Design Decisions

Guidelines:

- extend existing architecture rather than replacing it
- use current repo paths and package names
- include UI/UX decisions when the feature affects screens, flows, or components
- tie design sections back to requirements explicitly

#### Step 2.3 — Present & Approve

Present a summary and ask the user to approve or request changes before moving on.

---

### Phase 3: Tasks (`tasks.md`)

**Role:** Tech Lead — define the implementation plan.

#### Step 3.1 — Explore

Use `brainstorming` to determine sequencing, dependencies, parallelization, and test strategy.

#### Step 3.2 — Write

Generate `tasks.md` using `docs/specs/general-setup/task.md` as the format source.

Each task should include:

- status
- size
- dependencies
- requirements covered
- design references
- scope
- tests
- done criteria
- relevant skills

Skill inventory should use real, available skills only.

Preferred UI/UX skill rule:

- use `ui-ux-pro-max` when available for UI-heavy tasks
- otherwise use `frontend-design` and/or `stitch-design`

#### Step 3.3 — Present & Approve

Present a summary and ask the user to approve or request changes.

---

## Verification Checklist

After all three documents are approved, verify:

- [ ] All 3 files exist with non-empty content
- [ ] All documents follow `docs/specs/general-setup/` conventions
- [ ] Every requirement appears in at least one task
- [ ] Every task references requirements and design sections
- [ ] The task dependency graph has no circular dependencies
- [ ] The spec path matches the repo's chosen taxonomy under `docs/specs/`
- [ ] Only real, available skills are referenced in tasks
