---
name: java-feature-development
description: Orchestrate end-to-end Java Spring Boot feature development from idea or plan to reviewed, committed code. Use this skill proactively when the user wants to implement a feature, endpoint, service, domain object, or integration in a Spring Boot application — even if they just say "implement this", "add this endpoint", "build this service", "develop this plan", or "create this API". Spawns parallel specialist subagents for codebase exploration, architecture planning, Spring Boot implementation, testing, and code review, then guides the user through approval, commit, and optional PR creation.
license: MIT
metadata:
  author: Wesley Egberto
  version: "1.0.0"
  domain: backend
  triggers: Java, Spring Boot, Spring, feature, implement, build, develop, endpoint, API, service, domain, repository, entity, backend
  role: orchestrator
  scope: implementation
  output-format: code + summary
  related-skills: java-spring-boot-expert, java-architect, java-spring-boot-testing, java-spring-boot-security, java-jpa-patterns, terminal-monitor
---

# Java Spring Boot Feature Development Orchestrator

## Objective

Orchestrate the complete development of a Java Spring Boot feature — from requirements through architecture planning, implementation, testing, review, and delivery. Uses specialized subagents running in parallel where possible to accelerate the workflow without sacrificing quality.

---

## Subagent Team

This skill **starts a team of specialist subagents** to parallelize and accelerate the implementation. Before proceeding, inform the user which agents will be used:

```
This skill will coordinate a team of specialist subagents to implement your feature:

  🔍 Code Explorer        — maps the existing codebase, patterns, and impact areas
  🏗️  Backend Architect    — designs the component structure, API, data model, and security
  ☕ Spring Boot Engineer  — implements controller, service, repository, entities, DTOs, and migrations
  🧪 Test Automator       — writes unit, slice (@WebMvcTest/@DataJpaTest), and integration tests
  🔎 Code Reviewer        — reviews for correctness, Spring patterns, security, and performance

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
| 2 – Code Explorer | `subagent` | `🔍 Code Explorer` | `🔍 explorer` | `.java-dev/02-codebase-analysis.md` |
| 3 – Backend Architect | `subagent` | `🏗️ Backend Architect` | `🏗️ architect` | `.java-dev/03-architecture.md` |
| 4 – Spring Boot Engineer | `subagent` | `☕ Spring Boot Engineer` | `☕ engineer` | `.java-dev/04-implementation.md` |
| 5a – Test Automator | `subagent` | `🧪 Test Automator` | `🧪 tests` | `.java-dev/05-quality.md` |
| 5b – Code Reviewer | `subagent` | `🔎 Code Reviewer` | `🔎 reviewer` | `.java-dev/05-quality.md` |

---

## CRITICAL BEHAVIORAL RULES

Follow these rules exactly. Violating any of them is a failure.

1. **Execute steps in order.** Do NOT skip ahead, reorder, or merge steps.
2. **Write output files.** Each step MUST produce its output file in `.java-dev/` before the next step begins. Read from prior step files — do NOT rely on context window memory.
3. **Stop at checkpoints.** When you reach a `PHASE CHECKPOINT`, you MUST stop and wait for explicit user approval using `AskUserQuestion`. Do NOT continue automatically.
4. **Halt on failure.** If any agent errors or a step cannot be completed, STOP immediately and ask the user how to proceed.
5. **Architecture before code.** The `backend-architect` step MUST complete and be approved before implementation begins. Do NOT skip or merge it with implementation.
6. **Never enter plan mode autonomously.** Do NOT call `EnterPlanMode` — this skill IS the plan. Execute it.

---

## Pre-flight Checks

### 1. Check for existing session

Check if `.java-dev/state.json` exists:

- If `status` is `"in_progress"`: Read it and ask the user via `AskUserQuestion`:

  ```
  Found an in-progress Java feature session:
  Feature: [name from state]
  Current step: [step from state]

  1. Resume from where we left off
  2. Start fresh (archives existing session to .java-dev/archive/)
  ```

- If `status` is `"complete"`: Ask whether to archive and start fresh.

### 2. Initialize state

Create `.java-dev/` directory and `state.json`:

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

1. **Feature description**: "Describe the feature to be built. What is its purpose, and which business domain does it belong to?"
2. **API contract**: "Describe the API surface needed: HTTP methods, endpoint paths, request/response payloads. If there's an existing API spec (OpenAPI, Swagger), share it."
3. **Acceptance criteria**: "What are the key acceptance criteria? When is this feature 'done'?"
4. **Data and persistence**: "What data needs to be persisted? Are there new entities, or does this extend existing ones? Share the relevant schema or entity relationships if available."
5. **Integrations**: "Does this feature call external services, message queues, or other microservices? If so, describe the integration contracts."
6. **Non-functional requirements**: "Any NFRs to consider? (e.g., latency SLA, throughput, security rules, multi-tenancy, audit logging, transaction boundaries)"
7. **Out of scope**: "What is explicitly OUT of scope for this feature?"

After gathering answers, write:

**Output file:** `.java-dev/01-requirements.md`

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

[From Q4 — entities, relationships, schema changes]

## Integrations

[From Q5 — external services, queues, other microservices]

## Non-Functional Requirements

[From Q6 — latency, security, transactions, audit]

## Out of Scope

[From Q7]
```

