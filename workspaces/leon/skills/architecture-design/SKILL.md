---
name: Architecture Design
description: Evaluate system design, recommend refactors, review boundaries and coupling. Use for component design, dependency analysis, and architectural decision records.
requires: []
---

# Architecture Design

## When to Use

- Evaluating a new feature design before implementation
- Refactoring existing code to improve maintainability
- Choosing between implementation approaches
- Reviewing system boundaries and interfaces

## Analysis Framework

### 1. Understand Current State

```bash
# Clone and explore
git clone https://github.com/rajsinghtech/<repo>.git /tmp/arch-review
cd /tmp/arch-review

# File structure
find . -type f -name "*.go" -o -name "*.ts" -o -name "*.py" | head -50

# Dependencies
cat go.mod 2>/dev/null || cat package.json 2>/dev/null || cat requirements.txt 2>/dev/null
```

### 2. Evaluate

- **Separation of concerns** — Does each module have a clear, single responsibility?
- **Dependencies** — Are dependency directions clean? Circular dependencies?
- **Interfaces** — Are boundaries well-defined? Can components be tested independently?
- **Data flow** — How does data move through the system? Any unnecessary transformations?
- **Error handling** — Is it consistent? Do errors propagate with context?
- **Scalability** — What breaks first under load? What's the bottleneck?

### 3. Recommend

Provide recommendations with:
- **What** to change
- **Why** it improves the system
- **How** to migrate (incremental steps, not big-bang rewrites)
- **Tradeoffs** — what you gain vs what you give up
