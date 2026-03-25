# Architectural Patterns

---

## Hexagonal Architecture (Ports & Adapters)

Developed by Alistair Cockburn. Also called **Ports and Adapters**.

> "A versatile architecture that can serve as a base for other required architectures."

### Inside vs Outside

The system is split into two primary areas:

| Area | Contents |
|------|----------|
| **Inside (core)** | Business rules and use cases — the application's reason to exist |
| **Outside (infrastructure)** | UI, databases, message brokers, external APIs, tests |

The outside depends on the inside — never the reverse. This creates a clear boundary where application use cases begin and end.

### Three Principles

1. The inside knows nothing about the outside.
2. Any adapter that fits a port must be swappable.
3. No business rule or use case belongs in the outside.

### Ports and Adapters

**Port** — an abstraction interface defining how the outside communicates with the inside. Can represent a use case or a processing capability.

**Adapter** — implements a port; transforms the external protocol into the application's internal interface.

| Adapter Type | Examples |
|-------------|----------|
| **Inbound (driving)** | REST API controller, message queue consumer, CLI handler |
| **Outbound (driven)** | Database repository, file writer, event publisher, queue producer |

### Internal Layers

```
Domain Model       — entities, value objects
Domain Services    — business process classes
Application Services — use case orchestrators
Outer Layer        — UI, database, tests
```

The core (Domain Model + Domain Services + Application Services) contains all logic needed to run and test the application, as long as dependencies are injected.

### Hexagonal vs Layered

| Dimension | Layered | Hexagonal |
|-----------|---------|-----------|
| Infrastructure direction | All layers can depend on it | Infrastructure is outermost; core never depends on it |
| Use case visibility | Hidden inside layers | Explicit at the application service boundary |
| Testability | Harder without infrastructure | Core fully testable without infrastructure |
| Framework coupling | High | Low |

### Trade-offs

**Pros**
- Business logic is isolated and testable without infrastructure
- Directed coupling — outside depends on inside, never reversed
- Swappable external systems (databases, UIs, brokers) without touching the core
- Pairs well with DDD

**Cons**
- Steeper learning curve
- Interfaces everywhere — indirection between ports and adapters
- Over-engineering risk when only one UI and database exist
- Navigating the codebase requires understanding adapter-port mapping
- Framework annotations in the core are a recurring design tension

### References

