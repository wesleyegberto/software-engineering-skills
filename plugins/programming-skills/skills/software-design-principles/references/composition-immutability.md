# Prefer Composition over Inheritance & Immutability

---

## Prefer Composition over Inheritance

> Favour object composition over class inheritance. — Gang of Four (*Design Patterns*, 1994)

### Two Types of Inheritance

| Type | Mechanism | Effect |
|------|-----------|--------|
| **Class inheritance** | `class A extends B` | Reuses *implementation* — subclass accesses parent internals |
| **Interface inheritance** | `interface I extends J` | Reuses *contract only* — no implementation coupling |

Class inheritance was oversold in the 1980s as the silver bullet for code reuse.
In practice it introduces tight coupling between parent and child:

> "Inheritance exposes to subclasses the implementation details of parent classes.
> That's why inheritance is often said to break encapsulation. The implementation of
> subclasses becomes so coupled to the implementation of parent classes that any change
> in the parents may force changes in the subclasses." — Erich Gamma

### Inheritance vs Composition

| | Class Inheritance | Composition |
|---|---|---|
| **Reuse type** | White-box (internals exposed) | Black-box (only public interface) |
| **Coupling** | High — subclass knows parent details | Low — only the public interface |
| **Flexibility** | Rigid hierarchy | Behaviours mixed at runtime |
| **Encapsulation** | Often broken | Preserved |
| **LSP risk** | High — easy to violate subtly | Low |

### When Composition Beats Inheritance

- The relationship is "has-a" not "is-a"
- The parent class has behaviour you don't want to inherit
- You need to combine behaviours from multiple hierarchies
- You want to swap behaviour at runtime
- The **Decorator pattern** is the canonical example: wraps an object and adds
  behaviour without extending it

### When Class Inheritance Is Acceptable

- The relationship is genuinely "is-a" and LSP holds
- The subtype only *extends* behaviour, never narrows or breaks the contract
- The hierarchy is shallow (1–2 levels)

### Practical Refactoring

Look for inheritance hierarchies where:
- Subclasses override most methods from the parent
- Subclasses call `super` only to satisfy a compiler, not for meaningful reuse
- Adding a new behaviour requires a new subclass rather than composing an existing one

These are signals to extract an interface and compose the behaviour instead.

---

## Immutability

An immutable object cannot be modified after construction — it has exactly one state
for its entire lifetime.

### Rules for Immutable Classes (Joshua Bloch, *Effective Java*, 2001)

1. **No mutating methods** — don't provide setters or any method that modifies state
2. **Prevent extension** — mark the class `final` so no subclass can add mutation
3. **All fields `final`** — the compiler enforces that they are set once
4. **All fields `private`** — clients cannot access internals directly
5. **Exclusive access to mutable components** — if a field holds a mutable object,
   return a defensive copy from getters and accept defensive copies in the constructor

```java
// Example — immutable Money value object
public final class Money {
    private final BigDecimal amount;
    private final Currency currency;

    public Money(BigDecimal amount, Currency currency) {
        this.amount = Objects.requireNonNull(amount);
        this.currency = Objects.requireNonNull(currency);
    }

    public Money add(Money other) {
        if (!this.currency.equals(other.currency)) throw new IllegalArgumentException();
        return new Money(this.amount.add(other.amount), this.currency); // new object
    }

    public BigDecimal getAmount() { return amount; }
    public Currency getCurrency() { return currency; }
}
```

### Trade-offs

| Advantages | Disadvantages |
|-----------|--------------|
| Simple reasoning — only one possible state | Higher memory usage (new object on each "change") |
| Inherently thread-safe — no synchronisation needed | Not suitable for objects with frequent state transitions |
| Safe to share, cache, and use as map keys freely | |
| Failure atomicity — partial state change is impossible | |

### When to Prefer Immutability

- **Value objects** in Domain-Driven Design (Money, DateRange, Coordinates)
- **Configuration objects** that are built once and read many times
- **Shared state in concurrent systems** — eliminates synchronisation complexity
- **Functional-style pipelines** — operations return new values instead of mutating

---

## Key References

| Work | Author | Contribution |
|------|--------|-------------|
| *Design Patterns* (1994) | Gamma, Helm, Johnson, Vlissides (GoF) | Composition over inheritance, Decorator pattern |
| *Effective Java* (2001) | Joshua Bloch | Immutability rules |
