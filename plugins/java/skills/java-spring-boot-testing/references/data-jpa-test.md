# JPA Tests with `@DataJpaTest`

Configures and initializes only the JPA-related parts.
By default, uses an H2 in-memory database and each test runs in a transaction with automatic rollback.

```java
@DataJpaTest
@TestPropertySource("classpath:/application-test.properties")
public class ProductRepositoryTests {
    @Autowired
    private TestEntityManager entityManager; // prepares scenario without using other repositories

    @Autowired
    private ProductRepository repository;

    @Test
    public void testSaveNewProduct() {
        entityManager.persist(new Product("iPhone 10", 1099));

        Product product = repository.findByName("iPhone 10");

        assertThat(product.getName()).isEqualTo("iPhone 10");
    }
}
```

---

## Repository Test with TestEntityManager

`TestEntityManager` prepares the test scenario without coupling to other repository beans.

```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ActiveProfiles("test")
class UserRepositoryTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    @DisplayName("Should find user by email")
    void shouldFindUserByEmail() {
        User user = User.builder()
            .email("test@example.com").password("password")
            .username("testuser").active(true).build();
        entityManager.persistAndFlush(user);

        Optional<User> found = userRepository.findByEmail("test@example.com");

        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("test@example.com");
    }

    @Test
    @DisplayName("Should check if email exists")
    void shouldCheckIfEmailExists() {
        User user = User.builder()
            .email("test@example.com").password("password")
            .username("testuser").active(true).build();
        entityManager.persistAndFlush(user);

        assertThat(userRepository.existsByEmail("test@example.com")).isTrue();
    }

    @Test
    @DisplayName("Should fetch user with roles")
    void shouldFetchUserWithRoles() {
        Role adminRole = Role.builder().name("ADMIN").build();
        entityManager.persist(adminRole);

        User user = User.builder()
            .email("admin@example.com").password("password")
            .username("admin").active(true).roles(Set.of(adminRole)).build();
        entityManager.persistAndFlush(user);
        entityManager.clear(); // detach to force lazy load

        Optional<User> found = userRepository.findByEmailWithRoles("admin@example.com");

        assertThat(found).isPresent();
        assertThat(found.get().getRoles()).extracting(Role::getName).contains("ADMIN");
    }
}
```

---

## Use real database (without H2)

```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = Replace.NONE)
public class ProductRepositoryTest {}
```

---

## Disable automatic rollback

```java
@DataJpaTest
@Rollback(false) // entire class
public class ProductRepositoryTests {}
```

```java
@Test
@Rollback(false) // specific method
public void testSaveNewProduct() {}
```

---

## Order tests to reuse state

```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = Replace.NONE)
@TestMethodOrder(OrderAnnotation.class)
public class ProductRepositoryTests {
    @Autowired
    private ProductRepository repo;

    @Test @Rollback(false) @Order(1)
    public void testCreateProduct() {}

    @Test @Order(2)
    public void testFindProductByName() {}

    @Test @Order(3)
    public void testListProducts() {}

    @Test @Rollback(false) @Order(4)
    public void testUpdateProduct() {}

    @Test @Rollback(false) @Order(5)
    public void testDeleteProduct() {}
}
```
