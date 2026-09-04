## 2024-11-20 - Adding Accessibility Tooltips to IconButtons
**Learning:** Found several icon-only buttons across the app lacking tooltips, which makes the UI difficult to navigate for screen reader users and those relying on mouse hover for context.
**Action:** When adding new `IconButton`s, ensure they always have a descriptive `tooltip` attribute. For stateful icons (e.g., Play/Pause), ensure the tooltip text updates dynamically based on the current state.
