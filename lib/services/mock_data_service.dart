import '../models/user.dart';
import '../models/level.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  User? _currentUser;
  List<Level> _levels = [];

  User? get currentUser => _currentUser;
  List<Level> get levels => _levels;

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeLevels();
  }

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = User(
      id: 'user_001',
      email: email,
      name: 'テストユーザー',
      isAuthenticated: true,
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
    );
    
    return _currentUser!;
  }

  Future<void> saveProfile(Profile profile) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(profile: profile);
    }
  }

  Future<List<Level>> getLevels() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _levels;
  }

  Future<Level> getLevel(String levelId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _levels.firstWhere((level) => level.id == levelId);
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
    
    final category = await getCategory(categoryId);
    return category.examples;
  }

  Future<void> updateExampleCompletion(String exampleId, bool isCompleted) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    for (int i = 0; i < _levels.length; i++) {
      for (int j = 0; j < _levels[i].categories.length; j++) {
        for (int k = 0; k < _levels[i].categories[j].examples.length; k++) {
          if (_levels[i].categories[j].examples[k].id == exampleId) {
            _levels[i].categories[j].examples[k] = 
                _levels[i].categories[j].examples[k].copyWith(
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
            _levels[i].categories[j].examples[k] = 
                _levels[i].categories[j].examples[k].copyWith(
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
      Level(
        id: 'junior_high',
        name: '中学レベル',
        description: '基礎的な英文法と語彙',
        order: 1,
        categories: [
          Category(
            id: 'be_verb',
            name: 'be動詞',
            description: 'be動詞の基本的な使い方',
            levelId: 'junior_high',
            order: 1,
            examples: [
              Example(
                id: 'be_001',
                categoryId: 'be_verb',
                levelId: 'junior_high',
                japanese: '私は学生です。',
                english: 'I am a student.',
                order: 1,
              ),
              Example(
                id: 'be_002',
                categoryId: 'be_verb',
                levelId: 'junior_high',
                japanese: 'あなたは先生ですか？',
                english: 'Are you a teacher?',
                order: 2,
              ),
              Example(
                id: 'be_003',
                categoryId: 'be_verb',
                levelId: 'junior_high',
                japanese: '彼は医者ではありません。',
                english: 'He is not a doctor.',
                order: 3,
              ),
              Example(
                id: 'be_004',
                categoryId: 'be_verb',
                levelId: 'junior_high',
                japanese: 'この本は面白いです。',
                english: 'This book is interesting.',
                order: 4,
              ),
              Example(
                id: 'be_005',
                categoryId: 'be_verb',
                levelId: 'junior_high',
                japanese: '私たちは忙しいです。',
                english: 'We are busy.',
                order: 5,
              ),
              Example(
                id: 'be_006',
                categoryId: 'be_verb',
                levelId: 'junior_high',
                japanese: '彼らは家にいます。',
                english: 'They are at home.',
                order: 6,
              ),
              Example(
                id: 'be_007',
                categoryId: 'be_verb',
                levelId: 'junior_high',
                japanese: '今日は暑いです。',
                english: 'It is hot today.',
                order: 7,
              ),
              Example(
                id: 'be_008',
                categoryId: 'be_verb',
                levelId: 'junior_high',
                japanese: '私の名前は田中です。',
                english: 'My name is Tanaka.',
                order: 8,
              ),
              Example(
                id: 'be_009',
                categoryId: 'be_verb',
                levelId: 'junior_high',
                japanese: 'これは私のペンです。',
                english: 'This is my pen.',
                order: 9,
              ),
              Example(
                id: 'be_010',
                categoryId: 'be_verb',
                levelId: 'junior_high',
                japanese: '彼女は親切です。',
                english: 'She is kind.',
                order: 10,
              ),
            ],
            totalExamples: 10,
            completedExamples: 0,
          ),
          Category(
            id: 'general_verb',
            name: '一般動詞',
            description: '一般動詞の基本的な使い方',
            levelId: 'junior_high',
            order: 2,
            examples: [
              Example(
                id: 'gv_001',
                categoryId: 'general_verb',
                levelId: 'junior_high',
                japanese: '私は毎日英語を勉強します。',
                english: 'I study English every day.',
                order: 1,
              ),
              Example(
                id: 'gv_002',
                categoryId: 'general_verb',
                levelId: 'junior_high',
                japanese: '彼は音楽を聞きます。',
                english: 'He listens to music.',
                order: 2,
              ),
              Example(
                id: 'gv_003',
                categoryId: 'general_verb',
                levelId: 'junior_high',
                japanese: 'あなたは何を食べますか？',
                english: 'What do you eat?',
                order: 3,
              ),
              Example(
                id: 'gv_004',
                categoryId: 'general_verb',
                levelId: 'junior_high',
                japanese: '私は本を読みません。',
                english: 'I do not read books.',
                order: 4,
              ),
              Example(
                id: 'gv_005',
                categoryId: 'general_verb',
                levelId: 'junior_high',
                japanese: '彼女は料理を作ります。',
                english: 'She cooks meals.',
                order: 5,
              ),
              Example(
                id: 'gv_006',
                categoryId: 'general_verb',
                levelId: 'junior_high',
                japanese: '私たちは公園で遊びます。',
                english: 'We play in the park.',
                order: 6,
              ),
              Example(
                id: 'gv_007',
                categoryId: 'general_verb',
                levelId: 'junior_high',
                japanese: '彼は早く走ります。',
                english: 'He runs fast.',
                order: 7,
              ),
              Example(
                id: 'gv_008',
                categoryId: 'general_verb',
                levelId: 'junior_high',
                japanese: '私の母は先生として働きます。',
                english: 'My mother works as a teacher.',
                order: 8,
              ),
              Example(
                id: 'gv_009',
                categoryId: 'general_verb',
                levelId: 'junior_high',
                japanese: 'あなたは映画を見ますか？',
                english: 'Do you watch movies?',
                order: 9,
              ),
              Example(
                id: 'gv_010',
                categoryId: 'general_verb',
                levelId: 'junior_high',
                japanese: '私たちは友達と話します。',
                english: 'We talk with friends.',
                order: 10,
              ),
            ],
            totalExamples: 10,
            completedExamples: 0,
          ),
        ],
        totalExamples: 20,
        completedExamples: 0,
      ),
      Level(
        id: 'high_school_1',
        name: '高校1年',
        description: '高校初級レベルの英文法',
        order: 2,
        categories: [
          Category(
            id: 'present_perfect',
            name: '現在完了',
            description: '現在完了形の使い方',
            levelId: 'high_school_1',
            order: 1,
            examples: [
              Example(
                id: 'pp_001',
                categoryId: 'present_perfect',
                levelId: 'high_school_1',
                japanese: '私は宿題を終えました。',
                english: 'I have finished my homework.',
                order: 1,
              ),
              Example(
                id: 'pp_002',
                categoryId: 'present_perfect',
                levelId: 'high_school_1',
                japanese: 'あなたは昼食を食べましたか？',
                english: 'Have you eaten lunch?',
                order: 2,
              ),
              Example(
                id: 'pp_003',
                categoryId: 'present_perfect',
                levelId: 'high_school_1',
                japanese: '彼はまだ帰っていません。',
                english: 'He has not come back yet.',
                order: 3,
              ),
              Example(
                id: 'pp_004',
                categoryId: 'present_perfect',
                levelId: 'high_school_1',
                japanese: '私は3年間英語を勉強しています。',
                english: 'I have studied English for three years.',
                order: 4,
              ),
              Example(
                id: 'pp_005',
                categoryId: 'present_perfect',
                levelId: 'high_school_1',
                japanese: '彼女は京都に行ったことがあります。',
                english: 'She has been to Kyoto.',
                order: 5,
              ),
              Example(
                id: 'pp_006',
                categoryId: 'present_perfect',
                levelId: 'high_school_1',
                japanese: '私たちは今まで彼に会ったことがありません。',
                english: 'We have never met him.',
                order: 6,
              ),
              Example(
                id: 'pp_007',
                categoryId: 'present_perfect',
                levelId: 'high_school_1',
                japanese: '彼は2時間前からここにいます。',
                english: 'He has been here since two hours ago.',
                order: 7,
              ),
              Example(
                id: 'pp_008',
                categoryId: 'present_perfect',
                levelId: 'high_school_1',
                japanese: '私は最近忙しいです。',
                english: 'I have been busy recently.',
                order: 8,
              ),
              Example(
                id: 'pp_009',
                categoryId: 'present_perfect',
                levelId: 'high_school_1',
                japanese: 'あなたは今までにこの映画を見たことがありますか？',
                english: 'Have you ever seen this movie?',
                order: 9,
              ),
              Example(
                id: 'pp_010',
                categoryId: 'present_perfect',
                levelId: 'high_school_1',
                japanese: '彼らは既に出発しました。',
                english: 'They have already left.',
                order: 10,
              ),
            ],
            totalExamples: 10,
            completedExamples: 0,
          ),
        ],
        totalExamples: 10,
        completedExamples: 0,
      ),
      Level(
        id: 'high_school_2',
        name: '高校2年',
        description: '高校中級レベルの英文法',
        order: 3,
        categories: [
          Category(
            id: 'passive_voice',
            name: '受動態',
            description: '受動態の使い方',
            levelId: 'high_school_2',
            order: 1,
            examples: [
              Example(
                id: 'pv_001',
                categoryId: 'passive_voice',
                levelId: 'high_school_2',
                japanese: 'この本は多くの人に読まれています。',
                english: 'This book is read by many people.',
                order: 1,
              ),
              Example(
                id: 'pv_002',
                categoryId: 'passive_voice',
                levelId: 'high_school_2',
                japanese: 'その建物は去年建てられました。',
                english: 'The building was built last year.',
                order: 2,
              ),
              Example(
                id: 'pv_003',
                categoryId: 'passive_voice',
                levelId: 'high_school_2',
                japanese: '英語は世界中で話されています。',
                english: 'English is spoken all over the world.',
                order: 3,
              ),
              Example(
                id: 'pv_004',
                categoryId: 'passive_voice',
                levelId: 'high_school_2',
                japanese: '私の車は修理されています。',
                english: 'My car is being repaired.',
                order: 4,
              ),
              Example(
                id: 'pv_005',
                categoryId: 'passive_voice',
                levelId: 'high_school_2',
                japanese: 'その問題は既に解決されています。',
                english: 'The problem has already been solved.',
                order: 5,
              ),
              Example(
                id: 'pv_006',
                categoryId: 'passive_voice',
                levelId: 'high_school_2',
                japanese: '新しい病院が来年建設される予定です。',
                english: 'A new hospital will be built next year.',
                order: 6,
              ),
              Example(
                id: 'pv_007',
                categoryId: 'passive_voice',
                levelId: 'high_school_2',
                japanese: 'その手紙は彼によって書かれました。',
                english: 'The letter was written by him.',
                order: 7,
              ),
              Example(
                id: 'pv_008',
                categoryId: 'passive_voice',
                levelId: 'high_school_2',
                japanese: '私は友達に招待されました。',
                english: 'I was invited by my friend.',
                order: 8,
              ),
              Example(
                id: 'pv_009',
                categoryId: 'passive_voice',
                levelId: 'high_school_2',
                japanese: 'この曲は若い人たちに愛されています。',
                english: 'This song is loved by young people.',
                order: 9,
              ),
              Example(
                id: 'pv_010',
                categoryId: 'passive_voice',
                levelId: 'high_school_2',
                japanese: '彼の提案は承認されませんでした。',
                english: 'His proposal was not approved.',
                order: 10,
              ),
            ],
            totalExamples: 10,
            completedExamples: 0,
          ),
        ],
        totalExamples: 10,
        completedExamples: 0,
      ),
      Level(
        id: 'high_school_3',
        name: '高校3年',
        description: '高校上級レベルの英文法',
        order: 4,
        categories: [
          Category(
            id: 'relative_pronouns',
            name: '関係代名詞',
            description: '関係代名詞の使い方',
            levelId: 'high_school_3',
            order: 1,
            examples: [
              Example(
                id: 'rp_001',
                categoryId: 'relative_pronouns',
                levelId: 'high_school_3',
                japanese: '私が昨日会った人は私の友達です。',
                english: 'The person who I met yesterday is my friend.',
                order: 1,
              ),
              Example(
                id: 'rp_002',
                categoryId: 'relative_pronouns',
                levelId: 'high_school_3',
                japanese: '私が読んでいる本はとても面白いです。',
                english: 'The book which I am reading is very interesting.',
                order: 2,
              ),
              Example(
                id: 'rp_003',
                categoryId: 'relative_pronouns',
                levelId: 'high_school_3',
                japanese: '彼女は英語を上手に話す学生です。',
                english: 'She is a student who speaks English well.',
                order: 3,
              ),
              Example(
                id: 'rp_004',
                categoryId: 'relative_pronouns',
                levelId: 'high_school_3',
                japanese: '私が昨日買った車は赤いです。',
                english: 'The car that I bought yesterday is red.',
                order: 4,
              ),
              Example(
                id: 'rp_005',
                categoryId: 'relative_pronouns',
                levelId: 'high_school_3',
                japanese: '彼が住んでいる家は大きいです。',
                english: 'The house where he lives is big.',
                order: 5,
              ),
              Example(
                id: 'rp_006',
                categoryId: 'relative_pronouns',
                levelId: 'high_school_3',
                japanese: 'これは私が探していた本です。',
                english: 'This is the book which I was looking for.',
                order: 6,
              ),
              Example(
                id: 'rp_007',
                categoryId: 'relative_pronouns',
                levelId: 'high_school_3',
                japanese: '私たちが訪れた博物館は有名です。',
                english: 'The museum which we visited is famous.',
                order: 7,
              ),
              Example(
                id: 'rp_008',
                categoryId: 'relative_pronouns',
                levelId: 'high_school_3',
                japanese: '彼女は私が尊敬する先生です。',
                english: 'She is a teacher whom I respect.',
                order: 8,
              ),
              Example(
                id: 'rp_009',
                categoryId: 'relative_pronouns',
                levelId: 'high_school_3',
                japanese: '私が生まれた町は小さいです。',
                english: 'The town where I was born is small.',
                order: 9,
              ),
              Example(
                id: 'rp_010',
                categoryId: 'relative_pronouns',
                levelId: 'high_school_3',
                japanese: '彼が言ったことは正しかった。',
                english: 'What he said was correct.',
                order: 10,
              ),
            ],
            totalExamples: 10,
            completedExamples: 0,
          ),
        ],
        totalExamples: 10,
        completedExamples: 0,
      ),
    ];
  }

  List<String> get ageGroups => [
    '10代学生',
    '20代社会人',
    '30代社会人',
    '40代以上',
  ];

  List<String> get occupations => [
    '学生',
    '会社員',
    '公務員',
    '自営業',
    '主婦/主夫',
    'その他',
  ];

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

  List<String> get targetStudyMinutes => [
    '5-10分',
    '10-20分',
    '20-30分',
    '30分以上',
  ];

  List<String> get challenges => [
    '時間がない',
    'モチベーション維持',
    '内容が退屈',
    '効果が実感できない',
  ];

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