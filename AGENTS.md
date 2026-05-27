# AGENTS.md

Guidance for agents working in this repository.

## Core Principles

- **Code like Kent Beck**: Small, focused changes; clear intent; avoid speculative abstractions.

## Language

- Write **comments, commits, and docs in English**.
- User-facing UI strings may stay in Japanese unless a task says otherwise.

## Task Completion Checklist

When finishing a task that changes Swift source:

### Format

```bash
swift format -ir .
```

### Lint

```bash
swift format lint -r .
```

## Code Artifacts

- **Explain why, not what**: Comment only non-obvious decisions; never restate the code.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>
```

- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
- Breaking changes: `<type>!: <subject>` (lowercase subject, no trailing period)
- Optional trailer: `Assisted-by: {{agent name}} (model: {{model name}})`

## Response Format (Chat)

When citing code in agent responses, use fenced blocks with language and file path:

````markdown
```swift Sources/ChannelFeature/ChannelView.swift
// ...
```
````

Use four backticks when nesting code blocks inside another fenced block.
