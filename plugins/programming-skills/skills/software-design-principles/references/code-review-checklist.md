# Code Review & Design Checklist

Use this checklist when reviewing code or evaluating a design proposal.
Each section maps to a property or principle from the reference files.

---

## Cohesion
- [ ] Does each class/module have a single, clearly nameable responsibility?
- [ ] Can you describe its purpose in one short sentence?
- [ ] Are all its methods and fields related to that single purpose?
- [ ] Does it avoid mixing business logic with infrastructure details?
- [ ] Are there methods that seem unrelated to the class's core concept?

## Coupling
- [ ] Does it depend only through stable interfaces, not concrete implementations?
- [ ] Are there chains of `getX().getY().getZ()` method calls? (**Demeter violation**)
- [ ] Is there shared mutable global state between classes?
- [ ] Are dependencies injected rather than constructed inside the class?
- [ ] Would changing an infrastructure detail (DB, HTTP, SDK) require touching business logic?

## Information Hiding
- [ ] Are implementation details private and hidden from callers?
- [ ] Would swapping an implementation require changing callers?
- [ ] Are third-party SDK types leaking through public interfaces?
- [ ] Does the module's public API reveal more than clients need to know?

## SOLID
- [ ] **SRP** — Does each class have exactly one reason to change?
- [ ] **OCP** — Can new behaviour be added without modifying existing classes?
- [ ] **LSP** — Do all subclasses honour the full contract of their supertype?
  - No narrowing of preconditions
  - No weakening of postconditions
  - No throwing exceptions the supertype doesn't throw
- [ ] **ISP** — Are interfaces small and specific to the needs of each client?
- [ ] **DIP** — Does high-level business logic depend only on abstractions?
  - Are concrete implementations referenced from high-level code?
  - Are interfaces designed from the client's perspective, not the implementation's?

## GRASP
- [ ] Is each responsibility assigned to the class that has the most relevant information? (**Information Expert**)
- [ ] Is there a clean entry-point for each use case, separate from the domain? (**Controller**)
- [ ] Is object creation encapsulated appropriately? (**Creator**)
- [ ] Are variation points wrapped in stable interfaces? (**Protected Variations**)

## Law of Demeter
- [ ] Do methods only call: their own class, their parameters, objects they create, their own fields?
- [ ] Are there chains like `a.getB().getC().method()`?
- [ ] Do methods tell objects what to do rather than querying and acting themselves? (**Tell, Don't Ask**)

## Inheritance vs Composition
- [ ] Is every `extends` relationship a genuine "is-a" that satisfies LSP?
- [ ] Are subclasses overriding most parent methods (sign it's not a real "is-a")?
- [ ] Could composition + delegation replace an inheritance hierarchy?
- [ ] Is the Decorator pattern applicable instead of extending?

## Immutability
- [ ] Are value objects (Money, DateRange, Coordinates) immutable?
- [ ] Are mutable fields that should be read-only exposed through defensive copies?
- [ ] Is state shared across threads mutable? (Thread-safety risk)

## Module-Level (for package / library reviews)
- [ ] No circular dependencies between packages/modules? (**ADP**)
- [ ] Do unstable modules depend on stable ones, not the other way around? (**SDP**)
- [ ] Are stable modules abstract (interfaces/abstractions rather than concrete classes)? (**SAP**)
- [ ] Are classes grouped by change reason (same team, same business concept)? (**CCP**)
- [ ] Are classes grouped so that consumers reuse all or none of them? (**CRP/REP**)
- [ ] Is the module's public API separated from its implementation? (**Separate Abstractions**)

---

## Quick Red Flags

| Code smell | Likely violation |
|-----------|-----------------|
| God class / giant service | SRP, Cohesion |
| `getA().getB().getC()` chains | Law of Demeter |
| `new ConcreteClass()` inside business logic | DIP |
| Interface with 10+ methods | ISP |
| Subclass that overrides and empties parent methods | LSP |
| Circular imports between packages | ADP |
| Abstract stable module importing a concrete unstable one | SDP |
| Fat module where clients only use half the classes | CRP |
| Copy-pasted library code | Reuse without release (REP) |
| Mutable shared state accessed from threads | Immutability |
