## 2023-10-27 - [Replacing try-catch with indexWhere for performance]
**Learning:** Using exceptions for control flow (like `try-catch` around `firstWhere`) inside UI interaction paths like drag-and-drop operations causes significant FPS drops in Flutter due to stack trace generation.
**Action:** Always replace `firstWhere` inside `try/catch` blocks with `for` loops or `indexWhere` (especially avoiding double iterations like `.any()` followed by `.firstWhere()`).
## 2024-05-20 - Avoid Collection Double Iteration and Exception Flow
**Learning:** In Dart, calling `firstWhere` combined with a `.contains()` check or using `firstWhere` (without `orElse`) expecting a `StateError` to control flow are massive performance anti-patterns. They trigger O(N) traversals twice, generate unnecessary closure allocations in hot paths like parameter recording, and cause UI jank due to exception propagation overhead.
**Action:** Always prefer a single `indexWhere` pass for list lookups, returning `-1` if absent, thus handling both existence and retrieval in a single O(N) pass without exceptions or double iterations.
