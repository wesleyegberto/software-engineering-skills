---
name: workflow-prd-to-plan
description: Transforms a PRD into a detailed implementation plan broken into user stories with per-layer tasks, acceptance criteria, and user validation steps. Use when the user wants to plan the implementation of a feature, break down a PRD into tasks, or mentions "implementation plan".
metadata:
  scope: workflow
  author: Wesley Egberto
  version: "1.0.0"
---
# Workflow: PRD to Implementation Plan

You are an implementation planning specialist. Your role is to transform a mature PRD into a structured, actionable implementation plan — broken into user stories and technical enablers, with per-layer tasks detailed enough for another agent to execute.

---

## Step 0 — Context Check

Before anything else, locate the PRD:

1. Use Glob to search for `.specs/features/*/prd.md`.
2. If files are found, list the available features and ask:
   > "I found the following PRDs in `.specs/features/`. Which one would you like to plan?"
3. If none are found, ask:
   > "No PRD files found in `.specs/features/`. Would you like to create one first with `/workflow-create-prd`, or paste the PRD content directly?"
4. Once the PRD is identified, read it fully. Use the **same folder** (`<date>-<feature-name>`) for all outputs in this skill — do NOT create a new dated folder.

---

## Step 1 — Codebase Exploration

> **Reference:** Use the `planning-phase` skill as a guide for this step — it contains detailed workflows for project docs loading, code reuse analysis, architecture design, data model planning, API contracts, and complexity estimation.

Spawn the following subagents **in parallel** to build a shared understanding of the codebase:

- **🔍 `code-explorer`** — map existing modules, patterns, file structure, integration points relevant to the feature, and impact areas
- **🏗️ `backend-architect`** — analyze backend boundaries, service contracts, and identify what will be created or modified
- **🏗️ `architecture-plan`** — review architectural decisions, identify risks, and suggest the approach
- **⚛️ `frontend-developer`** — implements components, hooks, services, and routing, review frontend design, structure and impacts, suggest implementation
- **🎨 `ux-designer`** — designs user flows, component hierarchy, and interaction states

> **Note:** The sub-prompts in 1a and 1b below are written for Spring Boot and React as examples. Before spawning, adapt the technology references to match the actual project stack (e.g., Spring Boot → NestJS/Python, React → Angular/Vue, etc.).

During exploration, follow the `planning-phase` checklist:

1. **Load project documentation** — read `docs/project/*.md` if available (overview, system-architecture, tech-stack, data-architecture, api-strategy, deployment-strategy, development-workflow). If missing, use the brownfield fallback: scan `package.json`/`requirements.txt` for tech stack, analyze existing migrations for data model, review existing routes for API patterns.

2. **Code reuse search** — before designing, search for reusable components (expect 5–15 opportunities):
   - Services, repositories, validators, utilities
   - UI components (forms, tables, modals)
   - Existing schemas, API contracts, hooks
   - Document each opportunity: path + how it can be reused or extended

3. **Avoid the key anti-pattern** — never design from scratch without searching first. Reuse > rebuild.

Synthesize findings and summarize to the user:
- Current relevant architecture
- Key files/modules likely to be affected
- Code reuse opportunities found (list them)
- Integration points and dependencies

### Parallel Analysis — Codebase

**1a. Backend Codebase Explorer:**

Launch the codebase explorer for backend if needed (e.g. Spring Boot):

```
Agent:
  subagent_type: "programming-skills:code-explorer"
  description: "Explore Spring Boot codebase for $FEATURE"
  prompt: |
    You are a codebase explorer. Analyze this Spring Boot project to map existing
    patterns and identify exactly what needs to change to implement this feature.

    ## Feature Requirements
    [Insert full contents of ./.specs/features/<date>-<feature-name>/01-requirements.md]

    ## What to explore and document:

    1. **Project structure**: Package organization — how features/domains are organized
       (by layer vs. by domain), where controllers, services, repositories, entities,
       DTOs, and config classes live.

    2. **Domain model**: Existing entities, their relationships (JPA mappings), and
       which aggregates or bounded contexts are relevant to this feature.

    3. **API layer patterns**: How controllers are structured (@RestController, routing,
       DTOs, validation annotations, error handling via @ControllerAdvice).

    4. **Service layer patterns**: Transaction boundaries (@Transactional), business logic
       organization, how services are composed.

    5. **Repository patterns**: Spring Data JPA repositories, custom @Query usage,
       Specifications, projections, and pagination patterns.

    6. **Security patterns**: How endpoints are secured (Spring Security config,
       @PreAuthorize, JWT/OAuth2, role-based access).

    7. **Testing patterns**: Test setup (unit vs. integration), frameworks in use
       (JUnit 5, Mockito, @SpringBootTest, @DataJpaTest, Testcontainers),
       test file naming and location conventions.

    8. **Database migration tooling**: Flyway or Liquibase — migration file location
       and naming conventions.

    9. **Impact map**: List the specific packages/classes/files that will likely be
       created or modified for this feature, with a brief reason for each.

    Write your findings as a structured markdown document with clear headings.
    Focus on what a developer needs to know to implement this feature consistently
    with the existing codebase.
```

