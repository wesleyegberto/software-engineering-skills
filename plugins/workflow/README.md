# Workflow Plugin

Skills to orchestrate the complete software development lifecycle — from raw idea to implementation — compatible with any methodology (Scrum, Kanban, Shape Up, etc.) and applicable at any granularity: feature, story, or task.

---

## Recommended Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DEVELOPMENT LIFECYCLE                        │
└─────────────────────────────────────────────────────────────────────┘

           Raw idea or problem
                    │
                    ▼
         ┌──────────────────┐
         │  /workflow-      │  Progressive Socratic interview
         │  explore-ideia   │  → validates problem, users, scope
         └────────┬─────────┘
                  │  exploration.md saved to .specs/features/
                  │
                  ▼
         ┌──────────────────┐
         │  /workflow-      │  Requirements interview + codebase
         │  create-prd      │  analysis → PRD document
         └────────┬─────────┘
                  │  prd.md saved to .specs/features/
                  │
                  ▼
         ┌──────────────────┐
         │  /workflow-      │  Architectural analysis + breakdown
         │  prd-to-plan     │  into enablers and estimated stories
         └────────┬─────────┘
                  │  plan.md saved to .specs/features/
                  │
                  ▼
         ┌──────────────────┐
         │  /workflow-      │  Detects stack → spawns specialized
         │  implement       │  agents per layer
         └────────┬─────────┘
                  │  artifacts in .specs/features/artifacts/
                  ▼
              ✅ Feature delivered

────────────────────────────────────────────────────────────────────
 Each skill ends with a user confirmation step before the next one.
 No automatic transitions — the user controls when to advance.
────────────────────────────────────────────────────────────────────
 Shortcuts (alternative entry points)
────────────────────────────────────────────────────────────────────
 • Have a clear idea?      → skip to /workflow-create-prd
 • Have a ready PRD?       → skip to /workflow-prd-to-plan
 • Have an approved plan?  → go straight to /workflow-implement
```

---

## Skills

### `/workflow-explore-ideia`

**Goal:** Turn a raw idea into a mature requirement, ready to become a PRD, through a structured Socratic interview.

**When to use:**
- You have a vague idea and want to develop it before writing requirements
- You want to validate hypotheses and map risks before committing effort
- Triggered by: "explore idea", "I have an idea", "let's explore"

**Exploration phases:**

| Phase | Focus | Questions |
|-------|-------|-----------|
| 1 — Problem Understanding | Clarity on the real problem | What pain? For whom? Impact of not solving it? |
| 2 — Solution Exploration | Alternatives and opportunities | How to solve it? What alternatives? What else does this enable? |
| 3 — Constraints & Risks | Feasibility and dependencies | What can go wrong? What integrations? Technical constraints? |
| 4 — Success Criteria | Definition of "done" | How will we know it worked? Smallest scope with real value? |

**Maturity checklist** (before advancing):
- [ ] Problem clearly defined and validated
- [ ] Target users identified
- [ ] Proposed solution addresses the problem
- [ ] Alternatives considered with justification
- [ ] Non-negotiable requirements listed
- [ ] Main use cases mapped
- [ ] Dependencies and risks identified
- [ ] Success criterion defined
- [ ] Feature scoped

**Output:** `.specs/features/<YYYY-MM-DD>-<feature-name>/exploration.md`

**Transition:** Workflow ends here; user invokes `/workflow-create-prd` when ready.

---

### `/workflow-create-prd`

**Goal:** Produce a complete PRD by combining a requirements interview with analysis of the existing codebase.

**When to use:**
- Idea already explored and mature (or clear enough to go directly)
- Triggered by: "create PRD", "requirements document", "plan feature"

**Steps:**

| Step | Action |
|------|--------|
| 0 — Context Check | Checks for existing explorations in `.specs/features/`; offers reuse or fresh start |
| 1 — Requirements Gathering | Requirements interview with the user |
| 2 — Codebase Exploration | Analyzes existing code, patterns, dependencies |
| 3 — Deep-Dive Interview | Technical questions specific to the codebase context |
| 4 — Module Design | Defines modules, APIs, implementation and testing decisions |

**Generated PRD structure:**
- Problem Statement
- Solution
- User Stories
- Implementation Decisions
- Testing Decisions
- Out of Scope
- Further Notes

**Output:** `.specs/features/<YYYY-MM-DD>-<feature-name>/prd.md`

**Transition:** Workflow ends here; user invokes `/workflow-prd-to-plan` when ready.

---

### `/workflow-prd-to-plan`

**Goal:** Transform the PRD into a detailed implementation plan with technical enablers and per-layer estimated user stories.

**When to use:**
- PRD approved and ready for technical planning
- Triggered by: "plan implementation", "break down into tasks", "implementation plan"

**Steps:**

| Step | Action |
|------|--------|
| 0 — Context Check | Locates the PRD; confirms feature to plan |
| 1 — Codebase Exploration | Parallel analysis: architecture, patterns, dependencies, API contracts |
| 2 — Architectural Decisions | Identifies durable architecture decisions with justifications and alternatives |
| 3 — Technical Enablers | Lists infrastructure prerequisites (P0) that block stories |
| 4 — User Stories | Breaks down into stories following INVEST criteria, prioritized and estimated |
| 5 — Review | Presents plan to user for validation |
| 6 — Save | Saves `plan.md` with full structure |
| 7 — Handoff | Prepares transition to implementation |

**Story criteria:**
- INVEST validation (Independent, Negotiable, Valuable, Estimable, Small, Testable)
- Priority: P0 (critical) → P1 (important) → P2 (nice-to-have)
- Fibonacci estimation: 1 / 2 / 3 / 5 / 8 pts

**Output:** `.specs/features/<YYYY-MM-DD>-<feature-name>/plan.md`

**Transition:** Workflow ends here; user invokes `/workflow-implement` when ready.

---

### `/workflow-implement`

**Goal:** Orchestrate the complete feature implementation from the approved plan, dispatching specialized agents per stack and layer.

**When to use:**
- Plan approved, ready to code
- Triggered by: "implement", "start coding", "execute the plan"

**Steps:**

| Step | Action |
|------|--------|
| 0 — Load Plan | Loads `plan.md`; checks progress status |
| 1 — Detect Tech Stack | Identifies languages, frameworks, layers |
| 2 — Map Stacks to Agents | Selects specialized skill per layer |
| 3 — Initialize Tracker | Creates `implementation-status.md` with status for each item |
| 4 — Execute Enablers | Runs P0 enablers **sequentially** in dependency order |
| 5 — Execute Stories | Runs stories **in parallel** by dependency tier |
| 6 — Run Tests | Executes test suite; reports coverage and failures |
| 7 — Collect Artifacts | Consolidates artifacts into `.specs/features/.../artifacts/` |
| 8 — Final Report | Summary of stories, tests, artifacts, and pending items |

**Artifact structure:**
```
.specs/features/<date>-<feature>/
├── 01-requirements.md         ← output from workflow-create-prd (Step 1)
├── 02-codebase-analysis.md    ← output from workflow-prd-to-plan (Step 1)
├── 03-architecture.md         ← output from workflow-prd-to-plan (Step 2)
├── exploration.md             ← output from workflow-explore-ideia
├── prd.md                     ← output from workflow-create-prd (Step 4)
├── plan.md                    ← output from workflow-prd-to-plan (Step 6)
├── implementation-status.md   ← implementation tracker
└── artifacts/
    ├── java/            ← Java agent artifacts
    ├── node/            ← Node agent artifacts
    ├── react/           ← React agent artifacts
    └── python/          ← Python agent artifacts
