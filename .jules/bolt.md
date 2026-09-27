## 2023-10-27 - [Replacing try-catch with indexWhere for performance]
**Learning:** Using exceptions for control flow (like `try-catch` around `firstWhere`) inside UI interaction paths like drag-and-drop operations causes significant FPS drops in Flutter due to stack trace generation.
**Action:** Always replace `firstWhere` inside `try/catch` blocks with `for` loops or `indexWhere` (especially avoiding double iterations like `.any()` followed by `.firstWhere()`).

## 2026-09-20 - [O(log N) Binary Search for Sorted Data Lookups]
**Learning:** In continuous playback loops like audio automation, linear iteration (O(N)) to find points on a timeline causes frame drops as point count grows. Since `AutomationLane` points are strictly sorted by time, they are perfect candidates for binary search.
**Action:** Use O(log N) binary search instead of `for` loops when querying bounded values in time-sorted collections to maintain constant playback performance regardless of automation density.

## 2026-09-26 - [Reduce GC pressure by removing intermediate lists]
**Learning:** In Dart/Flutter, using spread operators, `.where().toList()`, or `.expand()` inside frequently accessed getters (like `_allActiveClips`) or loops (like in `updateTotalDuration`) causes massive GC pressure and frame drops during rapid UI callbacks or continuous playback polling.
**Action:** Iterate sequentially using manual `for` loops and cache getter results in local variables to avoid massive temporary array allocations when computing frequently polled states.

## 2026-10-27 - [Preventing continuous jank during UI playback tick updates]
**Learning:** During timeline playback tick updates, state objects are continuously recreated via `copyWith`. However, without overriding `operator ==` and `hashCode`, Flutter will default to referential identity checks for state objects which will ALWAYS cause a state update and widget rebuild, even when actual property values haven't changed.
**Action:** When creating ViewModels managing frequent tick states, override `operator ==` and `hashCode` in data models. This ensures `newState != _state` validates identity correctly, limiting `notifyListeners()` only to when data actually updates.
