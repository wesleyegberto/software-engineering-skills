# Consumer Driven Contracts — Spring Cloud Contract

Framework for **Consumer Driven Contracts (CDC)**.

- Uses DSL in **Groovy** or **YAML** to define contracts.
- From the contracts, automatically generates:
  - JSON stubs for WireMock (used in client tests)
  - Messaging routes (Spring Integration, Spring Cloud Stream, Apache Camel)
  - Acceptance tests (JUnit/Spock) to validate the server-side
