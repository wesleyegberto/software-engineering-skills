---
name: node-feature-development
description: Orchestrate end-to-end Node.js backend feature development from idea or plan to reviewed, committed code. Use this skill proactively when the user wants to implement a feature, endpoint, service, module, or integration in a Node.js application — even if they just say "implement this", "add this endpoint", "build this service", "develop this plan", or "create this API". Works with any Node.js framework (Express, Fastify, NestJS, Koa) and TypeScript or JavaScript. Spawns parallel specialist subagents for codebase exploration, architecture planning, implementation, testing, and code review, then guides the user through approval, commit, and optional PR creation.
license: MIT
metadata:
  author: Wesley Egberto
  version: "1.0.0"
  domain: backend
  triggers: Node.js, Express, Fastify, NestJS, Koa, TypeScript, JavaScript, feature, implement, build, endpoint, API, service, middleware, module, backend
  role: orchestrator
  scope: implementation
  output-format: code + summary
  related-skills: nodejs-backend-patterns, javascript-expert, typescript-advanced-types, auth-implementation-patterns, javascript-testing-patterns, terminal-monitor
---

# Node.js Backend Feature Development Orchestrator

## Objective

Orchestrate the complete development of a Node.js backend feature — from requirements through architecture planning, implementation, testing, review, and delivery. Uses specialized subagents running in parallel where possible to accelerate the workflow without sacrificing quality.

---

## Subagent Team

This skill **starts a team of specialist subagents** to parallelize and accelerate the implementation. Before proceeding, inform the user which agents will be used:

```
This skill will coordinate a team of specialist subagents to implement your feature:

  🔍 Code Explorer        — maps the existing codebase, patterns, and impact areas
  🏗️  Backend Architect    — designs the module/component structure, API, data model, and security
  🟢 Node.js Developer    — implements router, service, repository, DTOs, and migrations
  🧪 Test Automator       — writes unit, integration, and API tests
  🔎 Code Reviewer        — reviews for correctness, security, performance, and consistency

Agents run in parallel where possible to save time.
Each agent will open in a dedicated terminal pane (tmux or iTerm2) so you can follow progress in real time.

Shall I start the team and begin the feature development workflow?
1. Yes — let's go
2. No — I'll implement manually
```

Use `AskUserQuestion` to present this message and wait for confirmation before continuing.
If the user selects option 2, stop and let them proceed on their own.

---

## Terminal Monitoring

Each agent step MUST open a dedicated terminal pane before launching so the user can follow progress in real time.

use skill `programming-skills:terminal-monitor` — handles detection (tmux / iTerm2 / none) and pane opening. Call it once per agent with the parameters below.

### Pane parameters per step

| Step | `mode` | `label` | `pane-name` | `output-file` |
|------|--------|---------|------------|---------------|
| 2 – Code Explorer | `subagent` | `🔍 Code Explorer` | `🔍 explorer` | `.node-dev/02-codebase-analysis.md` |
| 3 – Backend Architect | `subagent` | `🏗️ Backend Architect` | `🏗️ architect` | `.node-dev/03-architecture.md` |
| 4 – Node.js Developer | `subagent` | `🟢 Node.js Developer` | `🟢 node` | `.node-dev/04-implementation.md` |
| 5a – Test Automator | `subagent` | `🧪 Test Automator` | `🧪 tests` | `.node-dev/05-quality.md` |
| 5b – Code Reviewer | `subagent` | `🔎 Code Reviewer` | `🔎 reviewer` | `.node-dev/05-quality.md` |

---

## CRITICAL BEHAVIORAL RULES

Follow these rules exactly. Violating any of them is a failure.

1. **Execute steps in order.** Do NOT skip ahead, reorder, or merge steps.
2. **Write output files.** Each step MUST produce its output file in `.node-dev/` before the next step begins. Read from prior step files — do NOT rely on context window memory.
3. **Stop at checkpoints.** When you reach a `PHASE CHECKPOINT`, you MUST stop and wait for explicit user approval using `AskUserQuestion`. Do NOT continue automatically.
4. **Halt on failure.** If any agent errors or a step cannot be completed, STOP immediately and ask the user how to proceed.
5. **Architecture before code.** The `backend-architect` step MUST complete and be approved before implementation begins. Do NOT skip or merge it with implementation.
6. **Never enter plan mode autonomously.** Do NOT call `EnterPlanMode` — this skill IS the plan. Execute it.

