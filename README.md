# software-engineering-skills

Collection of agents, commands and skills for software engineering.

Some skills were collected from authors listed in the [Resources section](#resources) and some were crafted from study notes and practical examples.

The goal is to enable any agent to develop software using the industry's consolidated knowledge.

Plugins are available for specific stacks: Java, Node.js, Python, Angular, React, DevOps tooling, and more.

> **Note:** all plugins depend on `programming-skills` as a base.

## Structure

Each plugin follows the same directory layout:

```
plugins/<plugin-name>/
├── agents/     # Specialized agent definitions (.agent.md)
├── commands/   # Slash commands (/command-name)
└── skills/     # Reusable knowledge prompts
```

## Install

### Claude Code

To try without installing:

```sh
claude --plugin-dir ./software-engineering-skills/plugins/<plugin-name>
```

To install as a plugin, run the Claude Code command:

```
# Remote
claude plugin marketplace add https://github.com/wesleyegberto/software-engineering-skills.git

# Local path
git clone https://github.com/wesleyegberto/software-engineering-skills.git
claude plugin marketplace add ./software-engineering-skills

# Install a specific plugin
claude plugin install programming-skills@software-engineering-skills
claude plugin install docs@software-engineering-skills
claude plugin install java@software-engineering-skills
claude plugin install node@software-engineering-skills
claude plugin install python@software-engineering-skills
claude plugin install frontend@software-engineering-skills
claude plugin install devops@software-engineering-skills
```

### Gemini

To install just link the extension with the folder:

```bash
# Local path
git clone https://github.com/wesleyegberto/software-engineering-skills.git

# Install extensions
gemini extensions link ./software-engineering-skills/plugins/programming-skills/
gemini extensions link ./software-engineering-skills/plugins/devops/
gemini extensions link ./software-engineering-skills/plugins/docs/
gemini extensions link ./software-engineering-skills/plugins/frontend/
gemini extensions link ./software-engineering-skills/plugins/java/
gemini extensions link ./software-engineering-skills/plugins/node/
gemini extensions link ./software-engineering-skills/plugins/python/
```

## Plugins

### `programming-skills`

Foundation plugin with general software engineering knowledge. All other plugins build on top of this one.

**11 agents** · **4 commands** · **21 skills**

| Category | Items |
|----------|-------|
| Agents | `code-explorer`, `code-reviewer`, `debugger`, `demonstrate-understanding`, `dx-optimizer`, `error-detective`, `legacy-modernizer`, `principal-software-engineer`, `software-engineer`, `tech-debt-remediation-plan`, `test-automator` |
| Commands | `/code`, `/code-review`, `/debug`, `/git`, '/test` |
| Skills | `anti-duplication`, `api-designer`, `breaking-change-detector`, `clean-architecture`, `clean-code`, `code-patterns`, `debugging-strategies`, `domain-driven-design`, `error-handling-patterns`, `git-advanced-workflows`, `git-commit`, `git-guardrails`, `multi-reviewer-patterns`, `parallel-debugging`, `pragmatic-programmer`, `programming`, `refactoring-patterns`, `software-design-complexity`, `software-design-principles`, `tests-expert` |

---

### `java`

Agents, commands and skills for Java development with Spring Boot.

**5 agents** · **7 commands** · **9 skills**

| Category | Items |
|----------|-------|
| Agents | `java-architect`, `java-build-resolver`, `java-mcp-developer`, `java-reviewer`, `java-spring-boot` |
| Commands | `/create-project`, `/docs`, `/junit`, `/mcp-server-generator`, `/refactoring-extract-method`, `/refactoring-remove-parameter`, `/spring-boot` |
| Skills | `java-architect`, `java-code-review`, `java-coding-standards`, `java-jpa-patterns`, `java-performance`, `java-spring-boot-expert`, `java-spring-boot-security`, `java-spring-boot-testing`, `java-spring-boot-verification-loop`, `java-feature-development` |

---

### `python`

Agents, commands and skills for Python development.

**2 agents** · **4 commands** · **19 skills**

| Category | Items |
|----------|-------|
| Agents | `python-developer`, `python-mcp-developer` |
| Commands | `/comment-code-generate-a-tutorial`, `/mcp-server-generator`, `/review`, `/scaffold` |
| Skills | `django-expert`, `python-anti-patterns`, `python-async-patterns`, `python-background-jobs`, `python-code-style`, `python-configuration`, `python-design-patterns`, `python-error-handling`, `python-expert`, `python-observability`, `python-packaging`, `python-performance-optimization`, `python-project-structure`, `python-resilience`, `python-resource-management`, `python-testing-patterns`, `python-type-safety`, `temporal-python-testing`, `uv-package-manager` |

---

### `node`

Agents, commands and skills for Node.js/JavaScript/TypeScript development.

**2 agents** · **2 commands** · **10 skills**

| Category | Items |
|----------|-------|
| Agents | `javascript-developer`, `typescript-developer` |
| Commands | `/mcp-server-generator`, `/setup-pre-commit` |
| Skills | `auth-implementation-patterns`, `fullstack-guardian`, `javascript-coding-standards`, `javascript-expert`, `javascript-modern-patterns`, `javascript-testing-patterns`, `node-tests`, `nodejs-backend-patterns`, `playwright-expert`, `typescript-advanced-types`, `node-feature-development` |

---

### `frontend`

Agents, commands and skills for frontend development (React, Angular, Next.js, mobile).

**8 agents** · **2 commands** · **23 skills**

| Category | Items |
|----------|-------|
| Agents | `angular-developer`, `frontend-developer`, `ios-developer`, `mobile-developer`, `nextjs-developer`, `react-developer`, `ui-ux-designer`, `ui-visual-validator` |
| Commands | `/accessibility-audit`, `/react-component-scaffold` |
| Skills | `angular-architect`, `angular-expert`, `angular-new-app`, `chrome-devtools`, `e2e-testing-patterns`, `frontend-design`, `frontend-design-everyday-things`, `frontend-lean-ux`, `frontend-microinteractions`, `frontend-refactoring-ui`, `frontend-screen-reader-testing`, `frontend-top-design`, `frontend-ux-heuristics`, `nestjs-expert`, `nextjs-app-router-patterns`, `nextjs-expert`, `react-expert`, `react-native-architecture`, `react-native-expert`, `react-patterns`, `react-state-management`, `tailwind-design-system`, `wcag-audit-patterns`, `react-feature-development` |

---

### `devops`

Agents, commands and skills for DevOps, infrastructure and platform engineering.

**12 agents** · **1 command** · **21 skills**

| Category | Items |
|----------|-------|
| Agents | `bash-expert`, `deployment-engineer`, `devops-expert`, `devops-troubleshooter`, `github-actions-expert`, `kubernetes-architect`, `kubernetes-expert`, `kubernetes-sre`, `network-engineer`, `observability-engineer`, `posix-shell-developer`, `terraform-expert` |
| Commands | `/multi-stage-dockerfile` |
| Skills | `bash-defensive-patterns`, `bash-testing-patterns`, `cli-developer`, `cost-optimization`, `deployment-pipeline-design`, `github-actions-templates`, `gitlab-ci-patterns`, `helm-chart-scaffolding`, `hybrid-cloud-networking`, `istio-traffic-management`, `k8s-manifest-generator`, `k8s-security-policies`, `kubernetes-specialist`, `mtls-configuration`, `multi-cloud-architecture`, `release-it`, `secrets-management`, `shellcheck-configuration`, `sre-engineer`, `terraform-engineer`, `terraform-module-library` |

---

### `docs`

Agents and commands for technical writing and documentation generation.

**6 agents** · **6 commands** · **1 skill**

| Category | Items |
|----------|-------|
| Agents | `api-documenter`, `documentation-architect`, `mermaid-expert`, `reference-builder`, `technical-writer`, `tutorial-builder` |
| Commands | `/code-exemplars-blueprint-generator`, `/code-explain`, `/doc-generate`, `/readme-blueprint-generator`, `/update-markdown-file-index`, `/write-coding-standards-from-file` |
| Skills | `code-documenter` |

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

## Resources

> Credits and references whenever possible.

- [Jeffallan](https://github.com/Jeffallan/claude-skills)
- [Wondelai](https://github.com/wondelai/skills)
