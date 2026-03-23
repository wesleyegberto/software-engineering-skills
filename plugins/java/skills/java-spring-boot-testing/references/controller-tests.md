# Controller Tests

## Testing Strategies Overview

| Approach | Tool | Spring Context | Real Web Server |
|----------|------|----------------|-----------------|
| Unit — standalone | `MockMVC` | No | No |
| Integration — web slice | `@WebMvcTest` + `MockMVC` / `MockMvcTester` | Partial | No |
| Full integration — mock server | `@SpringBootTest` + `MockMvc` | Full | No |
| Full integration — real server | `@SpringBootTest` + `TestRestTemplate` | Full | Yes |
| Reactive — web slice | `@WebFluxTest` + `WebTestClient` | Partial | No |

> The main difference across formats is how to send the request body (raw JSON or serialized object).

---

## Unit Test — MockMVC Standalone

Spring context is **not** loaded. Dependencies are mocked manually with Mockito.

- JUnit 5: extension `MockitoExtension`
- Spring Boot 3.4+: `@MockBean` → `@MockitoBean`

```java
@ExtendWith(MockitoExtension.class)
public class PetsControllerStandaloneTest {
    private MockMvc mvc;

    @Mock
    private PetsRepository petsRepository;

    @InjectMocks
    private PetsController petsController;

    private JacksonTester<Pet> json;

    @BeforeEach
    public void setup() {
        JacksonTester.initFields(this, new ObjectMapper());
        mvc = MockMvcBuilders.standaloneSetup(petsController)
                .setControllerAdvice(new PetExceptionHandler())
                .addFilters(new ApiVersionFilter())
                .build();
    }

    @Test
    public void should_return_existing_pet() throws Exception {
        given(petsRepository.findById(42))
                .willReturn(Optional.of(new Pet(42, "Marley", "Owner Name")));

        MockHttpServletResponse response = mvc.perform(
                        get("/pets/42").accept(MediaType.APPLICATION_JSON))
                .andReturn().getResponse();

        assertThat(response.getStatus()).isEqualTo(HttpStatus.OK.value());
        assertThat(response.getContentAsString())
                .isEqualTo(json.write(new Pet(42, "Marley", "Owner Name")).getJson());
    }

    @Test
    public void should_return_not_found() throws Exception {
        given(petsRepository.findById(42)).willThrow(new PetNotFoundException());

        MockHttpServletResponse response = mvc.perform(
                        get("/pets/42").accept(MediaType.APPLICATION_JSON))
                .andReturn().getResponse();

        assertThat(response.getStatus()).isEqualTo(HttpStatus.NOT_FOUND.value());
        assertThat(response.getContentAsString()).isEmpty();
    }

    @Test
    public void should_create_new_pet() throws Exception {
        MockHttpServletResponse response = mvc.perform(
                        post("/pets")
                                .accept(MediaType.APPLICATION_JSON)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(json.write(new Pet("Marley", "Owner Name")).getJson()))
                .andReturn().getResponse();

        assertThat(response.getStatus()).isEqualTo(HttpStatus.CREATED.value());

        ArgumentCaptor<Pet> captor = ArgumentCaptor.forClass(Pet.class);
        verify(petsRepository).save(captor.capture());
        assertThat(captor.getValue().getName()).isEqualTo("Marley");
    }

    @Test
    public void should_add_api_version_header() throws Exception {
        given(petsRepository.findById(42))
                .willReturn(Optional.of(new Pet(42, "Marley", "Owner Name")));

        MockHttpServletResponse response = mvc.perform(
                        get("/pets/42").accept(MediaType.APPLICATION_JSON))
                .andReturn().getResponse();

        assertThat(response.getHeaders("X-PETS-VERSION")).containsOnly("v1");
    }
}
```

---

## Integration Test — @WebMvcTest with MockMvc (classic)

Loads only the web layer. Services are mocked with `@MockitoBean`.

> In Spring Boot 2.1+, `@WebMvcTest` is already decorated with `@ExtendWith(SpringExtension.class)`.