Update `state.json`: set `current_step` to 2, add `"01-requirements.md"` to `files_created`.

---

## Phase 2: Codebase Analysis (Step 2)

### Step 2: Codebase Exploration

Read `.java-dev/01-requirements.md`.

use skill `programming-skills:terminal-monitor` with: `mode: subagent`, `label: 🔍 Code Explorer`, `pane-name: 🔍 explorer`, `output-file: .java-dev/02-codebase-analysis.md`

Launch the codebase explorer:

```
Agent:
  subagent_type: "programming-skills:code-explorer"
  description: "Explore Spring Boot codebase for $FEATURE"
  prompt: |
    You are a codebase explorer. Analyze this Spring Boot project to map existing
    patterns and identify exactly what needs to change to implement this feature.

    ## Feature Requirements
    [Insert full contents of .java-dev/01-requirements.md]

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

Save the output to:

**Output file:** `.java-dev/02-codebase-analysis.md`

Update `state.json`: set `current_step` to 3, add step 2 to `completed_steps`.

---

## Phase 3: Architecture Planning (Step 3)

### Step 3: Backend Architecture Design

Read `.java-dev/01-requirements.md` and `.java-dev/02-codebase-analysis.md`.

use skill `programming-skills:terminal-monitor` with: `mode: subagent`, `label: 🏗️ Backend Architect`, `pane-name: 🏗️ architect`, `output-file: .java-dev/03-architecture.md`

Launch the architecture agent:

```
Agent:
  subagent_type: "backend-architect"
  description: "Design backend architecture for $FEATURE"
  prompt: |
    You are a backend architect. Design the detailed technical architecture for this
    Spring Boot feature, grounded in the existing codebase patterns.

    ## Feature Requirements
    [Insert full contents of .java-dev/01-requirements.md]

    ## Existing Codebase Patterns
    [Insert full contents of .java-dev/02-codebase-analysis.md]

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

Save the output to:

**Output file:** `.java-dev/03-architecture.md`

Update `state.json`: set `current_step` to `"checkpoint-1"`, add step 3 to `completed_steps`.

---

## PHASE CHECKPOINT 1 — Architecture Review

You MUST stop here. Present a concise summary and ask via `AskUserQuestion`:

```
Architecture design complete. Review .java-dev/03-architecture.md for full details.

Components: [list controller/service/repository names from the design]
Data model: [summary of new entities/tables and migrations]
API: [list of new endpoints]
Security: [auth requirements summary]

1. Approve — proceed to implementation
2. Request changes — tell me what to adjust
3. Pause — save progress and stop here
```

Do NOT proceed to Phase 4 until the user selects option 1.
If they select option 2, revise `.java-dev/03-architecture.md` and re-checkpoint.
If option 3, update `state.json` status to `"paused"` and stop.

---

## Phase 4: Spring Boot Implementation (Step 4)

### Step 4: Implement the Feature

