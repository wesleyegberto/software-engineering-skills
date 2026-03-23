# Testcontainers

## Basic Setup

Start a PostgreSQL container per test class with `@Testcontainers` and `@Container`.

```java
@SpringBootTest
@Testcontainers
@ActiveProfiles("test")
class UserServiceIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url",      postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @Test
    @DisplayName("Should create and find user in real database")
    void shouldCreateAndFindUser() {
        UserCreateRequest request = new UserCreateRequest(
            "test@example.com", "Password123", "testuser", 25);

        UserResponse created = userService.create(request);
        UserResponse found   = userService.findById(created.id());

        assertThat(found).isNotNull();
        assertThat(found.email()).isEqualTo(request.email());
    }
}
```

---

## Shared Container — AbstractIntegrationTest

Reuse a single container across all integration tests to speed up the suite.
The `static` block starts the container once per JVM process.

```java
public abstract class AbstractIntegrationTest {

    static final PostgreSQLContainer<?> postgres;

    static {
        postgres = new PostgreSQLContainer<>("postgres:16-alpine")
            .withReuse(true);
        postgres.start();
    }

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url",      postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
}
```

Usage — extend instead of repeating `@Container` declarations:

```java
@SpringBootTest
class UserServiceIntegrationTest extends AbstractIntegrationTest {
    // container already running, properties already bound
}

@SpringBootTest
class OrderServiceIntegrationTest extends AbstractIntegrationTest {
    // same container instance reused
}
```
