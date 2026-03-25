# Enterprise Application Patterns

Reference: *Patterns of Enterprise Application Architecture* — Martin Fowler (2002)

---

## Domain Logic Patterns

One of the first steps in designing software is deciding which approach to use for domain logic.

### Transaction Script

Organises logic as a single procedure per business transaction, making calls to the database directly or through a thin wrapper.

Most business applications can be thought of as a series of transactions. A transaction may be simple (display database info) or complex (multi-step validation and calculation).

**When to use:** Simple domains; small teams; limited time.

**Structure:**
```
User Action → Transaction Script → Database
```

**Trade-offs**

| Pros | Cons |
|------|------|
| Simple; most developers understand it | Maintenance degrades as domain logic grows |
| Works well with simple data source patterns | Logic duplication across procedures |
| Transaction boundaries are explicit | Hard to reuse logic across procedures |

### Domain Model

Creates a network of interconnected objects where each represents a meaningful entity in the business context.

Each object holds a portion of the logic relevant to it. Class structure and relationships represent business rules in natural language.

**When to use:** Complex business rules with many scenarios; DDD applications.

**Trade-offs**

| Pros | Cons |
|------|------|
| Full use of OO: encapsulation, polymorphism | Domain model may diverge significantly from database schema |
| Logic distributed meaningfully to owning objects | Requires mapping layer (Data Mapper) for persistence |
| Natural representation of business rules | Steeper learning curve |

### Service Layer

Defines the application boundary using a layer of services that establishes a set of available operations and coordinates the application's response to each.

Sits above the Domain Model (or Transaction Script), orchestrating use cases without containing business logic itself.

---

## Data Source Patterns

Define how the business model is represented in persistence.

### Active Record

The domain object contains both data and persistence behaviour (save, find, delete). Classes correspond to database table structure.

**When to use:** Simple domains; rapid development; straightforward CRUD.

**Trade-offs**

| Pros | Cons |
|------|------|
| Simple; easy to implement | Violates SRP — mixes domain and persistence concerns |
| Good for simple domain logic | Difficult to model complex object graphs |
| No separate mapping layer | Tight coupling to database schema |

### Data Mapper

A separate mapping layer transfers data between in-memory objects and the database. Domain objects do not know a database exists.

Objects and relational databases have different mechanisms for structuring data. The mapper bridges the object world and the relational world.

**When to use:** Complex domains; when database schema and object model evolve independently; testable domain logic required.

**Trade-offs**

| Pros | Cons |
|------|------|
| Clean separation of concerns (SRP) | More code — additional mapping layer |
| Domain model evolves independently from schema | More complex to implement and test |
| Domain objects are fully testable without a database | ORM tools (Hibernate, JPA, EF Core) implement this pattern |

### Choosing Between Active Record and Data Mapper

```
Domain complexity low, schema stable  →  Active Record
Domain complexity high, schema may diverge  →  Data Mapper
```

---

## Enterprise Integration Patterns (EIP)

Applications rarely live in isolation. Integration solutions must:
- Transmit information between systems with different languages, OS, and data formats
- Interact with different technologies
- Minimise dependencies between systems (loose coupling)

> "Designing a distributed solution the same way as a monolith can have disastrous performance implications." — Hohpe & Woolf

### Four Integration Approaches

#### 1. File Transfer

Applications exchange data by writing and reading files. Agreement required on: file name, location, format, timing, and who deletes the file.

```
App A ──writes──▶ File ──reads──▶ App B
```

| Pros | Cons |
|------|------|
| Universal — works across all platforms and languages | Updates infrequent; data can be stale |
| Integrators don't need to know internal details | Slow reads; potential consistency problems |
| Simple to implement | Manual agreement on file conventions |

**Best for:** Batch processing; legacy system integration; infrequent bulk data exchange.

#### 2. Shared Database

All applications read from and write to the same database. Schema designed to serve all application needs.

```
App A ──▶ ╔══════════╗ ◀── App B
          ║ Shared   ║
App C ──▶ ║ Database ║ ◀── App D
          ╚══════════╝
```

| Pros | Cons |
|------|------|
| Near-instant updates | Performance complexity (contention, locking) |
| No data duplication or transfer | Schema coupling — all apps share one schema |
| Simple to implement | Changes to schema affect all consumers |
| ACID transactions across systems | Bottleneck and deadlocks under high load |

**Best for:** Tightly coupled systems within one organisation; when consistency is paramount.

#### 3. Remote Procedure Call (RPC)

Each application exposes an interface. Other applications call remote functions directly as if they were local.

```
App A ──RPC call──▶ App B's Interface
```

| Pros | Cons |
|------|------|
| Familiar programming model | Remote calls are slower and less reliable than local calls |
| Many standards available (REST, gRPC, SOAP) | Temporal coupling — both systems must be available |
| Data freshness: always current | Tight coupling can develop over time |

**Best for:** Synchronous request/response interactions; when both parties can be available simultaneously.

#### 4. Messaging

Applications communicate by sending messages asynchronously through a message broker. Sending does not require the receiver to be available.

```
App A ──message──▶ [Broker] ──message──▶ App B
```

| Pros | Cons |
|------|------|
| Loose coupling — sender/receiver independent | Eventual consistency; data may lag |
| High reliability with broker guarantees | More complex to implement and debug |
| Higher throughput possible | Testing and tracing end-to-end flows is harder |
| Retry and dead-letter queue support | Requires broker infrastructure |

**Best for:** High-volume async workflows; EDA; microservices communication; systems that need resilience to downstream failures.

**Related patterns:**
- Enterprise Service Bus (ESB) — centralised broker with routing and transformation logic
- Message-Oriented Middleware (MOM) — broker without embedded business logic (preferred in microservices)

---

## Integration Pattern Selection Guide

| Need | Consider |
|------|----------|
| Batch data between legacy systems | File Transfer |
| Instant consistency, single org | Shared Database |
| Synchronous request/response | RPC (REST / gRPC) |
| Async, decoupled, resilient | Messaging |
| Async + workflow orchestration | Messaging + ESB or orchestrator |
| Microservices communication | Messaging (dumb pipe broker) or REST |

---

## References

| Work | Author | Contribution |
|------|--------|-------------|
| *Patterns of Enterprise Application Architecture* | Martin Fowler | Transaction Script, Domain Model, Active Record, Data Mapper |
| *Enterprise Integration Patterns* | Hohpe & Woolf | File Transfer, Shared DB, RPC, Messaging |
| [EAP Further Patterns](https://martinfowler.com/eaaDev/) | Fowler | Extended patterns |