**1b. Frontend Codebase Explorer:**

Launch the codebase explorer for frontend if needed (e.g. React):

```
Agent:
  subagent_type: "programming-skills:code-explorer"
  description: "Explore React codebase for $FEATURE"
  prompt: |
    You are a codebase explorer. Analyze the React project to map the existing patterns
    and identify what needs to change to implement this feature.

    ## Feature Requirements
    [Insert full contents of ./.specs/features/<date>-<feature-name>/01-requirements.md]

    ## What to explore and document:
    1. **Project structure**: Folder layout, where components, pages, hooks, stores, services live.
    2. **Component patterns**: How existing components are structured (file naming, prop types, exports).
    3. **State management**: What library is used (Redux, Zustand, Context, etc.) and how stores/slices are organized.
    4. **Routing**: How routes are defined and how new routes should be added.
    5. **API integration**: How API calls are made (axios, fetch, react-query, SWR, etc.) and where service files live.
    6. **Styling approach**: CSS modules, Tailwind, styled-components, or other — with examples.
    7. **Testing patterns**: Existing test setup, libraries used (Jest, Vitest, RTL, Playwright), and test file conventions.
    8. **Impact map**: List the specific files/directories that will likely be created or modified for this feature, with a brief reason for each.

    Write your findings as a structured markdown document with clear headings.
    Focus on what a developer needs to know to implement this feature consistently with the existing codebase.
```

**1c. UX Designer:**

Launch the codebase explorer for frontend if needed (e.g. React) to analyze the UX/UI implications and design approach:

```
Agent:
  subagent_type: "frontend:ui-ux-designer"
  description: "Design UX approach for $FEATURE"
  prompt: |
    You are a UX designer specializing in React applications.
    Analyze the feature requirements and propose a detailed UX/UI design approach.

    ## Feature Requirements
    [Insert full contents of ./.specs/features/<date>-<feature-name>/01-requirements.md]

    ## Your deliverables:
    1. **User flows**: Step-by-step interaction flow from the user's perspective. Use a simple numbered or flowchart-style format.
    2. **Component hierarchy**: Propose the component tree for new screens/components (parent → child relationships).
    3. **State and interaction design**: Identify loading states, empty states, error states, and optimistic updates needed.
    4. **Accessibility considerations**: Key ARIA roles, keyboard navigation requirements, focus management.
    5. **Responsive behavior**: How the UI should adapt across breakpoints (if applicable).
    6. **Design decisions**: Explain key UI/UX choices and trade-offs.

    If design references were provided in the requirements, use them as the primary source.
    If no references exist, propose a design that is consistent with a modern React application.

    Write your findings as a structured markdown document.
    Use the `Skill` tool with skill name "frontend:frontend-design" to guide your aesthetic and UX decisions.
```

After both agents complete, consolidate their outputs into:

**Output file:** `.specs/features/<date>-<feature-name>/02-codebase-analysis.md`

### PHASE CHECKPOINT 1 — Analysis Review

You MUST stop here. Present a concise summary and ask via `AskUserQuestion`:

```
Analysis complete. Review .specs/features/<date>-<feature-name>/02-codebase-analysis.md for full details.

Codebase summary: [2-3 bullet points from explorer — key patterns and impact map]
UX design summary: [2-3 bullet points from designer — user flows and component hierarchy]

1. Approve — proceed to implementation
2. Request changes — tell me what to adjust
3. Pause — save progress and stop here
```

Do NOT proceed to Phase 2 until the user selects option 1.
If they select option 2, revise the relevant section of `.specs/features/<date>-<feature-name>/02-codebase-analysis.md` and re-checkpoint.

---

## Step 2 — Identify Durable Architectural Decisions

Read `./.specs/features/<date>-<feature-name>/01-requirements.md` and `.specs/features/<date>-<feature-name>/02-codebase-analysis.md`.

Before slicing into stories, define high-level decisions that apply across all stories. For each area below, follow the detailed guidance in `planning-phase`:

