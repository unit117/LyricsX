# GitHub Copilot Agents for LyricsX

> Reference: [github/awesome-copilot](https://github.com/github/awesome-copilot) - A curated collection of GitHub Copilot agents, prompts, and instructions.

This document lists relevant GitHub Copilot agents that can assist with the LyricsX modernization project. The agents directory contains **100+ agents** for various development tasks.

---

## Swift & Apple Development

| Agent | Description |
|-------|-------------|
| [Swift MCP Expert](https://github.com/github/awesome-copilot/blob/main/agents/swift-mcp-expert.agent.md) | Expert agent for Swift development with Model Context Protocol integration |

---

## Architecture & Planning

| Agent | Description |
|-------|-------------|
| [Architecture](https://github.com/github/awesome-copilot/blob/main/agents/arch.agent.md) | Helps design and document software architecture |
| [Blueprint Mode](https://github.com/github/awesome-copilot/blob/main/agents/blueprint-mode.agent.md) | Creates detailed blueprints for software projects |
| [Plan](https://github.com/github/awesome-copilot/blob/main/agents/plan.agent.md) | Generates structured project plans |
| [Planner](https://github.com/github/awesome-copilot/blob/main/agents/planner.agent.md) | Task and milestone planning assistant |
| [Implementation Plan](https://github.com/github/awesome-copilot/blob/main/agents/implementation-plan.agent.md) | Creates detailed implementation plans for features |
| [Task Planner](https://github.com/github/awesome-copilot/blob/main/agents/task-planner.agent.md) | Breaks down work into actionable tasks |
| [PRD](https://github.com/github/awesome-copilot/blob/main/agents/prd.agent.md) | Product Requirements Document generator |
| [Specification](https://github.com/github/awesome-copilot/blob/main/agents/specification.agent.md) | Creates technical specifications |
| [ADR Generator](https://github.com/github/awesome-copilot/blob/main/agents/adr-generator.agent.md) | Architecture Decision Record generator |

---

## Testing & Quality

| Agent | Description |
|-------|-------------|
| [TDD Red](https://github.com/github/awesome-copilot/blob/main/agents/tdd-red.agent.md) | Test-Driven Development: Write failing tests first |
| [TDD Green](https://github.com/github/awesome-copilot/blob/main/agents/tdd-green.agent.md) | Test-Driven Development: Make tests pass |
| [TDD Refactor](https://github.com/github/awesome-copilot/blob/main/agents/tdd-refactor.agent.md) | Test-Driven Development: Refactor while keeping tests green |
| [Playwright Tester](https://github.com/github/awesome-copilot/blob/main/agents/playwright-tester.agent.md) | End-to-end testing with Playwright |

---

## Debugging & Maintenance

| Agent | Description |
|-------|-------------|
| [Debug](https://github.com/github/awesome-copilot/blob/main/agents/debug.agent.md) | Systematic debugging and issue resolution |
| [Janitor](https://github.com/github/awesome-copilot/blob/main/agents/janitor.agent.md) | Code cleanup and maintenance tasks |
| [Tech Debt Remediation Plan](https://github.com/github/awesome-copilot/blob/main/agents/tech-debt-remediation-plan.agent.md) | Identifies and plans technical debt resolution |

---

## Development Modes

| Agent | Description |
|-------|-------------|
| [4.1 Beast](https://github.com/github/awesome-copilot/blob/main/agents/4.1-Beast.agent.md) | High-performance coding mode |
| [Thinking Beast Mode](https://github.com/github/awesome-copilot/blob/main/agents/Thinking-Beast-Mode.agent.md) | Deep reasoning and problem-solving mode |
| [GPT-5 Beast Mode](https://github.com/github/awesome-copilot/blob/main/agents/gpt-5-beast-mode.agent.md) | Advanced coding capabilities |
| [Critical Thinking](https://github.com/github/awesome-copilot/blob/main/agents/critical-thinking.agent.md) | Careful analysis and evaluation |

---

## Documentation & Review

| Agent | Description |
|-------|-------------|
| [Code Tour](https://github.com/github/awesome-copilot/blob/main/agents/code-tour.agent.md) | Creates guided tours of codebases |
| [Mentor](https://github.com/github/awesome-copilot/blob/main/agents/mentor.agent.md) | Educational guidance and code explanations |
| [Address Comments](https://github.com/github/awesome-copilot/blob/main/agents/address-comments.agent.md) | Helps address code review comments |
| [Refine Issue](https://github.com/github/awesome-copilot/blob/main/agents/refine-issue.agent.md) | Improves issue descriptions and clarity |

---

## Accessibility

| Agent | Description |
|-------|-------------|
| [Accessibility](https://github.com/github/awesome-copilot/blob/main/agents/accessibility.agent.md) | Ensures accessibility compliance and best practices |

---

## API & Backend

| Agent | Description |
|-------|-------------|
| [API Architect](https://github.com/github/awesome-copilot/blob/main/agents/api-architect.agent.md) | Designs and documents APIs |

---

## Research & Spikes

| Agent | Description |
|-------|-------------|
| [Research Technical Spike](https://github.com/github/awesome-copilot/blob/main/agents/research-technical-spike.agent.md) | Investigates technical solutions and approaches |
| [Task Researcher](https://github.com/github/awesome-copilot/blob/main/agents/task-researcher.agent.md) | Researches and gathers information for tasks |

---

## Prompt Engineering

| Agent | Description |
|-------|-------------|
| [Prompt Engineer](https://github.com/github/awesome-copilot/blob/main/agents/prompt-engineer.agent.md) | Creates and optimizes prompts |
| [Prompt Builder](https://github.com/github/awesome-copilot/blob/main/agents/prompt-builder.agent.md) | Builds structured prompts for specific tasks |

---

## Usage in LyricsX

Based on the [ROADMAP.md](../ROADMAP.md), here are recommended agents for each phase:

### Phase 1: Foundation Modernization
| Task | Recommended Agents |
|------|-------------------|
| Architecture documentation | Blueprint Mode, ADR Generator, Architecture |
| Project planning | Plan, Planner |
| SPM migration planning | Implementation Plan |

### Phase 2: UI Layer Redesign
| Task | Recommended Agents |
|------|-------------------|
| SwiftUI development | Swift MCP Expert |
| Accessibility support | Accessibility |
| Code review | Address Comments, Mentor |

### Phase 3: Backend Integration Layer
| Task | Recommended Agents |
|------|-------------------|
| Service protocol design | Architecture, API Architect |
| Technical decisions | ADR Generator, Critical Thinking |

### Phase 4: Feature Enhancements
| Task | Recommended Agents |
|------|-------------------|
| Accessibility audit | Accessibility |
| Technical research | Research Technical Spike, Task Researcher |

### Phase 5: Testing & Polish
| Task | Recommended Agents |
|------|-------------------|
| Test-Driven Development | TDD Red, TDD Green, TDD Refactor |
| Debugging | Debug |
| Code cleanup | Janitor, Tech Debt Remediation Plan |
| Documentation | Code Tour, Mentor |

---

## More Resources

Explore the full collection of resources in the awesome-copilot repository:

| Resource | Description | Best For |
|----------|-------------|----------|
| [Agents Overview](https://github.com/github/awesome-copilot/blob/main/docs/README.agents.md) | Complete guide to available agents | Understanding how agents work and their capabilities |
| [Prompts Guide](https://github.com/github/awesome-copilot/blob/main/docs/README.prompts.md) | Reusable prompt templates | Quick, task-specific prompts without full agent setup |
| [Custom Instructions](https://github.com/github/awesome-copilot/blob/main/docs/README.instructions.md) | Repository-level instruction files | Setting up project-wide Copilot behavior |
| [Collections](https://github.com/github/awesome-copilot/blob/main/docs/README.collections.md) | Curated agent collections | Finding grouped agents for specific workflows |
| [All Agents](https://github.com/github/awesome-copilot/tree/main/agents) | Browse all 100+ agents | Exploring the full catalog of available agents |
