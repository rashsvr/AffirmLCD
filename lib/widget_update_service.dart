import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import 'affirmation.dart';
import 'affirmation_service.dart';
import 'affirmation_store.dart';

class WidgetUpdateService {
  WidgetUpdateService({AffirmationService? affirmationService})
    : _affirmationService = affirmationService ?? AffirmationService();

  final AffirmationService _affirmationService;

  static const appGroupId = 'group.com.rashsvr.affirmlcd';
  static const affirmationKey = 'affirmation_text';
  static const affirmationListKey = 'affirmation_list';
  static const updatedAtKey = 'affirmation_updated_at';
  static const androidProviderName =
      'com.rashsvr.affirmlcd.AffirmationWidgetProvider';
  static const iosWidgetKind = 'AffirmLCDWidget';

  Future<void> initialize() async {
    if (!kIsWeb && Platform.isIOS) {
      await HomeWidget.setAppGroupId(appGroupId);
    }
  }

  Future<Affirmation?> generateSaveAndUpdate({
    required AffirmationStore store,
    String? currentId,
  }) async {
    final affirmations = await store.loadAll();
    final affirmation = _affirmationService.nextFrom(
      affirmations,
      currentId: currentId,
    );

    if (affirmation == null) {
      await saveAffirmationList(const []);
      await saveAndUpdate(AffirmationService.emptyListText);
      return null;
    }

    await store.setCurrentId(affirmation.id);
    await saveAffirmationList(affirmations);
    await saveAffirmationAndUpdate(affirmation);
    return affirmation;
  }

  Future<void> saveAffirmationAndUpdate(Affirmation affirmation) {
    return saveAndUpdate(affirmation.text);
  }

  Future<void> saveAffirmationList(List<Affirmation> affirmations) async {
    try {
      final texts = affirmations
          .map((affirmation) => affirmation.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      await HomeWidget.saveWidgetData<String>(
        affirmationListKey,
        jsonEncode(texts),
      );
    } on PlatformException catch (exception) {
      debugPrint('Could not save widget affirmation list: $exception');
    }
  }

  Future<void> saveAndUpdate(String affirmation) async {
    await _save(affirmation);
    await updateWidgets();
  }

  Future<String> loadAffirmation() async {
    try {
      return await HomeWidget.getWidgetData<String>(
            affirmationKey,
            defaultValue: AffirmationService.defaultAffirmation,
          ) ??
          AffirmationService.defaultAffirmation;
    } on PlatformException catch (exception) {
      debugPrint('Could not load widget affirmation: $exception');
      return AffirmationService.defaultAffirmation;
    }
  }

  Future<void> updateWidgets() async {
    try {
      await HomeWidget.updateWidget(
        qualifiedAndroidName: androidProviderName,
        iOSName: iosWidgetKind,
      );
    } on PlatformException catch (exception) {
      debugPrint('Could not update home widget: $exception');
    }
  }

  Future<void> _save(String affirmation) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>(affirmationKey, affirmation),
        HomeWidget.saveWidgetData<String>(
          updatedAtKey,
          DateTime.now().toIso8601String(),
        ),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Could not save widget affirmation: $exception');
    }
  }
}
