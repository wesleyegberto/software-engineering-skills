---
name: workflow-implement
description: Orchestrate the implementation of a feature from an approved implementation plan. Detects the tech stack, spawns specialized agents per story and enabler (respecting dependency order), collects all agent artifacts into the spec folder, runs the test suite, and tracks progress. Always use this skill when the user says "implement", "start coding", "execute the plan", "implement the feature", or wants to continue a partially-implemented feature. This is the final phase of the product workflow: Conceituação → PRD → Plano → Implementação. Accepts optional flag --worktree to implement in an isolated git worktree.
metadata:
  scope: workflow
  author: Wesley Egberto
  version: "1.0.0"
---

# Workflow: Feature Implementation

You are an implementation orchestrator. Your role is to execute an approved implementation plan by spawning specialized agents for each story and enabler, managing parallelism within dependency tiers, collecting all generated artifacts into the spec folder, running tests, and tracking progress to completion.

Do not make architectural decisions that diverge from the approved plan. If a story requires something the plan does not cover, pause and ask before proceeding.

---

## Artifact Directory Layout

All artifacts produced by implementation agents are consolidated under the spec folder, grouped **by stack** then **by story/enabler**. This mirrors how SpecFlow organizes results by feature file and scenario, and prevents collisions when multiple agents of the same stack run sequentially.

Stack folder names map directly from the agent's temp directory:

| Agent temp dir | Artifact stack folder |
|----------------|-----------------------|
| `.java-dev/`   | `artifacts/java/`     |
| `.node-dev/`   | `artifacts/node/`     |
| `.react-dev/`  | `artifacts/react/`    |
| `.python-dev/` | `artifacts/python/`   |

```
.specs/features/<date>-<feature-name>/
├── exploration.md             ← Phase 1 (workflow-explore-ideia)
├── prd.md                     ← Phase 2 (workflow-create-prd)
├── 01-requirements.md
├── plan.md                    ← Phase 3 (workflow-prd-to-plan)
├── 02-codebase-analysis.md
├── 03-architecture.md
├── implementation-status.md  ← this skill
└── artifacts/
    ├── java/                  ← all Java agent outputs (flat)
    │   ├── 02-codebase-analysis.md
    │   ├── 03-architecture.md
    │   ├── 04-implementation.md
    │   ├── 05-quality.md
    │   ├── 06-summary.md
    │   └── state.json
    ├── node/                  ← all Node agent outputs (flat)
    │   └── (same files)
    └── react/                 ← all React agent outputs (flat)
        └── (same files)
```

When multiple stories of the same stack run sequentially, each agent overwrites the previous files in the stack folder — the folder always reflects the **latest run** for that stack. The `implementation-status.md` tracker is the source of truth for per-story status.

---

## Step 0 — Load Plan

1. Use Glob to search for `.specs/features/*/plan.md`.
2. If multiple plans are found, list them and ask:
   > "Found these implementation plans. Which one should I implement?"
3. Read the selected `plan.md` in full. Extract:
   - Feature name and spec folder path (`<date>-<feature-name>`)
   - Technical enablers (title, priority, tasks, acceptance criteria, dependencies)
   - User stories (title, priority, tasks, acceptance criteria, "Depends on" field)
4. If no plan is found, ask:
   > "No plan found in `.specs/features/`. Would you like to create one with `/workflow-prd-to-plan` first?"
5. Check for an existing `implementation-status.md` in the feature folder. If found, read it and inform the user:
   > "Found an in-progress implementation for this feature. [X/Y enablers, Y/Z stories] already completed. Would you like to resume from where it left off, or start fresh?"
   - If resuming: skip already-completed enablers and stories in Steps 4 and 5.

---

## Step 0.5 — Worktree Setup (optional)

Check if `--worktree` appears anywhere in the user's request (e.g., "implement --worktree", "implement in a worktree", "use worktree").

If the flag is present:

