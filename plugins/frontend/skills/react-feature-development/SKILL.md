---
name: react-feature-development
description: Orchestrate end-to-end React feature development from idea or plan to reviewed, committed code. Use this skill proactively when the user wants to implement a feature, page, component, or UI flow in a React application — even if they just say "implement this", "build this", "add this to the app", "develop this plan", or "create this screen". Spawns parallel specialist subagents for codebase exploration, UX design, React implementation, testing, and code review, then guides the user through approval, commit, and optional PR creation.
license: MIT
metadata:
  author: Wesley Egberto
  version: "1.0.0"
  domain: frontend
  triggers: React, feature, implement, build, develop, plan, component, page, UI, screen, interface, frontend
  role: orchestrator
  scope: implementation
  output-format: code + summary
  related-skills: react-expert, react-patterns, react-state-management, frontend-design, e2e-testing-patterns
---

# React Feature Development Orchestrator

## Objective

Orchestrate the complete development of a React feature — from requirements through implementation, testing, review, and delivery. Uses specialized subagents running in parallel where possible to accelerate the workflow without sacrificing quality.

---

## Subagent Team

This skill **starts a team of specialist subagents** to parallelize and accelerate the implementation. Before proceeding, inform the user which agents will be used:

```
This skill will coordinate a team of specialist subagents to implement your feature:

  🔍 Code Explorer      — maps the existing codebase, patterns, and impact areas
  🎨 UX Designer        — designs user flows, component hierarchy, and interaction states
  ⚛️  React Developer    — implements components, hooks, services, and routing
  🧪 Test Automator     — writes unit, component, integration, and E2E tests
  🔎 Code Reviewer      — reviews for correctness, performance, security, and consistency

Agents run in parallel where possible to save time.

Shall I start the team and begin the feature development workflow?
1. Yes — let's go
2. No — I'll implement manually
```

Use `AskUserQuestion` to present this message and wait for confirmation before continuing.
If the user selects option 2, stop and let them proceed on their own.

---

## CRITICAL BEHAVIORAL RULES

Follow these rules exactly. Violating any of them is a failure.

1. **Execute steps in order.** Do NOT skip ahead, reorder, or merge steps.
2. **Write output files.** Each step MUST produce its output file in `.react-dev/` before the next step begins. Read from prior step files — do NOT rely on context window memory.
3. **Stop at checkpoints.** When you reach a `PHASE CHECKPOINT`, you MUST stop and wait for explicit user approval using `AskUserQuestion`. Do NOT continue automatically.
4. **Halt on failure.** If any agent errors or a step cannot be completed, STOP immediately and ask the user how to proceed.
5. **Respect scope.** This is a React/frontend-focused orchestrator. For full-stack features, use the general `feature-development` command instead.
6. **Never enter plan mode autonomously.** Do NOT call `EnterPlanMode` — this skill IS the plan. Execute it.

---

## Pre-flight Checks

### 1. Check for existing session

Check if `.react-dev/state.json` exists:

- If `status` is `"in_progress"`: Read it and ask the user via `AskUserQuestion`:

  ```
  Found an in-progress React feature session:
  Feature: [name from state]
  Current step: [step from state]

  1. Resume from where we left off
  2. Start fresh (archives existing session to .react-dev/archive/)
  ```

- If `status` is `"complete"`: Ask whether to archive and start fresh.

### 2. Initialize state

Create `.react-dev/` directory and `state.json`:

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

## Phase 1: Discovery (Steps 1–2) — Interactive

### Step 1: Requirements Gathering

Gather requirements through interactive Q&A using `AskUserQuestion`. Ask ONE question at a time — do NOT dump all questions at once.

**Questions to ask (in order):**

1. **Feature description**: "Describe the feature, page, or component to be built. What is its purpose and who will use it?"
2. **Screens and components**: "Which existing screens or components are affected or need to be created?"
3. **Acceptance criteria**: "What are the key acceptance criteria? When is this feature 'done'?"
4. **Design references**: "Are there mockups, Figma files, or design references? If so, share them. If not, should I propose a design approach?"
5. **API / data contracts**: "Does this feature consume APIs or backend data? If so, what are the endpoints or data shapes? (Share contracts if available)"
6. **Technical constraints**: "Any technical constraints? (e.g., must use specific state management, library version, existing component library, performance budget)"

After gathering answers, write:

