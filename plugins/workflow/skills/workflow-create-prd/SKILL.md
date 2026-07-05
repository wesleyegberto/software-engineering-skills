---
name: workflow-create-prd
description: Create a PRD through user interview, codebase exploration, and module design, then submit as a GitHub issue. Use when user wants to write a PRD, create a product requirements document, or plan a new feature.
metadata:
  scope: workflow
  author: Wesley Egberto
  version: "1.0.0"
---

This skill will be invoked when the user wants to create a PRD. You may skip steps if you don't consider them necessary.

## Step 0 — Context Check

Before anything else, determine how the user wants to start:

1. Check if any exploration files exist under `.specs/features/` (use Glob to look for `.specs/features/*/exploration.md`).

2. If exploration files are found, present the list of feature folders and ask:
   > "I found previous idea exploration files in `.specs/features/`. Would you like to use one of them as the basis for this PRD, or start fresh with a new idea?"

   - **If the user picks one:** Read `.specs/features/<date>-<feature-name>/exploration.md` and use its content to pre-fill the context. Reuse the **same folder** (`<date>-<feature-name>`) for all outputs in this skill — do NOT create a new dated folder. Skip to Step 2 (codebase exploration) — do not re-interview about things already captured.
   - **If the user wants to start fresh:** Ask for a full description of the idea, then offer to run `/workflow-explore-ideia` first to develop it further before creating the PRD. If they prefer to proceed directly, continue to Step 1.

3. If no exploration files are found, ask:
   > "Would you like to start by exploring the idea together with `/workflow-explore-ideia`, or describe your idea directly so we can create the PRD?"

   - **If they want to explore first:** Invoke `/workflow-explore-ideia`.
   - **If they want to proceed directly:** Continue to Step 1 and derive the spec folder name using today's date: `.specs/features/<YYYY-MM-DD>-<kebab-case-feature-name>/`.

---

## Step 1 — Requirements Gathering

Gather requirements through interactive Q&A using `AskUserQuestion`. Ask **ONE question at a time** — do NOT dump all questions at once.

You SHOULD:

- Ask the user for a long, detailed description of the problem they want to solve and any potential ideas for solutions.
- Explore the repo to verify their assertions and understand the current state of the codebase.
- Interview the user relentlessly about every aspect of this plan until you reach a shared understanding.


**Questions to ask (in order):**

1. **Feature description**: "Describe the feature to be built. What is its purpose, and which business domain does it belong to?"
2. **API contract**: "Describe the API surface needed: HTTP methods, endpoint paths, request/response payloads. If there's an existing API spec (OpenAPI, Swagger), share it."
3. **Acceptance criteria**: "What are the key acceptance criteria? When is this feature 'done'?"
4. **Data and persistence**: "What data needs to be persisted? Are there new entities, or does this extend existing ones? Share the relevant schema or entity relationships if available."
5. **Integrations**: "Does this feature call external services, message queues, or other microservices? If so, describe the integration contracts."
6. **Non-functional requirements**: "Any NFRs to consider? (e.g., latency SLA, throughput, security rules, multi-tenancy, audit logging, transaction boundaries)"
7. **Out of scope**: "What is explicitly OUT of scope for this feature?"

After gathering all answers, save the requirements to `.specs/features/<date>-<feature-name>/01-requirements.md` (use the folder resolved in Step 0):

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

---

## Step 2 — Codebase Exploration

Explore the repo to verify the user's assertions and understand the current state of the codebase relevant to this feature. Use Glob, Read, and Bash to analyze the project.

Focus on:
1. **Tech stack** — identify the main languages, frameworks, and libraries in use (`package.json`, `pom.xml`, `pyproject.toml`, etc.)
2. **Existing patterns** — find similar features or modules already implemented that serve as reference or can be reused
3. **Data model** — identify entities, schemas, or tables relevant to the feature
4. **API patterns** — understand how existing endpoints are structured and what conventions to follow
5. **Impact map** — list files, modules, or services likely to be created or modified

Keep findings in context for use in Steps 3 and 4.

---

## Step 3 — Deep-Dive Interview

With the requirements doc and codebase findings as anchors, resolve any remaining ambiguities before writing the PRD. Ask **one question at a time**. Focus on:

1. **Conflicting assumptions** — any requirement the codebase contradicts (e.g., an endpoint that already exists with different behavior)
2. **Underspecified areas** — parts of the feature where the implementation approach is unclear
3. **Edge cases** — behaviors for invalid input, empty states, authorization failures
4. **Integration gaps** — external services or dependencies mentioned in requirements but not yet clarified

Only ask questions not already answered by the requirements doc or codebase exploration.

---

## Step 4 — Module Design

Sketch out the major modules you will need to build or modify to complete the implementation. Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

Once you have a complete understanding of the problem and solution, use the template below to write the PRD.

Save the PRD to a file using the Write tool.

**File path:** `.specs/features/<date>-<feature-name>/prd.md` (same folder resolved in Step 0).

   The file content should be the full PRD produced from the template below, with a frontmatter header:

   ```markdown
   ---
   title: <Feature Name>
   date: <YYYY-MM-DD>
   status: Draft
   exploration: <relative path to exploration file, or "none">
   ---
   ```

After saving, confirm to the user and ask what they want to do next:

> "PRD saved at `.specs/features/<date>-<feature-name>/prd.md`. Ready to move to implementation planning? Invoke `/workflow-prd-to-plan` (or say 'plan this feature') when you'd like to proceed."

**This workflow ends here.** Do NOT invoke `/workflow-prd-to-plan` or any implementation agent. Wait for the user to explicitly request the next step.

<prd-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

</prd-template>
