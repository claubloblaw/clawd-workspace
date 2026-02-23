# Anthropic Claude — Official Prompt Engineering Guide

Source: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/
Downloaded: 2026-02-22

---

## 1. Overview

Prompt engineering techniques ordered from most broadly effective to most specialized:
1. Be clear and direct
2. Use examples (multishot)
3. Let Claude think (chain of thought)
4. Use XML tags
5. Give Claude a role (system prompts)
6. Chain complex prompts
7. Long context tips
8. Extended thinking tips

---

## 2. Be Clear, Direct, and Detailed

Think of Claude as a brilliant but new employee with amnesia who needs explicit instructions.

**Golden rule**: Show your prompt to a colleague with minimal context. If they're confused, Claude will be too.

### How to be clear:
- **Give contextual information**: What the results will be used for, target audience, workflow position, end goal
- **Be specific**: If you want only code, say so
- **Sequential steps**: Use numbered lists/bullet points

### Key patterns:
- **Bad**: "Remove PII from this data"
- **Good**: "Your task is to anonymize customer feedback. Instructions: 1. Replace names with CUSTOMER_[ID]  2. Replace emails with EMAIL_[ID]@example.com  3. Redact phone numbers as PHONE_[ID]..."

- **Bad**: "Write a marketing email for new features"
- **Good**: Specify target audience, key features, tone, CTA, subject line constraints, personalization variables, structure

- **Bad**: "Summarize this report"
- **Good**: "Skip preamble. Keep terse. List only: 1) Cause 2) Duration 3) Impacted services 4) Affected users 5) Revenue loss"

---

## 3. Use Examples (Multishot Prompting)

Examples are the secret weapon for accuracy, consistency, and performance.

**Power tip**: Include 3-5 diverse, relevant examples. More examples = better performance for complex tasks.

### Crafting effective examples:
- **Relevant**: Mirror your actual use case
- **Diverse**: Cover edge cases, vary enough to avoid unintended pattern matching
- **Clear**: Wrap in `<example>` tags (multiple: nested in `<examples>`)

### Pattern:
```
<example>
Input: The new dashboard is a mess! It takes forever to load.
Category: UI/UX, Performance
Sentiment: Negative
Priority: High
</example>
```

**Pro tip**: Ask Claude to evaluate your examples for relevance/diversity, or generate more based on your initial set.

---

## 4. Let Claude Think (Chain of Thought)

Giving Claude space to think dramatically improves performance on complex tasks.

### Why:
- **Accuracy**: Reduces errors in math, logic, analysis
- **Coherence**: More organized responses
- **Debugging**: See where prompts may be unclear

### Three levels (least → most complex):

1. **Basic**: Add "Think step-by-step"
2. **Guided**: Outline specific thinking steps ("First think about X, then consider Y, finally Z")
3. **Structured**: Use XML tags to separate reasoning from answer:
   ```
   Think in <thinking> tags. Then provide your answer in <answer> tags.
   ```

**Critical**: Always have Claude output its thinking. Without outputting, no thinking occurs!

### When to use:
- Complex math, multi-step analysis
- Writing complex documents
- Decisions with many factors

### When NOT to use:
- Simple lookups or short answers (adds latency)

---

## 5. Use XML Tags

XML tags help Claude parse prompts with multiple components accurately.

### Why:
- **Clarity**: Separate different prompt parts
- **Accuracy**: Reduce misinterpretation
- **Flexibility**: Easy to modify parts
- **Parseability**: Extract specific response parts via post-processing

### Best practices:
- **Be consistent**: Same tag names throughout; reference them ("Using the contract in <contract> tags...")
- **Nest tags**: `<outer><inner></inner></outer>` for hierarchical content
- No canonical "best" tags — use names that make sense with the content

### Power combo: XML + multishot (`<examples>`) + CoT (`<thinking>`, `<answer>`)

### Common tags:
- `<instructions>`, `<example>`, `<formatting>`, `<data>`, `<document>`, `<context>`
- `<thinking>`, `<answer>`, `<findings>`, `<recommendations>`

