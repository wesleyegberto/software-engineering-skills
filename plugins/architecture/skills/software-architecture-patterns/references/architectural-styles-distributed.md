# Distributed Architectural Styles

---

## Microservices Architecture

> "Small, autonomous services that work together, modelled around a business domain." — Sam Newman

The application is split into a set of independently deployable services, each with its own domain, business logic, and data store.

Strongly inspired by Domain-Driven Design (DDD); the concept of Bounded Context decisively shaped the microservices style.

### Core Topology

- Each service runs in its own process (physical or virtual machine)
- **Data isolation:** no shared schemas or centralised databases
- Service interfaces are the only integration surface (APIs, contracts)
- Services communicate via REST/HTTP, gRPC, or messaging

### Principles (Sam Newman)

| Principle | Meaning |
|-----------|---------|
| Modelled around business domains | Each service maps to a business capability, not a technical tier |
| Culture of automation | CI/CD, automated testing, infrastructure as code are mandatory |
| Hide implementation details | Expose only what the API contract specifies |
| Independent deployment | Any service can be deployed without coordinating with others |
| Consumer first | Design the service contract around consumer needs |
| Isolated failure | A failing service must not cascade to other services |
| Highly observable | Centralised logging, distributed tracing, and monitoring are non-optional |

### Sizing a Service

- Apply DDD to identify business capabilities (bounded contexts)
- Decompose the domain top-down to establish correct boundaries
- Migration from a monolith is easier — boundaries already exist in the code

### Transactions

Avoid cross-service transactions and Two-Phase Commit.
Prefer **eventual consistency** to reduce synchronous coupling.

Techniques to reshape use cases for eventual consistency:
- Remodel functions to avoid cross-service writes
- Sequence operations to minimise failure surface
- Compensating operations to reverse changes on failure (Saga pattern)

### Pitfalls

- **Anemic CRUD microservice:** turns every noun into a service — logic ends up distributed across many places
- **Circular dependencies** between services
- **Chatty services:** excessive synchronous calls between services for a single operation
- **Distributed monolith:** services that are not truly autonomous — the worst of both worlds

### Evolution Path

1. Grow the monolith → add a microservice alongside
2. Decompose the monolith → extract microservices incrementally
3. Do not start a new project directly with microservices — boundaries are hard to get right upfront

### Trade-offs

**Pros**
- Independent development, testing, and deployment per service
- Technology diversity — best tool per service
- Selective scalability (scale only what is overloaded)
- Business agility; enables rapid experimentation
- Naturally encourages modern engineering: CI/CD, automated testing

**Cons**
- Very high operational complexity: communication, coordination, backward compatibility, logging, monitoring, debugging
- Network latency and unreliability become first-class concerns
- Data isolation increases complexity of cross-service queries and replication
- Risk of logic duplication and chatty inter-service calls
- Requires high degree of automation to be viable

### References

