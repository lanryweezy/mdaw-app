## 2023-10-27 - [Replacing try-catch with indexWhere for performance]
**Learning:** Using exceptions for control flow (like `try-catch` around `firstWhere`) inside UI interaction paths like drag-and-drop operations causes significant FPS drops in Flutter due to stack trace generation.
**Action:** Always replace `firstWhere` inside `try/catch` blocks with `for` loops or `indexWhere` (especially avoiding double iterations like `.any()` followed by `.firstWhere()`).

## 2026-09-20 - [O(log N) Binary Search for Sorted Data Lookups]
**Learning:** In continuous playback loops like audio automation, linear iteration (O(N)) to find points on a timeline causes frame drops as point count grows. Since `AutomationLane` points are strictly sorted by time, they are perfect candidates for binary search.
**Action:** Use O(log N) binary search instead of `for` loops when querying bounded values in time-sorted collections to maintain constant playback performance regardless of automation density.

## 2026-09-26 - [Reduce GC pressure by removing intermediate lists]
**Learning:** In Dart/Flutter, using spread operators, `.where().toList()`, or `.expand()` inside frequently accessed getters (like `_allActiveClips`) or loops (like in `updateTotalDuration`) causes massive GC pressure and frame drops during rapid UI callbacks or continuous playback polling.
**Action:** Iterate sequentially using manual `for` loops and cache getter results in local variables to avoid massive temporary array allocations when computing frequently polled states.
## 2023-10-28 - [State Equality to prevent unnecessary rebuilds]
**Learning:** In Flutter/Dart, continuous UI jank occurs if ViewModel states don't properly override `operator ==` and `hashCode`, especially when a new state is emitted continuously (like during audio playback `.copyWith()` cycles). If equality falls back to referential identity, unchanged data will still trigger full widget rebuilds via `notifyListeners()`.
**Action:** Always verify that State classes (like `TimelineState`, `DawState`) implement `operator ==` and `hashCode` with deep property checks so that equality statements like `newState != _state` correctly identify redundant updates and drop them.
