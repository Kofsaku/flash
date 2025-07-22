import '../models/user.dart';
import '../models/level.dart';
import '../data/junior_high_1_data.dart';
import '../data/junior_high_2_data.dart';
import '../data/junior_high_3_data.dart';
import '../data/high_school_1_data.dart';
import '../data/high_school_2_data.dart';
import '../data/high_school_3_data.dart';
import '../data/university_toeic_data.dart';
import '../data/practical_english_data.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  User? _currentUser;
  List<Level> _levels = [];

  User? get currentUser => _currentUser;
  List<Level> get levels => _levels;

  /// 現在のユーザーを設定（FirebaseAuth連携用）
  void setCurrentUser(User? user) {
    _currentUser = user;
    if (user != null) {
      print('💾 MockDataService: ユーザー設定完了 ${user.email}');
    } else {
      print('💾 MockDataService: ユーザークリア完了');
    }
  }

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeLevels();
  }

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Create a complete default profile for existing users
    final defaultProfile = Profile(
      ageGroup: '30代',
      occupation: '会社員',
      englishLevel: '中級',
      hobbies: ['映画・ドラマ', '読書'],
      industry: 'IT・テクノロジー',
      lifestyle: ['計画的', 'アクティブ'],
      learningGoal: 'ビジネス英語',
      studyTime: ['15分'],
      targetStudyMinutes: '15',
      challenges: ['語彙力不足', 'スピーキング'],
      region: '関東',
      familyStructure: '夫婦',
      englishUsageScenarios: ['職場', 'オンライン'],
      interestingTopics: ['ビジネス', 'テクノロジー'],
      learningStyles: ['視覚的学習', '反復学習'],
      skillLevels: {
        'リスニング': '中級',
        'スピーキング': '初中級',
        'リーディング': '中級',
        'ライティング': '初中級',
      },
      studyEnvironments: ['自宅', '通勤中'],
      weakAreas: ['語彙', '発音'],
      motivationDetail: 'キャリアアップのためにビジネス英語を習得したい',
    );

    _currentUser = User(
      id: 'user_001',
      email: email,
      name: 'テストユーザー',
      isAuthenticated: true,
      profile: defaultProfile,
    );

    return _currentUser!;
  }

  Future<User> register(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User(
      id: 'user_002',
      email: email,
      name: name,
      isAuthenticated: true,
      profile: null, // Explicitly set profile to null
    );

    return _currentUser!;
  }

  Future<void> updateUserInfo(String name, String email) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name, email: email);
    } else {
      throw Exception('No current user to update');
    }
  }

  Future<void> saveProfile(Profile profile) async {
    await Future.delayed(const Duration(seconds: 1));

    print('💾 MockDataService: プロファイル保存開始');
    print('💾 現在のユーザー: ${_currentUser?.email}');
    print('💾 保存するプロファイル: isCompleted=${profile.isCompleted}');

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(profile: profile);
      print('💾 プロファイル保存完了: ${_currentUser!.profile?.isCompleted}');

      // ローカルストレージに保存（シミュレート）
      await _saveToLocalStorage();
    } else {
      print('💾 エラー: 現在のユーザーが見つかりません');
      throw Exception('No current user to save profile');
    }
  }

  Future<void> _saveToLocalStorage() async {
    // 実際のアプリでは SharedPreferences や SQLite を使用
    // ここではシミュレートのみ
    print('💾 ローカルストレージに保存中...');
    await Future.delayed(const Duration(milliseconds: 100));
    print('💾 ローカルストレージ保存完了');
  }

  Future<void> loadProfileFromStorage() async {
    print('💾 ローカルストレージからプロファイル読み込み開始');
    await Future.delayed(const Duration(milliseconds: 500));

    // 実際のアプリでは保存されたデータを読み込む
    // 既存ユーザーの場合、プロファイルが存在する可能性がある
    if (_currentUser?.profile?.isCompleted == true) {
      print('💾 完了済みプロファイルを発見: ${_currentUser!.email}');
      print('💾 プロファイル詳細: ${_currentUser!.profile!.englishLevel}');
    } else {
      print('💾 完了済みプロファイルが見つかりません - 新規ユーザーまたは未完了');

      // 既存ユーザーの場合はデフォルトの完了済みプロファイルを設定
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          profile: Profile(
            englishLevel: 'intermediate',
            learningGoal: 'conversation',
            isCompleted: true,
          ),
        );
        print('💾 既存ユーザーのためのデフォルトプロファイルを設定');
      }
    }
  }

  Future<void> updateDailyGoal(int dailyGoal) async {
    await Future.delayed(const Duration(milliseconds: 500));

    print('📊 ========== MOCK DATA SERVICE UPDATE ==========');
    print('📊 Input dailyGoal = $dailyGoal');
    print('📊 _currentUser?.dailyGoal (before) = ${_currentUser?.dailyGoal}');
    
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(dailyGoal: dailyGoal);
      print('📊 _currentUser?.dailyGoal (after) = ${_currentUser?.dailyGoal}');
    } else {
      print('📊 ERROR: No current user to update daily goal');
      throw Exception('No current user to update daily goal');
    }
    
    print('📊 =======================================');
  }

  Future<List<Level>> getLevels() async {
    print('MockDataService: Getting all levels for home screen');
    await Future.delayed(const Duration(milliseconds: 300));

    // パーソナライズ例文を考慮した例文数に更新
    if (_currentUser?.profile != null) {
      List<Level> updatedLevels = [];
      for (Level level in _levels) {
        List<Category> updatedCategories =
            level.categories.map((category) {
              return category;
            }).toList();

        int totalExamples = updatedCategories.fold(
          0,
          (sum, cat) => sum + cat.totalExamples,
        );
        int completedExamples = updatedCategories.fold(
          0,
          (sum, cat) => sum + cat.completedExamples,
        );

        Level updatedLevel = level.copyWith(
          categories: updatedCategories,
          totalExamples: totalExamples,
          completedExamples: completedExamples,
        );
        updatedLevels.add(updatedLevel);
      }

      print('MockDataService: Updated all levels with personalized counts');
      return updatedLevels;
    }

    return _levels;
  }

  Future<Level?> getLevel(String levelId) async {
    print('MockDataService: Getting level $levelId');
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      Level originalLevel = _levels.firstWhere((level) => level.id == levelId);
      print(
        'MockDataService: Found level ${originalLevel.name} with ${originalLevel.categories.length} categories',
      );

      // パーソナライズ例文を考慮した例文数に更新（実際の例文は取得しない）
      if (_currentUser?.profile != null) {
        List<Category> updatedCategories =
            originalLevel.categories.map((category) {
              // 各カテゴリーに+3例文（パーソナライズ例文の想定数）
              return category;
            }).toList();

        int totalExamples = updatedCategories.fold(
          0,
          (sum, cat) => sum + cat.totalExamples,
        );
        int completedExamples = updatedCategories.fold(
          0,
          (sum, cat) => sum + cat.completedExamples,
        );

        print('MockDataService: Level updated with personalized counts');

        return originalLevel.copyWith(
          categories: updatedCategories,
          totalExamples: totalExamples,
          completedExamples: completedExamples,
        );
      }

      return originalLevel;
    } catch (e) {
      print('MockDataService: Error getting level $levelId: $e');
      return null;
    }
  }


  Future<Category> getCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    for (final level in _levels) {
      for (final category in level.categories) {
        if (category.id == categoryId) {
          return category;
        }
      }
    }

    throw Exception('Category not found');
  }

  Future<List<Example>> getExamples(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 全てのユーザーに同じ基本例文を返す
    return await getBaseExamples(categoryId);
  }


  /// 基本例文を取得
  Future<List<Example>> getBaseExamples(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final category = await getCategory(categoryId);
    return category.examples;
  }

  Future<void> updateExampleCompletion(
    String exampleId,
    bool isCompleted,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));

    for (int i = 0; i < _levels.length; i++) {
      for (int j = 0; j < _levels[i].categories.length; j++) {
        for (int k = 0; k < _levels[i].categories[j].examples.length; k++) {
          if (_levels[i].categories[j].examples[k].id == exampleId) {
            _levels[i].categories[j].examples[k] = _levels[i]
                .categories[j]
                .examples[k]
                .copyWith(
                  isCompleted: isCompleted,
                  completedAt: isCompleted ? DateTime.now() : null,
                );
            return;
          }
        }
      }
    }
  }

  Future<void> toggleFavorite(String exampleId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    for (int i = 0; i < _levels.length; i++) {
      for (int j = 0; j < _levels[i].categories.length; j++) {
        for (int k = 0; k < _levels[i].categories[j].examples.length; k++) {
          if (_levels[i].categories[j].examples[k].id == exampleId) {
            _levels[i].categories[j].examples[k] = _levels[i]
                .categories[j]
                .examples[k]
                .copyWith(
                  isFavorite: !_levels[i].categories[j].examples[k].isFavorite,
                );
            return;
          }
        }
      }
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  void _initializeLevels() {
    _levels = [
      getJuniorHigh1Level(),
      getJuniorHigh2Level(),
      getJuniorHigh3Level(),
      getHighSchool1Level(),
      getHighSchool2Level(),
      getHighSchool3Level(),
      getUniversityToeicLevel(),
      getPracticalEnglishLevel(),
    ];
    
    // Sort levels by order to ensure correct display
    _levels.sort((a, b) => a.order.compareTo(b.order));
  }


  List<String> get ageGroups => ['10代学生', '20代社会人', '30代社会人', '40代以上'];

  List<String> get occupations => ['学生', '会社員', '公務員', '自営業', '主婦/主夫', 'その他'];

  List<String> get englishLevels => [
    '初心者（1年未満）',
    '初級（1-3年）',
    '中級（3-5年）',
    '上級（5年以上）',
  ];

  List<String> get hobbies => [
    '映画・ドラマ鑑賞',
    '音楽・ライブ',
    '読書',
    'ゲーム',
    'スポーツ観戦',
    '料理・グルメ',
    '旅行・観光',
    'アウトドア',
    '写真撮影',
    'アニメ・マンガ',
  ];

  List<String> get industries => [
    'IT・エンジニア',
    '営業・販売',
    'マーケティング',
    '医療・介護',
    '教育',
    '金融・保険',
    '製造業',
    'サービス業',
    '公務員',
    'その他',
  ];

  List<String> get lifestyles => [
    '健康・フィットネス',
    '美容・ファッション',
    '家族・育児',
    'ペット',
    '投資・副業',
    '自己啓発',
    '環境・エコ',
  ];

  List<String> get learningGoals => [
    '日常会話ができるようになりたい',
    '仕事で英語を使いたい',
    '海外旅行で困らないレベル',
    'TOEIC・英検のスコアアップ',
    '留学・ワーホリ準備',
    '洋画・洋楽を字幕なしで楽しみたい',
  ];

  List<String> get studyTimes => [
    '朝（6-9時）',
    '通勤・通学時間',
    '昼休み',
    '夕方（17-19時）',
    '夜（19-22時）',
    '深夜（22時以降）',
    '休日の午前',
    '休日の午後',
  ];

  List<String> get targetStudyMinutes => ['5-10分', '10-20分', '20-30分', '30分以上'];

  List<String> get challenges => ['時間がない', 'モチベーション維持', '内容が退屈', '効果が実感できない'];

  List<String> get regions => [
    '北海道',
    '東北',
    '関東',
    '中部',
    '関西',
    '中国',
    '四国',
    '九州',
    '沖縄',
  ];

  List<String> get familyStructures => [
    '一人暮らし',
    '夫婦',
    '子供あり（未就学児）',
    '子供あり（小中学生）',
    '子供あり（高校生以上）',
    '親と同居',
    'その他',
  ];

  List<String> get englishUsageScenarios => [
    '海外出張・会議',
    '外国人観光客対応',
    'オンライン会議',
    '英語資料の読み書き',
    '趣味での国際交流',
    '特になし',
  ];
}