**Output file:** `.react-dev/01-requirements.md`

```markdown
# Requirements: $FEATURE

## Feature Description

[From Q1]

## Screens and Components Affected

[From Q2]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Design References

[From Q4 — mockup links, descriptions, or "design to be proposed"]

## API / Data Contracts

[From Q5 — endpoints, request/response shapes, or "no external API"]

## Technical Constraints

[From Q6]
```

Update `state.json`: set `current_step` to 2, add `"01-requirements.md"` to `files_created`.

---

### Step 2: Parallel Analysis — Codebase + UX Design

Read `.react-dev/01-requirements.md`. Then launch TWO agents in parallel in a single response using the `Agent` tool:

**2a. Codebase Explorer:**

```
Agent:
  subagent_type: "programming-skills:code-explorer"
  description: "Explore React codebase for $FEATURE"
  prompt: |
    You are a codebase explorer. Analyze the React project to map the existing patterns
    and identify what needs to change to implement this feature.

    ## Feature Requirements
    [Insert full contents of .react-dev/01-requirements.md]

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

**2b. UX Designer:**

```
Agent:
  subagent_type: "frontend:ui-ux-designer"
  description: "Design UX approach for $FEATURE"
  prompt: |
    You are a UX designer specializing in React applications.
    Analyze the feature requirements and propose a detailed UX/UI design approach.

    ## Feature Requirements
    [Insert full contents of .react-dev/01-requirements.md]

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

**Output file:** `.react-dev/02-analysis.md`

```markdown
# Codebase & UX Analysis: $FEATURE

## Codebase Findings

[Full output from code explorer — project structure, patterns, impact map]

## UX Design Approach

[Full output from UX designer — user flows, component hierarchy, state design]
```

Update `state.json`: set `current_step` to `"checkpoint-1"`, add step 2 to `completed_steps`.

---

## PHASE CHECKPOINT 1 — Analysis Review

You MUST stop here. Present a concise summary and ask via `AskUserQuestion`:

```
Analysis complete. Review .react-dev/02-analysis.md for full details.

Codebase summary: [2-3 bullet points from explorer — key patterns and impact map]
UX design summary: [2-3 bullet points from designer — user flows and component hierarchy]

1. Approve — proceed to implementation
2. Request changes — tell me what to adjust
3. Pause — save progress and stop here
```

Do NOT proceed to Phase 2 until the user selects option 1.
If they select option 2, revise the relevant section of `.react-dev/02-analysis.md` and re-checkpoint.
If option 3, update `state.json` status to `"paused"` and stop.

---

## Phase 2: React Implementation (Step 3)

### Step 3: Implement the Feature

Read `.react-dev/01-requirements.md` and `.react-dev/02-analysis.md`.

Use `EnterWorktree` to create an isolated development branch before implementation begins. This protects the main branch during development.

Then launch the React developer agent:

```
Agent:
  subagent_type: "frontend:react-developer"
  isolation: "worktree"
  description: "Implement React feature: $FEATURE"
  prompt: |
    You are a senior React developer. Implement this feature based on the approved
    requirements and analysis.

    ## Feature Requirements
    [Insert full contents of .react-dev/01-requirements.md]

    ## Codebase & UX Analysis
    [Insert full contents of .react-dev/02-analysis.md]

    ## Implementation Instructions
    1. Follow the component hierarchy and user flows from the UX analysis exactly.
    2. Match the existing code patterns documented in the codebase analysis — naming conventions,
       file structure, state management approach, API integration style, and styling method.
    3. Implement all required states: loading, empty, error, success, and any optimistic updates.
    4. Add accessibility: semantic HTML, ARIA labels where needed, keyboard navigation.
    5. Keep components focused and composable — avoid monolithic components.
    6. Add inline comments only where logic is non-obvious.
    7. Do NOT introduce new libraries unless clearly necessary and not already available in the project.

    Use the `Skill` tool with the following skills as needed:
    - "frontend:react-expert" — for React 19+ patterns, hooks, Server Components
    - "frontend:react-patterns" — for reusable component patterns
    - "frontend:react-state-management" — for state management decisions

    Write all code files directly to the project directory.
    After implementation, report a complete summary as a markdown document listing:
    - Every file created or modified (with path and brief description of changes)
    - Key implementation decisions and patterns used
    - Any deviations from the analysis and why
```

Save the agent's summary to:

