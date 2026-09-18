## 2023-10-27 - [Replacing try-catch with indexWhere for performance]
**Learning:** Using exceptions for control flow (like `try-catch` around `firstWhere`) inside UI interaction paths like drag-and-drop operations causes significant FPS drops in Flutter due to stack trace generation.
**Action:** Always replace `firstWhere` inside `try/catch` blocks with `for` loops or `indexWhere` (especially avoiding double iterations like `.any()` followed by `.firstWhere()`).
## 2024-05-19 - [Replacing double iteration with indexWhere]
**Learning:** Using `firstWhere` combined with `contains` inside high-frequency functions (like automation value recording during UI interactions) causes a double O(N) iteration, leading to unnecessary CPU cycles.
**Action:** Replace `firstWhere` and `contains` sequential checks with a single `indexWhere` to handle presence checking and element fetching in a single O(N) pass.
