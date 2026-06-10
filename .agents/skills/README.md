# Shared agent skills

Skills here follow the [agentskills.io](https://agentskills.io) open standard. Both Claude Code and Codex CLI load them:

- **Claude** reads `.claude/skills/`, which is a symlink to this directory (`.agents/skills`).
- **Codex** reads `.agents/skills/` directly.

## Layout per skill

```
<skill-name>/
├── SKILL.md          # required: YAML frontmatter + body
├── scripts/          # optional: executable helpers
├── references/       # optional: long lookup docs (loaded on demand)
└── assets/           # optional: templates, fixtures, images
```

## SKILL.md format

```markdown
---
name: <kebab-case-id>
description: Use when <trigger>. Do not use when <anti-trigger>.
---

# <Title>

<Body the agent reads only after the description matches the task.>
```

Both tools use **progressive disclosure**: only the description loads at session start; the full body loads when the agent decides the skill applies. Write the description as a routing decision ("use when…" / "do not use when…"), not a summary.

## When to write one

- A recurring workflow that's longer than a paragraph and not part of the always-on root `AGENTS.md`.
- A subsystem deep-dive that's only relevant when an agent is working in that subsystem.
- A schema, glossary, or long lookup table → put it in `references/` inside a skill, not in the main body.

For one-off context that belongs in every session (stack, conventions, top-level architecture), edit `AGENTS.md` instead.
