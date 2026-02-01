---
description: Operating instructions for the brain vault - read this first every session
type: system
---

# Brain System

This vault is a tool for thought designed for agent operation. It's a knowledge graph built from markdown files where wiki-links form the edges between ideas.

## Structure

```
brain/
├── inbox/       # Raw inputs awaiting processing
├── notes/       # Atomic notes (one claim per note)
├── mocs/        # Maps of Content (index notes)
├── learning/    # Observations, hypotheses, reflections
├── archive/     # Deprecated or superseded notes
├── hooks/       # Automation scripts
└── templates/   # Note templates
```

## YAML Convention

Every note MUST have a YAML header with at minimum:

```yaml
---
description: One sentence describing the claim or content
type: note|moc|learning|source
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: seed|growing|evergreen|archive
---
```

### Status Lifecycle

- **seed** — Initial capture, may be rough
- **growing** — Being developed, has some links
- **evergreen** — Mature, well-connected, stable claim
- **archive** — Superseded or deprecated

## Naming Convention

Note titles ARE claims. Write them as complete thoughts you can embed in sentences:

- ✅ `quality is the hard part`
- ✅ `context windows are the bottleneck`
- ❌ `Quality` (too vague)
- ❌ `Notes on context` (not a claim)

This enables in-sentence wiki-links: "Since [[quality is the hard part]], we focus on..."

## Context Loading (Progressive Disclosure)

```
file tree → descriptions → headings → sections → full content
```

1. **File tree** — Scan titles to understand what exists
2. **Descriptions** — Read YAML descriptions to decide relevance
3. **Headings** — Skim structure before committing
4. **Full content** — Only load what's needed

Most decisions should happen at the description level.

## Phases

### /reduce
Extract atomic claims from raw content in inbox. Each claim becomes a note.

### /reflect  
Find connections between notes. Update MOCs. Add wiki-links.

### /reweave
Revisit old notes with new knowledge. Add links, refine claims.

### /recite
Verify descriptions accurately represent content and enable retrieval.

### /review
Health checks: find orphans, broken links, sparse notes, stale content.

### /rethink
Challenge assumptions. Compare claims against evidence. Update or archive.

### /learn
Request research on topics. Queue items for deep exploration.

## Links

- Prefer wiki-links: `[[note title]]`
- Link liberally — connections are the value
- Backlinks are automatic — don't duplicate them manually
