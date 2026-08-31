## 2024-05-13 - Add Tooltips for Timeline Controls
**Learning:** Found multiple icon-only `IconButton` and `ToggleButtons` widgets on the timeline control bar without descriptive `tooltip` labels, degrading accessibility for screen readers and new users trying to discover the icons' meaning.
**Action:** Always wrap `Icon` components in `Tooltip` when used in multi-selection controls like `ToggleButtons`, and verify standard `IconButton` components have their `tooltip` property correctly initialized, especially for critical features like mute, solo, and tools.
