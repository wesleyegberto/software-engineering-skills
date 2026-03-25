---
name: software-architecture-patterns
description: >
  Comprehensive reference for software architecture: fundamentals, architectural styles
  (layered, pipeline, microkernel, microservices, event-driven, SOA), architectural
  patterns (hexagonal/ports & adapters, CQRS, event sourcing, MVC), enterprise application
  patterns, and integration patterns.

  ALWAYS activate this skill when: reviewing system or component architecture, designing
  new services or systems, doing system design sessions, making architectural decisions,
  evaluating trade-offs between architectural styles, creating new bounded contexts or
  microservices, discussing modularisation, scalability, or extensibility at the system
  level, documenting architecture (ADR, Architecture Haiku), or any time architectural
  quality attributes (availability, scalability, maintainability, fault tolerance) are
  being discussed.
metadata:
  author: Wesley Egberto
  version: "1.0.0"
---

# Software Architecture

Reference companion for architecture reviews, system design sessions, and architectural
decision-making. Each topic lives in its own reference file.

## Reference Files

| File | Contents |
|------|----------|
| `references/fundamentals.md` | Architecture definition, architect role, architectural requirements, decisions, constraints, documentation (ADR, Architecture Haiku) |
| `references/architectural-styles-monolithic.md` | Layered, Pipeline, Microkernel — topology, trade-offs, when to use |
| `references/architectural-styles-distributed.md` | Microservices, Event-Driven Architecture (EDA), SOA — topology, principles, trade-offs |
| `references/architectural-patterns.md` | Hexagonal (Ports & Adapters), CQRS, Event Sourcing, MVC |
| `references/enterprise-patterns.md` | Domain logic patterns (Transaction Script, Domain Model), data source patterns (Active Record, Data Mapper), integration patterns (File Transfer, Shared DB, RPC, Messaging) |
| `references/architecture-review-checklist.md` | Structured checklist for architecture reviews and system design sessions |

## When to Read Each File

**Architecture review / system design:**
Start with `architecture-review-checklist.md`, then read the relevant style or pattern file for deeper context.

**Choosing an architectural style:**
Read `architectural-styles-monolithic.md` or `architectural-styles-distributed.md` (or both) and compare the trade-off summary table.

**Designing a new service or component:**
Read `architectural-patterns.md` (hexagonal for internal structure, CQRS/event sourcing for complex domains).

**Integration between systems:**
Read `enterprise-patterns.md` (integration section) for the four integration approaches.

**Documenting architectural decisions:**
Read `fundamentals.md` for ADR and Architecture Haiku templates.

## Architectural Style Quick Comparison

```
Style             | Type        | Scalability | Complexity | Best For
──────────────────┼─────────────┼─────────────┼────────────┼───────────────────────────
Layered           | Monolithic  | Low         | Low        | Small/medium business apps
Pipeline          | Monolithic  | Low         | Low        | Data processing, ETL
Microkernel       | Monolithic  | Low         | Medium     | Product apps, plugin systems
Event-Driven      | Distributed | High        | High       | Async, decoupled workflows
SOA               | Distributed | Medium      | High       | Enterprise integration
Microservices     | Distributed | High        | Very High  | Independent team/domain scale
```

## Quality Attribute → Style/Pattern Lookup

| Need | Consider |
|------|---------|
| Independent deployability | Microservices |
| Extensibility / plugin model | Microkernel |
| High throughput data processing | Pipeline |
| Async decoupling | Event-Driven Architecture |
| Complex read/write scaling | CQRS |
| Full audit trail | Event Sourcing |
| Testable business logic isolated from infra | Hexagonal |
| Simple team-owned service | Layered |
