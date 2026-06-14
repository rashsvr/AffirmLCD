# AffirmLCD WidgetKit Extension

This folder contains the native iOS WidgetKit implementation for the home
screen widget.

This folder is wired into `ios/Runner.xcodeproj` as a real WidgetKit extension
target named `AffirmLCDWidget`.

Xcode configuration:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Confirm the `AffirmLCDWidget` target exists.
3. Confirm its bundle identifier is
   `com.rashsvr.affirmlcd.AffirmLCDWidget`.
4. Confirm the extension target's `Info.plist` is
   `AffirmationWidget/Info.plist`.
5. Confirm the extension target's entitlements are
   `AffirmationWidget/AffirmationWidget.entitlements`.
6. Confirm Runner has an `Embed App Extensions` build phase that embeds
   `AffirmLCDWidget.appex` into `PlugIns`.
7. Enable App Groups for both Runner and AffirmLCDWidget:
   `group.com.rashsvr.affirmlcd`.

The Flutter app writes the current affirmation to the same App Group through
the `home_widget` package. The WidgetKit timeline reads the key
`affirmation_text` from `UserDefaults(suiteName: "group.com.rashsvr.affirmlcd")`.

Supported widget families in `AffirmationWidget.swift`:

- `.systemSmall`
- `.systemMedium`
- `.systemLarge`

Tapping the widget opens `affirmlcd://affirmation`. The Flutter app's first
screen is the affirmation list, so widget taps land directly on the editable
list.

iOS does not allow widgets to refresh every time the screen turns on. This
widget refreshes when the Flutter app saves data and asks WidgetKit to reload,
and through WidgetKit's timeline policy when iOS allows it.
