---
description: Loading information in stages (titles → descriptions → content) lets agents decide relevance before committing tokens
type: note
created: 2025-01-25
updated: 2025-01-25
status: seed
tags: [cognition, retrieval]
sources: []
---

# Progressive disclosure reduces token waste

Instead of loading full files immediately, move through stages:

```
file tree → descriptions → headings → sections → full content
```

At each stage, decide if deeper loading is worth it. Most decisions can happen at the description level without ever loading the full file.

This mirrors how humans skim — but agents can be more systematic about it.

## Implementation

1. File names are claims — scannable without opening
2. YAML `description` field — one sentence summary
3. Headings — structure preview
4. Full content — only when needed

## See Also

- [[context windows are the bottleneck]]
- [[descriptions enable retrieval without loading]]
