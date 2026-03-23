# Test Configuration

## application-test.yml

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
    properties:
      hibernate:
        format_sql: true
  security:
    user:
      name: test
      password: test

logging:
  level:
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
```

---

## @TestConfiguration — Custom Beans

Any nested static class annotated with `@TestConfiguration` adds its beans to the Spring context during the test.
Useful for overriding beans with test-specific implementations.

```java
@TestConfiguration
public class TestConfig {

    @Bean
    @Primary
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(4); // lower cost = faster tests
    }

    @Bean
    public Clock fixedClock() {
        return Clock.fixed(
            Instant.parse("2024-01-01T00:00:00Z"),
            ZoneId.of("UTC")
        );
    }
}
```

With imports (e.g. OAuth2):
```java
@TestConfiguration
@Import(OAuth2ServerConfiguration.class)
static class SecurityTestConfig {
    @Bean
    public UserDetailsService userDetailsService() {
        return new StubUserDetailsService();
    }

    @Bean
    public TokenStore tokenStore() {
        return new InMemoryTokenStore();
    }
}
```

---

## TestDataFactory

Centralise test object creation to avoid duplication across test classes.

```java
@Component
public class TestDataFactory {

    public static User createUser(String email, String username) {
        return User.builder()
            .email(email)
            .password("encodedPassword")
            .username(username)
            .active(true)
            .createdAt(LocalDateTime.now())
            .updatedAt(LocalDateTime.now())
            .build();
    }

    public static UserCreateRequest createUserRequest() {
        return new UserCreateRequest(
            "test@example.com", "Password123", "testuser", 25);
    }
}
```