---

## Pre-flight Checks

### 1. Check for existing session

Check if `.node-dev/state.json` exists:

- If `status` is `"in_progress"`: Read it and ask the user via `AskUserQuestion`:

  ```
  Found an in-progress Node.js feature session:
  Feature: [name from state]
  Current step: [step from state]

  1. Resume from where we left off
  2. Start fresh (archives existing session to .node-dev/archive/)
  ```

- If `status` is `"complete"`: Ask whether to archive and start fresh.

### 2. Initialize state

Create `.node-dev/` directory and `state.json`:

```json
{
  "feature": "$ARGUMENTS",
  "status": "in_progress",
  "current_step": 1,
  "current_phase": 1,
  "completed_steps": [],
  "files_created": [],
  "started_at": "ISO_TIMESTAMP",
  "last_updated": "ISO_TIMESTAMP"
}
```

The feature description (`$FEATURE`) is the full content of `$ARGUMENTS`.

---

## Phase 1: Discovery (Step 1) — Interactive

### Step 1: Requirements Gathering

Gather requirements through interactive Q&A using `AskUserQuestion`. Ask ONE question at a time — do NOT dump all questions at once.

**Questions to ask (in order):**

1. **Feature description**: "Describe the feature to be built. What is its purpose, and which domain or module does it belong to?"
2. **API contract**: "Describe the API surface needed: HTTP methods, endpoint paths, request/response payloads. If there's an existing API spec (OpenAPI, Swagger), share it."
3. **Acceptance criteria**: "What are the key acceptance criteria? When is this feature 'done'?"
4. **Data and persistence**: "What data needs to be persisted? Describe the data model — new collections/tables, fields, relationships. Share existing schema or ORM models if available."
5. **Integrations**: "Does this feature call external services, message queues, third-party APIs, or other microservices? If so, describe the integration contracts."
6. **Non-functional requirements**: "Any NFRs to consider? (e.g., latency SLA, rate limiting, authentication/authorization requirements, multi-tenancy, audit logging)"
7. **Out of scope**: "What is explicitly OUT of scope for this feature?"

After gathering answers, write:

**Output file:** `.node-dev/01-requirements.md`

```markdown
# Requirements: $FEATURE

## Feature Description

[From Q1]

## API Contract

[From Q2 — endpoints, methods, request/response shapes]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Data and Persistence

[From Q4 — entities/models, relationships, schema changes]

## Integrations

[From Q5 — external services, queues, third-party APIs]

## Non-Functional Requirements

[From Q6 — latency, rate limiting, auth, audit]

## Out of Scope

[From Q7]
```

Update `state.json`: set `current_step` to 2, add `"01-requirements.md"` to `files_created`.

---

## Phase 2: Codebase Analysis (Step 2)

### Step 2: Codebase Exploration

Read `.node-dev/01-requirements.md`.

use skill `programming-skills:terminal-monitor` with: `mode: subagent`, `label: 🔍 Code Explorer`, `pane-name: 🔍 explorer`, `output-file: .node-dev/02-codebase-analysis.md`

Launch the codebase explorer:

