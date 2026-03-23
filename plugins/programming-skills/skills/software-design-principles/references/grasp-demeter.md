# GRASP Patterns and Law of Demeter

---

## GRASP — General Responsibility Assignment Software Patterns

Documented by Craig Larman in *Applying UML and Patterns*. GRASP provides heuristics
for assigning responsibilities to classes, answering: *"Which class should own this behaviour?"*

### General Principles

| Principle | Meaning |
|-----------|---------|
| **High Cohesion** | Keep related responsibilities together |
| **Low Coupling** | Minimise dependencies between classes |
| **Polymorphism** | Use polymorphic dispatch rather than conditionals on type |
| **Indirection** | Introduce a mediator/intermediary to avoid direct coupling (avoid trivial one-liners) |
| **Protected Variations** | Identify variation points and wrap them in stable interfaces |

> Protected Variations: "Identify predicted points of variation and create a stable interface around them." — Larman (2001)

### Specific Patterns

| Pattern | When to use | What it does |
|---------|-------------|--------------|
| **Information Expert** | Assigning a responsibility | Give it to the class that has the most relevant data to fulfil it |
| **Controller** | Handling system events | A single entry-point for a use case or user-facing event — keeps UI separated from domain |
| **Creator** | Deciding who builds an object | Assign creation to the class most closely related to the created object (contains, aggregates, or initialises it) |
| **Pure Fabrication** | Achieving low coupling when no domain class fits | Introduce a class that doesn't exist in the business domain but promotes high cohesion and low coupling |

**Information Expert in practice:** If you need to compute an order total, assign
the responsibility to `Order`, not to a service that fetches order data separately.
The class that *has* the data should do the work.

**Pure Fabrication in practice:** A `PaymentGatewayAdapter` or a `ReportFormatter`
have no counterpart in the domain model, but they exist to isolate a concern cleanly.

---

## Law of Demeter (Principle of Least Knowledge)

A set of rules to prevent encapsulation violations in object-oriented code.
Also known as "Don't talk to strangers."

### The Rule

> A method should only call methods of:
> 1. Its own class
> 2. Objects passed as parameters
> 3. Objects it creates itself
> 4. Its own fields/attributes

```java
class Service {
    private Repository repository;

    public void process(Request request) {
        this.validate();                            // ✅ own method
        request.getId();                            // ✅ parameter
        new Validator().check(request);             // ✅ created here
        this.repository.findById(request.getId()); // ✅ own field

        // ❌ VIOLATION — reaching through a chain of objects:
        request.getUser().getAddress().getCity()
    }
}
```

### Tell, Don't Ask

Send commands telling objects *what to do* rather than querying their internals to
do the work yourself.

```java
// ❌ Ask style — reaching in to do work:
if (customer.getAccount().getBalance() > amount) {
    customer.getAccount().debit(amount);
}

// ✅ Tell style — delegate:
customer.debit(amount);
```

A method chain like `a.getB().getC().doSomething()` is a classic Demeter violation —
it reveals the internal structure of `a` and creates hidden structural coupling. Any
change to the chain's middle elements breaks callers silently.

### Why It Matters

- Reduces structural coupling between unrelated classes
- Makes refactoring safer — the internal structure can change without affecting callers
- Improves testability — fewer indirect dependencies to mock/stub

### References

- [The Art of Enbugging](https://www2.ccs.neu.edu/research/demeter/related-work/pragmatic-programmer/jan_03_enbug.pdf) — Hunt & Thomas
- [The Paperboy, The Wallet and The Law of Demeter](https://www2.ccs.neu.edu/research/demeter/demeter-method/LawOfDemeter/paper-boy/demeter.pdf) — David Bock
