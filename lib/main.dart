import 'package:flutter/material.dart';

import 'affirmation_list_screen.dart';
import 'affirmation_store.dart';
import 'widget_design.dart';
import 'widget_update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AffirmationStore();
  final widgetService = WidgetUpdateService();
  await widgetService.initialize();
  runApp(AffirmationApp(store: store, widgetService: widgetService));
}

class AffirmationApp extends StatelessWidget {
  const AffirmationApp({
    super.key,
    required this.store,
    required this.widgetService,
  });

  final AffirmationStore store;
  final WidgetUpdateService widgetService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Widget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: WidgetDesign.appBackground,
        cardColor: WidgetDesign.lcdBackground,
        colorScheme: const ColorScheme.dark(
          primary: WidgetDesign.lcdBackground,
          onPrimary: WidgetDesign.textPrimary,
          secondary: Color(0xffa8c47f),
          onSecondary: WidgetDesign.textPrimary,
          surface: WidgetDesign.appSurface,
          onSurface: WidgetDesign.appText,
          error: Color(0xffffb4ab),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: WidgetDesign.appBackground,
          foregroundColor: WidgetDesign.appText,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: WidgetDesign.lcdBackground,
          foregroundColor: WidgetDesign.textPrimary,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: WidgetDesign.lcdBackground,
          titleTextStyle: const TextStyle(
            color: WidgetDesign.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
          contentTextStyle: const TextStyle(color: WidgetDesign.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xffe8f5d2),
          labelStyle: TextStyle(color: WidgetDesign.textMuted),
          hintStyle: TextStyle(color: WidgetDesign.textMuted),
          counterStyle: TextStyle(color: WidgetDesign.textMuted),
          errorStyle: TextStyle(
            color: Color(0xff7a140d),
            fontWeight: FontWeight.w700,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: WidgetDesign.textPrimary, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: WidgetDesign.textMuted),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff7a140d), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff7a140d), width: 1.5),
          ),
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: AffirmationListScreen(store: store, widgetService: widgetService),
    );
  }
}