```
Agent:
  subagent_type: "programming-skills:code-explorer"
  description: "Explore Node.js codebase for $FEATURE"
  prompt: |
    You are a codebase explorer. Analyze this Node.js project to map existing
    patterns and identify exactly what needs to change to implement this feature.

    ## Feature Requirements
    [Insert full contents of .node-dev/01-requirements.md]

    ## What to explore and document:

    1. **Project structure**: Folder and module organization — how routes, controllers,
       services, repositories/DAOs, models, middleware, and config are structured.
       Note whether it's organized by layer or by domain/feature.

    2. **Framework and runtime**: Which framework is in use (Express, Fastify, NestJS,
       Koa, etc.), Node.js version, and whether the project uses TypeScript or JavaScript.
       Note the tsconfig or Babel config if present.

    3. **ORM / Database layer**: Which ORM or query builder is used (Prisma, TypeORM,
       Sequelize, Mongoose, Drizzle, Knex, raw SQL, etc.), how models/schemas are
       defined, and where migrations or seed files live.

    4. **Routing patterns**: How routes are defined and registered, how route parameters,
       query strings, and request bodies are handled, how versioning is done.

    5. **Middleware patterns**: Authentication middleware (JWT, session, OAuth), validation
       middleware (Zod, Joi, express-validator, class-validator), error handling middleware,
       logging middleware.

    6. **Service layer patterns**: How business logic is organized, how dependencies are
       injected or composed (DI container, manual wiring, NestJS DI, etc.).

    7. **Error handling**: How errors are thrown (custom error classes vs. standard),
       how they're caught (global handler, try/catch patterns), response error shapes.

    8. **Testing patterns**: Test setup (Jest, Vitest, Mocha), how integration/API tests
       are structured (Supertest, test containers, in-memory DB), mocking patterns,
       test file naming and location conventions.

    9. **Impact map**: List the specific modules/files/directories that will likely be
       created or modified for this feature, with a brief reason for each.

    Write your findings as a structured markdown document with clear headings.
    Focus on what a developer needs to know to implement this feature consistently
    with the existing codebase.
```

Save the output to:

**Output file:** `.node-dev/02-codebase-analysis.md`

Update `state.json`: set `current_step` to 3, add step 2 to `completed_steps`.

---

## Phase 3: Architecture Planning (Step 3)

### Step 3: Backend Architecture Design

Read `.node-dev/01-requirements.md` and `.node-dev/02-codebase-analysis.md`.

use skill `programming-skills:terminal-monitor` with: `mode: subagent`, `label: 🏗️ Backend Architect`, `pane-name: 🏗️ architect`, `output-file: .node-dev/03-architecture.md`

Launch the architecture agent:

```
Agent:
  subagent_type: "backend-architect"
  description: "Design Node.js backend architecture for $FEATURE"
  prompt: |
    You are a backend architect. Design the detailed technical architecture for this
    Node.js feature, grounded in the existing codebase patterns.

    ## Feature Requirements
    [Insert full contents of .node-dev/01-requirements.md]

    ## Existing Codebase Patterns
    [Insert full contents of .node-dev/02-codebase-analysis.md]

    ## Architecture Deliverables

    Provide ALL of the following:

    ### 1. Module / Component Design
    Map each component that needs to be created or modified:
    - **Router/Controller**: route paths, HTTP methods, request validation, response shapes
    - **Service(s)**: business logic responsibilities, async patterns, transaction handling
    - **Repository/DAO**: data access methods, query patterns, ORM usage
    - **Model/Schema**: data structure, field types, validations, relationships
    - **DTOs / Validators**: request/response schemas, validation library (Zod, Joi, etc.)
    - **Middleware**: any new middleware needed (auth guards, rate limiting, logging)

    ### 2. Data Model
    - New collections/tables with field definitions and types
    - Relationships (foreign keys, embedded documents, references)
    - Indexing strategy for query performance
    - Database migration or schema update content (Prisma migration, Mongoose schema, SQL DDL)

    ### 3. API Design
    - Complete REST API specification: endpoint, HTTP method, request body schema,
      response schema, HTTP status codes, error responses
    - Pagination/filtering strategy if collections are returned
    - Input validation rules per field

    ### 4. Security Design
    - Which endpoints require authentication/authorization
    - Role or permission requirements
    - Input sanitization strategy
    - Sensitive data handling (what NOT to return in responses)
    - Rate limiting if applicable

    ### 5. Integration Design
    - External service/queue contracts and how they will be called
    - Async vs. sync integration strategy
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

Save the output to:

**Output file:** `.node-dev/03-architecture.md`

Update `state.json`: set `current_step` to `"checkpoint-1"`, add step 3 to `completed_steps`.

---

## PHASE CHECKPOINT 1 — Architecture Review

You MUST stop here. Present a concise summary and ask via `AskUserQuestion`:

```
Architecture design complete. Review .node-dev/03-architecture.md for full details.

