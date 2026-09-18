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
## 2024-11-20 - Ensure Tooltip property on inner IconButton widgets in custom builders
**Learning:** Even when custom UI builders like `_buildTransportButton` or `_buildControlButton` provide a `Tooltip` wrapper around `IconButton`, failing to pass the `tooltip` property natively to the inner `IconButton` drops critical semantic accessibility cues for screen readers and avoids standard hover visual interactions for mouse users.
**Action:** Always ensure that icon-only `IconButton` instances, even nested inside custom functions, have their intrinsic `tooltip` argument set, either explicitly via a `tooltip` parameter or reusing an equivalent `label` variable.
