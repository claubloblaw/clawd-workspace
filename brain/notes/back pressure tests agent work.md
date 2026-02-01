---
description: Agents need mechanisms to test their own outputs before accepting them as correct — similar to how tests validate code
type: note
created: 2025-01-25
updated: 2025-01-25
status: seed
tags: [agents, verification, methodology]
sources: []
---

# Back pressure tests agent work

In software, tests create "back pressure" — they push back against code changes, catching errors before they propagate. Without tests, bugs compound silently.

Agents face the same problem. They generate outputs (code, notes, decisions) but how do they know if those outputs are *correct*?

## Forms of Back Pressure for Agents

**Code:**
- Run tests, linters, type checkers
- Execute and observe results
- CI pipelines that block bad changes

**Knowledge work:**
- ??? (this is the open question)

## The Problem

Vibe coding worked until scale broke it. Tests were the answer.

Vibe note-taking works until scale breaks it. What's the answer?

Possible mechanisms:
- Consistency checks (do claims contradict each other?)
- Retrieval tests (can I find this again via description?)
- Prediction → outcome logging (was I right?)
- External validation (check against sources)

## Open Questions

- What's the minimal viable "test" for a note?
- How do you catch drift before it compounds?
- Can agents self-verify, or do they need external ground truth?

## See Also

- [[what is the test for knowledge work]]
- [[rules start as hypotheses]]
