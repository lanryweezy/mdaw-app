## 2024-06-13 - Avoid try-catch for control flow and double iterations
**Learning:** Using `try-catch` blocks around `firstWhere` for standard control flow (e.g., searching for an item that may not exist) can cause jank during rapid UI callbacks. Additionally, checking `.any()` followed by `.firstWhere()` causes unnecessary double iterations over collections.
**Action:** Use `for` loops or `indexWhere`/`firstWhere(orElse: ...)` without throwing exceptions for standard collection searching. Refactor double iterations into a single pass.
