class Level {
  final String id;
  final String name;
  final String description;
  final int order;
  final List<Category> categories;
  final int totalExamples;
  final int completedExamples;

  Level({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    this.categories = const [],
    this.totalExamples = 0,
    this.completedExamples = 0,
  });

  double get progress => totalExamples > 0 ? completedExamples / totalExamples : 0.0;

  Level copyWith({
    String? id,
    String? name,
    String? description,
    int? order,
    List<Category>? categories,
    int? totalExamples,
    int? completedExamples,
  }) {
    return Level(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      categories: categories ?? this.categories,
      totalExamples: totalExamples ?? this.totalExamples,
      completedExamples: completedExamples ?? this.completedExamples,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'order': order,
      'categories': categories.map((e) => e.toJson()).toList(),
      'totalExamples': totalExamples,
      'completedExamples': completedExamples,
    };
  }

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      order: json['order'],
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e))
          .toList() ?? [],
      totalExamples: json['totalExamples'] ?? 0,
      completedExamples: json['completedExamples'] ?? 0,
    );
  }
}

class Category {
  final String id;
  final String name;
  final String description;
  final String levelId;
  final int order;
  final List<Example> examples;
  final int totalExamples;
  final int completedExamples;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.levelId,
    required this.order,
    this.examples = const [],
    this.totalExamples = 0,
    this.completedExamples = 0,
  });

  double get progress => totalExamples > 0 ? completedExamples / totalExamples : 0.0;
  bool get isCompleted => completedExamples >= totalExamples && totalExamples > 0;

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? levelId,
    int? order,
    List<Example>? examples,
    int? totalExamples,
    int? completedExamples,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      levelId: levelId ?? this.levelId,
      order: order ?? this.order,
      examples: examples ?? this.examples,
      totalExamples: totalExamples ?? this.totalExamples,
      completedExamples: completedExamples ?? this.completedExamples,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'levelId': levelId,
      'order': order,
      'examples': examples.map((e) => e.toJson()).toList(),
      'totalExamples': totalExamples,
      'completedExamples': completedExamples,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      levelId: json['levelId'],
      order: json['order'],
      examples: (json['examples'] as List<dynamic>?)
          ?.map((e) => Example.fromJson(e))
          .toList() ?? [],
      totalExamples: json['totalExamples'] ?? 0,
      completedExamples: json['completedExamples'] ?? 0,
    );
  }
}

class Example {
  final String id;
  final String categoryId;
  final String levelId;
  final String japanese;
  final String english;
  final String? hint;
  final int order;
  final bool isCompleted;
  final bool isFavorite;
  final DateTime? completedAt;

  Example({
    required this.id,
    required this.categoryId,
    required this.levelId,
    required this.japanese,
    required this.english,
    this.hint,
    required this.order,
    this.isCompleted = false,
    this.isFavorite = false,
    this.completedAt,
  });

  Example copyWith({
    String? id,
    String? categoryId,
    String? levelId,
    String? japanese,
    String? english,
    String? hint,
    int? order,
    bool? isCompleted,
    bool? isFavorite,
    DateTime? completedAt,
  }) {
    return Example(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      levelId: levelId ?? this.levelId,
      japanese: japanese ?? this.japanese,
      english: english ?? this.english,
      hint: hint ?? this.hint,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'levelId': levelId,
      'japanese': japanese,
      'english': english,
      'hint': hint,
      'order': order,
      'isCompleted': isCompleted,
      'isFavorite': isFavorite,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      id: json['id'],
      categoryId: json['categoryId'],
      levelId: json['levelId'],
      japanese: json['japanese'],
      english: json['english'],
      hint: json['hint'],
      order: json['order'],
      isCompleted: json['isCompleted'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}