**Output file:** `.react-dev/03-implementation.md`

```markdown
# Implementation Summary: $FEATURE

## Files Created

- `src/components/FeatureName/FeatureName.tsx`: [description]
- `src/components/FeatureName/FeatureName.module.css`: [description]
- `src/hooks/useFeatureName.ts`: [description]
- `src/services/featureNameService.ts`: [description]

## Files Modified

- `src/routes/index.tsx`: Added route for new feature page.
- `src/store/featureSlice.ts`: Added state slice for feature data.

## Key Decisions

- [Decision 1 and rationale]
- [Decision 2 and rationale]

## Deviations from Analysis

- [Any deviations and why — or "None"]
```

Update `state.json`: set `current_step` to `"checkpoint-2"`, add step 3 to `completed_steps`.

---

## PHASE CHECKPOINT 2 — Implementation Review

You MUST stop here. Present a summary and ask via `AskUserQuestion`:

```
Implementation complete. Review .react-dev/03-implementation.md for full details.

Files created: [count] | Files modified: [count]
Key changes: [2-3 bullet points of most important changes]

1. Approve — proceed to testing and code review
2. Request changes — tell me what to fix
3. Pause — save progress and stop here
```

Do NOT proceed to Phase 3 until the user selects option 1.

---

## Phase 3: Quality — Testing & Review (Step 4)

### Step 4: Parallel Testing and Code Review

Read `.react-dev/01-requirements.md`, `.react-dev/02-analysis.md`, and `.react-dev/03-implementation.md`.

Launch TWO agents in parallel in a single response:

**4a. Test Automator:**

```
Agent:
  subagent_type: "programming-skills:test-automator"
  description: "Create test suite for $FEATURE"
  prompt: |
    You are a frontend test engineer. Create a comprehensive test suite for this
    React feature.

    ## Requirements
    [Insert full contents of .react-dev/01-requirements.md]

    ## Implementation Summary
    [Insert full contents of .react-dev/03-implementation.md]

    ## Testing Instructions
    1. Write unit tests for all new custom hooks and utility functions.
    2. Write component tests using React Testing Library for all new components —
       cover: render, user interactions, loading states, error states, empty states.
    3. Write integration tests for key user flows (as described in requirements).
    4. Write at least one E2E test for the primary happy path using the project's E2E framework.
    5. Follow the existing test patterns and file conventions found in the codebase analysis.
    6. Target 80%+ coverage for new code.
    7. Mock external APIs and dependencies appropriately.

    Use the `Skill` tool with "frontend:e2e-testing-patterns" for E2E test guidance.

    Write all test files directly to the project directory.
    Report a summary of: test files created, what each covers, and any coverage gaps identified.
```

**4b. Code Reviewer:**

```
Agent:
  subagent_type: "programming-skills:code-reviewer"
  description: "Code review for $FEATURE"
  prompt: |
    You are a senior React code reviewer. Perform a thorough review of this
    feature implementation.

    ## Requirements
    [Insert full contents of .react-dev/01-requirements.md]

    ## Codebase Patterns (for consistency check)
    [Insert the "Codebase Findings" section from .react-dev/02-analysis.md]

    ## Implementation Summary
    [Insert full contents of .react-dev/03-implementation.md]

    ## Review Dimensions
    Review ALL of these dimensions. For each finding, include severity
    (Critical, High, Medium, Low), the affected file:line if known, and a specific fix recommendation.

    1. **Correctness**: Logic errors, off-by-one bugs, incorrect API usage, missing null checks.
    2. **React patterns**: Correct hook usage, unnecessary re-renders, missing dependencies in useEffect/useCallback/useMemo, key props in lists.
    3. **Code consistency**: Does the code match existing patterns documented in the codebase analysis?
    4. **Accessibility**: Missing ARIA attributes, keyboard navigation issues, insufficient color contrast descriptions.
    5. **Performance**: Unnecessary re-renders, missing memoization, large bundle additions, unoptimized images.
    6. **Security**: XSS vectors (dangerouslySetInnerHTML), unvalidated user input rendered to DOM, sensitive data in state.
    7. **Maintainability**: Overly complex components, missing error boundaries, hardcoded values that should be constants.

    Format your findings as a structured markdown list:
    ```
    - **Severity**: High
      **File**: `src/components/Feature/Feature.tsx:42`
      **Finding**: useEffect missing dependency causing stale closure.
      **Fix**: Add `userId` to the dependency array.
    ```

    Provide an overall assessment: Approved / Approved with minor fixes / Requires changes.
```

