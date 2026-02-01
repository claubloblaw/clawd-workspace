---
description: YAML description fields let agents assess note relevance without spending tokens on full content
type: note
created: 2025-01-25
updated: 2025-01-25
status: seed
tags: [retrieval, yaml]
sources: []
---

# Descriptions enable retrieval without loading

Every note has a YAML `description` field — a single sentence capturing the core claim or content.

When scanning for relevant notes, load descriptions first. This costs ~20 tokens per note vs hundreds for full content. If the description signals relevance, load more. If not, move on.

This is the agent equivalent of reading book spines in a library before pulling volumes off the shelf.

## Quality Criteria

Good descriptions are:
- Complete sentences (not fragments)
- Specific (not "notes about X")
- Claims (not summaries)
- Standalone (make sense without context)

## See Also

- [[progressive disclosure reduces token waste]]
- [[recite verifies retrieval]]
