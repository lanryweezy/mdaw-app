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
## 2026-11-12 - [Reduce GC pressure by removing chained intermediate lists via where.toList]
**Learning:** In Dart/Flutter, using `.where().toList()` creates intermediate lazy iterables which resolve into lists, putting extra GC pressure on paths that update frequently, like during continuous UI polling.
**Action:** Replace `.where().toList()` with sequential `for` loops appending to a List when optimizing frequently called accessors (like automation lanes) to decrease GC allocations.
## 2026-11-13 - [Reduce GC pressure by removing chained map().toList() in Flutter builds]
**Learning:** In Flutter, UI `build` methods can be called frequently (up to 60 times per second during animations or continuous playback updates). Using `.map(...).toList()` inside these build methods creates unnecessary Garbage Collection (GC) pressure because `.map()` allocates a lazy iterable that is immediately forced into a concrete list by `.toList()`.
**Action:** Replace `.map(...).toList()` patterns in Flutter `build` methods with Dart's native list comprehensions `[ for (final item in list) build(item) ]`. The Dart compiler optimizes list comprehensions directly, avoiding the allocation of intermediate lazy iterables and reducing overall GC overhead during frequent UI repaints.
## 2024-06-25 - Avoid .map().toList() in Widget Builds
**Learning:** Chained `.map(...).toList()` operations inside `build` methods allocate an intermediate lazy iterable that is immediately forced into a concrete list, generating unnecessary Garbage Collection (GC) pressure during frequent UI repaints.
**Action:** Use Dart's native list comprehensions (e.g., `[ for (final item in list) build(item) ]`) which are directly optimized by the compiler and avoid intermediate iterable allocation.
## 2026-10-17 - [Hoist Math Operations out of Processing Loops]
**Learning:** In audio processing loops (like  methods in ), evaluating redundant and computationally expensive math functions like  for every single audio sample causes significant CPU overhead, especially since these loops execute thousands of times per second (e.g., 44,100 times for 1 second of audio at 44.1kHz).
**Action:** Always identify variables that depend strictly on constants (or properties that don't change per-sample) and hoist their calculations outside the main processing  loop to optimize sample-by-sample processing.
## 2024-05-15 - [Hoist Math Operations out of Processing Loops]
**Learning:** In audio processing loops (like `process` methods in `lib/models/audio_effects.dart`), evaluating redundant and computationally expensive math functions like `pow(10, x / 20)` for every single audio sample causes significant CPU overhead, especially since these loops execute thousands of times per second (e.g., 44,100 times for 1 second of audio at 44.1kHz).
**Action:** Always identify variables that depend strictly on constants (or properties that don't change per-sample) and hoist their calculations outside the main processing `for` loop to optimize sample-by-sample processing.
## 2024-10-25 - [Avoid Map Lookups in Audio Processing Loops]
**Learning:** In highly repetitive loops like audio sample processing (e.g., `for (int i = 0; i < input.length; i++)` handling 44,100 samples per second), performing map lookups (e.g., `parameters['key']!.value`) inside the loop introduces significant, unnecessary overhead per sample.
**Action:** Always fetch configuration or parameter values from maps outside the main processing loop and store them in local variables. Use these local variables inside the loop to ensure optimal sample-by-sample performance.
## 2024-11-20 - [Unroll Inner Loops in Audio DSP Functions]
**Learning:** In highly repetitive audio processing methods like `AudioEffect.process()` processing arrays of audio data, fixed-length nested loops (such as evaluating predefined reverb delays) introduce unnecessary loop overhead, branching, and redundant constant math calculations per sample.
**Action:** Unroll fixed-length nested loops inside audio processing buffers to replace them with manual `if` evaluations and pre-calculated constants. This avoids repeated math logic per frame and removes looping overhead inside sample buffers.

## 2026-11-20 - [Reduce GC pressure by iterating directory streams sequentially]
**Learning:** In Dart/Flutter, chaining `.list().toList()` and `.where(...).toList()` on asynchronous directory streams allocates unnecessary intermediate lists, putting extra GC pressure.
**Action:** Replace these chains with a manual `await for` loop over `Directory.list()` to process and filter elements sequentially, eliminating intermediate iterable allocations.