```java
@WebMvcTest(UserController.class)
@Import(SecurityConfig.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser(roles = "ADMIN")
    @DisplayName("Should get all users")
    void shouldGetAllUsers() throws Exception {
        Page<UserResponse> users = new PageImpl<>(List.of(
            new UserResponse(1L, "user1@example.com", "user1", 25, true, null, null),
            new UserResponse(2L, "user2@example.com", "user2", 30, true, null, null)
        ));
        when(userService.findAll(any(Pageable.class))).thenReturn(users);

        mockMvc.perform(get("/api/v1/users").contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content").isArray())
            .andExpect(jsonPath("$.content.length()").value(2))
            .andExpect(jsonPath("$.content[0].email").value("user1@example.com"))
            .andDo(print());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    @DisplayName("Should create user")
    void shouldCreateUser() throws Exception {
        UserCreateRequest request = new UserCreateRequest("test@example.com", "Password123", "testuser", 25);
        UserResponse response = new UserResponse(1L, request.email(), request.username(),
                request.age(), true, LocalDateTime.now(), LocalDateTime.now());
        when(userService.create(any(UserCreateRequest.class))).thenReturn(response);

        mockMvc.perform(post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(header().exists("Location"))
            .andExpect(jsonPath("$.email").value(request.email()))
            .andDo(print());
    }

    @Test
    @WithMockUser(roles = "USER")
    @DisplayName("Should return 403 for non-admin user")
    void shouldReturn403ForNonAdmin() throws Exception {
        mockMvc.perform(get("/api/v1/users").contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isForbidden());
    }
}
```

---

## Integration Test — @WebMvcTest with MockMvcTester (Spring Boot 3.4+)

`MockMvcTester` is an abstraction on top of `MockMvc` with native **AssertJ** support. No static imports needed.

```java
@WebMvcTest(PetsController.class)
public class PetsControllerMockMvcTesterTest {

    @Autowired
    private MockMvcTester mvc;

    @MockitoBean
    private PetsRepository petsRepository;

    @Test
    public void should_return_existing_pet() {
        given(petsRepository.findById(42))
                .willReturn(Optional.of(new Pet(42, "Marley", "Owner Name")));

        MvcTestResult result = mvc.get().uri("/pets/42").exchange();

        assertThat(result)
                .hasStatusOk()
                .bodyJson()
                .isLenientlyEqualTo("""
                        { "id": 42, "name": "Marley", "owner": "Owner Name" }
                        """);
    }

    @Test
    public void should_compare_with_resource_file() {
        given(petsRepository.findById(42))
                .willReturn(Optional.of(new Pet(42, "Marley", "Owner Name")));

        MvcTestResult result = mvc.get().uri("/pets/42").exchange();

        var expected = new ClassPathResource("/pets/get-by-id-response.json", Pet.class);
        assertThat(result)
                .hasStatus(HttpStatus.OK)
                .bodyJson()
                // isStrictlyEqualTo for exact JSON structure match (no extra fields)
                .isLenientlyEqualTo(expected);
    }

    @Test
    public void should_convert_to_object_and_assert() {
        given(petsRepository.findById(42))
                .willReturn(Optional.of(new Pet(42, "Marley", "Owner Name")));

        assertThat(mvc.get().uri("/pets/42").exchange())
                .hasStatus(HttpStatus.OK)
                .bodyJson()
                .convertTo(Pet.class)
                .satisfies(pet -> {
                    assertThat(pet.getId()).isEqualTo(42);
                    assertThat(pet.getName()).isEqualTo("Marley");
                });
    }
}
```

Gradual migration from MockMvc to MockMvcTester:
```java
// Before (MockMvc)
mockMvc.perform(get("/api/users/1")).andExpect(status().isOk());

// After (MockMvcTester)
assertThat(mockMvcTester.get().uri("/api/users/1")).hasStatusOk();

// Wrapping existing MockMvc instance
this.mockMvcTester = MockMvcTester.create(mockMvc);
```

---

## Full Integration — @SpringBootTest + MockMvc (no real web server)

Starts the full application context without a real web server (`WebEnvironment.MOCK`).

