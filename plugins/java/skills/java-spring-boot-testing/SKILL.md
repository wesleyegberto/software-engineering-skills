---
name: java-spring-boot-testing
description: 'Complete guide to testing in Spring Boot — unit tests with Mockito, controller tests (MockMVC standalone, @WebMvcTest, MockMvcTester, @SpringBootTest, WebTestClient), JPA repository tests, Testcontainers, Spring Cloud Contract, and stress testing. Use when writing or reviewing any Spring Boot test.'
metadata:
  scope: testing
  version: "1.0.0"
---

# Spring Boot Testing

Guide to testing strategies and examples for Spring Boot applications.

## When to Use This Skill

- Write unit tests for services and components (JUnit 5 + Mockito)
- Write controller tests: unit (standalone MockMVC) or integration (@WebMvcTest, @SpringBootTest)
- Test JPA repositories with `@DataJpaTest`
- Use Testcontainers for real database integration tests
- Implement Consumer Driven Contracts with Spring Cloud Contract
- Diagnose or simulate thread pool starvation
- Benchmark performance with JMH

## Reference Guide

| Topic | Reference | Load When |
|-------|-----------|-----------|
| Controller Tests | `references/controller-tests.md` | MockMVC standalone, @WebMvcTest, MockMvcTester, @SpringBootTest + MockMvc/TestRestTemplate, WebFluxTest + WebTestClient |
| Unit Testing | `references/unit-testing.md` | Service/component tests with Mockito, parameterized tests, test data builders |
| JPA Tests | `references/data-jpa-test.md` | @DataJpaTest, TestEntityManager, H2, real database, rollback, ordered tests |
| Testcontainers | `references/testcontainers.md` | PostgreSQL container, DynamicPropertySource, AbstractIntegrationTest |
| Test Configuration | `references/test-configuration.md` | application-test.yml, @TestConfiguration, TestDataFactory |
| Contract Testing | `references/contract-testing.md` | Spring Cloud Contract, Consumer Driven Contracts, WireMock stubs |
| Stress Testing | `references/stress-testing.md` | Thread pool starvation with JMeter, JMH micro-benchmarks |

## Testing Best Practices

- Follow the **AAA pattern** (Arrange, Act, Assert)
- Use `@DisplayName` for descriptive test names
- Mock external dependencies in unit tests; use Testcontainers for real DB
- Achieve **85%+ code coverage**
- Test both happy path and edge/error cases
- Use `@Transactional` for automatic test data cleanup
- Keep unit tests and integration tests in separate source sets or naming conventions
- Use parameterized tests to cover multiple input scenarios
- Test security rules (`@WithMockUser`) and input validation
- Keep tests fast and independent — avoid shared mutable state