- [Microservices — Martin Fowler](https://martinfowler.com/articles/microservices.html)
- [Microservices Principles — Sam Newman](https://www.youtube.com/watch?v=PFQnNFe27kU)
- [Design Patterns for Microservices — DZone](https://dzone.com/articles/design-patterns-for-microservices-1)

---

## Event-Driven Architecture (EDA)

> "EDA is a software architecture that promotes the production, detection, consumption, and reaction to events."

An asynchronous, distributed style that enables highly scalable and high-performance applications. Components react to events rather than direct calls.

**Key constraint:** events notify about something that *already happened*. Do not "eventify" internal operations that should stay within a component — this increases coupling rather than reducing it.

### When to Use Events

- Decouple components (not modules within the same component)
- Execute asynchronous tasks
- Track state changes for audit trails

### Topologies

| Topology | Purpose |
|----------|---------|
| **Broker** | Greater responsiveness and dynamic control; no central coordinator; services react to events and emit new ones |
| **Mediator** | Orchestrates the workflow (sequence of steps) of a complex event; central coordinator controls flow |

### Event Patterns (Fowler)

#### 1. Event Notification
The event carries minimal data (entity ID, timestamp). Consumers query the emitter if they need more.

- **Pro:** high resilience; components evolve independently
- **Con:** risk of tight coupling if consumers need frequent lookups; can create spaghetti flows if overused

#### 2. Event-Carried State Transfer
The event carries all data needed for processing, eliminating consumer queries to the emitter.

- **Pro:** high resilience; reduced latency; independent evolution
- **Con:** data duplication; consumers must maintain a local copy

#### 3. Event Sourcing
All state changes are stored as events. See `architectural-patterns.md`.

### Event Listener vs Event Subscriber

| Concept | Reacts to | Typical use |
|---------|-----------|-------------|
| **Event Listener** | One specific event type; may have multiple handler methods | `UserRegisteredEventListener` |
| **Event Subscriber** | Multiple event types; multiple handler methods | `RequestTransactionSubscriber` |

### Trade-offs

**Pros**
- Decouples business components
- High performance, scalability, and fault tolerance
- Highly evolvable — producers and consumers change independently

**Cons**
- Complex workflow control (hard to trace end-to-end flows)
- Potential data inconsistency
- Requires Saga pattern for distributed error handling

### References

- [What Do You Mean By "Event-Driven"? — Fowler](https://martinfowler.com/articles/201701-event-driven.html)
- [Event-Driven Architecture — Graca](https://herbertograca.com/2017/10/05/event-driven-architecture/)
- [6 Event-Driven Architecture Patterns — Wix](https://medium.com/wix-engineering/6-event-driven-architecture-patterns-part-1-93758b253f470)

---

## Service-Oriented Architecture (SOA)

> "SOA has different meanings for different people." — traditional ESB/Web Services SOA vs. modern distributed SOA with business-capability separation.

A hybrid between microservices and monolithic styles. Less complexity and cost than microservices; more modularity than a monolith.

### Topology

- Separate user interface, remote services, and database
- Services are independently deployable parts of an application
- User interface exposed via remote protocols (SOAP, REST, RPC)
- **Typically uses shared databases** (key difference from microservices)
- Internal structure is usually layered or domain-component-based

### Thomas Erl's Eight SOA Principles

| # | Principle | Meaning |
|---|-----------|---------|
| 1 | **Reusable** | As generic as possible; a service is a company asset, not a team asset |
| 2 | **Formal contract** | Specifies functionality, inputs, and outputs |
| 3 | **Low coupling** | Consumers unaffected by service evolution |
| 4 | **Abstracted logic** | Black box — internal logic hidden from consumers |
| 5 | **Composable** | Services can be composed to build solutions |
| 6 | **Autonomous** | Self-managing; independent of external elements for execution |
| 7 | **Stateless** | Avoids long-held resources to guarantee availability and reuse |
| 8 | **Discoverable** | Registered and discoverable via directories (UDDI, ebXML) |

### SOA with ESB (Enterprise Service Bus)

ESB is the integration backbone in traditional SOA. It provides:
- Service exposure and invocation
- Generic functions: authentication, authorisation, logging
- Protocol conversion, routing, mediation
- Deployment and versioning control

> ESB goes against the "dumb pipe" principle — business logic leaks into the bus.

The main downside: the bus becomes a single point of failure, high maintenance burden, and often accumulates business logic that should live in services.

### Trade-offs

**Pros**
- Independent deployment per service
- Domain isolation
- Can be a stepping stone toward microservices
- Fewer domain-boundary pitfalls than microservices (services are larger, more complete)

**Cons**
- Services tend to grow large without strict domain governance
- Limited scalability and elasticity compared to microservices
- Synchronous communication can create bottlenecks
- Traditional ESB: single point of failure; complex configuration; team needed just to manage the bus

### SOA vs Microservices

| Dimension | SOA | Microservices |
|-----------|-----|---------------|
| Database | Usually shared | Independent per service |
| Communication | Centralised ESB common | Dumb pipes (broker); direct calls |
| Autonomy | Service-level | Environment-level |
| Size | Larger, coarser | Fine-grained, bounded context |
| Complexity | High | Very high |

---

## Quick Comparison: Distributed Styles

| Dimension | EDA | SOA | Microservices |
|-----------|-----|-----|---------------|
| Scalability | High | Medium | High |
| Fault tolerance | High | Low–Medium | High (with patterns) |
| Complexity | High | High | Very High |
| Data isolation | Variable | Low (shared DB) | High |
| Team autonomy | Medium | Low | High |
| Best for | Async decoupled workflows | Enterprise integration | Independent team/domain scale |