```java
@SpringBootTest
@AutoConfigureJsonTesters
@AutoConfigureMockMvc
public class PetsControllerSpringBootMockTest {

    @Autowired
    private MockMvc mvc;

    @MockitoBean
    private PetsRepository petsRepository;

    @Autowired
    private JacksonTester<Pet> json; // initialized by @AutoConfigureJsonTesters

    @Test
    public void should_return_existing_pet() throws Exception {
        given(petsRepository.findById(42))
                .willReturn(Optional.of(new Pet(42, "Marley", "Owner Name")));

        MockHttpServletResponse response = mvc.perform(
                        get("/pets/42").accept(MediaType.APPLICATION_JSON))
                .andReturn().getResponse();

        assertThat(response.getStatus()).isEqualTo(HttpStatus.OK.value());
        assertThat(response.getContentAsString())
                .isEqualTo(json.write(new Pet(42, "Marley", "Owner Name")).getJson());
    }
}
```

> Prefer `@WebMvcTest` when testing a specific controller — it's faster and more focused.

---

## Full Integration — @SpringBootTest + TestRestTemplate (real web server)

Starts the full application with a real web server (Tomcat/Jetty) on a random port.

```java
@SpringBootTest(
    classes = MySpringBootApplication.class,
    webEnvironment = WebEnvironment.RANDOM_PORT
)
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class UserControllerIntegrationTest {

    @MockitoBean
    private PetsRepository petsRepository;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    @Order(1)
    @DisplayName("Should create user via API")
    void shouldCreateUserViaApi() {
        UserCreateRequest request = new UserCreateRequest(
            "test@example.com", "Password123", "testuser", 25);

        ResponseEntity<UserResponse> response = restTemplate.postForEntity(
            "/api/v1/users", request, UserResponse.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().email()).isEqualTo(request.email());
        assertThat(response.getHeaders().getLocation()).isNotNull();
    }

    @Test
    @Order(2)
    @DisplayName("Should return validation error for invalid request")
    void shouldReturnValidationError() {
        UserCreateRequest request = new UserCreateRequest(
            "invalid-email", "short", "u", 15);

        ResponseEntity<ValidationErrorResponse> response = restTemplate.postForEntity(
            "/api/v1/users", request, ValidationErrorResponse.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody().errors()).isNotEmpty();
    }
}
```

---

## Reactive — @WebFluxTest + WebTestClient

Loads only the reactive web layer. Use for controllers built with Spring WebFlux.

```java
@WebFluxTest(UserReactiveController.class)
class UserReactiveControllerTest {

    @Autowired
    private WebTestClient webTestClient;

    @MockitoBean
    private UserReactiveService userService;

    @Test
    @DisplayName("Should get user reactively")
    void shouldGetUserReactively() {
        UserResponse user = new UserResponse(1L, "test@example.com", "testuser",
                25, true, LocalDateTime.now(), LocalDateTime.now());
        when(userService.findById(1L)).thenReturn(Mono.just(user));

        webTestClient.get()
            .uri("/api/v1/users/{id}", 1L)
            .accept(MediaType.APPLICATION_JSON)
            .exchange()
            .expectStatus().isOk()
            .expectBody(UserResponse.class)
            .value(response -> {
                assertThat(response.id()).isEqualTo(1L);
                assertThat(response.email()).isEqualTo("test@example.com");
            });
    }

    @Test
    @DisplayName("Should create user reactively")
    void shouldCreateUserReactively() {
        UserCreateRequest request = new UserCreateRequest(
            "test@example.com", "Password123", "testuser", 25);
        UserResponse response = new UserResponse(1L, request.email(), request.username(),
                request.age(), true, LocalDateTime.now(), LocalDateTime.now());
        when(userService.create(any(UserCreateRequest.class))).thenReturn(Mono.just(response));

        webTestClient.post()
            .uri("/api/v1/users")
            .contentType(MediaType.APPLICATION_JSON)
            .body(Mono.just(request), UserCreateRequest.class)
            .exchange()
            .expectStatus().isCreated()
            .expectHeader().exists("Location")
            .expectBody(UserResponse.class)
            .value(u -> assertThat(u.email()).isEqualTo(request.email()));
    }
}
```

---

## Quick Reference

| Annotation | Scope | Real Server |
|------------|-------|-------------|
| `@ExtendWith(MockitoExtension.class)` | Unit — no Spring | No |
| `@WebMvcTest(Ctrl.class)` | Web slice only | No |
| `@WebFluxTest(Ctrl.class)` | Reactive web slice | No |
| `@SpringBootTest` + `@AutoConfigureMockMvc` | Full context | No |
| `@SpringBootTest(webEnvironment = RANDOM_PORT)` | Full context | Yes |