```

---

## Specialized Skills in the Implementation Phase

`/workflow-implement` detects the stack and delegates to specialized skills. Each skill knows the patterns, conventions, and tooling of its ecosystem.

| Detected stack | Skill used | Intent |
|----------------|------------|--------|
| Java / Spring Boot | `java:java-feature-development` | Implements with Spring, JPA patterns, JUnit tests |
| NestJS | `node:node-feature-development` | Implements NestJS modules with decorators and DI |
| Node.js | `node:node-feature-development` | Implements Node services and APIs with best practices |
| Next.js | `frontend:nextjs-developer` | Implements App Router pages, Server Components, RSC |
| React (SPA) | `frontend:react-feature-development` | Implements React components with hooks and state |
| Python | `python:python-developer` | Implements with modern Python patterns (uv, ruff, pydantic) |
| Fullstack | Backend agent **+** Frontend agent | `[Backend]` and `[Frontend]` stories are split and run in parallel |

> **Parallelism note:** Agents sharing the same temp directory (e.g., two Java agents writing to `.java-dev/`) must run **sequentially**. Agents on different layers (e.g., Java backend + React frontend) can run **in parallel**.

---

## Directory Structure

```
.specs/
└── features/
    └── <YYYY-MM-DD>-<feature-name>/
        ├── exploration.md
        ├── 01-requirements.md
        ├── prd.md
        ├── 02-codebase-analysis.md
        ├── 03-architecture.md
        ├── plan.md
        ├── implementation-status.md
        └── artifacts/
            ├── java/
            ├── node/
            ├── react/
            └── python/
```

---

## Compatibility

The plugin is methodology-agnostic. Adapt the flow to your context:

| Methodology | Suggested granularity | Notes |
|-------------|----------------------|-------|
| Scrum | Feature / Epic | One full cycle per sprint or epic |
| Kanban | Story / Task | Enter directly at `/workflow-create-prd` or `/workflow-prd-to-plan` |
| Shape Up | Shape / Pitch | Use `/workflow-explore-ideia` as betting table prep |
| Solo dev | Feature / Task | Use the full flow or just the final skills |