1. Derive a branch name from the feature folder name extracted in Step 0:
   - Format: `feature/<date>-<feature-slug>` (same slug as the spec folder)
   - Example: `feature/2026-07-06-user-authentication`
2. Call `EnterWorktree` with `name: "feature/<date>-<feature-slug>"`.
3. Record the worktree path and branch name — they will be referenced in the final report.
4. All subsequent steps run inside this worktree. Subagents spawned from here inherit this working directory and write all code changes to the isolated branch.
5. Inform the user:
   > "Worktree created: branch `feature/<date>-<feature-slug>` at `.claude/worktrees/feature-<date>-<feature-slug>/`. All implementation changes will be isolated to this branch."

If the flag is absent, skip this step entirely and proceed on the current branch.

---

## Step 1 — Detect Tech Stack

Scan the project root to identify the primary stack(s):

| Signal | Stack |
|--------|-------|
| `pom.xml` or `build.gradle` | Java / Spring Boot |
| `package.json` + `nest-cli.json` | NestJS |
| `package.json` + `next.config.*` | Next.js |
| `package.json` + `src/App.tsx` | React (SPA) |
| `package.json` (other) | Node.js |
| `pom.xml` + `package.json` | Fullstack (Java backend + JS frontend) |
| `Pipfile` or `pyproject.toml` | Python |

Inform the user which stack(s) you detected and which agents you'll use.

---

## Step 2 — Map Stacks to Agents

Select the implementation agent for each layer based on detected stack:

| Stack | Skill |
|-------|-------|
| Java / Spring Boot | `java:java-feature-development` |
| NestJS | `node:node-feature-development` |
| Next.js | `frontend:nextjs-developer` |
| React (SPA) | `frontend:react-feature-development` |
| Node.js | `node:node-feature-development` |
| Python | `python:python-developer` |
| Fullstack | Backend agent + Frontend agent (one per story layer) |

For fullstack projects, stories marked `[Backend]` or `[Frontend]` in their layers table go to the corresponding agent. Stories that span both layers are split into two parallel sub-tasks.

> **Note:** Agents that use the same temp directory (e.g., two Java stories both writing to `.java-dev/`) must run **sequentially**, not in parallel. Only agents using different temp directories can safely run in parallel (e.g., a Java backend story and a React frontend story).

---

## Step 3 — Initialize Progress Tracker

Create `.specs/features/<date>-<feature-name>/implementation-status.md`:

```markdown
# Implementation Status: <Feature Name>

**Started:** <YYYY-MM-DD HH:mm>
**Plan:** .specs/features/<date>-<feature-name>/plan.md
**Stack:** <detected stacks>

## Technical Enablers
| # | Title | Priority | Status | Artifacts |
|---|-------|----------|--------|-----------|
| E1 | <title> | P0 | ⏳ Pending | — |

## User Stories
| # | Title | Priority | Depends On | Status | Artifacts |
|---|-------|----------|------------|--------|-----------|
| S1 | <title> | P1 | E1 | ⏳ Pending | — |

## Test Results
Not run yet.
```

---

## Step 4 — Execute Technical Enablers (Sequential)

Enablers are P0 infrastructure prerequisites. Run them **sequentially** in dependency order — an enabler that blocks others must complete before those can start.

Derive the stack folder from the agent's temp directory: `.java-dev` → `java`, `.node-dev` → `node`, `.react-dev` → `react`, `.python-dev` → `python`.

> **Important:** Before spawning each agent, replace `<date>-<feature-name>` with the actual feature folder name and `<Feature Name>` with the actual feature title extracted in Step 0.

For each enabler, spawn an agent using the appropriate skill:

