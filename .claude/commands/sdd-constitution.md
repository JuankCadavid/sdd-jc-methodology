# Establish SDD Constitution

Establish or strengthen the project-wide SDD foundation. This command creates the documentation baseline that all later module-level SDD work depends on.

## Usage

```
/sdd-constitution
```

## Behavior

### Step 0: Foundation Setup

1. Ensure `docs/` exists.
2. Ensure `docs/specs/` exists.
3. Ensure `docs/specs/general-setup/` exists.
4. Default behavior is to enhance existing project docs in place instead of creating parallel copies.

The constitutional baseline must cover these files:

- `docs/prd.md`
- `docs/system-design/design.md`
- `docs/detailed-design/detailed-design.md`
- `docs/specs/general-setup/requirements.md`
- `docs/specs/general-setup/design.md`
- `docs/specs/general-setup/task.md`
- `CLAUDE.md`

---

### Step 1: Read Project Context First

Before writing anything, read the repository context carefully:

1. Root `CLAUDE.md` if it exists
2. Package-level `CLAUDE.md` files if they exist
3. Existing `docs/prd.md`
4. Existing `docs/system-design/design.md`
5. Existing `docs/detailed-design/detailed-design.md`
6. Existing `docs/specs/` folders to extract terminology, taxonomy, and prior feature history
7. Any architecture, infrastructure, setup, or product docs already present under `docs/`

Also inspect the codebase to understand:

- Product domain and business model
- Main user roles and workflows
- Current frontend/backend/shared architecture
- Existing visual patterns and design system signals
- Technical constraints already enforced by the repo
- Existing spec taxonomy under `docs/specs/` such as domain, enhancement, bugfix, or epic folders

Do not write generic placeholder documentation when the repository already contains enough context to infer a strong baseline.

---

### Step 2: Clarify Missing Business Context

If essential product context is missing or ambiguous, ask focused user questions before drafting the documents.

Focus especially on:

- The core problem the product solves
- Primary personas and user roles
- Business goals and expected outcomes
- Success metrics or KPIs
- Scope boundaries and non-goals
- Known constraints, dependencies, and risks
- Preferred `docs/specs/` taxonomy when the repo does not already imply one

Ask only what is needed to avoid unstable assumptions.

---

### Step 3: Create or Enhance the General PRD

Create or enhance `docs/prd.md` as a concise living document.

**Primary skill:** `product-manager-toolkit`

**PRD rules:**

- Lead with the why: problem statement, business context, user need
- Keep it concise and maintainable
- Define measurable success metrics before implementation begins
- Define explicit out-of-scope items
- Use user-centric requirements and user stories
- Use testable acceptance criteria
- Collaborate through assumptions and open questions rather than pretending certainty
- Keep it AI-ready with clean headings and concise bullets

**Pitfalls to avoid:**

- Do not mix goals with requirements
- Do not use vague language like "fast" or "intuitive" without measurable meaning
- Do not treat the PRD as static
- Do not force a predetermined technical solution into the PRD

**Required PRD structure:**

1. Overview & Purpose
2. Problem Statement
3. Target Personas
4. Goals & Success Metrics
5. Scope (In / Out)
6. User Stories
7. Acceptance Criteria
8. Assumptions, Dependencies, & Constraints
9. Open Questions

When `docs/prd.md` already exists, preserve useful content and upgrade weak sections to follow the rules above.

---

### Step 4: Create or Enhance the System Design Document

Create or enhance `docs/system-design/design.md` as the UI/UX system blueprint.

**Preferred skill chain:**

- `ui-ux-pro-max` if available
- otherwise `frontend-design` + `stitch-design`

This document represents the visual and interaction system, not the low-level technical implementation.

**Required structure:**

1. Product Experience Principles
2. Information Architecture
3. Primary User Flows
4. Screen Inventory
5. Navigation Model
6. Layout Patterns
7. Design Tokens
8. Component Inventory
9. Responsive Behavior
10. Accessibility Expectations
11. Dark Mode Behavior
12. Design Decisions
13. Open Gaps / Open Questions

**Document intent:**

- Define a reusable, consistent UI/UX system
- Capture visual consistency, accessibility, and interaction rules
- Reference existing brand, color, typography, and component patterns from the repository when available
- Prefer clarity over decorative language

When the file already exists, refine it in place instead of replacing established valid patterns.

---

### Step 5: Create or Enhance the Detailed Design Document

Create or enhance `docs/detailed-design/detailed-design.md` as the technical implementation blueprint.

**Use skills when relevant:**

- `nestjs-expert`
- `api-design-principles`
- `error-handling-patterns`
- `aws-serverless`
- `shadcn-ui`
- `tailwind-design-system`
- `vercel-react-best-practices`

**Required structure:**

1. System Overview
2. Domain Modules & Responsibilities
3. Data Model & Entities
4. API Surface & Contracts
5. Backend Workflows & Business Rules
6. Frontend Architecture & State Boundaries
7. Integration Points
8. Security & Authorization Model
9. Error Handling & Observability
10. Testing Strategy
11. Technical Constraints & Assumptions

---

### Step 6: Create or Enhance General Setup Templates

Create or enhance the canonical templates under `docs/specs/general-setup/`.

These files define the format that `/sdd-specify` must follow later:

1. `requirements.md` — requirement numbering, structure, and writing standards
2. `design.md` — architecture, data model, API, frontend, and decision-record structure
3. `task.md` — task format, dependency graph format, testing expectations, and execution conventions

These are methodology templates for future specs, not a feature spec themselves.

They must reflect:

- The repo's current architecture and package layout
- The chosen `docs/specs/` taxonomy
- The approved PRD, system design, and detailed design conventions

---

### Step 7: Update the Root CLAUDE Guide

Update root `CLAUDE.md` so it references:

- `docs/prd.md`
- `docs/system-design/design.md`
- `docs/detailed-design/detailed-design.md`
- `docs/specs/general-setup/`

The update should explain briefly:

- What each document is for
- When Claude should consult each one
- That these documents form the constitutional baseline for future SDD work
- How module specs should be organized under `docs/specs/`

Preserve the repository's existing `CLAUDE.md` conventions and extend them.

---

### Step 8: Present and Confirm

After drafting or enhancing the documents, present a concise summary covering:

- What was created vs enhanced
- The chosen spec taxonomy under `docs/specs/`
- The main problem statement and personas captured in the PRD
- The main UX/system decisions captured in system design
- The main technical decisions captured in detailed design
- Any assumptions and open questions that still need validation

Ask the user whether to approve or request changes. If changes are requested, revise the affected documents and re-present.

---

## Outcome

At the end of `/sdd-constitution`, the repository should have a project-level baseline that future `/sdd-specify`, `/sdd-execute`, `/sdd-validate`, and `/sdd-test` work can rely on without guessing the structure or conventions.
