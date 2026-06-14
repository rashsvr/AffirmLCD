# Widget Design Contract

The Flutter preview, Android RemoteViews widget, and iOS WidgetKit view should
stay visually aligned.

- Background: dark app shell with an LCD panel.
- LCD color: `#B8C6A2`.
- Primary text: `#162113`.
- Muted label: `#53624B`.
- Font: platform monospace / monospaced design.
- Label: current local time in `HH:mm`.
- Suffix emoji: `☀`.
- Shape: 10px/dp/pt radius, no custom outer border, no shadow in the widget
  surface, no image assets, no gradients.
- Long text: center aligned, max lines, ellipsis or minimum scale.
- Fallback text:
  - Empty list: `✨ Add your first affirmation`
  - Missing/loading: `📟 Your next thought is loading…`

iOS cannot refresh on every screen wake. Android may receive some system
broadcasts inconsistently depending on OS and launcher, so reliable updates are
app-triggered, widget tap opening the app, and platform scheduled refresh.
