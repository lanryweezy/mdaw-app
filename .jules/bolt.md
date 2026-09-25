## 2023-10-27 - [Replacing try-catch with indexWhere for performance]
**Learning:** Using exceptions for control flow (like `try-catch` around `firstWhere`) inside UI interaction paths like drag-and-drop operations causes significant FPS drops in Flutter due to stack trace generation.
**Action:** Always replace `firstWhere` inside `try/catch` blocks with `for` loops or `indexWhere` (especially avoiding double iterations like `.any()` followed by `.firstWhere()`).

## 2026-09-20 - [O(log N) Binary Search for Sorted Data Lookups]
**Learning:** In continuous playback loops like audio automation, linear iteration (O(N)) to find points on a timeline causes frame drops as point count grows. Since `AutomationLane` points are strictly sorted by time, they are perfect candidates for binary search.
**Action:** Use O(log N) binary search instead of `for` loops when querying bounded values in time-sorted collections to maintain constant playback performance regardless of automation density.

## 2024-05-18 - [Avoiding List Allocation in High-Frequency Getters]
**Learning:** Creating intermediate lists by spreading arrays and filtering inside commonly accessed getters (like `_allActiveClips` called within loops or `updateTotalDuration()`) causes massive GC pressure and frame drops in Dart/Flutter.
**Action:** Iterate sequentially using manual loops without allocating intermediate flattened arrays in performance-sensitive logic paths. Cache the result of property access in local variables when used in a loop.
