# OpenAI — Official Prompt Engineering Guides

Sources:
- https://platform.openai.com/docs/guides/prompt-engineering
- https://cookbook.openai.com/examples/gpt4-1_prompting_guide
- https://cookbook.openai.com/examples/gpt-5/gpt-5_prompting_guide
- https://platform.openai.com/docs/guides/reasoning-best-practices
Downloaded: 2026-02-22

---

## Model Selection

- **Reasoning models** (o3, o4-mini): "The planners" — think longer about complex tasks. Best for strategy, planning, ambiguous info, code review.
- **GPT models** (GPT-4.1, GPT-5): "The workhorses" — fast, cost-efficient, precise execution. Best for well-defined tasks.
- Most workflows should use **both**: o-series for planning/decisions, GPT for execution.

---

## 1. Prompt Structure (Universal)

Recommended order for developer messages:

```
# Identity (role, purpose, communication style)
# Instructions (rules, what to do/never do)
## Sub-categories for detailed instructions
# Reasoning Steps (ordered list for workflow)
# Output Format
# Examples
# Context (supporting documents, data — best near end)
# Final instructions + prompt to think step by step
```

### Delimiters

- **Markdown**: Best starting point. Use headers (H1-H4+), backtick code blocks, lists.
- **XML**: Great for precise wrapping, metadata, nesting. Best for long-context document indexing.
- **JSON**: Good for structured coding contexts but verbose. **Performs poorly for document indexing.**

For long-context document indexing:
```xml
<document index="1">
  <source>report.pdf</source>
  <content>...</content>
</document>
```

Or pipe-delimited (Lee et al.):
```
ID: 1 | TITLE: The Fox | CONTENT: The quick brown fox...
```

---

## 2. Message Roles & Authority

- **`developer`** (formerly system): High-priority instructions, business logic, rules. Like a function definition.
- **`user`**: End-user inputs. Like function arguments.
- **`assistant`**: Model-generated messages.