- [Ports and Adapters Architecture — Graca](https://herbertograca.com/2017/09/14/ports-adapters-architecture/)
- [DDD, Hexagonal, Onion, Clean, CQRS — Graca](https://herbertograca.com/2017/11/16/explicit-architecture-01-ddd-hexagonal-onion-clean-cqrs-how-i-put-it-all-together/)
- [Onion Architecture — Graca](https://herbertograca.com/2017/09/21/onion-architecture/)

---

## CQRS (Command and Query Responsibility Segregation)

> "Each method should either be a command that performs an action, or a query that returns data, but not both." — Bertrand Meyer (CQS principle)

CQRS takes this further at the architectural level: the models for write operations (commands) and read operations (queries) are completely separate and may even use different data stores.

### When to Use

- Applications with a high read-to-write ratio
- Complex business domains where write logic and read projections diverge significantly
- Systems needing independent read and write scalability

### Model Split

```
                 ┌─────────────┐        ┌──────────────┐
User action ────▶│  Command    │──event─▶│  Query       │
                 │  Model      │        │  Model       │
                 │ (write DB)  │        │ (read store) │
                 └─────────────┘        └──────────────┘
```

### Command Model

- Only write operations and lookup-by-ID
- Client must provide all data needed to execute the operation
- All parameter validation happens here
- **Synchronous:** command executes in the request; event published afterwards for read-model update
- **Asynchronous:** command queued for later processing; client receives an acknowledgement immediately

> Start synchronous. Move to async only when scalability demands it — avoid accidental complexity.

The command request can be persisted to enable audit trails.

### Query Model

- Only read operations (by ID or filters)
- Model need not be normalised — optimise for how data will be consumed
- Multiple query models can coexist for different views/clients
- New query models can be generated at any time from the event log

**Synchronous projection:** easier to implement; consistent within the same transaction; may add latency under load.
**Asynchronous projection:** eventual consistency; more flexible; supports multiple independent consumers.

> Always measure acceptable delay with real users before choosing sync vs async.

### Trade-offs

**Pros**
- Command model focuses purely on business logic and validation
- Query model focuses on display needs — can be denormalised for performance
- Independent scalability: reads scale more easily than writes
- Enables optimised read stores (e.g., Elasticsearch, Redis) alongside a normalised write store

**Cons**
- Keeping command and query models in sync adds complexity
- Eventual consistency in the query model can affect user decisions
- Significant architectural investment — not warranted for simple CRUD domains

### References

- [From CQS to CQRS — Graca](https://herbertograca.com/2017/10/19/from-cqs-to-cqrs/)
- [CQRS Documents — Greg Young](https://cqrs.wordpress.com/wp-content/uploads/2010/11/cqrs_documents.pdf)
- [An Illustrated Guide to CQRS Data Patterns — Red Hat](https://www.redhat.com/architect/illustrated-cqrs)

---

## Event Sourcing

> "Every state change in an application should be a first-class citizen — represented as a fact."

Instead of persisting current state, all events that produced the current state are persisted. The current state can always be derived by replaying events in chronological order.

Classic example: a bank account stores every debit and credit transaction, not just the current balance.

### Core Rules

- Events are **never deleted or modified** — only new events are appended (corrections are new events)
- The current state is derived by **replaying all events** (left-fold over the event stream)
- **Snapshots** can cache derived state to avoid replaying the entire stream

### Events and Projections

An **event stream** is the ordered sequence of events for an entity.

A **projection** is the computation over a time period of events:
- Enables auditing state at any point in time
- Supports "what-if" scenarios by adding hypothetical events
- Helps debug production issues by replaying real event sequences

### Replay Considerations

| Concern | Mitigation |
|---------|-----------|
| External updates during replay | Guard against re-executing side effects |
| External queries during replay | Persist queried values if history is unavailable externally |
| Code changes since original event | Apply Strategy pattern per event version |

### Rolling Snapshot

For aggregates with thousands of events, snapshots accelerate state reconstruction:

1. Build and store a snapshot of the derived state.
2. On next load, start from the snapshot rather than event zero.
3. Snapshots require **versioning** — schema changes must be handled carefully.

> "Current state is a left-fold of prior events."

### When to Use

- Applications that publish events to external systems
- Systems built on CQS/CQRS
- Complex domains requiring full audit trails
- Systems that need "time travel" — querying state at any historical point

### Trade-offs

**Pros**
- Automatic audit log
- Full temporal query capability
- State reconstruction for debugging
- Replay for "what-if" analysis

**Cons**
- Requires discipline — corrections are new events, not updates
- Schema evolution is non-trivial (old events lack new fields; Strategy pattern needed)
- Replaying large streams is expensive without snapshots
- Querying current state requires projection materialisation

### References

- [Event Sourcing — Fowler](https://martinfowler.com/eaaDev/EventSourcing.html)
- [CQRS and Event Sourcing — Greg Young](https://www.youtube.com/watch?v=JHGkaShoyNs)
- [The Many Meanings of Event-Driven Architecture — Fowler](https://www.youtube.com/watch?v=STKCRSUsyP0)
- [Domain Events vs. Event Sourcing](https://www.innoq.com/en/blog/2019/01/domain-events-versus-event-sourcing/)

---

## MVC (Model-View-Controller)

Created in 1970 at Xerox for visual interfaces in Smalltalk. Foundational pattern for separating UI concerns.

> "Separate the presentation from the model; separate the controller from the view." — Fowler

### Roles

| Layer | Responsibility |
|-------|---------------|
| **Model** | Stores application state; responds to data requests; encapsulates business logic |
| **View** | Renders the user interface; requests data from Model; sends events to Model; allows Controller to select next View |
| **Controller** | Routes requests to the correct page; maps UI data changes to Model; passes data to/from Model |

### Trade-offs

**Pros**
- Clean separation of distinct concerns
- Same model can be rendered in multiple ways
- Easy to add new data sources without touching View
- Easy to add new client types without touching Model
- Increases component reusability
- Easier error tracking

**Cons**
- Separation between View and Controller can be complex in practice

### Related Design Patterns

MVC relies heavily on: **Observer** (Model notifies View of changes), **Composite** (View is composed of sub-views), **Strategy** (Controller swappable at runtime).

### MVC Variants

- **Supervising Controller** — Controller handles complex view logic; View handles simple bindings
- **Passive View** — View is completely dumb; Controller drives all updates; best for testability

---

## Pattern Selection Guide

| Goal | Consider |
|------|----------|
| Isolate business logic from infrastructure | Hexagonal (Ports & Adapters) |
| Independent read/write scalability | CQRS |
| Full audit trail + temporal queries | Event Sourcing |
| Complex domain + event publishing | CQRS + Event Sourcing |
| Separate UI concerns | MVC |
| All of the above, DDD-aligned | Hexagonal + CQRS + Event Sourcing |
