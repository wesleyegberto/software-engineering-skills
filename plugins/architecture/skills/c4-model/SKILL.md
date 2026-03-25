---
name: c4-model
description: Generate C4 architecture documentation at any level using specialized agents (Code, Component, Container, Context). Use this skill whenever the user wants to document system architecture with the C4 model, create architecture diagrams, document code structure, define component boundaries, map deployment containers, or create system context diagrams. Trigger for prompts like "document architecture", "create C4 diagram", "generate architecture docs", "map system components", "create context diagram", "document this codebase architecture", or "analyze code structure with C4". Always use this skill for C4 documentation requests, even partial ones like a single level.
---

# C4 Model Documentation Orchestrator

Orchestrates four specialized agents to generate C4 model architecture documentation. Each agent targets one hierarchical level, producing documentation files that feed into the next level.

## C4 Levels Overview

| Level | Agent subagent_type | Input | Output files |
|-------|---------------------|-------|--------------|
| **Code** | `c4-code` | Source directories | `c4-code-<name>.md` per directory |
| **Component** | `c4-component` | `c4-code-*.md` files | `c4-component-<name>.md` + index |
| **Container** | `c4-container` | Component docs + deployment configs | `c4-container.md` + OpenAPI specs |
| **Context** | `c4-context` | Container/component docs + README/tests | `c4-context.md` |

## Workflow: Bottom-Up (Standard)

When the user requests full C4 documentation:

```
1. Code level    → Analyze all source directories (run in parallel per directory)
2. Component     → Synthesize code docs into logical components
3. Container     → Map components to deployment units + document APIs
4. Context       → Create high-level stakeholder view
```

Run agents in sequence (each level depends on the previous). Within the Code level, multiple directories can be processed in parallel.

## Selective Documentation

Ask the user which level(s) they need if not clear from context:
- Single level: invoke just that agent
- Partial chain: e.g., only Code + Component
- Full chain: all four in order

## Agent Reference Files

When working on a specific level, read the corresponding reference file for full agent instructions, templates, and diagram syntax:

- **Code level** → `references/c4-code.md`
- **Component level** → `references/c4-component.md`
- **Container level** → `references/c4-container.md`
- **Context level** → `references/c4-context.md`

## Output Organization

Suggest placing all documentation in a consistent location:

```
docs/architecture/
├── c4-code-handlers.md       # Code level (one per directory)
├── c4-code-services.md
├── c4-component-api.md       # Component level
├── c4-component-domain.md
├── c4-component.md           # Component index
├── c4-container.md           # Container level
├── api-spec.yaml             # OpenAPI specs (if generated)
└── c4-context.md             # Context level
```

## Invoking the Agents

Use the `Agent` tool with the appropriate `subagent_type`. Example for Code level:

```
Agent(
  subagent_type="c4-code",
  prompt="Analyze the directory src/handlers and create C4 Code-level documentation. Save to docs/architecture/c4-code-handlers.md"
)
```

For the Context level agent, note it lives at `/Users/wesley/.claude/agents/c4-context.md` — use `subagent_type="c4-context"`.

## Key Principles

- **Bottom-up**: Code → Component → Container → Context (each level builds on the previous)
- **Parallel Code runs**: Multiple directories can be documented simultaneously
- **Sequential synthesis**: Component, Container, and Context must run after their inputs exist
- **Self-contained**: Each output file should be understandable independently
- **Mermaid diagrams**: Each level has specific diagram types (see reference files)
