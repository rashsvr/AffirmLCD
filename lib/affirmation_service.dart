import 'dart:math';

import 'affirmation.dart';

class AffirmationService {
  AffirmationService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const emptyListText = '✨ Add your first affirmation';
  static const loadingText = '📟 Your next thought is loading…';
  static const defaultAffirmation = loadingText;

  static const defaultAffirmations = [
    '✨ I am becoming her.',
    '🌙 Soft life, strong mind.',
    '📟 One calm thought at a time.',
    '🖤 I choose peace over pressure.',
    '🌱 Small steps still count.',
    '🪞 I am allowed to grow slowly.',
    '☁️ My energy is precious.',
    '🧠 I trust my future self.',
    '🕯️ I can begin again.',
    '🤍 My peace is the priority.',
    '🌷 I grow in quiet ways.',
    '🫧 I release what feels heavy.',
    '🪐 My timing is still sacred.',
    '🧺 I keep what feels gentle.',
    '💌 I am safe to change.',
    '🌦️ Softer days are coming.',
  ];

  Affirmation? nextFrom(List<Affirmation> affirmations, {String? currentId}) {
    if (affirmations.isEmpty) return null;

    var next = affirmations[_random.nextInt(affirmations.length)];
    if (affirmations.length > 1) {
      while (next.id == currentId) {
        next = affirmations[_random.nextInt(affirmations.length)];
      }
    }
    return next;
  }
}
