# Software Simplicity

Based on Peter van Hardenberg's talk *"Why Can't We Make Simple Software?"*

---

## What Complexity Is (and Isn't)

- Complexity is **not** difficulty
- Complexity is **not** depth

> Complexity is when your system interacts.
> A complex system can become irrational — hard to reason about.

Complexity emerges from the *interactions* between parts, not from the parts themselves.
A system with many simple, isolated components can be easier to reason about than one
with few but highly entangled parts.

---

## Causes of Complexity

### Defensive Code

Making code safe and reliable can obscure its core intent. Error handling and input
validation are necessary, but when they dominate the code they bury the actual
business logic.

**Observations:**
- Minimise the scope of potential failures — fail fast and at the boundary
- Maximise the extent of guaranteed values — validate at entry points, trust internally

The goal is not to eliminate defensive code but to contain it so that the happy path
remains readable and intention-revealing.

---

### Scale

Decisions that were correct at one scale can become incorrect at another — not because
they were wrong at the time, but because the requirements changed as the system grew.

Each order-of-magnitude increase in scale tends to introduce new problems that the
previous level never encountered.

**Observations:**
- Tools that solve problems at one scale may not work at a different scale (in either
  direction — over-engineering is as harmful as under-engineering)
- Plan to *rebuild* subsystems as each scale threshold is crossed, rather than patching
  the existing solution indefinitely

This aligns with the **Acyclic Dependencies Principle** and **SDP**: a modular
architecture where components can be replaced independently is what makes rebuilding
at scale feasible.

---

### Abstraction Leaks

An abstraction that leaks implementation details makes the system harder to evolve.
When internal decisions surface through a public interface, consumers couple themselves
to those decisions — preventing the implementation from being improved.

**Observations:**
- A well-designed interface can nearly completely hide complexity
- A stable API can become a cage: it may lock in a weaker implementation to preserve
  backwards compatibility (abstraction vs performance trade-off)

This is the tension at the heart of **Information Hiding**: exposing too much prevents
change; but an interface too rigid prevents improvement of the underlying implementation.

---

### Gaps Between Model and Reality

Incorrect modelling of the business domain causes problems throughout the system's
lifetime. The further the code model drifts from reality, the more workarounds
accumulate.

These gaps are expensive to fix because the mismatch is often load-bearing — other
code has adapted around it.

**Options when a gap is confirmed:**
| Option | When appropriate |
|--------|-----------------|
| Fix the problem | The gap is small or early-stage; the cost of fixing is lower than the cost of carrying it |
| Work around it (hack) | The gap is too costly to fix now; the workaround is local and well-documented |
| Ignore it | The gap has no observable impact on users or correctness |

The accumulation of workarounds is a primary source of **evolutionary coupling** —
changes in one area unexpectedly break another because both adapted around the same
gap.

---

### Hyperspace (Combinatorial Explosion)

When a problem is multiplied by independent dimensions of variation — browsers, screen
sizes, API versions, locales, user roles — the number of states the system must handle
grows combinatorially.

**Example:** A feature that must work across 3 browsers × 4 screen sizes × 2 API
versions already has 24 distinct cases before any business logic is added.

**Observations:**
- Use abstractions that already handle the varying dimensions (platform libraries,
  responsive frameworks, versioned adapters) — let the abstraction absorb the
  combinatorial complexity
- The *organisational cost* of implementing all variations manually can be prohibitive;
  factor this into design decisions

---

## Homeostasis

Systems tend toward a stable level of complexity. As complexity is removed in one
place, it often reappears elsewhere — through workarounds, compensating mechanisms,
or accumulated edge cases. Simplifying a system requires sustained discipline, not
a one-off refactor.

---

## Design Implications

| Complexity source | Design response |
|------------------|----------------|
| Defensive code | Validate at boundaries; trust internally (Information Hiding) |
| Scale drift | Design for replaceability — modularity, stable interfaces (ADP, SDP) |
| Abstraction leaks | Separate interface from implementation (Separate Abstractions, ISP) |
| Model/reality gap | Invest in domain modelling (DDD); fix gaps early before workarounds compound |
| Hyperspace | Push variation into abstractions; reduce the number of dimensions code must handle |

---

## Reference

- [Why Can't We Make Simple Software? — Peter van Hardenberg (Strange Loop 2023)](https://www.youtube.com/watch?v=czzAVuVz7u4)