Developer messages take priority over user messages per the [model spec](https://model-spec.openai.com).

---

## 3. Few-Shot Learning

Include 3-5 diverse input/output examples in developer message. Use XML for structure:

```xml
<product_review id="example-1">
I absolutely love these headphones!
</product_review>
<assistant_response id="example-1">
Positive
</assistant_response>
```

---

## 4. GPT-4.1 Specific

GPT-4.1 follows instructions **more literally** than predecessors. Key differences:
- Won't liberally infer intent — you must be explicit
- Highly steerable — a single firm sentence usually corrects behavior
- Use API `tools` field for tool definitions (not manual prompt injection) — 2% improvement on SWE-bench

### Agentic Prompts — Three Essential Components

1. **Persistence**: "Keep going until the user's query is completely resolved. Only terminate when the problem is solved."
2. **Tool-calling**: "If not sure about content, use tools to gather info. Do NOT guess."
3. **Planning** (optional): "Plan extensively before each function call, reflect on outcomes."

These three instructions increased SWE-bench score by ~20%.

### Induced Chain-of-Thought

GPT-4.1 is NOT a reasoning model, but you can induce explicit planning:
- Add "Think step by step" or structured reasoning steps
- Improves pass rate ~4% on agentic tasks
- Think of it as the model "thinking out loud"

### Long Context (1M tokens)

- Place instructions at **both beginning and end** of provided context (best performance)
- If only once, place **above** the context
- XML works best for document delimiting in long context

### Instruction Following

Workflow for debugging instruction issues:
1. Start with "Response Rules" / "Instructions" section with bullet points
2. Add subsections for specific behaviors
3. Add ordered lists for step-by-step workflows
4. Check for **conflicting/underspecified instructions** — GPT-4.1 follows the one closer to prompt end
5. Add examples that demonstrate desired behavior

### Common Failure Modes

- "Always call a tool before responding" → model halluccinates tool inputs when insufficient info. Fix: add "if not enough info, ask the user"
- Sample phrases used verbatim → instruct model to vary them
- Excessive prose/formatting without instructions → add format constraints

---

## 5. GPT-5 Specific

Biggest leap in agentic performance, coding, steerability.

### Agentic Eagerness Control

**Less eager** (faster, less exploration):
- Lower `reasoning_effort` (medium or low)
- Define clear context-gathering criteria with early stop conditions
- Set tool call budgets ("absolute maximum of 2 tool calls")
- Provide escape hatches ("even if not fully correct")

**More eager** (autonomous, persistent):
- Increase `reasoning_effort`
- Use persistence prompt:
```
Keep going until completely resolved.
Never stop at uncertainty — deduce and continue.
Do not ask to confirm assumptions — document them and proceed.
```

### Tool Preambles

GPT-5 is trained to provide progress updates between tool calls. Steer with:
```
- Begin by rephrasing user's goal before calling tools
- Outline structured plan for each step
- Narrate each step succinctly
- Finish by summarizing completed work
```

### Reasoning Effort Parameter

- `minimal` / `low` / `medium` (default) / `high`
- Scale up for complex multi-step tasks
- At `minimal`: prompt more like GPT-4.1 (explicit planning, detailed tool instructions, agentic persistence reminders)

### Verbosity Parameter (new in GPT-5)

- Controls final answer length (separate from reasoning length)
- Can override per-context in prompt: "Use high verbosity for writing code"
- Cursor's approach: low verbosity globally + high verbosity for code tools only

### Instruction Following

GPT-5 follows with "surgical precision" — **contradictory instructions are more damaging** than with other models. It spends reasoning tokens trying to reconcile contradictions instead of picking one.

Fix: Review prompts for conflicts, especially in multi-stakeholder living documents. Use the prompt optimizer tool.

### Frontend Development

Best frameworks: Next.js (TS), Tailwind CSS, shadcn/ui, Radix Themes, Lucide icons, Motion for animation.

For zero-to-one apps, use self-reflection rubric:
```
First, think of a rubric with 5-7 categories (don't show user).
Use rubric to iterate on best solution.
If not hitting top marks, start again.
```

### Metaprompting

Use GPT-5 to optimize its own prompts:
```
What specific phrases could be added/deleted from this prompt
to more consistently elicit [desired behavior]
and prevent [undesired behavior]?
```

### Markdown

GPT-5 does NOT format in Markdown by default in API. To enable:
```
Use Markdown only where semantically correct
(inline code, code fences, lists, tables).
```
Re-add instruction every 3-5 messages in long conversations.

### Responses API

Use Responses API over Chat Completions — reasoning persists between tool calls:
- Tau-Bench Retail: 73.9% → 78.2% just by switching APIs
- Pass `previous_response_id` to reuse reasoning context

---

## 6. Reasoning Models (o3, o4-mini)

### Key Differences from GPT

- **Keep prompts simple and direct** — they reason internally
- **Avoid "think step by step"** — unnecessary, can hurt performance
- **Try zero-shot first** — they often don't need examples
- **Be very specific about success criteria** — encourage iterating until criteria met
- **No markdown by default** — add "Formatting re-enabled" on first line of developer message to enable

### Best Use Cases

1. **Ambiguous tasks**: Limited/disparate info, understanding intent
2. **Needle in haystack**: Large unstructured data, finding relevant info
3. **Cross-document reasoning**: Drawing parallels, finding relationships
4. **Multi-step agentic planning**: Strategy, orchestrating other models
5. **Visual reasoning** (o1): Complex charts, architectural drawings
6. **Code review/debugging**: Background quality checks
7. **Evaluating other model outputs**: LLM-as-judge (4x improvement over GPT-4o)

### Reasoning Item Persistence (o3, o4-mini)

In Responses API: reasoning items adjacent to function calls are included in subsequent context. Pass all reasoning items from previous requests for best performance and lower token usage.

In Chat Completions API: reasoning items are never included (stateless). Slightly degraded performance in complex multi-tool scenarios.

---

## 7. Prompt Caching

Keep **reusable content at the beginning** of prompts. Static instructions, role definitions, and examples should come first. Dynamic context (user-specific data) goes at the end.
