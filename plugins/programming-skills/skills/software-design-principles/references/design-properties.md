# Design Properties

Design properties are the *qualities* we aim for in well-designed software.
Principles (see other reference files) are the concrete practices that produce them.

---

## Cohesion

A module is cohesive when it implements a single, focused responsibility — one reason
to exist. All methods and attributes should contribute to that single purpose.

**Benefits:**
- Easier to implement, understand, and maintain
- A single person or team can own the module clearly
- Easier to test in isolation and to reuse

**Separation of Concerns (SoC):** Each unit should implement only one *concern* —
any given functionality, requirement, or responsibility.

> "A class is cohesive if a change to one function requires changes to all the others."

**Diagnostic signals for low cohesion (Maurício Aniche):**
- Class has many unrelated methods
- Modified frequently for different reasons
- Keeps growing without a clear boundary
- Imports span unrelated domains (networking + business logic + persistence)

---

## Coupling

Coupling is the strength of the connection between two classes or modules.

> "Two elements are coupled when changes in one element demand changes in another." — Kent Beck

### Acceptable Coupling
- Class A uses only the *public interface* of class B
- That interface is stable syntactically (signature doesn't change often) and
  semantically (behaviour contract is consistent)

### Bad Coupling
- Class A reaches directly into class B's internal resources (files, databases, globals)
- Both classes share global state
- Class B's interface is unstable

> What makes coupling bad is that the dependency is *not mediated by a stable interface*.

### Structural Forms

| Form | Definition |
|------|-----------|
| **Structural coupling** | Class A holds an explicit reference to class B in its code |
| **Evolutionary (logical) coupling** | Changes in class B tend to propagate into class A over time |

**Rule:** Maximise cohesion; minimise bad coupling.

---

## Information Hiding

First described by David Parnas in *On the Criteria To Be Used in Decomposing Systems
into Modules* (1972).

> "Modules must hide design decisions that are subject to change."

Parnas argued that the *criterion* used to decompose a system determines whether
modularisation delivers its benefits. Splitting by algorithmic steps is the wrong
criterion. Splitting by *design decisions that might change* is the right criterion.

**Benefits:**
- Enables parallel development — teams can work on separate modules independently
- Flexibility to change — swapping an implementation doesn't ripple outward
- Easier understanding — each module is a black box with a clear contract

**Practical implication:** Hide anything that might change: database schema, file
format, third-party SDK details, algorithms. Expose only stable, intention-revealing
interfaces.

---

## Conceptual Integrity

Proposed by Frederick Brooks in *The Mythical Man-Month* (1975).

> "Conceptual integrity is the most important consideration in system design. It is
> better for a system to omit certain anomalous features and improvements, but to
> reflect one set of design ideas, than to have one that contains many good but
> independent and uncoordinated ideas." — F. Brooks

A system has conceptual integrity when:
- UI patterns are consistent across all screens (same action buttons, same table
  filtering/sorting conventions)
- Naming conventions and code structure are uniform across all modules
- Behaviour is predictable because it follows a coherent model

**Lack of conceptual integrity** makes the system harder to learn for end-users and
harder to navigate for developers. It is the result of many independent contributors
making local decisions without a unifying design philosophy.

---

## Key References

| Work | Author | Contribution |
|------|--------|-------------|
| *The Mythical Man-Month* (1975) | Frederick Brooks | Conceptual Integrity |
| *On the Criteria To Be Used in Decomposing Systems into Modules* (1972) | David Parnas | Information Hiding, modularisation criterion |
| *Object-Oriented Software Construction* (1988) | Bertrand Meyer | Modularity criteria |
