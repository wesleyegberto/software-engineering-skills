# Modularisation and Module-Level Principles

---

## Modularisation

Modularisation is the practice of decomposing a system into well-defined, self-contained
modules with explicit interfaces. The *criterion* used to decompose determines whether
modularisation actually delivers its promised benefits (Parnas, 1972).

### Module Characteristics (Kirk Knoernschild, *Java Application Architecture*, 2012)

| Characteristic | Meaning |
|---------------|---------|
| **Deployable** | Can be delivered and executed as an independent artefact |
| **Reusable** | Can be used by other applications without network calls |
| **Testable** | Can be unit-tested in isolation |
| **Manageable** | Can be installed, upgraded, and removed independently |
| **Composable** | Can be combined with other modules to build applications |
| **Stateless** | Modules carry no runtime state (classes may, modules do not) |

### Benefits of Modularisation (Craig Walls, *Modular Java*, 2009)

- Swap a module for a different implementation as long as the public interface is preserved
- Understand each module individually without needing to read the others
- Develop in parallel — teams can work on separate modules independently
- Test at the module boundary as a unit
- Reuse modules across different applications

### True Reuse (Uncle Bob, *Granularity*, 1996)

> "I reuse code if, and only if, I never need to look at the source code. That is, I
> expect code that I am reusing to be treated as a product. It is not maintained by
> me. It is not distributed by me. I am the consumer." — Uncle Bob

Copy-paste is not reuse — you become the owner of bugs and all future evolution.

### Modularity Pattern — Separate Abstractions

Keep abstract interfaces and their concrete implementations in *different* modules.

- Knoernschild calls this **Separate Abstractions**
- *Java 9 Modularity* (Mak & Bakker, 2017) calls it the **API Module** pattern:

> "Applications where modules export everything they contain are usually a warning sign...
> A modularised application hides implementation details from other parts of the
> application, just as a good library hides its internal components. Whenever your
> module is used by different parts of the application, having a well-defined and
> stable API is fundamental."

### Meyer's Modularity Criteria (*Object-Oriented Software Construction*, 1988)

**Criteria for modular code:**
- Decomposability
- Composability
- Comprehensibility
- Continuity
- Protection

**Rules of modularity:**
- Direct mapping
- Few interfaces
- Small interfaces
- Explicit interfaces
- Information hiding

**Principles of modularity:**
- Linguistic modular units
- Self-documentation
- Uniform access
- Single choice
- Open/Closed (OCP)

---

## Module Cohesion Principles (Uncle Bob)

Three principles guide *what to put in* a module:

### Release/Reuse Equivalency Principle (REP)

> The granule of reuse is the granule of release.

A module is only genuinely reusable if it is versioned and released by its maintainer.
When you reuse a module you accept *all* of its classes and dependencies — so group
classes whose combined reuse makes sense.

### Common Closure Principle (CCP)

> Gather into modules the classes that change for the same reasons and at the same
> times. Separate into different modules classes that change at different times and
> for different reasons.

CCP is SRP applied to modules. It directly echoes Parnas's information-hiding
criterion: a module built around one design decision that might change will have fewer
change ripples than a grab-bag module.

### Common Reuse Principle (CRP)

> Classes in a module are reused together. Whoever reuses one reuses them all.
>
> Don't force users of a module to depend on things they don't need.

If only half the module's classes are needed by a consumer, any change to the unneeded
classes still forces a re-release that the consumer must adopt.

### Tension Between Cohesion Principles

| Principle | Tendency | Rationale |
|-----------|----------|-----------|
| REP | Bigger modules | Groups for reuse |
| CCP | Bigger modules | Groups by change reason |
| CRP | Smaller modules | Avoids unnecessary dependencies |

REP and CCP cause module growth; CRP pushes toward splitting. The right balance
depends on the project phase: early development favours CCP (stability matters more
than reusability); mature shared libraries favour REP and CRP.

---

## Module Coupling Principles (Uncle Bob)

Three principles guide *how modules should depend on each other*:

### Acyclic Dependencies Principle (ADP)

> The dependency graph of modules must have no cycles.

A dependency cycle means you cannot build, test, or release one module independently
of all others in the cycle. Break cycles by extracting a shared abstraction module
that both sides depend on (applying DIP at the module level).

### Stable Dependencies Principle (SDP)

> Depend in the direction of stability.

A module is *stable* when many others depend on it (high fan-in) — changing it has
wide impact, so you think carefully before doing so. An *unstable* module depends on
others but few depend on it — easy to change.

**Instability metric:**

```
fan-in  = number of external classes that import from this module
fan-out = number of external classes this module imports

I = fan-out / (fan-in + fan-out)

I → 0  : maximally stable (many depend on it; it depends on nothing)
I → 1  : maximally unstable (depends on many; nobody depends on it)
```

Rule: unstable modules (high I) should depend on stable modules (low I), not the
other way around.

### Stable Abstractions Principle (SAP)

> A module should be as abstract as it is stable.

Stable modules are dangerous to change — so they should be abstract (interfaces,
abstract classes) to allow extension without modification (OCP at module level).

**Abstractness metric:**

```
Na = number of abstract classes and interfaces
Nc = number of concrete classes

A = Na / Nc

A → 0 : all concrete (fragile if stable)
A → 1 : all abstract (flexible)
```

**The Main Sequence:** The ideal relationship is `I + A ≈ 1`. Maximally stable
modules should be maximally abstract; maximally unstable modules can be maximally
concrete. Modules far from this diagonal fall into one of two problem zones:
- *Zone of Pain* (stable + concrete): hard to change, hard to extend
- *Zone of Uselessness* (unstable + abstract): abstract but nothing depends on it

---

## Key References

| Work | Author | Contribution |
|------|--------|-------------|
| *On the Criteria To Be Used in Decomposing Systems into Modules* (1972) | David Parnas | Modularisation criterion, information hiding |
| *Object-Oriented Software Construction* (1988) | Bertrand Meyer | Modularity criteria and rules |
| *Granularity* (1996) | Robert C. Martin | REP, CCP, CRP |
| *Clean Architecture* (2017) | Robert C. Martin | ADP, SDP, SAP with metrics |
| *Modular Java* (2009) | Craig Walls | Modularisation benefits |
| *Java Application Architecture* (2012) | Kirk Knoernschild | Module characteristics, Separate Abstractions |
| *Java 9 Modularity* (2017) | Sander Mak, Paul Bakker | API Module pattern |