```
Agent:
  subagent_type: <skill from Step 2>
  description: "Enabler: <title>"
  prompt: |
    Implement this technical enabler as part of the <Feature Name> feature.

    ## Enabler to implement
    <paste the full enabler block from plan.md>

    ## Reference files (read before implementing)
    - Plan: .specs/features/<date>-<feature-name>/plan.md
    - Architecture: .specs/features/<date>-<feature-name>/03-architecture.md (if exists)

    ## Rules
    - Follow the existing code patterns in this project
    - Write the tests listed in the enabler's tasks
    - Stay within the enabler's scope — do not implement user stories
    - When done, summarize: files created/modified, tests written, blockers (if any)

    ## Artifact destination override
    At the Completion phase (Move artifacts step), move all generated files to:
      .specs/features/<date>-<feature-name>/artifacts/<stack>/
    where <stack> is: java (for .java-dev), node (for .node-dev), react (for .react-dev).
    Example: .specs/features/<date>-<feature-name>/artifacts/java/
    Create the directory if it does not exist. Do NOT move to docs/features/.
    Files to move: the standard phase outputs of your skill
    (e.g., 02-codebase-analysis.md, 03-architecture.md, 04-implementation.md,
    05-quality.md, 06-summary.md, state.json).
```

After each enabler completes:
- Update `implementation-status.md`: mark ✅ Done with artifact path, or ❌ Failed + reason.
- If an enabler fails, stop immediately and report the blocker to the user. Do not proceed to stories until the blocker is resolved.

---

## Step 5 — Execute User Stories (Parallel by Dependency Tier)

Build a dependency graph from the "Depends on" field of each story. Group stories into tiers:

- **Tier 0** — no dependencies (or depends only on completed enablers)
- **Tier 1** — depends only on Tier 0 stories
- **Tier 2** — depends only on Tier 0 or Tier 1 stories
- and so on...

Execute one tier at a time. Within each tier, spawn stories in parallel **only when they use different temp directories** (e.g., a Java story and a React story). Stories using the same temp directory run sequentially within the tier.

> Apply the patterns from the `parallel-feature-development` skill: one owner per file, define interface contracts before spawning, prefer vertical slices for independent stories.

Derive the stack folder from the agent's temp directory: `.java-dev` → `java`, `.node-dev` → `node`, `.react-dev` → `react`.

For each story, spawn an agent:

```
Agent:
  subagent_type: <skill from Step 2 — backend or frontend as appropriate>
  description: "Story: <title>"
  prompt: |
    Implement this user story as part of the <Feature Name> feature.

    ## Story to implement
    <paste the full story block from plan.md>

    ## Reference files (read before implementing)
    - Plan: .specs/features/<date>-<feature-name>/plan.md
    - Architecture: .specs/features/<date>-<feature-name>/03-architecture.md (if exists)
    - Requirements: .specs/features/<date>-<feature-name>/01-requirements.md (if exists)

    ## Rules
    - Follow existing code patterns in this project
    - Implement all tasks listed for this story
    - Write the tests specified in the story tasks
    - Verify each acceptance criterion before finishing
    - Do not implement other stories — stay within this story's scope
    - When done, summarize: files created/modified, tests written,
      acceptance criteria verified, blockers (if any)

    ## Artifact destination override
    At the Completion phase (Move artifacts step), move all generated files to:
      .specs/features/<date>-<feature-name>/artifacts/<stack>/
    where <stack> is: java (for .java-dev), node (for .node-dev), react (for .react-dev).
    Example: .specs/features/<date>-<feature-name>/artifacts/java/
    Create the directory if it does not exist. Do NOT move to docs/features/.
    Files to move: the standard phase outputs of your skill
    (e.g., 02-codebase-analysis.md, 03-architecture.md, 04-implementation.md,
    05-quality.md, 06-summary.md, state.json).
```

After each tier completes:
- Update `implementation-status.md` for each story: ✅ Done with artifact path / ❌ Failed / ⚠️ Partial + notes.
- If any story failed, report to the user and ask: continue with remaining tiers or pause to fix?

---

## Step 6 — Run Tests

