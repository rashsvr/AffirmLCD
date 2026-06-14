class Affirmation {
  const Affirmation({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Affirmation copyWith({String? text, DateTime? updatedAt}) {
    return Affirmation(
      id: id,
      text: text ?? this.text,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Affirmation? fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final text = json['text'];
    final createdAt = DateTime.tryParse('${json['createdAt']}');
    final updatedAt = DateTime.tryParse('${json['updatedAt']}');

    if (id is! String ||
        text is! String ||
        createdAt == null ||
        updatedAt == null) {
      return null;
    }

    return Affirmation(
      id: id,
      text: text,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
