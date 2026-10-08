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

## 2026-10-03 - [O(1) equality fast-path and hashing for large collections]
**Learning:** In Dart/Flutter, using `Object.hashAll()` or unconditionally iterating element-by-element in `operator ==` for classes with large collections (like audio waveforms or track clips) causes severe CPU overhead and UI jank during frequent state updates (like audio playback UI refreshes). Often, immutable collections or collections re-used across `.copyWith()` updates retain the same reference.
**Action:** When overriding `operator ==` and `hashCode` in Dart models, always check `identical(collection, other.collection)` first to skip O(N) iteration when references match. For `hashCode`, avoid `Object.hashAll()` on large collections and instead hash the collection's length (e.g., `clips.length`) to avoid O(N) operations while preserving the strict `A == B => A.hashCode == B.hashCode` contract.

## 2023-11-06 - [Reduce GC pressure by removing chained intermediate lists via expand]
**Learning:** In Dart/Flutter, chained iterative list methods like `.where().expand().toList()` create massive GC pressure because `.where()` returns an iterable, `.expand()` iterates and flattens creating another lazy iterable, and finally `.toList()` instantiates the concrete list. This causes multiple internal allocations for temporary iterables before resolving to a List, severely impacting performance during heavy data manipulation paths.
**Action:** Replace chained `.where().expand().toList()` or similar functional chains with manual nested `for` loops that `.add()` elements sequentially to a pre-allocated or dynamically sized list. This single-pass iteration eliminates all intermediate iterable allocations and reduces GC spikes.
