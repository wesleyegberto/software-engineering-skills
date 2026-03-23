---
name: software-design-principles
description: >
  Reference guide for software design properties and principles: SOLID, GRASP,
  Law of Demeter, cohesion, coupling, information hiding, conceptual integrity,
  modularisation, module-level principles (REP/CCP/CRP/ADP/SDP/SAP), composition
  over inheritance, and immutability.

  ALWAYS activate this skill when: performing code reviews, designing classes or
  modules, evaluating dependencies or abstractions, discussing SOLID principles,
  analysing coupling or cohesion, reviewing inheritance hierarchies, making
  architectural decisions about package structure, or any time the conversation
  involves design quality, code maintainability, or software design principles.
metadata:
  author: wesleyegberto
  version: "1.0.0"
  scope: architecture
---

# Software Design Properties and Principles

This skill is a reference companion for code review and software design sessions.
Each concept lives in its own reference file — read only the file(s) relevant to
the current task.

## Reference Files

| File | Contents |
|------|----------|
| `references/design-properties.md` | Cohesion, Coupling, Information Hiding, Conceptual Integrity |
| `references/solid.md` | SRP, OCP, LSP, ISP, DIP — with nuances and critical counterpoints |
| `references/grasp-demeter.md` | GRASP patterns, Law of Demeter, Tell-Don't-Ask |
| `references/modularization.md` | Modularisation, REP/CCP/CRP, ADP/SDP/SAP, metrics |
| `references/composition-immutability.md` | Prefer Composition over Inheritance, Immutability rules |
| `references/simplicity.md` | Causes of complexity, abstraction leaks, scale, model/reality gaps |
| `references/error-handling.md` | Error types, when/where to handle, flow control, checked exceptions |
| `references/code-review-checklist.md` | Unified checklist + quick red-flag table for reviews |

## When to Read Each File

**During a code review:**
Start with `code-review-checklist.md` for a structured walkthrough, then open the
specific reference file for deeper context on any flagged issue.

**During software design:**
- Deciding class responsibilities → `design-properties.md` (cohesion, coupling)
- Designing interfaces or inheritance → `solid.md` + `composition-immutability.md`
- Assigning responsibilities to objects → `grasp-demeter.md`
- Structuring packages or modules → `modularization.md`
- Evaluating complexity or discussing simplicity trade-offs → `simplicity.md`
- Reviewing error handling, exception design, or propagation strategy → `error-handling.md`

## Core Principle Map

```
Goal                         Practice
────────────────────────────────────────────────────────────
High Cohesion           ←─   SRP, ISP, CCP, GRASP High Cohesion
Low Coupling            ←─   DIP, Law of Demeter, Composition, SDP
Information Hiding      ←─   Law of Demeter, Private fields, API Module
Extensibility           ←─   OCP, LSP, Protected Variations
Module Stability        ←─   ADP, SDP, SAP
Reusability             ←─   REP, CRP, Separate Abstractions
Thread Safety           ←─   Immutability
```

## Property → Principle Quick Lookup

| Property | Principles |
|----------|-----------|
| Cohesion | SRP, ISP, CCP |
| Coupling | DIP, Law of Demeter, Composition > Inheritance, SDP |
| Information Hiding | Law of Demeter, CCP, Separate Abstractions |
| Extensibility | OCP, LSP, Protected Variations (GRASP) |
| Module stability | ADP (no cycles), SDP (stable direction), SAP (abstract = stable) |
