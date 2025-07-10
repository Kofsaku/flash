class User {
  final String id;
  final String email;
  final String name;
  final bool isAuthenticated;
  final Profile? profile;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.isAuthenticated = false,
    this.profile,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? isAuthenticated,
    Profile? profile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isAuthenticated': isAuthenticated,
      'profile': profile?.toJson(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      isAuthenticated: json['isAuthenticated'] ?? false,
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
    );
  }
}

class Profile {
  // Step 1: 基本情報
  final String? ageGroup;
  final String? occupation;
  final String? englishLevel;
  
  // Step 2: 興味・関心
  final List<String> hobbies;
  final String? industry;
  final List<String> lifestyle;
  
  // Step 3: 学習環境・目標
  final String? learningGoal;
  final List<String> studyTime;
  final String? targetStudyMinutes;
  final List<String> challenges;
  
  // Step 4: 個人的背景
  final String? region;
  final String? familyStructure;
  final List<String> englishUsageScenarios;
  final List<String> interestingTopics;

  Profile({
    this.ageGroup,
    this.occupation,
    this.englishLevel,
    this.hobbies = const [],
    this.industry,
    this.lifestyle = const [],
    this.learningGoal,
    this.studyTime = const [],
    this.targetStudyMinutes,
    this.challenges = const [],
    this.region,
    this.familyStructure,
    this.englishUsageScenarios = const [],
    this.interestingTopics = const [],
  });

  Profile copyWith({
    String? ageGroup,
    String? occupation,
    String? englishLevel,
    List<String>? hobbies,
    String? industry,
    List<String>? lifestyle,
    String? learningGoal,
    List<String>? studyTime,
    String? targetStudyMinutes,
    List<String>? challenges,
    String? region,
    String? familyStructure,
    List<String>? englishUsageScenarios,
    List<String>? interestingTopics,
  }) {
    return Profile(
      ageGroup: ageGroup ?? this.ageGroup,
      occupation: occupation ?? this.occupation,
      englishLevel: englishLevel ?? this.englishLevel,
      hobbies: hobbies ?? this.hobbies,
      industry: industry ?? this.industry,
      lifestyle: lifestyle ?? this.lifestyle,
      learningGoal: learningGoal ?? this.learningGoal,
      studyTime: studyTime ?? this.studyTime,
      targetStudyMinutes: targetStudyMinutes ?? this.targetStudyMinutes,
      challenges: challenges ?? this.challenges,
      region: region ?? this.region,
      familyStructure: familyStructure ?? this.familyStructure,
      englishUsageScenarios: englishUsageScenarios ?? this.englishUsageScenarios,
      interestingTopics: interestingTopics ?? this.interestingTopics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ageGroup': ageGroup,
      'occupation': occupation,
      'englishLevel': englishLevel,
      'hobbies': hobbies,
      'industry': industry,
      'lifestyle': lifestyle,
      'learningGoal': learningGoal,
      'studyTime': studyTime,
      'targetStudyMinutes': targetStudyMinutes,
      'challenges': challenges,
      'region': region,
      'familyStructure': familyStructure,
      'englishUsageScenarios': englishUsageScenarios,
      'interestingTopics': interestingTopics,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      ageGroup: json['ageGroup'],
      occupation: json['occupation'],
      englishLevel: json['englishLevel'],
      hobbies: List<String>.from(json['hobbies'] ?? []),
      industry: json['industry'],
      lifestyle: List<String>.from(json['lifestyle'] ?? []),
      learningGoal: json['learningGoal'],
      studyTime: List<String>.from(json['studyTime'] ?? []),
      targetStudyMinutes: json['targetStudyMinutes'],
      challenges: List<String>.from(json['challenges'] ?? []),
      region: json['region'],
      familyStructure: json['familyStructure'],
      englishUsageScenarios: List<String>.from(json['englishUsageScenarios'] ?? []),
      interestingTopics: List<String>.from(json['interestingTopics'] ?? []),
    );
  }
}