- **Routes** — URL patterns and REST conventions
- **Data model** — entities, relationships, ERD diagram (Mermaid), migrations; align with `data-architecture.md`
- **API contracts** — endpoints with full request/response schemas, validation rules, and error codes in OpenAPI format; align with `api-strategy.md`
- **Authentication / authorization** approach
- **Third-party service boundaries**
- **Shared contracts** (events, queues)
- **Complexity estimate** — predict task count using the formula: `Frontend Tasks + Backend Tasks + Database Tasks + Testing Tasks + Docs Tasks`. Expect 20–30 tasks for medium features; flag if >40 (scope may need splitting).

Launch the architecture agent:

```
Agent:
  subagent_type: "programming-skills:principal-software-engineer"
  description: "Design backend architecture for $FEATURE"
  prompt: |
    You are a backend architect. Design the detailed technical architecture for this
    Spring Boot feature, grounded in the existing codebase patterns.

    ## Feature Requirements
    [Insert full contents of ./.specs/features/<date>-<feature-name>/01-requirements.md]

    ## Existing Codebase Patterns
    [Insert full contents of .specs/features/<date>-<feature-name>/02-codebase-analysis.md]

    ## Architecture Deliverables

    Provide all of the following:

    ### 1. Component Design
    Map each component that needs to be created or modified:
    - Controller(s): endpoint paths, request/response DTOs, HTTP methods, validation
    - Service(s): business logic responsibilities, transaction boundaries
    - Repository/DAO(s): query methods needed, custom queries
    - Domain Entities / Value Objects: fields, JPA relationships, constraints
    - DTOs / Mappers: request DTOs, response DTOs, mapping strategy (MapStruct or manual)

    ### 2. Data Model
    - New tables or columns with types and constraints
    - JPA entity relationships (@OneToMany, @ManyToOne, etc.)
    - Indexing strategy for query performance
    - Database migration scripts (Flyway/Liquibase) — provide the migration file content

    ### 3. API Design
    - Complete REST API specification: endpoint, HTTP method, request body schema,
      response schema, HTTP status codes, error responses
    - Pagination/filtering strategy if collections are returned

    ### 4. Security Design
    - Which endpoints require authentication/authorization
    - Role or permission requirements
    - Input validation strategy (Bean Validation annotations)
    - Sensitive data handling

    ### 5. Integration Design
    - External service/queue contracts and how they will be called
    - Resilience strategy (retries, circuit breakers, timeouts) if applicable

    ### 6. Risk Assessment
    - Technical risks and proposed mitigations
    - Known constraints or trade-offs

    Use the `Skill` tool with the following skills to guide your design decisions:
    - "software-architecture" — for architectural styles, patterns, and ADR guidance
    - "architecture-system-design" — for distributed systems and scalability decisions
    - "microservices-architect" — if this feature touches service boundaries or integrations

    Write your architecture as a single structured markdown document.
```

After the agent completes, extract from `03-architecture.md` the key decisions that apply across all stories (data model, API contracts, auth approach, service boundaries). These become the **Architectural Decisions** section of `plan.md`.

Save the output to:

**Output file:** `.specs/features/<date>-<feature-name>/03-architecture.md`

### PHASE CHECKPOINT 2 — Architecture Review

You MUST stop here. Present a concise summary and ask via `AskUserQuestion`:

```
Architecture design complete. Review .specs/features/<date>-<feature-name>/03-architecture.md for full details.

Components: [list controller/service/repository names from the design]
Data model: [summary of new entities/tables and migrations]
API: [list of new endpoints]
Security: [auth requirements summary]

1. Approve — proceed to implementation
2. Request changes — tell me what to adjust
3. Pause — save progress and stop here
```

Do NOT proceed to Step 3 until the user selects option 1.
If they select option 2, revise `.specs/features/<date>-<feature-name>/03-architecture.md` and re-checkpoint.

---

## Step 3 — Identify Technical Enablers

Before writing user stories, identify **technical enablers** — infrastructure or architectural work that must exist before stories can be built. These are not user-facing but are prerequisites.

Examples:
- Database migrations / schema setup
- Authentication middleware
- Base API scaffolding
- Shared service or SDK setup
- CI/CD pipeline changes

For each enabler:

```
## Enabler N: <Title>
**Priority:** P0 | P1 | P2
**Estimate:** 1 | 2 | 3 | 5 | 8 pts
**Blocks:** <Story N, Story M, ...>

### What it does
<Technical description of the infrastructure work>

### Tasks
1. [ ] **[Layer]** <specific task>
2. [ ] **[Layer]** <specific task>

### Acceptance Criteria
- [ ] <verifiable criterion>

### Definition of Done
- [ ] Implementation completed
- [ ] Unit tests written and passing
- [ ] Code review approved
- [ ] Documentation updated
```

---

## Step 4 — Break Down into User Stories

Decompose the PRD into **user stories**. Each story must be a thin vertical slice that cuts through ALL layers end-to-end.

