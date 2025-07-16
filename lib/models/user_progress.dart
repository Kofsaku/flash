class UserProgress {
  final String userId;
  final Map<String, ExampleProgress> exampleProgress;
  final Map<String, CategoryProgress> categoryProgress;
  final Map<String, LevelProgress> levelProgress;
  final DateTime lastUpdated;

  UserProgress({
    required this.userId,
    this.exampleProgress = const {},
    this.categoryProgress = const {},
    this.levelProgress = const {},
    required this.lastUpdated,
  });

  UserProgress copyWith({
    String? userId,
    Map<String, ExampleProgress>? exampleProgress,
    Map<String, CategoryProgress>? categoryProgress,
    Map<String, LevelProgress>? levelProgress,
    DateTime? lastUpdated,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      exampleProgress: exampleProgress ?? this.exampleProgress,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      levelProgress: levelProgress ?? this.levelProgress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'exampleProgress': exampleProgress.map((key, value) => MapEntry(key, value.toJson())),
      'categoryProgress': categoryProgress.map((key, value) => MapEntry(key, value.toJson())),
      'levelProgress': levelProgress.map((key, value) => MapEntry(key, value.toJson())),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'],
      exampleProgress: (json['exampleProgress'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, ExampleProgress.fromJson(value)),
      ) ?? {},
      categoryProgress: (json['categoryProgress'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, CategoryProgress.fromJson(value)),
      ) ?? {},
      levelProgress: (json['levelProgress'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, LevelProgress.fromJson(value)),
      ) ?? {},
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class ExampleProgress {
  final String exampleId;
  final bool isCompleted;
  final bool isFavorite;
  final DateTime? completedAt;
  final int attemptCount;

  ExampleProgress({
    required this.exampleId,
    this.isCompleted = false,
    this.isFavorite = false,
    this.completedAt,
    this.attemptCount = 0,
  });

  ExampleProgress copyWith({
    String? exampleId,
    bool? isCompleted,
    bool? isFavorite,
    DateTime? completedAt,
    int? attemptCount,
  }) {
    return ExampleProgress(
      exampleId: exampleId ?? this.exampleId,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      completedAt: completedAt ?? this.completedAt,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exampleId': exampleId,
      'isCompleted': isCompleted,
      'isFavorite': isFavorite,
      'completedAt': completedAt?.toIso8601String(),
      'attemptCount': attemptCount,
    };
  }

  factory ExampleProgress.fromJson(Map<String, dynamic> json) {
    return ExampleProgress(
      exampleId: json['exampleId'],
      isCompleted: json['isCompleted'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      attemptCount: json['attemptCount'] ?? 0,
    );
  }
}

class CategoryProgress {
  final String categoryId;
  final int completedExamples;
  final int totalExamples;
  final DateTime? lastStudiedAt;

  CategoryProgress({
    required this.categoryId,
    this.completedExamples = 0,
    required this.totalExamples,
    this.lastStudiedAt,
  });

  double get progressPercentage => 
      totalExamples > 0 ? completedExamples / totalExamples : 0.0;

  bool get isCompleted => completedExamples >= totalExamples && totalExamples > 0;

  CategoryProgress copyWith({
    String? categoryId,
    int? completedExamples,
    int? totalExamples,
    DateTime? lastStudiedAt,
  }) {
    return CategoryProgress(
      categoryId: categoryId ?? this.categoryId,
      completedExamples: completedExamples ?? this.completedExamples,
      totalExamples: totalExamples ?? this.totalExamples,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'completedExamples': completedExamples,
      'totalExamples': totalExamples,
      'lastStudiedAt': lastStudiedAt?.toIso8601String(),
    };
  }

  factory CategoryProgress.fromJson(Map<String, dynamic> json) {
    return CategoryProgress(
      categoryId: json['categoryId'],
      completedExamples: json['completedExamples'] ?? 0,
      totalExamples: json['totalExamples'] ?? 0,
      lastStudiedAt: json['lastStudiedAt'] != null
          ? DateTime.parse(json['lastStudiedAt'])
          : null,
    );
  }
}

class LevelProgress {
  final String levelId;
  final int completedExamples;
  final int totalExamples;
  final DateTime? lastStudiedAt;

  LevelProgress({
    required this.levelId,
    this.completedExamples = 0,
    required this.totalExamples,
    this.lastStudiedAt,
  });

  double get progressPercentage => 
      totalExamples > 0 ? completedExamples / totalExamples : 0.0;

  bool get isCompleted => completedExamples >= totalExamples && totalExamples > 0;

  LevelProgress copyWith({
    String? levelId,
    int? completedExamples,
    int? totalExamples,
    DateTime? lastStudiedAt,
  }) {
    return LevelProgress(
      levelId: levelId ?? this.levelId,
      completedExamples: completedExamples ?? this.completedExamples,
      totalExamples: totalExamples ?? this.totalExamples,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'completedExamples': completedExamples,
      'totalExamples': totalExamples,
      'lastStudiedAt': lastStudiedAt?.toIso8601String(),
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levelId: json['levelId'],
      completedExamples: json['completedExamples'] ?? 0,
      totalExamples: json['totalExamples'] ?? 0,
      lastStudiedAt: json['lastStudiedAt'] != null
          ? DateTime.parse(json['lastStudiedAt'])
          : null,
    );
  }
}