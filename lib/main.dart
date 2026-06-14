import 'package:flutter/material.dart';


import 'affirmation_list_screen.dart';
import 'affirmation_store.dart';
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
        scaffoldBackgroundColor: const Color(0xff10140f),
        cardColor: const Color(0xfff1f4e6),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xffb8c6a2),
          onPrimary: Color(0xff162113),
          secondary: Color(0xffd4dfbd),
          surface: Color(0xff182016),
          onSurface: Color(0xfff1f4e6),
          error: Color(0xffffb4ab),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff10140f),
          foregroundColor: Color(0xfff1f4e6),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xffb8c6a2),
          foregroundColor: Color(0xff162113),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xfff1f4e6),
          titleTextStyle: const TextStyle(
            color: Color(0xff162113),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
          contentTextStyle: const TextStyle(color: Color(0xff162113)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xffdfe7ce),
          labelStyle: TextStyle(color: Color(0xff53624b)),
          hintStyle: TextStyle(color: Color(0xff53624b)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff53624b)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffb8c6a2)),
          ),
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: AffirmationListScreen(store: store, widgetService: widgetService),
    );
  }
}
