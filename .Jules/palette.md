## 2024-05-13 - Add Tooltips for Timeline Controls
**Learning:** Found multiple icon-only `IconButton` and `ToggleButtons` widgets on the timeline control bar without descriptive `tooltip` labels, degrading accessibility for screen readers and new users trying to discover the icons' meaning.
**Action:** Always wrap `Icon` components in `Tooltip` when used in multi-selection controls like `ToggleButtons`, and verify standard `IconButton` components have their `tooltip` property correctly initialized, especially for critical features like mute, solo, and tools.
## 2026-08-30 - Added Accessibility Semantics and Tooltips
**Learning:** Flutter accessibility relies heavily on the `Semantics` widget. Custom buttons, especially those built directly with `GestureDetector`, are ignored by screen readers by default.
**Action:** Wrap custom interactive elements built using `GestureDetector` in a `Semantics(button: true)` widget. Provide `label` and `hint` parameters for screen readers. Furthermore, ensure icon-only standard Flutter widgets, like `IconButton`, have a `tooltip` property for visual hints on hover/long press and basic screen reader support.