Components: [list router/service/repository/model names from the design]
Data model: [summary of new models/collections and schema changes]
API: [list of new endpoints]
Security: [auth requirements summary]

1. Approve — proceed to implementation
2. Request changes — tell me what to adjust
3. Pause — save progress and stop here
```

Do NOT proceed to Phase 4 until the user selects option 1.
If they select option 2, revise `.node-dev/03-architecture.md` and re-checkpoint.
If option 3, update `state.json` status to `"paused"` and stop.

---

## Phase 4: Node.js Implementation (Step 4)

### Step 4: Implement the Feature

Read `.node-dev/01-requirements.md`, `.node-dev/02-codebase-analysis.md`, and `.node-dev/03-architecture.md`.

use skill `programming-skills:terminal-monitor` with: `mode: subagent`, `label: 🟢 Node.js Developer`, `pane-name: 🟢 node`, `output-file: .node-dev/04-implementation.md`

Then launch the implementation agent — use `node:typescript-developer` if the project uses TypeScript, or `node:javascript-developer` if it uses plain JavaScript (check the codebase analysis):

```
Agent:
  subagent_type: "node:typescript-developer"   # or node:javascript-developer
  description: "Implement Node.js feature: $FEATURE"
  prompt: |
    You are a senior Node.js backend engineer. Implement this feature based on the
    approved architecture and the existing codebase patterns.

    ## Feature Requirements
    [Insert full contents of .node-dev/01-requirements.md]

    ## Existing Codebase Patterns
    [Insert full contents of .node-dev/02-codebase-analysis.md]

    ## Approved Architecture
    [Insert full contents of .node-dev/03-architecture.md]

    ## Implementation Instructions

    1. Implement exactly what is specified in the architecture — router/controller,
       service, repository/DAO, model/schema, DTOs, middleware.
    2. Match ALL existing code patterns from the codebase analysis: folder structure,
       naming conventions, module export style (CommonJS vs. ESM), error handling
       approach, middleware composition, async patterns.
    3. Use async/await consistently. Avoid mixing Promises and callbacks.
    4. Apply input validation on all incoming request data using the project's
       existing validation library (Zod, Joi, class-validator, etc.).
    5. Implement proper error propagation — throw typed errors and let the global
       error handler catch them, unless the project uses a different convention.
    6. Add database migrations or schema updates as specified in the architecture,
       following the existing migration tooling and naming conventions.
    7. Add inline comments only where business logic is non-obvious.
    8. Do NOT introduce new libraries unless clearly necessary and explicitly approved
       in the architecture or already present in package.json.

    Use the `Skill` tool with the following skills as needed:
    - "node:nodejs-backend-patterns" — for Node.js service architecture, middleware, error handling
    - "node:typescript-advanced-types" — for TypeScript type design (if TypeScript project)
    - "node:javascript-modern-patterns" — for modern async/await and ES module patterns
    - "node:javascript-coding-standards" — for code style and naming conventions
    - "node:auth-implementation-patterns" — if the feature involves auth or authorization

    Write all code files directly to the project directory.
    After implementation, report a complete summary as a markdown document listing:
    - Every file created or modified (with path and brief description of changes)
    - Key implementation decisions and patterns used
    - Any deviations from the architecture and why
    - Database migration or schema files created
```

Save the agent's summary to:

**Output file:** `.node-dev/04-implementation.md`

```markdown
# Implementation Summary: $FEATURE

## Files Created

- `src/modules/feature/feature.router.ts`: Route definitions and request validation.
- `src/modules/feature/feature.service.ts`: Business logic.
- `src/modules/feature/feature.repository.ts`: Data access layer.
- `src/modules/feature/feature.schema.ts`: Zod/Joi request/response schemas.
- `prisma/migrations/YYYYMMDD_add_feature_table.sql`: Database migration.

## Files Modified

- `src/app.ts`: Registered new feature router.
- `src/types/index.ts`: Added feature-related types.

## Key Decisions

- [Decision 1 and rationale]
- [Decision 2 and rationale]

## Deviations from Architecture