After both complete, consolidate into:

**Output file:** `.react-dev/04-quality.md`

```markdown
# Quality Report: $FEATURE

## Test Suite

[Summary from test automator — files created, coverage areas, gaps]

## Code Review Findings

[Consolidated findings list from code reviewer]

### Overall Assessment

[Approved / Approved with minor fixes / Requires changes]

## Action Items (Critical & High severity)

[List of Critical and High findings that MUST be addressed before delivery]
```

**If Critical or High severity findings exist**, address them now:
1. Apply fixes directly or spawn a focused `frontend:react-developer` agent to fix them.
2. Update `.react-dev/03-implementation.md` with any additional files changed.
3. Re-run the code reviewer on the changed files only.

Update `state.json`: set `current_step` to `"checkpoint-3"`, add step 4 to `completed_steps`.

---

## PHASE CHECKPOINT 3 — Quality Review

You MUST stop here. Ask via `AskUserQuestion`:

```
Testing and code review complete. Review .react-dev/04-quality.md for full details.

Tests: [number of test files created] test files | [coverage summary]
Code review: [count Critical] Critical | [count High] High | [count Medium] Medium findings
Overall assessment: [Approved / Approved with minor fixes / Requires changes]

Critical/High items addressed: [Yes / None found]

1. Approve — proceed to final delivery
2. Request changes — tell me what to fix
3. Pause — save progress and stop here
```

Do NOT proceed to Phase 4 until the user selects option 1.

---

## Phase 4: Delivery (Step 5)

### Step 5: Summary, Review, and Commit

#### 5a. Generate Final Summary

Read all `.react-dev/*.md` files and write:

**Output file:** `.react-dev/05-summary.md`

```markdown
# Feature Delivery Summary: $FEATURE

## What Was Built

[2-4 sentence description of the feature and its purpose]

## Files Created

[Complete list from 03-implementation.md + 04-quality.md test files]

## Files Modified

[Complete list of modified files]

## Quality Assurance

- Tests: [list of test files and what they cover]
- Code review assessment: [overall assessment]
- Issues resolved: [list of Critical/High findings addressed, or "None found"]

## Points of Attention

[List any Medium/Low review findings NOT fixed — explain why deferred and recommended follow-up]
[List any known limitations or TODOs left in the code]
[Any areas where the implementation deviates from requirements and why]

## Impact Map

[From codebase analysis — which parts of the app were touched and how they interact]

## How to Test Manually

1. [Step 1 to verify the feature works end-to-end]
2. [Step 2]
3. [Step 3 — edge cases to check]
```

Present the summary to the user and then ask via `AskUserQuestion`:

```
Feature implementation is complete. Here's what was built:

[Paste the "What Was Built" and "Points of Attention" sections inline]

Please:
1. Review the code in the files listed above
2. Run the test suite: [insert the project's test command, e.g., `npm test`]
3. Perform manual verification using the steps in .react-dev/05-summary.md

When you're ready:
1. Approve — commit the changes
2. Request changes — tell me what to fix
3. Abort — discard all changes
```

Wait for user response. If they request changes, implement them and return to this checkpoint.

#### 5b. Commit

Once the user approves, perform the commit:

1. Run `git status` to confirm the changed files match the implementation summary.
2. Stage all implementation and test files (be explicit — do NOT use `git add .`).
3. Create a commit with a descriptive message following the project's commit convention (check recent `git log` to match the style):

```
feat(react): [brief description of the feature]

- [Key change 1]
- [Key change 2]
- [Key change 3]

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

#### 5c. Pull Request (if requested)

If the user says yes, create the PR using `gh pr create`:

- **Title**: `feat: [feature name]` (short, under 70 characters)
- **Body**: Include What Was Built, files changed, how to test manually, and the points of attention from `.react-dev/05-summary.md`

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

Present the final message:

```
React feature development complete: $FEATURE

Artifacts:
- .react-dev/01-requirements.md — Requirements
- .react-dev/02-analysis.md    — Codebase & UX analysis
- .react-dev/03-implementation.md — Implementation summary
- .react-dev/04-quality.md     — Tests & code review
- .react-dev/05-summary.md     — Final delivery summary

Next steps (if any):
[List any deferred items from points of attention]
```
