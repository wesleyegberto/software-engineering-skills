---
name: programming
description: >
  Provides recipes for programming tasks.
  Use when executing programming tasks like creating code, creating tests, reactoring code, reviewing code.
metadata:
  scope: implementation
  version: "1.0.0"
---

# Programming Recipes

This skill provides a collection of recipes to solve common programming tasks, focusing on refactoring, optimization, and best practices.

## Available Recipes

### 1. Decouple Business Logic from UI
- **Goal**: Separate business logic from UI components to improve maintainability, reusability, and testability.
- **Technique**: Extract business logic into services, state management solutions (e.g., Redux), or hooks.
- **Example**: Refactoring a React `Counter` component by moving state management to Redux, separating actions, reducers, and the store from the component's view.

### 2. Fix Lint Errors
- **Goal**: Improve code quality, catch bugs early, and ensure consistency by addressing linter warnings.
- **Common Fixes**:
  - Managing imports (adding missing, removing unused).
  - Adhering to style guidelines (naming conventions, spacing, indentation).
  - Removing unused variables and unreachable code.
  - Adding docstrings and replacing `print` statements with proper logging.

### 3. Handle Cross-Cutting Concerns
- **Goal**: Centralize logic for concerns that affect multiple parts of an application (e.g., logging, security, validation).
- **Technique**: Use Aspect-Oriented Programming (AOP), decorators, or middleware to avoid code duplication.
- **Example**: Refactoring a Python application to use `aspectlib` to handle logging for multiple service methods, keeping the logging logic in one place.

### 4. Improve Code Readability and Maintainability
- **Goal**: Make code easier to understand, maintain, and extend.
- **Techniques**:
  - **Use Descriptive Variable Names**: Replace abstract names (`a`, `b`) with meaningful ones (`name`, `age`).
  - **Avoid Sequential Conditionals**: Replace long `if/else` chains with dictionaries or switch statements.
  - **Reduce Nested Logic**: Use guard clauses to flatten deeply nested `if` statements.
  - **Split Large Methods**: Break down long methods into smaller, single-responsibility functions.

### 5. Refactor Data Access Layers
- **Goal**: Abstract database interactions to make the application more modular, scalable, and secure.
- **Technique**: Implement a repository pattern to separate data access logic from business logic.
- **Example**: Refactoring a Python function with a hardcoded, insecure SQL query into a `UserRepository` with a `Database` class that uses parameterized queries and a context manager.

### 6. Implement Design Patterns
- **Goal**: Solve common software design problems using established, reusable patterns.
- **Technique**: Identify areas where patterns like Singleton, Factory, or Module can improve code structure.
- **Example**: Refactoring JavaScript code to use the **Module Pattern** to encapsulate related functions and data, preventing global namespace pollution.

### 7. Optimize for Performance
- **Goal**: Identify and resolve performance bottlenecks in inefficient code.
- **Techniques**:
  - Optimize algorithms and data structures (e.g., using a sieve for prime generation instead of trial division).
  - Reduce redundant computations and memory allocation.
  - Introduce caching or parallelize operations where appropriate.

### 8. Refactor for Environmental Sustainability
- **Goal**: Reduce the energy consumption and environmental impact of software.
- **Technique**: Identify and refactor resource-intensive operations to be more efficient in terms of CPU and memory usage.
- **Example**: Improving a Python script that counts lines in a large file by reading it line-by-line instead of loading the entire file into memory.

### 9. Translate Between Programming Languages
- **Goal**: Port code from one language to another to leverage different features, improve performance, or standardize a codebase.
- **Process**: Translate the logic, syntax, and standard library calls from the source language to the target language, ensuring functional equivalence.
- **Example**: Converting a Perl script for file analysis into a modern TypeScript equivalent using Node.js modules.
