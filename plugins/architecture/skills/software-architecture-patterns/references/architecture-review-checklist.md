# Architecture Review Checklist

Use this checklist during architecture reviews, system design sessions, and before committing to significant architectural decisions.

---

## 1. Problem & Context

- [ ] Is the business problem clearly defined?
- [ ] Are the primary users and their access patterns understood (volume, frequency, peak load)?
- [ ] Is the criticality established? What is the impact of downtime (financial, reputational, safety)?
- [ ] Is the monetisation model clear? How does architecture support it?
- [ ] What is the target team size, technology stack, and seniority level?
- [ ] Are relevant regulatory or compliance constraints identified?

---

## 2. Architectural Requirements (AR)

- [ ] Are all non-functional requirements (NFRs) documented and prioritised?
- [ ] Are the top 3–5 quality attributes named and ordered by business priority?
  - Performance, Availability, Scalability, Maintainability, Testability, Security, Extensibility, Interoperability
- [ ] Are architectural constraints (things that cannot be changed) explicitly listed?
- [ ] Are premises (assumed truths) documented? Are they reasonable? (More premises = more risk)
- [ ] Are there variances where a decision cannot apply everywhere? Are they documented?

---

## 3. Style & Pattern Selection

### Monolithic Styles
- [ ] If **Layered**: is the separation of concerns well-defined? Are layers not bleeding into each other?
- [ ] If **Pipeline**: are filters truly stateless? Are long-running process boundaries handled?
- [ ] If **Microkernel**: is the core/plug-in boundary clear? Does the API cover future plug-in needs?

### Distributed Styles
- [ ] If **Microservices**: are services aligned to business capabilities (bounded contexts)? Are they truly autonomous (own data store)? Is operational tooling in place (observability, CI/CD)?
- [ ] If **EDA**: are events representing facts that already happened? Is the broker topology (Broker vs Mediator) appropriate? Is the Saga pattern in place for error handling?
- [ ] If **SOA**: is domain governance in place to prevent services from growing indefinitely? Is the ESB a single point of failure risk?

### Architectural Patterns
- [ ] If **Hexagonal**: does the inside know nothing about the outside? Are all external dependencies behind ports?
- [ ] If **CQRS**: is the read/write split warranted by domain complexity or scalability needs? Is eventual consistency acceptable to users?
- [ ] If **Event Sourcing**: is the event schema versioning strategy defined? Is snapshot strategy in place for large streams?
- [ ] If **MVC**: are Model, View, and Controller responsibilities clearly separated? Is the Observer pattern used for Model-View communication?

---

## 4. Data Architecture

- [ ] Is data ownership clear — which service or component owns each dataset?
- [ ] Is the choice between shared database and isolated databases intentional and justified?
- [ ] Are cross-service transaction requirements identified? Is eventual consistency acceptable?
- [ ] Is the data model appropriate to the access patterns (normalised for writes, denormalised for reads)?
- [ ] Is there a data migration and schema evolution strategy?
- [ ] Are data backup, recovery, and retention policies defined?

---

## 5. Integration & Communication

- [ ] Is the integration approach (File Transfer, Shared DB, RPC, Messaging) justified by the requirements?
- [ ] Are service contracts defined and versioned? Is backward compatibility strategy explicit?
- [ ] Is synchronous communication used only when the caller genuinely needs an immediate response?
- [ ] Are messaging failure scenarios handled (dead-letter queues, retry policies, idempotency)?
- [ ] Is there a strategy for handling partial failures in distributed workflows?

---

## 6. Quality Attributes Verification

### Performance & Scalability
- [ ] Are the most likely bottlenecks identified?
- [ ] Is the scaling model appropriate (horizontal vs vertical; which axis of the Scale Cube)?
- [ ] Are caching layers considered at the right level (application, database, CDN)?
- [ ] Is asynchronous processing considered for non-blocking operations?

### Availability & Reliability
- [ ] Are single points of failure identified and mitigated?
- [ ] Is a circuit-breaker or bulkhead pattern in place for distributed calls?
- [ ] Is the target availability (SLA/SLO) achievable with the proposed architecture?
- [ ] Is disaster recovery and failover designed?

### Security
- [ ] Is authentication and authorisation handled at the appropriate boundary?
- [ ] Is sensitive data identified? Is encryption at rest and in transit applied?
- [ ] Are inputs validated at system boundaries?
- [ ] Are secrets managed securely (no hard-coded credentials)?

### Maintainability & Testability
- [ ] Can the system be tested independently of external dependencies (ports & adapters, stubs)?
- [ ] Is observability built in: structured logging, distributed tracing, metrics?
- [ ] Are deployment units independently deployable without coordinating with others?
- [ ] Is the architecture documented (ADR, Architecture Haiku) at a level that allows onboarding?

---

## 7. Architectural Decisions

- [ ] Are key decisions documented in ADRs (Title, Context, Decision, Status, Consequences)?
- [ ] Were alternatives considered and the trade-offs evaluated?
- [ ] Is the decision reversibility known? Are irreversible decisions treated with extra care?
- [ ] Are automated architecture conformance tests considered (ArchUnit, JArch, Deptrac)?

---

## 8. Architecture Documentation

- [ ] Is an Architecture Haiku (or equivalent one-pager) available?
  1. Brief solution summary
  2. Contextual description
  3. Technical constraints
  4. Key functional requirements summary
  5. Prioritised quality attributes
  6. Design decisions with rationale and trade-offs
  7. Styles and patterns used
  8. Only diagrams that add meaning beyond the text
- [ ] Is there a history of past architectural decisions and diagrams for onboarding?
- [ ] Does documentation describe *why* decisions were made, not just *what* was decided?

---

## 9. Team & Organisational Fit

- [ ] Does the architecture match the team topology (Conway's Law)? Would a different topology serve better?
- [ ] Is the operational complexity within the team's capability?
- [ ] Are there knowledge gaps that need to be addressed before implementation?
- [ ] Is the chosen style aligned with the architecture lifecycle phase (Youth / Growth / Maturation)?

---

## Quick Red-Flag Table

| Observation | Likely Issue |
|-------------|-------------|
| Services sharing a database in a microservices setup | Data coupling — defeats autonomy |
| Business logic in ESB routing rules | Logic in the pipe — hard to test, change |
| Synchronous chains of 3+ service calls per user action | Latency risk + cascading failure |
| No observability (logging, tracing, metrics) planned | Blind operations |
| CQRS/Event Sourcing adopted for a simple CRUD domain | Accidental complexity |
| Many premises (assumed truths) undocumented | High hidden risk |
| No ADR for a decision that affects the entire system | Future maintainers will re-debate it |
| Core domain logic leaking into adapters / infrastructure | Breaks hexagonal boundary |
| Architecture docs describe *what* but not *why* | Knowledge loss risk |
| Team unfamiliar with distributed systems building microservices | Operational complexity underestimated |
