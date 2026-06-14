import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:affirmlcd/affirmation_store.dart';
import 'package:affirmlcd/main.dart';
import 'package:affirmlcd/widget_preview.dart';
import 'package:affirmlcd/widget_update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const homeWidgetChannel = MethodChannel('home_widget');
  const homeWidgetUpdatesChannel = MethodChannel('home_widget/updates');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidgetChannel, (call) async {
          switch (call.method) {
            case 'getWidgetData':
              return 'today is yours :)';
            case 'saveWidgetData':
            case 'updateWidget':
            case 'setAppGroupId':
              return true;
            case 'initiallyLaunchedFromHomeWidget':
              return null;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidgetUpdatesChannel, (call) async {
          if (call.method == 'listen' || call.method == 'cancel') {
            return null;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidgetChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidgetUpdatesChannel, null);
  });

  testWidgets('shows and refreshes an LCD affirmation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AffirmationApp(
        store: AffirmationStore(),
        widgetService: WidgetUpdateService(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WidgetPreview), findsOneWidget);
    expect(find.text('Affirmations'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(find.byType(WidgetPreview), findsOneWidget);
  });
}
