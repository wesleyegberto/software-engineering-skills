# Software Architecture Fundamentals

---

## What Is Software Architecture?

> "The fundamental organization of a system, its components, the relationships between
> them, and the environment that guides its design and evolution." — IEEE Standard 1471

> "The set of structures needed to reason about the system, which includes software
> elements, relations among them, and properties of both." — Bass, Clements & Kazman

> "A set of decisions that are hard to change later." — Martin Fowler

Key ideas:
- The **main elements** of the system — the pieces that are hard to change
- The **foundation** upon which everything else is built
- All technical decisions that affect all development resources (frameworks, coding standards, processes)
- It prepares the project for **change** and **reuse**, and defines standards for consistency

> Architects have the important responsibility of questioning assumptions left in the
> past and new ones that emerge.

---

## The Architect's Role

> "The architect should be like a guide — an experienced and capable team member who
> teaches others to manage better, yet is always there for the harder parts." — Martin Fowler

> "The architect's role is to ensure that the proposed solution meets business objectives,
> respects constraints, meets quality attributes at the lowest cost or risk." — Elemar Junior

**Key responsibilities:**

| Responsibility | What it means |
|---------------|---------------|
| Domain knowledge | Without business knowledge, it's impossible to plan an architecture that achieves requirements |
| Architectural decisions | Analyse solutions, define architectural decisions and design principles |
| Continuous analysis | Review architecture, code, and identify improvement opportunities |
| Technology choices | Decide how technologies will be applied |
| Conformance | Ensure the team follows architectural decisions and design principles |
| Interpersonal skills | "No matter what they tell you, it's always a people problem" |

**Types of architects:**

| Type | Focus |
|------|-------|
| Software | Responsible for a product; close to the dev team; directs patterns and practices |
| Solution | Bridges business and technology; high-level view across applications |
| Technology/Specialist | Deep expert in one technology domain (data, cloud, Java, etc.) |
| Systems | Connection between systems; large technology partnerships |
| Enterprise | Strategic; maps everything into a coherent company-wide picture |

---

## Architectural Requirements (AR)

> Requirements that directly or indirectly impact architecture.

Architectural designs must: meet business objectives, respect constraints, satisfy quality
attributes, mitigate risks, and reduce costs.

**Relationship with non-functional requirements (NFRs):** NFRs are used as selection
criteria when choosing between architectural alternatives, styles, and implementations.

**An architectural decision involves:**
- Affects business objectives or quality attributes (performance, availability, security, maintainability)
- Is hard to undo (one of the four sources of complexity)
- Implies significant cost or savings in time/money
- Required considerable effort, PoCs, or trade-off evaluation
- May be hard to understand without background context

**Defining architecture — questions to answer first:**
- For whom and who will use it? What's the access volume and frequency?
- What is the criticality? What's the impact of downtime?
- How will it be monetised?
- How much should it cost to build, maintain, and evolve?
- What's the team's technology stack and seniority level?

**Types of architectural requirements:**
Technical, Functional, Strategic, Security, Data, Infrastructure, Governance, Marketing, Monitoring

**How to document a requirement:**
```
AR-01 — Open Source Technologies
Weight: 3
Reasons:
  Interviews:
    Q: What is the biggest problem today?
    A: Growing without raising costs
    Q: What is the pain with current technology?
    A: Vendor discontinued the solution
```

---

## Architectural Decisions

> Define the rules for how a system should be built within a given structure.

Architectural decisions form the **constraints** of the system and serve as guidance
for the development team about what is and is not allowed.

**Recommendations:**
- Create an artefact documenting: topic, alternatives considered, the decision, and its justification
- Create automated tests to enforce the architecture (e.g., ArchUnit, JArch)

**Premises:** Hypothetical truths assumed during analysis when definitions are unavailable.
> The more premises, the higher the project risk.

**Constraints:** Factors imposed by the business that cannot be modified. Used as
part of viability analysis.

**Variances:** Some architectural decisions may not be implementable everywhere due
to specific constraints. Document variances explicitly with a validation/approval process.

**Evaluation methods:** ATAM (Architecture Tradeoff Analysis Method), MADR (Markdown
Architectural Decision Records)

---

## Architectural Documentation

> Documentation is good when its cost is offset by reduced costs in other activities
> or by risk mitigation.

**What to document:**
- Aspects that will remain true for the longest time
- The strategy that will authorise changes (a coherent pattern for decision-making)
- Current structure and its properties

> "One of the hardest things to track during the life of a project is the motivation
> behind certain decisions. Without understanding the rationale or the consequences,
> a person has only two options: accept it blindly or change it blindly." — Nygard

### Architecture Haiku (George Fairbanks)

A one-page design overview — quick to build and review:

1. Brief summary of the overall solution
2. Relevant contextual description
3. List of important technical constraints
4. High-level summary of key functional requirements
5. Prioritised list of quality attributes
6. Brief explanation of design decisions (rationale + trade-offs)
7. List of architectural styles and patterns used
8. Only diagrams that add meaning beyond the text

> Good starting point for organisations without a consolidated architecture practice.

### Architectural Decision Records (ADR)

Short text files kept in the project repository:

| Section | Content |
|---------|---------|
| **Title** | Short and expressive |
| **Context** | Technical, political, social aspects influencing the decision (neutral language) |
| **Decision** | Active voice — what path to follow |
| **Status** | Proposed / Accepted / Deprecated / Superseded |
| **Consequences** | Positive, negative, and neutral results of the decision |

---

## Architecture Lifecycle

| Phase | Characteristics |
|-------|----------------|
| **Youth** | Disordered early development; many assumptions; hacky feature delivery |
| **Growth** | Rapid feature delivery; business still changing; incomplete understanding |
| **Maturation** | Large-feature delivery; bug fixes; performance work (fixing earlier hacks) |
| **Ageing** | Stable product; only bug fixes and performance; major features go to new products |
| **End-of-life** | Bug fixes only; migration to successor underway |

**Key insight:** Architecture changes throughout the lifecycle (monolith → services →
microservices → macro-services → monolith). Architect should maintain a history of
decisions and architecture diagrams to onboard new team members without losing knowledge.

---

## References

| Work | Author | Contribution |
|------|--------|-------------|
| IEEE Standard 1471 | IEEE | Formal architecture definition |
| *Software Architecture in Practice* | Bass, Clements & Kazman | Architecture as structures and reasoning |
| *Fundamentals of Software Architecture* (2020) | Richards & Ford | Architectural styles and characteristics |
| *Just Enough Software Architecture* | George Fairbanks | Architecture Haiku |
| [Architecture and Product Life Cycle](https://medium.com/itnext/architecture-and-product-life-cycle-b23b2675a931) | — | Lifecycle phases |
