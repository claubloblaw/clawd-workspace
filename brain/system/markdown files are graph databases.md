---
description: A folder of markdown files with wiki-links and YAML frontmatter functions as a queryable knowledge graph
type: note
created: 2025-01-25
updated: 2025-01-25
status: seed
tags: [structure, knowledge-graph]
sources: ["[[heinrich tools for thought thread]]"]
---

# Markdown files are graph databases

You can build a graph database out of markdown files:
- Files are **nodes**
- Wiki-links are **edges** connecting them
- YAML frontmatter is **metadata** you can query

It's a knowledge graph that an LLM can traverse naturally — no special database, no API, just files.

## Why This Works for Agents

- Native format (agents already read/write markdown)
- Git-friendly (version control for free)
- Human-readable (you can browse it too)
- Tool-friendly (grep, ripgrep, Dataview)

## See Also

- [[wiki links are knowledge graph edges]]
- [[YAML frontmatter enables filtering]]
- [[the value is in the connections]]