Read `.java-dev/01-requirements.md`, `.java-dev/02-codebase-analysis.md`, and `.java-dev/03-architecture.md`.

use skill `programming-skills:terminal-monitor` with: `mode: subagent`, `label: ☕ Spring Boot Engineer`, `pane-name: ☕ engineer`, `output-file: .java-dev/04-implementation.md`

Then launch the Spring Boot implementation agent:

```
Agent:
  subagent_type: "java:java-spring-boot"
  description: "Implement Spring Boot feature: $FEATURE"
  prompt: |
    You are a senior Spring Boot engineer. Implement this feature based on the
    approved architecture and existing codebase patterns.

    ## Feature Requirements
    [Insert full contents of .java-dev/01-requirements.md]

    ## Existing Codebase Patterns
    [Insert full contents of .java-dev/02-codebase-analysis.md]

    ## Approved Architecture
    [Insert full contents of .java-dev/03-architecture.md]

    ## Implementation Instructions

    1. Implement exactly what is specified in the architecture — controller, service,
       repository, entities, DTOs, and database migrations.
    2. Match ALL existing code patterns from the codebase analysis: package naming,
       class structure, annotation usage, DTO conventions, error handling style.
    3. Use constructor injection with `private final` fields for all dependencies.
    4. Add Bean Validation annotations on all request DTOs.
    5. Respect existing transaction boundaries — annotate service methods with
       `@Transactional` where the architecture specifies.
    6. Write database migrations following the existing Flyway/Liquibase conventions.
    7. Add inline comments only where business logic is non-obvious.
    8. Do NOT introduce new libraries unless clearly necessary and already on the
       classpath or explicitly approved in the architecture.

    Use the `Skill` tool with the following skills as needed:
    - "java:java-spring-boot-expert" — for Spring Boot 3.x patterns, annotations, configuration
    - "java:java-jpa-patterns" — for JPA entity design, relationships, and query optimization
    - "java:java-coding-standards" — for code style and naming conventions
    - "java:java-spring-boot-security" — if the feature involves security or authorization

    Also consult these command references for patterns:
    - "java:spring-boot" — Spring Boot best practices
    - "java:docs" — documentation standards if public APIs are added
    - "java:junit" — test patterns (for awareness; tests will be written separately)

    Write all code files directly to the project directory.
    After implementation, report a complete summary as a markdown document listing:
    - Every file created or modified (with path and brief description of changes)
    - Key implementation decisions and patterns used
    - Any deviations from the architecture and why
    - Database migration files created
```

Save the agent's summary to:

**Output file:** `.java-dev/04-implementation.md`

```markdown
# Implementation Summary: $FEATURE

## Files Created

- `src/main/java/com/example/feature/FeatureController.java`: REST controller with endpoints.
- `src/main/java/com/example/feature/FeatureService.java`: Business logic and transaction management.
- `src/main/java/com/example/feature/FeatureRepository.java`: Spring Data JPA repository.
- `src/main/java/com/example/feature/domain/Feature.java`: JPA entity.
- `src/main/java/com/example/feature/dto/FeatureRequest.java`: Request DTO with validation.
- `src/main/java/com/example/feature/dto/FeatureResponse.java`: Response DTO.
- `src/main/resources/db/migration/V{N}__create_feature_table.sql`: Flyway migration.

## Files Modified

- `src/main/java/com/example/config/SecurityConfig.java`: Added authorization rules for new endpoints.

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
Implementation complete. Review .java-dev/04-implementation.md for full details.

Files created: [count] | Files modified: [count]
Key changes: [2-3 bullet points of most important changes]
Migrations: [list of migration files, or "None"]

1. Approve — proceed to testing and code review
2. Request changes — tell me what to fix
3. Pause — save progress and stop here
```

Do NOT proceed to Phase 5 until the user selects option 1.

---

## Phase 5: Quality — Testing & Review (Step 5)

### Step 5: Parallel Testing and Code Review

Read `.java-dev/01-requirements.md`, `.java-dev/03-architecture.md`, and `.java-dev/04-implementation.md`.

