# Monolithic Architectural Styles

---

## Layered Architecture (N-Tier)

Components are organised into horizontal logical layers where each layer performs a specific role and provides services to the layer above it.

**Core idea:** Upper layers depend on lower layers. Code must reside in its appropriate layer according to its function.

### Variants

| Variant | Rule |
|---------|------|
| **Strict** | A layer may only depend on the layer immediately below it |
| **Flexible** | A layer may depend on any layer below it |

> A lower layer can indirectly notify an upper layer via Observer or Mediator patterns.

### Typical Layer Stack

```
Presentation layer
Application layer
Domain layer
Persistence layer
Infrastructure layer
```

The most common arrangement has 4 layers: Presentation, Business, Persistence, Database.

### When to Use

- Small-to-medium business applications that do more than pure CRUD
- Teams with a clear separation of concerns across developer roles
- Budget-constrained or time-constrained starts with familiar structure
- When consistency across multiple projects is important

### Trade-offs

**Pros**
- Most developers already know the pattern
- Easy to write well-organised, testable code
- Consistent structure across projects
- Low initial cost

**Cons**
- Maintainability, agility, and testability degrade as the system grows
- Longer deployment cycles (full system redeployment)
- Tends to produce a monolith that is difficult to split
- Hides use cases — class structure does not reveal business flows clearly
- Often produces "pass-through" code that adds no value
- Low cohesion: classes contributing to one scenario are separated by technical concepts

### References
- [Layered Architecture — herbertograca.com](https://herbertograca.com/2017/08/03/layered-architecture/)
- [Layered Architecture is Good — DZone](https://dzone.com/articles/layered-architecture-is-good)

---

## Pipeline Architecture (Pipes and Filters)

Topology made up of two elements: **pipes** (channels) and **filters** (processors).

Ideal for problems that can be decomposed into discrete processing steps. The same model underlies MapReduce.

### Topology

| Element | Description |
|---------|-------------|
| **Pipe** | Unidirectional, point-to-point channel that connects filters |
| **Filter** | Stateless, self-contained processor; independent of other filters; performs a single task |

### Filter Roles

- **Producer** — creates data to enter the pipeline
- **Transformer** — transforms input data to output
- **Tester** — validates or filters data (may reject items)
- **Consumer** — terminates the pipeline; persists or delivers results

### Long-Running Processes

When many pipes and filters are involved:

1. Designate one filter as an **executive** that monitors progress and persists state.
2. Model the process as a set of **Aggregates** where one monitors overall state.
3. Keep all filters stateless and **enrich the event** at each step.

Use an **End-to-End ID** to correlate all events that belong to the same originating trigger.

For error handling: compensating filters or alternative user-facing flows.

### Trade-offs

**Pros**
- Simple to understand
- Low cost to build and maintain
- Good modularity — filters can be composed and reused

**Cons**
- Limited fault tolerance (no built-in recovery)
- Poor extensibility for complex branching logic
- Low scalability

### References
- [Pipeline — ITNEXT](https://itnext.io/pipeline-88e24688b5ec)
- [Pipelines in Architectural Patterns](https://itnext.io/pipelines-in-architectural-patterns-908a6bb2975e)

---

## Microkernel Architecture (Plugin Architecture)

Topology split into two elements: a **core system** and **plug-in components**.

Application logic is divided between independent plug-ins and a minimal core, providing extensibility, adaptability, and isolation of features and custom processing.

> "Natural choice for product-based applications." — Richards & Ford

### Topology

- **Core system:** provides the entry point and general flow of the application; does not know what each plug-in does; exposes an API that plug-ins must implement
- **Plug-ins:** autonomous, independent; reflect specialised processing; implement the core's interface

The core communicates with plug-ins through a defined interface, enabling runtime swapping.

### Ideal For

- Applications that read data from one source, transform it, and write to different destinations
- Workflow applications
- Task scheduling and execution applications
- IDEs and code editors (classic example)
- Any system with a stable core and variably pluggable features

### Trade-offs

**Pros**
- High flexibility and extensibility
- Plug-ins can be swapped at runtime
- Features can be added, removed, or modified without touching the core
- System can be simplified by disabling plug-ins
- Can be partitioned by domain or technically

**Cons**
- Scalability, fault tolerance, and testability are weak
- Little or no fault tolerance by default
- Hard to decide what belongs in the core versus a plug-in
- An API designed today may not fit future plug-ins well (careful refactoring required)

---

## Quick Comparison: Monolithic Styles

| Dimension | Layered | Pipeline | Microkernel |
|-----------|---------|----------|-------------|
| Scalability | Low | Low | Low |
| Fault tolerance | Low | Low | Low |
| Complexity | Low | Low | Medium |
| Testability | Medium | Medium | Medium |
| Extensibility | Low | Low | High |
| Best for | Business apps | ETL / data processing | Product apps, plugins |
