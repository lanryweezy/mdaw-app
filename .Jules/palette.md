## 2024-05-13 - Add Tooltips for Timeline Controls
**Learning:** Found multiple icon-only `IconButton` and `ToggleButtons` widgets on the timeline control bar without descriptive `tooltip` labels, degrading accessibility for screen readers and new users trying to discover the icons' meaning.
**Action:** Always wrap `Icon` components in `Tooltip` when used in multi-selection controls like `ToggleButtons`, and verify standard `IconButton` components have their `tooltip` property correctly initialized, especially for critical features like mute, solo, and tools.
## 2026-08-30 - Added Accessibility Semantics and Tooltips
**Learning:** Flutter accessibility relies heavily on the `Semantics` widget. Custom buttons, especially those built directly with `GestureDetector`, are ignored by screen readers by default.
**Action:** Wrap custom interactive elements built using `GestureDetector` in a `Semantics(button: true)` widget. Provide `label` and `hint` parameters for screen readers. Furthermore, ensure icon-only standard Flutter widgets, like `IconButton`, have a `tooltip` property for visual hints on hover/long press and basic screen reader support.
## 2024-10-27 - Missing Tooltips in MixerConsole
**Learning:** Discovered missing tooltips on `IconButton` standard elements in `MixerConsole` controls (specifically Mute and Solo), degrading screen reader accessibility and discoverability for icon-only buttons.
**Action:** When adding or reviewing `IconButton` widgets in complex, icon-heavy UI like DAW tracks or mixer components, consistently verify that the `tooltip` property is defined with dynamic state-aware text (e.g. 'Unmute' vs 'Mute').
## 2024-11-20 - Missing Tooltips in Custom Button Builders
**Learning:** Custom builder functions for UI elements (like `_buildTransportButton` in DAW screen) often forget to pass down standard accessibility properties like `tooltip` to the inner standard widgets (`IconButton`). This causes the resulting UI to be inaccessible to screen readers and lacking hover states for mouse users.
**Action:** When creating custom widget builder methods for buttons, explicitly require a `tooltip` parameter and ensure it is passed down to the underlying `IconButton` or `Tooltip` widget.
## 2025-01-22 - Semantic Wrappers for Custom Gestures
**Learning:** Flutter's custom interactive elements built with `GestureDetector` do not inherently possess accessibility roles (like buttons) or readable labels for screen readers, unlike standard buttons. Duplicate `tooltip` parameters on `IconButton` cause compilation errors.
**Action:** When implementing custom buttons or draggable handles using `GestureDetector`, always wrap them in a `Semantics` widget with `button: true` (if it's a button) and a descriptive `label`. Ensure standard widgets like `IconButton` only have a single `tooltip` property to provide a clean accessible name.
