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
## 2024-11-21 - Added Accessibility Semantics and Tooltips to Track Controls and Navigation
**Learning:** Verified the necessity of propagating `tooltip` properties into custom button builders like `_buildControlButton` across track widgets to ensure dynamically updated accessibility labels (e.g., 'Mute' vs 'Unmute'). Also, discovered that custom navigation toggles built with raw `GestureDetector` widgets are completely opaque to screen readers unless wrapped with `Semantics(button: true)`.
**Action:** When implementing or refactoring custom UI builder functions for interactive elements, require and explicitly pass standard accessibility parameters like `tooltip`. Always wrap bare `GestureDetector` or `InkWell` components with appropriate `Semantics` descriptors, particularly `button: true` and a descriptive `label`.
## 2026-09-22 - Timeline Interaction Accessibility
**Learning:** Found that custom drag handles and interaction areas built directly with `GestureDetector` (like timeline trim handles and the main track background) were completely opaque to screen readers, preventing visually impaired users from interacting with or understanding the timeline.
**Action:** When implementing custom interactive elements or drag handles using `GestureDetector`, ensure they are wrapped in a `Semantics` widget with appropriate properties (e.g., `button: true`) and a descriptive `label` to guarantee screen reader accessibility.
## 2026-09-25 - Custom Interactive Widgets need Semantics
**Learning:** Custom interactive widgets built directly with `GestureDetector` (like the audio clip boxes in Timeline Editor) do not inherently convey their interactivity to screen readers, unlike native Flutter buttons.
**Action:** Always wrap custom `GestureDetector` UI components that act as buttons or interactive regions in a `Semantics(button: true)` widget with a descriptive `label`.
