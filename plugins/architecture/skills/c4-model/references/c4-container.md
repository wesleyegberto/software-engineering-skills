# C4 Container Level — Agent Reference

Agent: `c4-container` | Model: sonnet | Input: Component docs + deployment configs | Output: `c4-container.md` + OpenAPI specs

## Purpose

Maps logical components to deployment containers (processes, applications, services, databases). Documents container interfaces as OpenAPI/Swagger specs. Shows high-level technology choices and deployment architecture.

## Core Philosophy

Containers are deployable units that must be running for the system to work. Container diagrams show **high-level technology choices** and how responsibilities are distributed. Technology details belong here, not at Component or Context level.

## Workflow

1. Review all `c4-component-*.md` files to understand component structure
2. Review deployment definitions (Dockerfiles, K8s manifests, Terraform, cloud configs)
3. Map components to containers based on deployment reality
4. Identify container names, descriptions, and deployment characteristics
5. Create OpenAPI/Swagger specs for all container interfaces
6. Map inter-container communication (HTTP, gRPC, queues, events)
7. Generate Mermaid C4Container diagrams
8. Link container docs to API specs and deployment configs

## Documentation Template

```markdown
# C4 Container Level: System Deployment

## Containers

### [Container Name]

- **Name**: [Container name]
- **Description**: [Short description of container purpose and deployment]
- **Type**: [Web Application, API, Database, Message Queue, etc.]
- **Technology**: [Node.js, Python, PostgreSQL, Redis, etc.]
- **Deployment**: [Docker, Kubernetes, Cloud Service, etc.]

## Purpose

[Detailed description of what this container does and how it's deployed]

## Components

This container deploys the following components:

- [Component Name]: [Description]
  - Documentation: [c4-component-name.md](./c4-component-name.md)

## Interfaces

### [API/Interface Name]

- **Protocol**: [REST/GraphQL/gRPC/Events/etc.]
- **Description**: [What this interface provides]
- **Specification**: [Link to OpenAPI/Swagger/API Spec file]
- **Endpoints**:
  - `GET /api/resource` - [Description]
  - `POST /api/resource` - [Description]

## Dependencies

### Containers Used

- [Container Name]: [How it's used, communication protocol]

### External Systems

- [External System]: [How it's used, integration type]

## Infrastructure

- **Deployment Config**: [Link to Dockerfile, K8s manifest, etc.]
- **Scaling**: [Horizontal/vertical scaling strategy]
- **Resources**: [CPU, memory, storage requirements]

## Container Diagram

[See diagram syntax below]
```

## Container Diagram Syntax

```mermaid
C4Container
    title Container Diagram for [System Name]

    Person(user, "User", "Uses the system")
    System_Boundary(system, "System Name") {
        Container(webApp, "Web Application", "Spring Boot, Java", "Provides web interface")
        Container(api, "API Application", "Node.js, Express", "Provides REST API")
        ContainerDb(database, "Database", "PostgreSQL", "Stores data")
        Container_Queue(messageQueue, "Message Queue", "RabbitMQ", "Handles async messaging")
    }
    System_Ext(external, "External System", "Third-party service")

    Rel(user, webApp, "Uses", "HTTPS")
    Rel(webApp, api, "Makes API calls to", "JSON/HTTPS")
    Rel(api, database, "Reads from and writes to", "SQL")
    Rel(api, messageQueue, "Publishes messages to")
    Rel(api, external, "Uses", "API")
```

## OpenAPI Spec Template

For each container API, create a specification file (e.g., `api-spec.yaml`):

```yaml
openapi: 3.1.0
info:
  title: [Container Name] API
  description: [API description]
  version: 1.0.0
servers:
  - url: https://api.example.com
    description: Production server
paths:
  /api/resource:
    get:
      summary: [Operation summary]
      description: [Operation description]
      responses:
        '200':
          description: [Response description]
          content:
            application/json:
              schema:
                type: object
```

## Key Principles

- This is where **technology details belong** in the C4 model
- Map based on deployment reality, not just logical grouping
- Every container interface should have an OpenAPI/Swagger spec
- Show communication protocols between containers
- Link to deployment configs (Dockerfiles, K8s manifests, etc.)
- This output feeds into the Context level agent
