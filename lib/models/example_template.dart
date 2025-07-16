class ExampleTemplate {
  final String id;
  final String baseJapanese;
  final String baseEnglish;
  final String categoryId;
  final List<String> grammarFocus;
  final Map<String, Map<String, Map<String, dynamic>>> variables;
  final String difficultyLevel;

  const ExampleTemplate({
    required this.id,
    required this.baseJapanese,
    required this.baseEnglish,
    required this.categoryId,
    required this.grammarFocus,
    required this.variables,
    this.difficultyLevel = 'intermediate',
  });

  ExampleTemplate copyWith({
    String? id,
    String? baseJapanese,
    String? baseEnglish,
    String? categoryId,
    List<String>? grammarFocus,
    Map<String, Map<String, Map<String, dynamic>>>? variables,
    String? difficultyLevel,
  }) {
    return ExampleTemplate(
      id: id ?? this.id,
      baseJapanese: baseJapanese ?? this.baseJapanese,
      baseEnglish: baseEnglish ?? this.baseEnglish,
      categoryId: categoryId ?? this.categoryId,
      grammarFocus: grammarFocus ?? this.grammarFocus,
      variables: variables ?? this.variables,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baseJapanese': baseJapanese,
      'baseEnglish': baseEnglish,
      'categoryId': categoryId,
      'grammarFocus': grammarFocus,
      'variables': variables,
      'difficultyLevel': difficultyLevel,
    };
  }

  factory ExampleTemplate.fromJson(Map<String, dynamic> json) {
    return ExampleTemplate(
      id: json['id'],
      baseJapanese: json['baseJapanese'],
      baseEnglish: json['baseEnglish'],
      categoryId: json['categoryId'],
      grammarFocus: List<String>.from(json['grammarFocus'] ?? []),
      variables: Map<String, Map<String, Map<String, dynamic>>>.from(
        json['variables']?.map(
              (key, value) => MapEntry(
                key,
                Map<String, Map<String, dynamic>>.from(
                  value?.map(
                        (k, v) =>
                            MapEntry(k, Map<String, dynamic>.from(v ?? {})),
                      ) ??
                      {},
                ),
              ),
            ) ??
            {},
      ),
      difficultyLevel: json['difficultyLevel'] ?? 'intermediate',
    );
  }
}

class PersonalizedExample {
  final String id;
  final String japanese;
  final String english;
  final String categoryId;
  final String levelId;
  final String templateId;
  final Map<String, String> appliedVariables;
  final bool isPersonalized;
  final int order;

  PersonalizedExample({
    required this.id,
    required this.japanese,
    required this.english,
    required this.categoryId,
    required this.levelId,
    required this.templateId,
    required this.appliedVariables,
    this.isPersonalized = true,
    required this.order,
  });

  PersonalizedExample copyWith({
    String? id,
    String? japanese,
    String? english,
    String? categoryId,
    String? levelId,
    String? templateId,
    Map<String, String>? appliedVariables,
    bool? isPersonalized,
    int? order,
  }) {
    return PersonalizedExample(
      id: id ?? this.id,
      japanese: japanese ?? this.japanese,
      english: english ?? this.english,
      categoryId: categoryId ?? this.categoryId,
      levelId: levelId ?? this.levelId,
      templateId: templateId ?? this.templateId,
      appliedVariables: appliedVariables ?? this.appliedVariables,
      isPersonalized: isPersonalized ?? this.isPersonalized,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'japanese': japanese,
      'english': english,
      'categoryId': categoryId,
      'levelId': levelId,
      'templateId': templateId,
      'appliedVariables': appliedVariables,
      'isPersonalized': isPersonalized,
      'order': order,
    };
  }

  factory PersonalizedExample.fromJson(Map<String, dynamic> json) {
    return PersonalizedExample(
      id: json['id'],
      japanese: json['japanese'],
      english: json['english'],
      categoryId: json['categoryId'],
      levelId: json['levelId'],
      templateId: json['templateId'],
      appliedVariables: Map<String, String>.from(
        json['appliedVariables'] ?? {},
      ),
      isPersonalized: json['isPersonalized'] ?? true,
      order: json['order'],
    );
  }
}
