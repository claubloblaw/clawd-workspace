---
description: The central open question — what mechanism catches errors and drift in knowledge systems the way tests catch bugs in code
type: note
created: 2025-01-25
updated: 2025-01-25
status: seed
tags: [open-question, methodology]
sources: ["heinrich tools for thought thread"]
---

# What is the test for knowledge work?

From Heinrich (@arscontexta):

> vibe note-taking has the same problem like vibe coding before ralph
> a few ideas works fine but dump hundreds and you're drowning in slop
> what's the "testing" for knowledge work?
> what catches drift before it compounds?

This is *the* question.

## Why It Matters

Code without tests: works until it doesn't, then silent failures compound.

Knowledge without tests: same pattern. Notes decay, claims drift, contradictions accumulate, retrieval degrades.

## Candidate Mechanisms

**Structural checks:**
- Orphan detection (notes with no links)
- Broken link detection
- Description coverage (every note needs one)
- Staleness detection (not updated in X days)

**Consistency checks:**
- Do claims contradict each other?
- Are sources still valid?
- Has my thinking changed but old notes remain?

**Retrieval checks:**
- Can I find this note from its description alone?
- Does the file tree give accurate sense of contents?
- Do links lead where expected?

**Predictive checks:**
- Log predictions → check outcomes
- If I claimed X would happen, did it?
- Track decision quality over time

**The meta question:**
- Can an agent verify its own knowledge, or is external ground truth required?

## Current Implementation

Our `/review` hook does basic structural checks. But it doesn't catch *semantic* drift — claims that were true but aren't anymore, or beliefs that contradict each other.

## See Also

- [[back pressure tests agent work]]
- [[vibe workflows break at scale]]
