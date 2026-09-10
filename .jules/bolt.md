## 2024-09-10 - Avoid exception-based control flow in hot UI paths
**Learning:** Using `firstWhere` with a `try-catch` block (catching `StateError`) or double iterations like `.any()` followed by `.firstWhere()` in frequently called UI methods (e.g., during drag operations or rapid state updates) causes significant overhead and jank.
**Action:** Prefer standard `for` loops or `indexWhere` with manual null checks instead of relying on `firstWhere` and exceptions for control flow when searching lists.
