# SOLID Principles

SOLID is an acronym compiled by Robert C. Martin ("Uncle Bob") and Michael Feathers
for five object-oriented design principles. When applied together, they produce code
that is adaptable to change.

| Principle | Targets |
|-----------|---------|
| Single Responsibility (SRP) | Cohesion |
| Open/Closed (OCP) | Extensibility |
| Liskov Substitution (LSP) | Extensibility / Correctness |
| Interface Segregation (ISP) | Cohesion |
| Dependency Inversion (DIP) | Coupling |

---

## Single Responsibility Principle (SRP)

> Every class should have one, and only one, reason to change.

SRP is the direct application of cohesion to classes. A class that serves multiple
purposes must be modified whenever any one of those purposes changes.

**How to analyse a class:**
- What are this class's responsibilities?
- What are the different reasons it could be modified?
- Do its imports span unrelated domains?

**Code review signals:**
- Many unrelated methods
- Frequently modified for different reasons
- Keeps growing without a clear boundary
- Imports mixing networking, business logic, and persistence

---

## Open/Closed Principle (OCP)

> A class should be open for extension but closed for modification.

Originally proposed by Bertrand Meyer (1980s). You should be able to add new
behaviour without touching existing, working code.

**Mechanisms to achieve OCP:**
- Polymorphism via inheritance and interfaces
- Higher-order functions / lambdas
- Design patterns: Abstract Factory, Template Method, Strategy

> "Identify predicted points of variation and create a stable interface around them." — Craig Larman (*Protected Variations*)

**Critical nuance:** Dan North (*CUPID — The Back Story*, 2021) and David Copeland
(*SOLID is Not Solid*, 2019) argue OCP was conceived when modifying and redistributing
compiled code was expensive and risky. With modern refactoring tools and TDD, code
is much more malleable. Apply OCP where you genuinely expect extension points, not
as a blanket rule.

---

## Liskov Substitution Principle (LSP)

> Subtypes must be substitutable for their base types without altering program correctness.

Formulated by Barbara Liskov in *Data Abstraction and Hierarchy* (1988).

A subtype must fulfil the *entire contract* of its supertype — not just the method
signature, but the behaviour. A subclass that throws where the parent doesn't, returns
different value ranges, or changes observable side effects, violates LSP.

**Modern phrasing:** A subtype must not break the contract of its supertype.

**Good example:** An `Exporter` base type that writes text; valid subtypes write JSON
or XML — different format, same contract (produces output from the same input set).

**Classic violation:** `Square extends Rectangle` — setting width on a Square also
changes height, breaking the Rectangle contract that width and height are independent.

---

## Interface Segregation Principle (ISP)

> Clients should not be forced to depend on interfaces they do not use.

ISP applies SRP to interfaces. Keep interfaces small, cohesive, and tailored to their
specific clients. Uncle Bob: *"Separate clients, separate interfaces."*

**Why it matters:** A fat interface forces a client to depend on the whole contract
even if it uses only a fraction. Every change to the unused part still affects the
client as a compile/link dependency.

**Critical nuance (Copeland):** ISP is most pressing in statically typed languages.
In dynamic languages or where classes are already cohesive, ISP adds interface
proliferation without proportional benefit. Dan North notes ISP was born from a
specific refactoring at Xerox, not a universal principle.

---

## Dependency Inversion Principle (DIP)

> High-level modules must not depend on low-level modules. Both must depend on abstractions.
> Abstractions must not depend on details. Details must depend on abstractions.

Uncle Bob splits code into two levels:
- **High-level:** business logic, use cases
- **Low-level:** delivery mechanisms, technical details (DB, HTTP, SMS SDKs)

By depending on an abstraction, the business logic is insulated from infrastructure
changes. The flow of control goes from high-level to low-level, but the *dependency
arrow* is reversed — high-level owns the interface, low-level implements it.

**Practical guidance:**
- Design interfaces that are *conceptually* abstract — a `MessageSender` taking
  `(recipient, message)` rather than an SDK-specific object
- Place the interface in the same package as its client (high-level owns the contract)
- Use DI frameworks or creational patterns (Factory, Builder) to wire implementations
- Observer/Event patterns further reduce coupling by eliminating direct method calls

**Watch out:** Strict DIP can create a 1:1 interface-to-class ratio. When business
logic is not complex, this adds unnecessary abstraction. Apply DIP where the interface
is genuinely expected to vary.

---

## Key References

| Work | Author | Contribution |
|------|--------|-------------|
| *Object-Oriented Software Construction* (1988) | Bertrand Meyer | Open/Closed Principle |
| *Data Abstraction and Hierarchy* (1988) | Barbara Liskov | LSP |
| *Clean Architecture* (2017) | Robert C. Martin | SOLID compilation and rationale |
| *SOLID is Not Solid* (2019) | David Copeland | Critical perspective |
| *CUPID — The Back Story* (2021) | Dan North | Alternative to SOLID |
