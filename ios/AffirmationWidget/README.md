# Affirmation WidgetKit Extension

This folder contains the native iOS WidgetKit implementation for the home
screen widget.

Manual Xcode setup still required:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Add a new target: `File > New > Target > Widget Extension`.
3. Name the target `AffirmationWidget`.
4. Use bundle identifier `com.rashsvr.mobilewidget.AffirmationWidget`.
5. Replace the generated Swift file with `AffirmationWidget.swift` from this
   folder, or add this folder's files to the extension target.
6. Set the extension target's `Info.plist` to `AffirmationWidget/Info.plist`.
7. Set the extension target's entitlements to
   `AffirmationWidget/AffirmationWidget.entitlements`.
8. Enable App Groups for both Runner and AffirmationWidget:
   `group.com.rashsvr.mobilewidget`.

The Flutter app writes the current affirmation to the same App Group through
the `home_widget` package. The WidgetKit timeline reads the key
`affirmation_text` from `UserDefaults(suiteName: "group.com.rashsvr.mobilewidget")`.

Supported widget families in `AffirmationWidget.swift`:

- `.systemSmall`
- `.systemMedium`
- `.systemLarge`

Tapping the widget opens `mobilewidget://affirmation`. The Flutter app's first
screen is the affirmation list, so widget taps land directly on the editable
list.

iOS does not allow widgets to refresh every time the screen turns on. This
widget refreshes when the Flutter app saves data and asks WidgetKit to reload,
and through WidgetKit's timeline policy when iOS allows it.
