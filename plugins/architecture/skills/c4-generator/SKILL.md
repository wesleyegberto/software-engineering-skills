---
name: c4-generator
description: Generate C4 diagrams from project analysis.
---
## Objective
Enable AI agents to automatically generate C4 diagrams (C1, C2, C3, and C4 levels) from project analysis.

## Process Steps

1. **Project Structure Analysis**
   - Identify the general architecture, main modules, components, and purpose of the system.

2. **Package/Folder Structure and Organization Analysis**
   - Map the directory hierarchy, logical groupings, and responsibilities of each package/folder.

3. **Analysis of Integrations with External Systems and Resources**
   - Detect connections with APIs, queues, files, databases, and other external systems.

4. **Dependency Analysis**
   - Identify relevant libraries, frameworks, and external dependencies for the architecture.

5. **C4 Diagram Generation**
   - Generate diagrams for each level (C1, C2, C3, C4) in Mermaid format.

6. **User Interaction**
   - If there are doubts or ambiguous points, ask the user for clarification before finalizing the diagrams.

7. **Final Markdown Generation**
   - Create a markdown file containing:
     - Analysis summary
     - Mermaid diagrams for each level (C1, C2, C3, C4)

## Example of Generated Markdown Structure

---
# C4 Analysis of Project <Project Name>

## Analysis Summary
- General project structure
- Main packages and responsibilities
- External integrations
- Dependencies

## C4 Diagram - Level 1 (Context)
```mermaid
C4Context
    ...
```

## C4 Diagram - Level 2 (Container)
```mermaid
C4Container
    ...
```

## C4 Diagram - Level 3 (Component)
```mermaid
C4Component
    ...
```

## C4 Diagram - Level 4 (Code)
```mermaid
C4Dynamic
    ...
```

---

## Observations
- Always question the user if any point of the analysis is not clear.
- Use the actual project structure to detail the diagrams.
- Adapt the diagrams according to the complexity and context of the analyzed project.