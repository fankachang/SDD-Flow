---
name: code-reuse-check
description: Search for existing implementations before adding any new reusable code (function, method, class, or module), reuse or extend instead of duplicating, and place shared code in the project's designated shared location. When existing duplicates are found, report them only; converge solely on explicit user request — never refactor beyond the task scope.
---

# Code Reuse Check

## When to Use

- Before adding any new reusable code (function, method, class, or module)
- When duplicate implementations with the same purpose are found across files (**report only**; convergence requires an explicit user request)

## Workflow

### 1. Search before creating

Grep for existing implementations before writing new reusable code:

- Name and likely synonyms (e.g. `FormatDate|DateFormat|ToDateString`)
- Distinctive logic markers (regex patterns, magic strings, API endpoints, constants)

If a same-purpose implementation already exists → reuse or extend it. Never copy it into another file. If multiple duplicates exist, reference the most suitable one — **do not touch the other copies in passing**.

### 2. Determine the shared location

Resolution order:

1. **Recorded value**: check the "專案技術棧與環境" section in `.github/copilot-instructions.md` for a shared-code location entry → use it.
2. **Detect convention** from the existing project structure:

   | Project type | Common conventions |
   |---|---|
   | C# / .NET | `Common/` or `Shared/` class library, `src/<App>.Common/` |
   | Frontend (JS/TS) | `src/utils/`, `src/lib/`, `src/shared/` |
   | Python | shared package such as `<pkg>/utils/`, `common/` |
   | Monorepo | dedicated shared package/library referenced by other packages |

3. **Still ambiguous** → ask the user (offer detected candidates plus free input), then record the confirmed path as a `- **共用程式碼位置**：<path>` line in the "專案技術棧與環境" section of `.github/copilot-instructions.md` (add the line if missing) so later sessions inherit it.

### 3. Converge existing duplicates (only on explicit user request)

**Precondition**: refactoring that is not demanded by the task is not allowed (especially in brownfield projects). When duplicates are discovered during a task, only report their locations and impact scope; execute the steps below only after the user explicitly agrees:

1. Grep all copies of the duplicated implementation
2. Keep or create the canonical version in the shared location
3. Redirect every call site to the canonical version
4. Delete the remaining copies
5. Build and run tests to verify