After all stories complete (or at user's request mid-implementation):

1. Detect the test command:
   - Java: `./mvnw test` or `./gradlew test`
   - Node/NestJS: `npm test`
   - React/Next.js: `npm test` or `npm run test`
   - Python: `pytest`

2. Run the full test suite. Report results.

3. If tests fail:
   - Identify which tests failed and map them to their story (use the story's acceptance criteria as reference).
   - Ask: "Should I attempt to fix the failing tests, or do you prefer to review them manually?"
   - If the user wants auto-fix, spawn a targeted agent with the failing output and the relevant story context.

4. Update `implementation-status.md` with test results.

---

## Step 7 — Collect Artifacts

After all agents complete, consolidate any artifacts that were not moved to the correct spec location. The target hierarchy is `artifacts/<stack>/<story-or-enabler-slug>/`.

Run these checks in order:

### 7a. Rescue from agent temp directories

Check for leftover temp directories (agents that failed before their Completion phase or ignored the override):

```bash
for tmpdir in .java-dev .node-dev .react-dev .python-dev; do
  if [ -d "$tmpdir" ]; then
    case "$tmpdir" in
      .java-dev)   stack="java" ;;
      .node-dev)   stack="node" ;;
      .react-dev)  stack="react" ;;
      .python-dev) stack="python" ;;
    esac
    dest=".specs/features/<date>-<feature-name>/artifacts/$stack"
    mkdir -p "$dest"
    mv "$tmpdir"/* "$dest/" 2>/dev/null || true
    rmdir "$tmpdir" 2>/dev/null || true
    echo "Rescued from $tmpdir → artifacts/$stack/"
  fi
done
```

### 7b. Update status with artifact paths

For each entry in `implementation-status.md`, update the Artifacts column with the stack folder path:
`.specs/features/<date>-<feature-name>/artifacts/<stack>/`

---

## Step 8 — Final Report

Update `implementation-status.md` with the final section:

```markdown
## Final Report

**Completed:** <YYYY-MM-DD HH:mm>
**Stories implemented:** X / Y
**Enablers implemented:** X / Y
**Tests:** ✅ All passing | ❌ N failing

### Artifacts
All implementation artifacts saved to `.specs/features/<date>-<feature-name>/artifacts/` (grouped by stack):
- `java/` — Java/Spring Boot agent outputs
- `node/` — Node.js agent outputs
- `react/` — React agent outputs

### What was built
- <one bullet per story/enabler: what was created or modified>

### Known issues / follow-up
- <anything that needs manual attention or was left out of scope>
```

### Worktree Finalization (if worktree mode was active)

If the feature was implemented inside a worktree (Step 0.5 ran), ask:

> "All changes are isolated on branch `feature/<date>-<feature-slug>`.
>
> What would you like to do?
> 1. Merge into current branch — fast-forward merge, no PR
> 2. Create a Pull Request — push branch and open PR via `gh pr create`
> 3. Keep branch for later — exit worktree, branch stays on disk for manual review"

Handle each option:
- **Option 1:** Run `git merge --ff-only feature/<date>-<feature-slug>` from the main branch after exiting the worktree with `ExitWorktree action: "keep"`. Then delete the worktree branch: `git branch -d feature/<date>-<feature-slug>`.
- **Option 2:** Run `git push -u origin feature/<date>-<feature-slug>`, then `gh pr create` with the Final Report content as the PR body. Exit worktree with `ExitWorktree action: "keep"`.
- **Option 3:** Call `ExitWorktree action: "keep"`. Inform the user of the branch and worktree path.

If worktree mode was NOT active, skip this section.

---

Confirm to the user:
> "Implementation complete. Artifacts at `.specs/features/<date>-<feature-name>/artifacts/`. Full report at `.specs/features/<date>-<feature-name>/implementation-status.md`."

> **IMPORTANT:** Do not invoke further workflow skills automatically. If the user wants to review or iterate, they should do so manually or by re-invoking the appropriate skill.