use skill `programming-skills:terminal-monitor` with: `mode: subagent`, `label: 🧪 Test Automator`, `pane-name: 🧪 tests`, `output-file: .java-dev/05-quality.md`
use skill `programming-skills:terminal-monitor` with: `mode: subagent`, `label: 🔎 Code Reviewer`, `pane-name: 🔎 reviewer`, `output-file: .java-dev/05-quality.md`

Launch TWO agents in parallel in a single response:

**5a. Test Automator:**

```
Agent:
  subagent_type: "programming-skills:test-automator"
  description: "Create test suite for $FEATURE"
  prompt: |
    You are a Java test engineer. Create a comprehensive test suite for this
    Spring Boot feature.

    ## Requirements
    [Insert full contents of .java-dev/01-requirements.md]

    ## Architecture
    [Insert full contents of .java-dev/03-architecture.md]

    ## Implementation Summary
    [Insert full contents of .java-dev/04-implementation.md]

    ## Testing Instructions

    1. Write unit tests for all new service methods using JUnit 5 + Mockito.
       Mock all dependencies. Cover: happy path, business rule violations,
       edge cases (null inputs, empty collections, boundary values).

    2. Write integration tests for all new repository methods using @DataJpaTest
       and Testcontainers (if already used in the project) or an H2 in-memory DB.
       Test custom queries and pagination.

    3. Write API/slice tests for all new controller endpoints using @WebMvcTest
       (or @SpringBootTest with MockMvc). Cover: valid requests, validation errors
       (400), unauthorized access (401/403), not-found cases (404), server errors (500).

    4. Write at least one end-to-end integration test for the primary happy path
       using @SpringBootTest with a real database.

    5. Follow the existing test patterns, class naming, and file location conventions
       from the codebase analysis.

    6. Target 80%+ coverage for new code.

    Use the `Skill` tool with:
    - "java:java-spring-boot-testing" — for Spring Boot test slice patterns and Testcontainers
    - "java:junit" command reference — for JUnit 5 and Mockito patterns

    Write all test files directly to the project directory.
    Report a summary of: test files created, what each covers, and any coverage gaps.
```

**5b. Code Reviewer:**

```
Agent:
  subagent_type: "programming-skills:code-reviewer"
  description: "Code review for $FEATURE"
  prompt: |
    You are a senior Java code reviewer. Perform a thorough review of this
    Spring Boot feature implementation.

    ## Requirements
    [Insert full contents of .java-dev/01-requirements.md]

    ## Approved Architecture (for conformance check)
    [Insert full contents of .java-dev/03-architecture.md]

    ## Codebase Patterns (for consistency check)
    [Insert full contents of .java-dev/02-codebase-analysis.md]

    ## Implementation Summary
    [Insert full contents of .java-dev/04-implementation.md]

    ## Review Dimensions

    Review ALL of the following dimensions. For each finding include severity
    (Critical, High, Medium, Low), the affected file:line if known, and a
    specific fix recommendation.

    1. **Correctness**: Logic errors, incorrect JPA mappings, wrong HTTP status codes,
       missing null checks, off-by-one in pagination.

    2. **Architecture conformance**: Does the implementation match the approved
       architecture? Check layering violations (e.g., repository called from controller),
       missing components, or unapproved deviations.

    3. **Spring Boot patterns**: Incorrect use of @Transactional, N+1 query risks,
       missing indexes, lazy vs. eager loading issues, improper use of @Autowired,
       bean scope problems.

    4. **Code consistency**: Does the code match the patterns documented in the
       codebase analysis? (naming, package structure, DTO conventions, error handling)

    5. **Security**: Missing authorization checks, SQL injection risks in custom queries,
       sensitive data exposed in response DTOs, improper input validation.

    6. **Performance**: Unoptimized queries (missing pagination, SELECT *), missing
       database indexes, unnecessary eager loading, large result sets loaded into memory.

    7. **Maintainability**: God classes, missing or incorrect exception types, hardcoded
       values that should be configuration, overly complex methods.

    Format findings as a structured markdown list:
    ```
    - **Severity**: High
      **File**: `src/main/java/com/example/feature/FeatureService.java:87`
      **Finding**: @Transactional missing on method that performs multiple writes.
      **Fix**: Add @Transactional to ensure atomicity across the two repository calls.
    ```

    Use the `Skill` tool with:
    - "java:java-code-review" — for Java-specific review patterns and anti-patterns
    - "java:java-spring-boot-security" — for security review of Spring Boot code

    Provide an overall assessment: Approved / Approved with minor fixes / Requires changes.
```

