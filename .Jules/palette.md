## 2026-08-30 - Added Accessibility Semantics and Tooltips
**Learning:** Flutter accessibility relies heavily on the `Semantics` widget. Custom buttons, especially those built directly with `GestureDetector`, are ignored by screen readers by default.
**Action:** Wrap custom interactive elements built using `GestureDetector` in a `Semantics(button: true)` widget. Provide `label` and `hint` parameters for screen readers. Furthermore, ensure icon-only standard Flutter widgets, like `IconButton`, have a `tooltip` property for visual hints on hover/long press and basic screen reader support.
