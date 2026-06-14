import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'affirmation.dart';
import 'affirmation_service.dart';

class AffirmationStore {
  AffirmationStore();

  static const _affirmationsKey = 'affirmations';
  static const _currentAffirmationIdKey = 'current_affirmation_id';
  static const _seededKey = 'affirmations_seeded';

  SharedPreferences? _preferences;

  bool get isReady => _preferences != null;

  Future<void> initialize() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      await _seedDefaultsIfNeeded();
    } catch (error) {
      _preferences = null;
      debugPrint('Could not initialize affirmation storage: $error');
      throw const AffirmationStoreException(
        'Local storage is not ready. Please reopen the app.',
      );
    }
  }

  Future<List<Affirmation>> loadAll() async {
    try {
      final preferences = _requirePreferences();
      final raw = preferences.getString(_affirmationsKey);
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('Stored affirmations are not a list.');
      }

      return decoded
          .whereType<Map>()
          .map((item) => Affirmation.fromJson(Map<String, Object?>.from(item)))
          .whereType<Affirmation>()
          .where((item) => item.text.trim().isNotEmpty)
          .toList();
    } catch (error) {
      debugPrint('Could not load affirmations: $error');
      throw const AffirmationStoreException(
        'Local storage is not ready. Please reopen the app.',
      );
    }
  }

  Future<Affirmation> add(String text) async {
    final cleaned = _clean(text);
    final now = DateTime.now();
    final affirmation = Affirmation(
      id: now.microsecondsSinceEpoch.toString(),
      text: cleaned,
      createdAt: now,
      updatedAt: now,
    );
    final items = await loadAll();
    await _saveAll([affirmation, ...items]);
    await setCurrentId(affirmation.id);
    return affirmation;
  }

  Future<Affirmation?> update(String id, String text) async {
    final cleaned = _clean(text);
    final items = await loadAll();
    Affirmation? updated;
    final next = [
      for (final item in items)
        if (item.id == id)
          updated = item.copyWith(text: cleaned, updatedAt: DateTime.now())
        else
          item,
    ];
    await _saveAll(next);
    return updated;
  }

  Future<void> delete(String id) async {
    final items = await loadAll();
    await _saveAll(items.where((item) => item.id != id).toList());
    if (await currentId() == id) {
      final preferences = _requirePreferences();
      await preferences.remove(_currentAffirmationIdKey);
    }
  }

  Future<String?> currentId() async {
    final preferences = _requirePreferences();
    return preferences.getString(_currentAffirmationIdKey);
  }

  Future<void> setCurrentId(String id) async {
    final preferences = _requirePreferences();
    await preferences.setString(_currentAffirmationIdKey, id);
  }

  Future<Affirmation?> currentAffirmation() async {
    final id = await currentId();
    final items = await loadAll();
    if (id == null) return items.firstOrNull;
    return items.where((item) => item.id == id).firstOrNull ??
        items.firstOrNull;
  }

  Future<void> _saveAll(List<Affirmation> items) async {
    final preferences = _requirePreferences();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    final saved = await preferences.setString(_affirmationsKey, encoded);
    if (!saved) {
      throw const AffirmationStoreException(
        'Local storage is not ready. Please reopen the app.',
      );
    }
  }

  Future<void> _seedDefaultsIfNeeded() async {
    final preferences = _requirePreferences();
    final seeded = preferences.getBool(_seededKey) ?? false;
    if (seeded) return;

    final raw = preferences.getString(_affirmationsKey);
    if (raw != null && raw.isNotEmpty) {
      await preferences.setBool(_seededKey, true);
      return;
    }

    await _saveAll(_seedAffirmations());
    await preferences.setBool(_seededKey, true);
  }

  List<Affirmation> _seedAffirmations() {
    final now = DateTime.now();
    return [
      for (var i = 0; i < AffirmationService.defaultAffirmations.length; i++)
        Affirmation(
          id: '${now.microsecondsSinceEpoch}-$i',
          text: AffirmationService.defaultAffirmations[i],
          createdAt: now,
          updatedAt: now,
        ),
    ];
  }

  static String _clean(String text) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) {
      return AffirmationService.emptyListText;
    }
    return cleaned.length > 180
        ? cleaned.substring(0, 180).trimRight()
        : cleaned;
  }

  SharedPreferences _requirePreferences() {
    final preferences = _preferences;
    if (preferences == null) {
      throw const AffirmationStoreException(
        'Local storage is not ready. Please reopen the app.',
      );
    }
    return preferences;
  }
}

class AffirmationStoreException implements Exception {
  const AffirmationStoreException(this.message);

  final String message;

  @override
  String toString() => message;
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