After both complete, consolidate into:

**Output file:** `.java-dev/05-quality.md`

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
1. Apply fixes directly or spawn a focused `java:java-spring-boot` agent to fix them.
2. Update `.java-dev/04-implementation.md` with any additional files changed.
3. Re-run the code reviewer on the changed files only.

Update `state.json`: set `current_step` to `"checkpoint-3"`, add step 5 to `completed_steps`.

---

## PHASE CHECKPOINT 3 — Quality Review

You MUST stop here. Ask via `AskUserQuestion`:

```
Testing and code review complete. Review .java-dev/05-quality.md for full details.

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

Read all `.java-dev/*.md` files and write:

**Output file:** `.java-dev/06-summary.md`

```markdown
# Feature Delivery Summary: $FEATURE

## What Was Built

[2-4 sentence description of the feature and its business purpose]

## Files Created

[Complete list from 04-implementation.md + 05-quality.md test files]

## Files Modified

[Complete list of modified files]

## Database Migrations

[List of migration files and what they do — or "None"]

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

[Which parts of the application were touched and how they interact with the rest of the system]

## How to Test Manually

1. [Step 1 — e.g., "Start the application: ./mvnw spring-boot:run"]
2. [Step 2 — e.g., "Call the endpoint: curl -X POST /api/features ..."]
3. [Step 3 — edge cases to verify manually]
```

Present the summary to the user and ask via `AskUserQuestion`:

```
Feature implementation is complete. Here's what was built:

[Paste "What Was Built", "API Surface", and "Points of Attention" sections inline]

Please:
1. Review the code in the files listed above
2. Run the test suite: [insert the project's test command, e.g., `./mvnw test`]
3. Perform manual verification using the steps in .java-dev/06-summary.md

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
feat(<domain>): [brief description of the feature]

- [Key change 1]
- [Key change 2]
- [Key change 3]
- Add database migration: [migration file name]

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

- **Title**: `feat(<domain>): [feature name]` (short, under 70 characters)
- **Body**: Include What Was Built, API Surface, files changed, how to test manually, and Points of Attention from `.java-dev/06-summary.md`

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
mkdir -p .specs/features/$DATE-$FEATURE_SLUG/artifacts/java
mv .java-dev/01-requirements.md      .specs/features/$DATE-$FEATURE_SLUG/artifacts/java/
mv .java-dev/02-codebase-analysis.md .specs/features/$DATE-$FEATURE_SLUG/artifacts/java/
mv .java-dev/03-architecture.md      .specs/features/$DATE-$FEATURE_SLUG/artifacts/java/
mv .java-dev/04-implementation.md    .specs/features/$DATE-$FEATURE_SLUG/artifacts/java/
mv .java-dev/05-quality.md           .specs/features/$DATE-$FEATURE_SLUG/artifacts/java/
mv .java-dev/06-summary.md           .specs/features/$DATE-$FEATURE_SLUG/artifacts/java/
mv .java-dev/state.json              .specs/features/$DATE-$FEATURE_SLUG/artifacts/java/
```

After moving, remove the now-empty `.java-dev/` directory:

```bash
rmdir .java-dev
```

Present the final message:

```
Java Spring Boot feature development complete: $FEATURE

Artifacts saved to .specs/features/$DATE-$FEATURE_SLUG/artifacts/java/:
- 01-requirements.md      — Requirements
- 02-codebase-analysis.md — Codebase exploration
- 03-architecture.md      — Backend architecture design
- 04-implementation.md    — Implementation summary
- 05-quality.md           — Tests & code review
- 06-summary.md           — Final delivery summary

Next steps (if any):
[List any deferred items from points of attention]
```
