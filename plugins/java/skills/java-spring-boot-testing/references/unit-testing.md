# Unit Testing with JUnit 5 and Mockito

## Service Layer Test

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    @Test
    @DisplayName("Should create user successfully")
    void shouldCreateUser() {
        // Given
        UserCreateRequest request = new UserCreateRequest(
            "test@example.com", "Password123", "testuser", 25);

        User user = User.builder()
            .id(1L).email(request.email()).username(request.username()).build();

        when(userRepository.existsByEmail(request.email())).thenReturn(false);
        when(passwordEncoder.encode(request.password())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        UserResponse response = userService.create(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.email()).isEqualTo(request.email());

        verify(userRepository).existsByEmail(request.email());
        verify(passwordEncoder).encode(request.password());
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("Should throw exception when email already exists")
    void shouldThrowExceptionWhenEmailExists() {
        // Given
        UserCreateRequest request = new UserCreateRequest(
            "test@example.com", "Password123", "testuser", 25);

        when(userRepository.existsByEmail(request.email())).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> userService.create(request))
            .isInstanceOf(DuplicateResourceException.class)
            .hasMessageContaining("Email already registered");

        verify(userRepository, never()).save(any(User.class));
    }
}
```

---

## Parameterized Tests

```java
@ParameterizedTest
@ValueSource(strings = {"admin", "user", "moderator"})
@DisplayName("Should validate different user roles")
void shouldValidateUserRoles(String role) {
    assertThat(role).isNotBlank();
    // test role-specific behavior
}

@ParameterizedTest
@CsvSource({
    "test@example.com, true",
    "invalid-email,    false",
    "another@test.org, true"
})
void shouldValidateEmailFormat(String email, boolean expected) {
    assertThat(EmailValidator.isValid(email)).isEqualTo(expected);
}
```

---

## Test Data Builder

Use a fluent builder when tests need many variations of the same object.

```java
public class UserTestBuilder {

    private Long id = 1L;
    private String email = "test@example.com";
    private String username = "testuser";
    private Boolean active = true;

    public static UserTestBuilder aUser() {
        return new UserTestBuilder();
    }

    public UserTestBuilder withId(Long id)         { this.id = id; return this; }
    public UserTestBuilder withEmail(String email)  { this.email = email; return this; }
    public UserTestBuilder inactive()               { this.active = false; return this; }

    public User build() {
        return User.builder()
            .id(id).email(email).username(username).active(active)
            .build();
    }
}
```

Usage:
```java
User admin  = aUser().withEmail("admin@example.com").build();
User banned = aUser().withEmail("banned@example.com").inactive().build();
```
