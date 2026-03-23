---
agent: 'agent'
tools: ['changes', 'search/codebase', 'edit/editFiles', 'problems', 'search']
description: 'Get best practices for JUnit 5 unit testing, including data-driven tests'
---
# JUnit 5+ Best Practices

Your goal is to help me write effective unit tests with JUnit 5, covering both standard and data-driven testing approaches.

## Project Setup

- Use a standard Maven or Gradle project structure.
- Place test source code in `src/test/java`.
- Include dependencies for `junit-jupiter-api`, `junit-jupiter-engine`, and `junit-jupiter-params` for parameterized tests.
- Use build tool commands to run tests: `mvn test` or `gradle test`.

## Test Structure

- Test classes should have a `Test` suffix, e.g., `CalculatorTest` for a `Calculator` class.
- Use `@Test` for test methods.
- Follow the Arrange-Act-Assert (AAA) pattern.
- Name tests using a descriptive convention, like `methodName_should_expectedBehavior_when_scenario`.
- Use `@BeforeEach` and `@AfterEach` for per-test setup and teardown.
- Use `@BeforeAll` and `@AfterAll` for per-class setup and teardown (must be static methods).
- Use `@DisplayName` to provide a human-readable name for test classes and methods.

## Standard Tests

- Keep tests focused on a single behavior.
- Avoid testing multiple conditions in one test method.
- Make tests independent and idempotent (can run in any order).
- Avoid test interdependencies.

## Data-Driven (Parameterized) Tests

- Use `@ParameterizedTest` to mark a method as a parameterized test.
- Use `@ValueSource` for simple literal values (strings, ints, etc.).
- Use `@MethodSource` to refer to a factory method that provides test arguments as a `Stream`, `Collection`, etc.
- Use `@CsvSource` for inline comma-separated values.
- Use `@CsvFileSource` to use a CSV file from the classpath.
- Use `@EnumSource` to use enum constants.

## Assertions

- Use the static methods from `org.junit.jupiter.api.Assertions` (e.g., `assertEquals`, `assertTrue`, `assertNotNull`).
- For more fluent and readable assertions, consider using a library like AssertJ (`assertThat(...).is...`).
- Use `assertThrows` or `assertDoesNotThrow` to test for exceptions.
- Group related assertions with `assertAll` to ensure all assertions are checked before the test fails.
- Use descriptive messages in assertions to provide clarity on failure.

## Mocking and Isolation

- Use a mocking framework like Mockito to create mock objects for dependencies.
- Use `@Mock` and `@InjectMocks` annotations from Mockito to simplify mock creation and injection.
- Use interfaces to facilitate mocking.

## Test Organization

- Group tests by feature or component using packages.
- Use `@Tag` to categorize tests (e.g., `@Tag("fast")`, `@Tag("integration")`).
- Use `@TestMethodOrder(MethodOrderer.OrderAnnotation.class)` and `@Order` to control test execution order when strictly necessary.
- Use `@Disabled` to temporarily skip a test method or class, providing a reason.
- Use `@Nested` to group tests in a nested inner class for better organization and structure.

## Spring Boot Controller

- Utilize `MockMvcTester` para testar a controller
- Se a controller tiver alguma dependência, utilize `@MockitoBean` para permitir mockar os retornos necessários para a controller
- Para operações de POST, PUT e PATCH, gere o JSON da requisição a partir do objeto de parâmetro com `@RequestBody` para não utilizar o tipo diretamente nos testes

```java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class PetsControllerSpringBootMockMvcTesterTest {
	@Autowired
	private MockMvcTester mvc;

	@MockitoBean
	private PetsRepository petsRepository;

	@Test
	void should_return_existing_pet() throws Exception {
		given(petsRepository.findById(42))
				.willReturn(Optional.of(new Pet(42, "Marley", "Bob")));

		MvcTestResult result = mvc.get().uri("/pets/42").exchange();

		assertThat(result)
				.hasStatusOk()
				.bodyJson()
				.isLenientlyEqualTo("""
							{
								"id": 42,
								"name": "Marley",
								"owner": "Bob"
							}
						""");

		// we also can use a resource file as expected value
		var expected = new ClassPathResource("/pets/get-by-id-response.json", Pet.class);

		assertThat(result)
				.hasStatus(HttpStatus.OK)
				.bodyJson()
				// we can use isStrictlyEqualTo if we want exact match of the JSON structure (no extra fields)
				.isLenientlyEqualTo(expected);

		// or convert to object and do assertions
		assertThat(result)
				.hasStatus(HttpStatus.OK)
				.bodyJson()
				.convertTo(Pet.class)
				.satisfies(response -> {
					assertThat(response.getId()).isEqualTo(42);
					assertThat(response.getName()).isEqualTo("Marley");
					assertThat(response.getOwner()).isEqualTo("Bob");
				});
	}

	@Test
	void should_return_not_found_for_non_existing_pet() throws Exception {
		given(petsRepository.findById(42))
				.willThrow(new PetNotFoundException());

		MvcTestResult result = mvc.get().uri("/pets/42").exchange();

		assertThat(result)
				.hasStatus(HttpStatus.NOT_FOUND)
				.bodyText()
				.isEmpty();

		assertThat(result)
				.hasStatus(HttpStatus.NOT_FOUND).failure()
				.isInstanceOf(PetNotFoundException.class)
				.hasMessage("Pet not found");
	}

	@Test
	void should_create_new_pet() throws Exception {
		String requestBody = """
					{
						"name": "Marley",
						"owner": "Bob"
					}
				""";
		var result = mvc.post()
				.uri("/pets")
				.contentType(MediaType.APPLICATION_JSON)
				.content(requestBody);

		assertThat(result)
				.hasStatus(HttpStatus.CREATED)
				.bodyJson();

		ArgumentCaptor<Pet> argCaptor = ArgumentCaptor.forClass(Pet.class);
		verify(petsRepository).save(argCaptor.capture());
		Pet pet = argCaptor.getValue();

		assertThat(pet.getId()).isEqualTo(0);
		assertThat(pet.getName()).isEqualTo("Marley");
		assertThat(pet.getOwner()).isEqualTo("Bob");
	}

	@Test
	void should_add_api_version_header() throws Exception {
		MvcTestResult result = mvc.get().uri("/pets/42").exchange();

		assertThat(result)
				.hasStatusOk()
				.headers()
				.hasValue("X-PETS-VERSION", "v1");
	}
}
```