---

## 6. Give Claude a Role (System Prompts)

Role prompting is the most powerful way to use system prompts.

### Why:
- **Enhanced accuracy**: Domain-specific performance boost
- **Tailored tone**: CFO brevity vs copywriter flair
- **Improved focus**: Stays within task requirements

### How:
Use the `system` parameter for the role. Put task-specific instructions in the `user` turn.

```python
system="You are a seasoned data scientist at a Fortune 500 company."
```

### Key insight:
- "data scientist" sees different insights than "marketing strategist"
- "data scientist specializing in customer insight for Fortune 500" yields different results still
- More specific roles → more targeted outputs

### Impact examples:
- Without role: Generic analysis, misses critical issues
- With role (e.g., "General Counsel of Fortune 500"): Catches issues that could cost millions, provides professional-grade recommendations

---

## 7. Chain Complex Prompts

Break complex tasks into smaller, manageable subtasks.

### Why:
- **Accuracy**: Each subtask gets full attention
- **Clarity**: Simpler instructions per step
- **Traceability**: Pinpoint and fix issues

### How:
1. Identify subtasks (distinct, sequential steps)
2. Structure with XML for clear handoffs between prompts
3. Single-task goal per subtask
4. Iterate based on performance

### Common chains:
- **Content creation**: Research → Outline → Draft → Edit → Format
- **Data processing**: Extract → Transform → Analyze → Visualize
- **Decision-making**: Gather info → List options → Analyze → Recommend
- **Verification loops**: Generate → Review → Refine → Re-review

### Self-correction chains:
Chain prompts to have Claude review its own work:
1. Generate initial output
2. Review for accuracy/completeness (grade A-F)
3. Revise based on feedback

**Optimization**: For independent subtasks, run prompts in parallel.

---

## 8. Long Context Tips

For Claude's extended context window (200K tokens).

### Essential tips:

1. **Put longform data at the top**: Place long documents (~20K+ tokens) above your query/instructions. Queries at the end improve response quality by up to 30%.

2. **Structure with XML**:
```xml
<documents>
  <document index="1">
    <source>annual_report.pdf</source>
    <document_content>{{CONTENT}}</document_content>
  </document>
</documents>
```

3. **Ground responses in quotes**: Ask Claude to quote relevant parts before carrying out the task. Helps cut through noise.
```
Find quotes from the records relevant to diagnosing symptoms.
Place these in <quotes> tags. Then list diagnostic info in <info> tags.
```

---

## 9. Extended Thinking Tips

For Claude's extended thinking mode (dedicated reasoning before responding).

### Technical considerations:
- Minimum budget: 1024 tokens. Start small, increase as needed.
- For >32K thinking tokens, use batch processing (avoids timeouts)
- Best in English (outputs can be any language)
- Below minimum budget → use standard mode with `<thinking>` XML tags instead

### Key techniques:

1. **General > prescriptive**: High-level "think deeply" often beats step-by-step instructions. Claude's creativity in approaching problems may exceed prescribed processes.
   - **Bad**: "Step 1: identify variables. Step 2: set up equation..."
   - **Good**: "Think thoroughly. Consider multiple approaches. Try different methods if first doesn't work."

2. **Multishot with thinking**: Include `<thinking>` or `<scratchpad>` tags in examples. Claude generalizes the pattern.

3. **Debugging via thinking output**: Read Claude's thinking to understand its logic. But:
   - Do NOT pass thinking back in user text (degrades results)
   - Prefilling thinking is not allowed
   - Manually changing output after thinking degrades results

4. **Self-verification**: Ask Claude to verify with test cases before declaring complete.

5. **Long outputs**: Increase thinking budget AND explicitly ask for longer outputs. For 20K+ words, request detailed outline with word counts first.

### Best use cases for extended thinking:
- Complex STEM problems
- Constraint optimization (multiple competing requirements)
- Structured thinking frameworks (Porter's Five Forces, etc.)