- [Any deviations and why — or "None"]
```

Update `state.json`: set `current_step` to `"checkpoint-2"`, add step 4 to `completed_steps`.

---

## PHASE CHECKPOINT 2 — Implementation Review

You MUST stop here. Ask via `AskUserQuestion`:

```
Implementation complete. Review .node-dev/04-implementation.md for full details.

Files created: [count] | Files modified: [count]
Key changes: [2-3 bullet points of most important changes]
Migrations/schema updates: [list of files, or "None"]

1. Approve — proceed to testing and code review
2. Request changes — tell me what to fix
3. Pause — save progress and stop here
```

Do NOT proceed to Phase 5 until the user selects option 1.

---

## Phase 5: Quality — Testing & Review (Step 5)

### Step 5: Parallel Testing and Code Review

Read `.node-dev/01-requirements.md`, `.node-dev/03-architecture.md`, and `.node-dev/04-implementation.md`.

use skill `programming-skills:terminal-monitor` with: `mode: subagent`, `label: 🧪 Test Automator`, `pane-name: 🧪 tests`, `output-file: .node-dev/05-quality.md`
use skill `programming-skills:terminal-monitor` with: `mode: subagent`, `label: 🔎 Code Reviewer`, `pane-name: 🔎 reviewer`, `output-file: .node-dev/05-quality.md`

Launch TWO agents in parallel in a single response:

**5a. Test Automator:**

```
Agent:
  subagent_type: "programming-skills:test-automator"
  description: "Create test suite for $FEATURE"
  prompt: |
    You are a Node.js test engineer. Create a comprehensive test suite for this
    Node.js backend feature.

    ## Requirements
    [Insert full contents of .node-dev/01-requirements.md]

    ## Architecture
    [Insert full contents of .node-dev/03-architecture.md]

    ## Implementation Summary
    [Insert full contents of .node-dev/04-implementation.md]

    ## Testing Instructions

    1. Write unit tests for all new service methods.
       Mock all dependencies (repository, external services).
       Cover: happy path, business rule violations, edge cases
       (null/undefined inputs, empty arrays, boundary values).

    2. Write unit tests for all new repository/DAO methods using an
       in-memory database or test containers if used in the project.
       Test query correctness, pagination, and filtering.

    3. Write integration/API tests for all new endpoints using Supertest
       (or the project's existing HTTP test client).
       Cover: valid requests (201/200), validation errors (400),
       unauthorized access (401/403), not-found cases (404), server errors (500).

    4. Write at least one end-to-end integration test for the primary happy path
       using a real database connection (test database or Testcontainers).

    5. Follow the existing test patterns, file naming conventions, and directory
       structure from the codebase analysis.

    6. Target 80%+ coverage for new code.

    Use the `Skill` tool with:
    - "node:javascript-testing-patterns" — for Jest/Vitest patterns, mocking, fixtures
    - "node:node-tests" — for Node.js-specific test setup and Supertest patterns
    - "node:playwright-expert" — if E2E browser tests are required

    Write all test files directly to the project directory.
    Report a summary of: test files created, what each covers, and any coverage gaps.
```

**5b. Code Reviewer:**

```
Agent:
  subagent_type: "programming-skills:code-reviewer"
  description: "Code review for $FEATURE"
  prompt: |
    You are a senior Node.js code reviewer. Perform a thorough review of this
    backend feature implementation.

    ## Requirements
    [Insert full contents of .node-dev/01-requirements.md]

    ## Approved Architecture (for conformance check)
    [Insert full contents of .node-dev/03-architecture.md]

    ## Codebase Patterns (for consistency check)
    [Insert full contents of .node-dev/02-codebase-analysis.md]

    ## Implementation Summary
    [Insert full contents of .node-dev/04-implementation.md]

    ## Review Dimensions

    Review ALL of the following dimensions. For each finding include severity
    (Critical, High, Medium, Low), the affected file:line if known, and a
    specific fix recommendation.

    1. **Correctness**: Logic errors, incorrect HTTP status codes, missing null/undefined
       checks, improper Promise handling (unhandled rejections, missing await).

    2. **Architecture conformance**: Does the implementation match the approved
       architecture? Check for layering violations (e.g., DB query in router), missing
       components, or unapproved deviations.

    3. **Node.js patterns**: Blocking I/O on the event loop, missing async/await,
       callback hell, improper error propagation, memory leaks (event listener
       accumulation, unclosed streams), unhandled Promise rejections.

    4. **Code consistency**: Does the code match the patterns documented in the
       codebase analysis? (naming, folder structure, module style, error handling)

    5. **Security**: Missing input validation, SQL/NoSQL injection risks, sensitive
       data exposed in responses, improper auth checks, missing rate limiting
       where required, prototype pollution risks.

    6. **Performance**: N+1 database query patterns, missing pagination, synchronous
       operations blocking the event loop, unnecessary data fetched from DB,
       missing indexes implied by query patterns.

    7. **Maintainability**: Overly complex functions, magic values that should be
       constants or config, missing TypeScript types (if TS project), unclear
       variable names, duplicated logic.

    Format findings as a structured markdown list:
    ```
    - **Severity**: High
      **File**: `src/modules/feature/feature.service.ts:54`
      **Finding**: Unhandled Promise rejection — repository call not wrapped in try/catch
        and not propagated to the global error handler.
      **Fix**: Wrap in try/catch and re-throw a typed AppError, or let it bubble
        through if the global handler catches unhandled rejections.
    ```

    Use the `Skill` tool with:
    - "node:nodejs-backend-patterns" — for Node.js-specific review patterns and anti-patterns
    - "node:javascript-modern-patterns" — for async patterns and modern JS/TS idioms
    - "node:auth-implementation-patterns" — for security review of auth-related code

    Provide an overall assessment: Approved / Approved with minor fixes / Requires changes.
```

After both complete, consolidate into:

**Output file:** `.node-dev/05-quality.md`

```markdown
# Quality Report: $FEATURE

## Test Suite

[Summary from test automator — test files created, coverage areas, gaps]

## Code Review Findings

[Consolidated findings list from code reviewer]

### Overall Assessment

[Approved / Approved with minor fixes / Requires changes]

## Action Items (Critical & High severity)

[List of Critical and High findings that MUST be addressed before delivery]
```

**If Critical or High severity findings exist**, address them now:
1. Apply fixes directly or spawn a focused `node:typescript-developer` (or `javascript-developer`) agent to fix them.
2. Update `.node-dev/04-implementation.md` with any additional files changed.
3. Re-run the code reviewer on the changed files only.

Update `state.json`: set `current_step` to `"checkpoint-3"`, add step 5 to `completed_steps`.

---

## PHASE CHECKPOINT 3 — Quality Review

You MUST stop here. Ask via `AskUserQuestion`:

```
Testing and code review complete. Review .node-dev/05-quality.md for full details.

Tests: [number of test files created] test files
Code review: [count Critical] Critical | [count High] High | [count Medium] Medium findings
Overall assessment: [Approved / Approved with minor fixes / Requires changes]
Critical/High items addressed: [Yes / None found]

1. Approve — proceed to final delivery
2. Request changes — tell me what to fix
3. Pause — save progress and stop here
```

Do NOT proceed to Phase 6 until the user selects option 1.

---

## Phase 6: Delivery (Step 6)

### Step 6: Summary, Review, and Commit

#### 6a. Generate Final Summary

Read all `.node-dev/*.md` files and write:

**Output file:** `.node-dev/06-summary.md`

```markdown
# Feature Delivery Summary: $FEATURE

## What Was Built

[2-4 sentence description of the feature and its business purpose]

## Files Created

[Complete list from 04-implementation.md + 05-quality.md test files]

## Files Modified

[Complete list of modified files]

## Database / Schema Changes

[List of migration or schema files and what they do — or "None"]

## API Surface

[List of new endpoints: METHOD /path — brief description]

## Quality Assurance

- Tests: [list of test files and what they cover]
- Code review assessment: [overall assessment]
- Issues resolved: [list of Critical/High findings addressed, or "None found"]

## Points of Attention

[List any Medium/Low review findings NOT fixed — explain why deferred and recommended follow-up]
[Any known limitations, TODO comments, or tech debt introduced]
[Any deviations from requirements and why]

## Impact Map

[Which modules and parts of the application were touched and how they interact]

## How to Test Manually

1. [Step 1 — e.g., "Install dependencies: npm install"]
2. [Step 2 — e.g., "Run migrations: npm run migrate"]
3. [Step 3 — e.g., "Start server: npm run dev"]
4. [Step 4 — e.g., "Call the endpoint: curl -X POST /api/features ..."]
5. [Step 5 — edge cases to verify manually]
```

Present the summary to the user and ask via `AskUserQuestion`:

```
Feature implementation is complete. Here's what was built:

[Paste "What Was Built", "API Surface", and "Points of Attention" sections inline]

Please:
1. Review the code in the files listed above
2. Run the test suite: [insert the project's test command, e.g., `npm test`]
3. Perform manual verification using the steps in .node-dev/06-summary.md

When you're ready:
1. Approve — commit the changes
2. Request changes — tell me what to fix
3. Abort — discard all changes
```

Wait for user response. If they request changes, implement them and return to this checkpoint.

#### 6b. Commit

Once the user approves:

1. Run `git status` to confirm the changed files match the implementation summary.
2. Stage all implementation and test files explicitly (do NOT use `git add .`).
3. Check recent `git log` to match the project's commit message convention. Then commit:

```
feat(<module>): [brief description of the feature]

- [Key change 1]
- [Key change 2]
- [Key change 3]
- Add schema/migration: [migration file name if applicable]

Co-Authored-By: Claude Code
```

4. Confirm the commit succeeded with `git status`.

Then ask via `AskUserQuestion`:

```
Changes committed successfully.

Branch: [current branch name]
Commit: [commit hash and message]

Would you like to open a Pull Request?

1. Yes — create a PR now
2. No — I'll open the PR manually later
```

#### 6c. Pull Request (if requested)

If the user says yes, create the PR using `gh pr create`:

- **Title**: `feat(<module>): [feature name]` (short, under 70 characters)
- **Body**: Include What Was Built, API Surface, files changed, how to test manually, and Points of Attention from `.node-dev/06-summary.md`

Return the PR URL to the user.

---

## Completion

Update `state.json`:

```json
{
  "status": "complete",
  "last_updated": "ISO_TIMESTAMP"
}
```

#### Move artifacts to feature docs folder

Derive the feature folder name from `$FEATURE`: lowercase, spaces replaced by hyphens, special characters removed (e.g., `"User Authentication"` → `user-authentication`). Call this `$FEATURE_SLUG`. Also capture today's date as `$DATE` (format `YYYY-MM-DD`).

Create the destination directory and move all generated files:

```bash
DATE=$(date +%Y-%m-%d)
mkdir -p .specs/features/$DATE-$FEATURE_SLUG/artifacts/node
mv .node-dev/01-requirements.md      .specs/features/$DATE-$FEATURE_SLUG/artifacts/node/
mv .node-dev/02-codebase-analysis.md .specs/features/$DATE-$FEATURE_SLUG/artifacts/node/
mv .node-dev/03-architecture.md      .specs/features/$DATE-$FEATURE_SLUG/artifacts/node/
mv .node-dev/04-implementation.md    .specs/features/$DATE-$FEATURE_SLUG/artifacts/node/
mv .node-dev/05-quality.md           .specs/features/$DATE-$FEATURE_SLUG/artifacts/node/
mv .node-dev/06-summary.md           .specs/features/$DATE-$FEATURE_SLUG/artifacts/node/
mv .node-dev/state.json              .specs/features/$DATE-$FEATURE_SLUG/artifacts/node/
```

After moving, remove the now-empty `.node-dev/` directory:

```bash
rmdir .node-dev
```

Present the final message:

```
Node.js backend feature development complete: $FEATURE

Artifacts saved to .specs/features/$DATE-$FEATURE_SLUG/artifacts/node/:
- 01-requirements.md      — Requirements
- 02-codebase-analysis.md — Codebase exploration
- 03-architecture.md      — Backend architecture design
- 04-implementation.md    — Implementation summary
- 05-quality.md           — Tests & code review
- 06-summary.md           — Final delivery summary

Next steps (if any):
[List any deferred items from points of attention]
```
