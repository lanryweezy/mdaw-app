## 2023-10-27 - [Replacing try-catch with indexWhere for performance]
**Learning:** Using exceptions for control flow (like `try-catch` around `firstWhere`) inside UI interaction paths like drag-and-drop operations causes significant FPS drops in Flutter due to stack trace generation.
**Action:** Always replace `firstWhere` inside `try/catch` blocks with `for` loops or `indexWhere` (especially avoiding double iterations like `.any()` followed by `.firstWhere()`).

## 2024-05-24 - [Optimize AutomationLane value lookup]
**Learning:** During continuous playback, repeatedly interpolating automation values meant iterating through points O(N) over and over. Since automation points are strictly sorted by time, looking up bounded points is perfectly suited for binary search O(log N).
**Action:** When a continuous tick/update loop is iterating through sorted values to find a bounding box, replace O(N) linear iteration with O(log N) binary search for improved performance during playback.
