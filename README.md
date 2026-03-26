# software-engineering-skills

![GitHub Stars](https://img.shields.io/github/stars/wesleyegberto/software-engineering-skills?style=flat-square)
![License](https://img.shields.io/github/license/wesleyegberto/software-engineering-skills?style=flat-square)
![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-blue?style=flat-square)

Collection of agents, commands and skills for software engineering.

Some skills were collected from authors listed in the [Resources section](#resources) and some were crafted from study notes and practical examples.

> The goal is to enable any agent to develop software using the industry's consolidated knowledge.

Plugins are available for specific stacks: Java, Node.js, Python, Angular, React, DevOps tooling, and more.

> [!NOTE]
> All plugins depend on `programming-skills` as a base. Install it first before any other plugin.

## Table of Contents

- [Concepts](#concepts)
- [Structure](#structure)
- [Quick Plugin Reference](#quick-plugin-reference)
- [Which Plugin Should I Use?](#which-plugin-should-i-use)
- [Install](#install)
- [Usage](#usage)
- [Plugins](#plugins)
  - [programming-skills](#programming-skills)
  - [java](#java)
  - [python](#python)
  - [node](#node)
  - [frontend](#frontend)
  - [devops](#devops)
  - [docs](#docs)
  - [architecture](#architecture)
- [Scripts](#scripts)
- [Contributing](#contributing)
- [Resources](#resources)

## Concepts

| | Concept | Description | How to invoke |
|-|---------|-------------|---------------|
| 🤖 | **Agent** | Specialized AI persona with focused expertise | `@agent-name` in Claude Code |
| ⚡ | **Command** | Slash command that triggers a pre-built workflow | `/command-name` |
| 🧰 | **Skill** | Reusable knowledge prompt that guides agent behavior on a specific topic | Referenced in conversation context |

## Structure

Each plugin follows the same directory layout:

```
plugins/<plugin-name>/
├── agents/     # Specialized agent definitions (.agent.md)
├── commands/   # Slash commands (/command-name)
└── skills/     # Reusable knowledge prompts
```

Plugin dependency:

```
programming-skills  (base — required by all)
├── java
├── python
├── node
├── frontend
├── devops
├── docs
└── architecture
```

## Quick Plugin Reference

| Plugin | 🤖 Agents | ⚡ Commands | 🧰 Skills | Stack |
|--------|:---------:|:----------:|:---------:|-------|
| [`programming-skills`](#programming-skills) | 11 | 5 | 22 | Any — foundation for all plugins |
| [`java`](#java) | 5 | 7 | 10 | Java / Spring Boot |
| [`python`](#python) | 2 | 4 | 19 | Python / Django / FastAPI |
| [`node`](#node) | 2 | 2 | 11 | Node.js / JavaScript / TypeScript |
| [`frontend`](#frontend) | 8 | 2 | 24 | React / Angular / Next.js / Mobile |
| [`devops`](#devops) | 12 | 1 | 21 | CI/CD / Kubernetes / Terraform |
| [`docs`](#docs) | 6 | 6 | 1 | Technical Writing / Documentation |
| [`architecture`](#architecture) | — | 6 | 13 | System Design / C4 / ADRs |

## Install

### Claude Code

To try without installing:

```sh
claude --plugin-dir ./software-engineering-skills/plugins/<plugin-name>
```

To install as a plugin, run the Claude Code command:

```sh
# Remote
claude plugin marketplace add https://github.com/wesleyegberto/software-engineering-skills.git

# Local path
git clone https://github.com/wesleyegberto/software-engineering-skills.git
claude plugin marketplace add ./software-engineering-skills

# Install a specific plugin
claude plugin install programming-skills@software-engineering-skills
claude plugin install java@software-engineering-skills
claude plugin install python@software-engineering-skills
claude plugin install node@software-engineering-skills
claude plugin install frontend@software-engineering-skills
claude plugin install devops@software-engineering-skills
claude plugin install docs@software-engineering-skills
claude plugin install architecture@software-engineering-skills
```

### Gemini

To install just link the extension with the folder:

```bash
# Local path
git clone https://github.com/wesleyegberto/software-engineering-skills.git

# Install extensions
gemini extensions link ./software-engineering-skills/plugins/programming-skills/
gemini extensions link ./software-engineering-skills/plugins/java/
gemini extensions link ./software-engineering-skills/plugins/python/
gemini extensions link ./software-engineering-skills/plugins/node/
gemini extensions link ./software-engineering-skills/plugins/frontend/
gemini extensions link ./software-engineering-skills/plugins/devops/
gemini extensions link ./software-engineering-skills/plugins/docs/
gemini extensions link ./software-engineering-skills/plugins/architecture/
```

## Usage

After installation, you can invoke agents, commands and skills directly in Claude Code:

```
# Invoke a specialized agent
@java-reviewer please review this PR for security issues

# Run a slash command
/debug
/junit UserServiceTest

# Ask Claude to use a skill's knowledge
Use the clean-architecture skill to evaluate this module structure
```

## Plugins

### Agent Colors

The agent color is defined as follows:

- 🔵 `blue`: planner
- 🟡 `yellow`: worker
- 🟢 `green`: reviewer
- 🔴 `red`: problem solver

### `programming-skills` — Foundation for All Stacks

Foundation plugin with general software engineering knowledge. All other plugins build on top of this one.

**11 agents** · **5 commands** · **22 skills**

| Category    | Items |
|-------------|-------|
| 🤖 Agents   | `code-explorer`, `code-reviewer`, `debugger`, `demonstrate-understanding`, `dx-optimizer`, `error-detective`, `legacy-modernizer`, `principal-software-engineer`, `software-engineer`, `tech-debt-remediation-plan`, `test-automator` |
| ⚡ Commands | `/code`, `/code-review`, `/debug`, `/git`, `/test` |
| 🧰 Skills   | `anti-duplication`, `api-designer`, `breaking-change-detector`, `clean-architecture`, `clean-code`, `code-patterns`, `code-review-expert`, `debugging-strategies`, `domain-driven-design`, `error-handling-patterns`, `git-advanced-workflows`, `git-commit`, `git-guardrails`, `multi-reviewer-patterns`, `parallel-debugging`, `pragmatic-programmer`, `programming`, `refactoring-patterns`, `software-design-complexity`, `software-design-principles`, `terminal-monitor`, `tests-expert` |

---

### `java` — Java & Spring Boot Development

Agents, commands and skills for Java development with Spring Boot.

**5 agents** · **7 commands** · **10 skills**

| Category | Items |
|----------|-------|
| 🤖 Agents | `java-architect`, `java-build-resolver`, `java-mcp-developer`, `java-reviewer`, `java-spring-boot` |
| ⚡ Commands | `/create-project`, `/docs`, `/junit`, `/mcp-server-generator`, `/refactoring-extract-method`, `/refactoring-remove-parameter`, `/spring-boot` |
| 🧰 Skills | `java-architect`, `java-code-review`, `java-coding-standards`, `java-jpa-patterns`, `java-performance`, `java-spring-boot-expert`, `java-spring-boot-security`, `java-spring-boot-testing`, `java-spring-boot-verification-loop`, `java-feature-development` |

---

### `python` — Modern Python Development

Agents, commands and skills for Python development.

**2 agents** · **4 commands** · **19 skills**

| Category | Items |
|----------|-------|
| 🤖 Agents | `python-developer`, `python-mcp-developer` |
| ⚡ Commands | `/comment-code-generate-a-tutorial`, `/mcp-server-generator`, `/review`, `/scaffold` |
| 🧰 Skills | `django-expert`, `python-anti-patterns`, `python-async-patterns`, `python-background-jobs`, `python-code-style`, `python-configuration`, `python-design-patterns`, `python-error-handling`, `python-expert`, `python-observability`, `python-packaging`, `python-performance-optimization`, `python-project-structure`, `python-resilience`, `python-resource-management`, `python-testing-patterns`, `python-type-safety`, `temporal-python-testing`, `uv-package-manager` |

---

### `node` — Node.js / JavaScript / TypeScript

Agents, commands and skills for Node.js/JavaScript/TypeScript development.

**2 agents** · **2 commands** · **11 skills**

| Category | Items |
|----------|-------|
| 🤖 Agents | `javascript-developer`, `typescript-developer` |
| ⚡ Commands | `/mcp-server-generator`, `/setup-pre-commit` |
| 🧰 Skills | `auth-implementation-patterns`, `fullstack-guardian`, `javascript-coding-standards`, `javascript-expert`, `javascript-modern-patterns`, `javascript-testing-patterns`, `node-tests`, `nodejs-backend-patterns`, `playwright-expert`, `typescript-advanced-types`, `node-feature-development` |

---

### `frontend` — React, Angular, Next.js & Mobile

Agents, commands and skills for frontend development (React, Angular, Next.js, mobile).

**8 agents** · **2 commands** · **24 skills**

| Category | Items |
|----------|-------|
| 🤖 Agents | `angular-developer`, `frontend-developer`, `ios-developer`, `mobile-developer`, `nextjs-developer`, `react-developer`, `ui-ux-designer`, `ui-visual-validator` |
| ⚡ Commands | `/accessibility-audit`, `/react-component-scaffold` |
| 🧰 Skills | `angular-architect`, `angular-expert`, `angular-new-app`, `chrome-devtools`, `e2e-testing-patterns`, `frontend-design`, `frontend-design-everyday-things`, `frontend-lean-ux`, `frontend-microinteractions`, `frontend-refactoring-ui`, `frontend-screen-reader-testing`, `frontend-top-design`, `frontend-ux-heuristics`, `nestjs-expert`, `nextjs-app-router-patterns`, `nextjs-expert`, `react-expert`, `react-native-architecture`, `react-native-expert`, `react-patterns`, `react-state-management`, `tailwind-design-system`, `wcag-audit-patterns`, `react-feature-development` |

---

### `devops` — Infrastructure, CI/CD & Platform Engineering

Agents, commands and skills for DevOps, infrastructure and platform engineering.

**12 agents** · **1 command** · **21 skills**

| Category | Items |
|----------|-------|
| 🤖 Agents | `bash-expert`, `deployment-engineer`, `devops-expert`, `devops-troubleshooter`, `github-actions-expert`, `kubernetes-architect`, `kubernetes-expert`, `kubernetes-sre`, `network-engineer`, `observability-engineer`, `posix-shell-developer`, `terraform-expert` |
| ⚡ Commands | `/multi-stage-dockerfile` |
| 🧰 Skills | `bash-defensive-patterns`, `bash-testing-patterns`, `cli-developer`, `cost-optimization`, `deployment-pipeline-design`, `github-actions-templates`, `gitlab-ci-patterns`, `helm-chart-scaffolding`, `hybrid-cloud-networking`, `istio-traffic-management`, `k8s-manifest-generator`, `k8s-security-policies`, `kubernetes-specialist`, `mtls-configuration`, `multi-cloud-architecture`, `release-it`, `secrets-management`, `shellcheck-configuration`, `sre-engineer`, `terraform-engineer`, `terraform-module-library` |

---

### `docs` — Technical Writing & Documentation

Agents, commands and skills for technical writing and documentation generation.

**6 agents** · **6 commands** · **1 skill**

| Category | Items |
|----------|-------|
| 🤖 Agents | `api-documenter`, `documentation-architect`, `mermaid-expert`, `reference-builder`, `technical-writer`, `tutorial-builder` |
| ⚡ Commands | `/code-exemplars-blueprint-generator`, `/code-explain`, `/doc-generate`, `/readme-blueprint-generator`, `/update-markdown-file-index`, `/write-coding-standards-from-file` |
| 🧰 Skills | `code-documenter` |

---

### `architecture` — System Design, C4 & ADRs

Commands and skills for software architecture design and documentation.

> [!NOTE]
> No dedicated agents. Use `@software-engineer` or `@principal-software-engineer` from `programming-skills` alongside these commands and skills.

**6 commands** · **13 skills**

| Category | Items |
|----------|-------|
| ⚡ Commands | `/architecture-elaboration`, `/blueprint-generator`, `/c4-generator`, `/design-api`, `/haiku-doc-generator`, `/system-design` |
| 🧰 Skills | `architecture-data-system-design`, `architecture-decision-records`, `architecture-designer`, `architecture-system-design`, `c4-generator`, `c4-model`, `cloud-architect`, `codebase-improve-architecture`, `event-store-design`, `event-stream-projection-patterns`, `microservices-architect`, `microservices-patterns`, `software-architecture-patterns` |

---

## Scripts

The `scripts/` directory contains utilities for maintaining the repository:

- `validate-markdown.py` — validates markdown formatting across skill files.
- `validate-skills.py` — validates skill structure, YAML frontmatter and cross-references. Run before releases to prevent broken skills from being published.
  ```sh
  python scripts/validate-skills.py                      # run all checks
  python scripts/validate-skills.py --check yaml         # YAML checks only
  python scripts/validate-skills.py --skill react-expert # single skill
  python scripts/validate-skills.py --format json        # JSON output for CI
  ```

Original scripts are available [here](https://github.com/Jeffallan/claude-skills/tree/main/scripts)

## Contributing

Contributions are welcome! To add a new skill, agent or command:

1. Follow the directory layout described in [Structure](#structure).
2. Add the new item under the appropriate plugin in `plugins/<plugin-name>/`.
3. Run the validation scripts before opening a PR:
   ```sh
   python scripts/validate-markdown.py
   python scripts/validate-skills.py
   ```
4. Update the plugin table in this README to reflect the new item and its count.

## Resources

> Credits and references whenever possible.

- [Jeffallan](https://github.com/Jeffallan/claude-skills)
- [Wondelai](https://github.com/wondelai/skills)
- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code)