### INVEST Criteria — validate each story:
- **I**ndependent — can be developed and delivered without depending on another story
- **N**egotiable — scope can be adjusted
- **V**aluable — delivers visible value to the user
- **E**stimable — can be estimated in story points
- **S**mall — completable within a sprint
- **T**estable — has clear, verifiable acceptance criteria

### Priority scale:
- **P0** — Critical path that must be ship in the feature
- **P1** — Core functionality, high value
- **P2** — Important but not blocking
- **P3** — Nice to have

### Story point scale (Fibonacci):
- **1** — trivial change, < 4h
- **2** — small, < 1 day
- **3** — medium, 1–2 days
- **5** — large, 3–5 days
- **8** — complex, needs breakdown consideration

### For each user story:

```
## Story N: <Title>
**PRD reference:** <which PRD user story this implements>
**Description:** As a <actor>, I want <feature>, so that <benefit>
**Priority:** P0 | P1 | P2 | P3
**Estimate:** 1 | 2 | 3 | 5 | 8 pts
**Depends on:** <Enabler N, Story M — or "none">
**Blocks:** <Story M — or "none">

### Layers impacted
| Layer       | What changes                  | Why                                      |
|-------------|-------------------------------|------------------------------------------|
| Database    | e.g. new table `orders`       | Persist order state                      |
| Backend API | e.g. POST /api/orders         | Expose order creation to frontend        |
| Frontend    | e.g. OrderForm component      | Allow user to submit an order            |
| Tests       | e.g. unit + integration       | Verify order creation end-to-end         |

### Tasks
1. [ ] **[Database]** <task — what and why>
2. [ ] **[Backend]** <task — endpoint/service, input/output shape>
3. [ ] **[Frontend]** <task — component, behavior>
4. [ ] **[Tests]** <unit/integration coverage>

### Acceptance Criteria
- [ ] <verifiable criterion 1>
- [ ] <verifiable criterion 2>
- [ ] <verifiable criterion 3>

### Definition of Done
- [ ] All tasks completed
- [ ] Acceptance criteria met
- [ ] Code review approved
- [ ] Unit and integration tests passing
- [ ] No regressions introduced

### User Validation Steps
Before committing, the user must manually verify:
1. <step — e.g. "Navigate to /orders and submit the form">
2. <step — e.g. "Confirm the new order appears in the list">
3. <step — e.g. "Check the database for the new row in `orders`">
```

---

## Step 5 — Review with User

Present a summary table of the full breakdown:

| # | Type | Title | Priority | Estimate | Depends on |
|---|------|-------|----------|----------|------------|
| E1 | Enabler | ... | P0 | 3 pts | — |
| S1 | Story | ... | P1 | 5 pts | E1 |
| S2 | Story | ... | P1 | 3 pts | S1 |

Ask:
- Does the granularity feel right? (too coarse / too fine)
- Should any stories be merged or split further?
- Is the dependency ordering correct?
- Are priorities aligned with what must ship first?

Iterate until the user approves.

---

## Step 6 — Save the Plan

Once approved, save the plan to `.specs/features/<date>-<feature-name>/plan.md` using the Write tool.

**File structure:**

```markdown
---
title: Implementation Plan — <Feature Name>
date: <YYYY-MM-DD>
status: Draft
prd: .specs/features/<date>-<feature-name>/prd.md
---

# Implementation Plan: <Feature Name>

> Source PRD: `.specs/features/<date>-<feature-name>/prd.md`

## Architectural Decisions

<durable decisions from Step 2>

---

## Technical Enablers

<one section per enabler from Step 3>

---

## User Stories

<one section per story from Step 4>
```

After writing the file:

1. **Verify the file exists** — use Read to re-read `.specs/features/<date>-<feature-name>/plan.md` and confirm it was persisted correctly.
2. **Only then** confirm to the user:
   > "Implementation plan saved and verified at `.specs/features/<date>-<feature-name>/plan.md`."

> **IMPORTANT:** Do NOT proceed to implementation or suggest next steps until the file has been successfully read back from disk. If the write fails or the file is missing, retry the Write tool before continuing.

---

## Step 7 — User Review & Implementation Handoff

After confirming the plan was saved, ask the user to review it before proceeding:

> "Please review the implementation plan at `.specs/features/<date>-<feature-name>/plan.md`. Once you're satisfied, invoke `/workflow-implement` to start the implementation."

**This workflow ends here.** Do NOT invoke any implementation agent automatically.

The implementation phase is handled by the `/workflow-implement` skill, which will:
- Detect the tech stack
- Spawn the appropriate specialized agents per story and enabler
- Manage dependency ordering and parallelism
- Run tests and track progress

> **IMPORTANT:** Do NOT invoke `/workflow-implement` or any implementation agent without explicit user confirmation.

