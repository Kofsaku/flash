import '../models/example_template.dart';

class PersonalizationTemplateService {
  static const Map<String, ExampleTemplate> _templates = {
    // 感情表現テンプレート
    'worry_emotion': ExampleTemplate(
      id: 'worry_emotion',
      baseJapanese: '私は{target}が心配です。',
      baseEnglish: 'I am worried about the {target}.',
      categoryId: 'emotions',
      grammarFocus: ['present_tense', 'emotions', 'be_worried_about'],
      variables: {
        'target': {
          'occupation': {
            '会社員': [
              ['会議', 'meeting'],
              ['プロジェクト', 'project'],
              ['締切', 'deadline'],
              ['プレゼンテーション', 'presentation'],
              ['売上', 'sales'],
            ],
            '学生': [
              ['試験', 'exam'],
              ['課題', 'assignment'],
              ['発表', 'presentation'],
              ['成績', 'grades'],
              ['就職活動', 'job hunting'],
            ],
            '医師': [
              ['患者', 'patient'],
              ['手術', 'surgery'],
              ['診断', 'diagnosis'],
              ['治療', 'treatment'],
              ['症状', 'symptoms'],
            ],
            '主婦': [
              ['子供', 'children'],
              ['家計', 'household budget'],
              ['家事', 'housework'],
              ['健康', 'health'],
              ['将来', 'future'],
            ],
            '教師': [
              ['生徒', 'students'],
              ['授業', 'class'],
              ['評価', 'evaluation'],
              ['保護者', 'parents'],
              ['教材', 'teaching materials'],
            ],
            'エンジニア': [
              ['システム', 'system'],
              ['バグ', 'bugs'],
              ['納期', 'deadline'],
              ['コード', 'code'],
              ['セキュリティ', 'security'],
            ],
          },
          'hobby': {
            '映画・ドラマ': [
              ['新作映画', 'new movie'],
              ['ドラマの結末', 'drama ending'],
              ['俳優の演技', "actor's performance"],
              ['レビュー', 'reviews'],
            ],
            'スポーツ': [
              ['試合結果', 'game results'],
              ['チームの調子', "team's condition"],
              ['トレーニング', 'training'],
              ['ケガ', 'injury'],
            ],
            '料理': [
              ['新しいレシピ', 'new recipe'],
              ['味付け', 'seasoning'],
              ['食材', 'ingredients'],
              ['料理の出来栄え', 'cooking results'],
            ],
            '読書': [
              ['本の続き', 'next part of the book'],
              ['作者の新作', "author's new work"],
              ['読書時間', 'reading time'],
              ['理解度', 'comprehension'],
            ],
            '音楽': [
              ['コンサート', 'concert'],
              ['新曲', 'new song'],
              ['演奏', 'performance'],
              ['音響', 'sound quality'],
            ],
          },
        },
      },
    ),

    'excited_emotion': ExampleTemplate(
      id: 'excited_emotion',
      baseJapanese: '私は{target}にワクワクしています。',
      baseEnglish: 'I am excited about the {target}.',
      categoryId: 'emotions',
      grammarFocus: ['present_tense', 'emotions', 'be_excited_about'],
      variables: {
        'target': {
          'occupation': {
            '会社員': [
              ['新プロジェクト', 'new project'],
              ['昇進', 'promotion'],
              ['出張', 'business trip'],
              ['新チーム', 'new team'],
            ],
            '学生': [
              ['新学期', 'new semester'],
              ['サークル活動', 'club activities'],
              ['文化祭', 'school festival'],
              ['卒業', 'graduation'],
            ],
            '医師': [
              ['新技術', 'new technology'],
              ['研修', 'training'],
              ['学会', 'conference'],
              ['新病院', 'new hospital'],
            ],
            '主婦': [
              ['家族旅行', 'family trip'],
              ['子供の成長', "children's growth"],
              ['新居', 'new home'],
              ['イベント', 'event'],
            ],
          },
          'hobby': {
            '映画・ドラマ': [
              ['新作公開', 'new movie release'],
              ['好きな俳優の映画', 'favorite actor movie'],
              ['プレミア上映', 'premiere screening'],
            ],
            'スポーツ': [
              ['大会', 'tournament'],
              ['新シーズン', 'new season'],
              ['オリンピック', 'Olympics'],
              ['地元チーム', 'local team'],
            ],
            '旅行': [
              ['次の旅行', 'next trip'],
              ['新しい場所', 'new place'],
              ['海外旅行', 'overseas trip'],
              ['温泉', 'hot spring'],
            ],
            '料理': [
              ['新レシピ', 'new recipe'],
              ['料理教室', 'cooking class'],
              ['新しい食材', 'new ingredients'],
              ['レストラン', 'restaurant'],
            ],
          },
        },
      },
    ),

    // 日常活動テンプレート
    'daily_activity': ExampleTemplate(
      id: 'daily_activity',
      baseJapanese: '私は毎日{activity}をします。',
      baseEnglish: 'I {activity} every day.',
      categoryId: 'daily_habits',
      grammarFocus: ['present_tense', 'habits', 'frequency'],
      variables: {
        'activity': {
          'occupation': {
            '会社員': [
              ['メールをチェック', 'check emails'],
              ['会議に参加', 'attend meetings'],
              ['資料を作成', 'create documents'],
              ['同僚と話す', 'talk with colleagues'],
            ],
            '学生': [
              ['勉強', 'study'],
              ['講義に出席', 'attend lectures'],
              ['友人と話す', 'talk with friends'],
              ['図書館に行く', 'go to the library'],
            ],
            '医師': [
              ['患者を診察', 'examine patients'],
              ['カルテを書く', 'write medical records'],
              ['同僚と相談', 'consult with colleagues'],
              ['医学論文を読む', 'read medical papers'],
            ],
            '主婦': [
              ['料理', 'cook'],
              ['掃除', 'clean'],
              ['子供と遊ぶ', 'play with children'],
              ['買い物に行く', 'go shopping'],
            ],
            '教師': [
              ['授業を準備', 'prepare lessons'],
              ['生徒を指導', 'teach students'],
              ['宿題をチェック', 'check homework'],
              ['保護者と連絡', 'contact parents'],
            ],
          },
          'hobby': {
            '映画・ドラマ': [
              ['映画を見る', 'watch movies'],
              ['レビューを読む', 'read reviews'],
              ['俳優について調べる', 'research actors'],
            ],
            'スポーツ': [
              ['運動', 'exercise'],
              ['スポーツニュースを見る', 'watch sports news'],
              ['トレーニング', 'train'],
            ],
            '料理': [
              ['料理', 'cook'],
              ['レシピを探す', 'search for recipes'],
              ['食材を買う', 'buy ingredients'],
            ],
            '読書': [
              ['本を読む', 'read books'],
              ['図書館に行く', 'go to the library'],
              ['読書メモを取る', 'take reading notes'],
            ],
            '音楽': [
              ['音楽を聞く', 'listen to music'],
              ['楽器を練習', 'practice instruments'],
              ['コンサート情報をチェック', 'check concert information'],
            ],
          },
        },
      },
    ),

    'weekend_plan': ExampleTemplate(
      id: 'weekend_plan',
      baseJapanese: '今度の週末は{activity}をする予定です。',
      baseEnglish: 'I am planning to {activity} this weekend.',
      categoryId: 'future_plans',
      grammarFocus: ['future_tense', 'plans', 'be_planning_to'],
      variables: {
        'activity': {
          'familyStructure': {
            '独身': ['友人と映画を見る', '一人旅をする', 'ジムに行く', '読書をする'],
            '夫婦': ['夫婦でデートする', '一緒に料理する', 'ドライブする', '映画を見る'],
            '子供有り': ['家族でお出かけする', '子供と公園に行く', '家族旅行をする', '親戚を訪問する'],
          },
          'hobby': {
            '映画・ドラマ': ['映画館に行く', '新作を見る', '映画祭に参加する'],
            'スポーツ': ['試合を見に行く', '運動する', 'ジムに行く'],
            '料理': ['新しいレストランに行く', '料理教室に参加する', '友人と料理する'],
            '旅行': ['日帰り旅行をする', '温泉に行く', '新しい街を探索する'],
          },
        },
      },
    ),

    // 過去の経験テンプレート
    'past_experience': ExampleTemplate(
      id: 'past_experience',
      baseJapanese: '昨日{activity}をしました。',
      baseEnglish: 'I {activity} yesterday.',
      categoryId: 'past_tense',
      grammarFocus: ['past_tense', 'experiences'],
      variables: {
        'activity': {
          'occupation': {
            '会社員': ['重要な会議に参加', '新しいプロジェクトを開始', 'クライアントと商談'],
            '学生': ['試験を受けた', '友人と勉強', '講義に出席'],
            '医師': ['手術を行った', '患者を診察', '研修に参加'],
            '主婦': ['子供と公園に行った', '家族と買い物', '料理を作った'],
          },
          'hobby': {
            '映画・ドラマ': ['新作映画を見た', 'ドラマを一気見', '映画レビューを書いた'],
            'スポーツ': ['試合を観戦', 'ジムで運動', 'ランニング'],
            '料理': ['新しいレシピに挑戦', 'レストランで食事', '友人と料理'],
            '旅行': ['日帰り旅行', '温泉に行った', '新しい街を訪問'],
          },
        },
      },
    ),

    // 質問文テンプレート
    'what_question': ExampleTemplate(
      id: 'what_question',
      baseJapanese: 'あなたの{target}は何ですか？',
      baseEnglish: 'What is your {target}?',
      categoryId: 'questions',
      grammarFocus: ['questions', 'what_questions', 'present_tense'],
      variables: {
        'target': {
          'general': {
            'all': ['仕事', '趣味', '目標', '夢', '専門', '計画'],
          },
          'occupation': {
            '会社員': ['部署', '職種', '担当プロジェクト', '専門分野'],
            '学生': ['専攻', '将来の目標', '好きな科目', '研究テーマ'],
            '医師': ['専門科', '研究分野', '今後の目標'],
            '主婦': ['家事のコツ', '子育ての悩み', '将来の計画'],
          },
        },
      },
    ),

    'where_question': ExampleTemplate(
      id: 'where_question',
      baseJapanese: 'どこで{activity}をしますか？',
      baseEnglish: 'Where do you {activity}?',
      categoryId: 'questions',
      grammarFocus: ['questions', 'where_questions', 'present_tense'],
      variables: {
        'activity': {
          'occupation': {
            '会社員': ['仕事', '会議', '昼食', '残業'],
            '学生': ['勉強', '講義受講', '友人と会う', 'アルバイト'],
            '医師': ['診察', '手術', '研修', '学会参加'],
            '主婦': ['買い物', '料理', '子供と遊ぶ', '家事'],
          },
          'hobby': {
            '映画・ドラマ': ['映画鑑賞', 'ドラマ視聴'],
            'スポーツ': ['運動', 'トレーニング', '試合観戦'],
            '料理': ['料理', '食材購入', '新レシピの研究'],
            '読書': ['読書', '本の購入', '読書会参加'],
          },
        },
      },
    ),

    // 比較表現テンプレート
    'comparison': ExampleTemplate(
      id: 'comparison',
      baseJapanese: '{subject1}は{subject2}より{adjective}です。',
      baseEnglish: '{subject1} is more {adjective} than {subject2}.',
      categoryId: 'comparison',
      grammarFocus: ['comparison', 'adjectives', 'more_than'],
      variables: {
        'subject1': {
          'occupation': {
            '会社員': ['この仕事', '今のプロジェクト', '新しいシステム'],
            '学生': ['この授業', '今の専攻', '新しい教科書'],
            '医師': ['この治療法', '新しい薬', '最新の技術'],
          },
        },
        'subject2': {
          'occupation': {
            '会社員': ['前の仕事', '古いプロジェクト', '旧システム'],
            '学生': ['前の授業', '他の専攻', '古い教科書'],
            '医師': ['従来の治療法', '古い薬', '従来の技術'],
          },
        },
        'adjective': {
          'general': {
            'all': ['興味深い', '難しい', '重要', '便利', '効果的'],
          },
        },
      },
    ),
  };

  static List<ExampleTemplate> getTemplatesForCategory(String categoryId) {
    return _templates.values
        .where((template) => template.categoryId == categoryId)
        .toList();
  }

  static List<ExampleTemplate> getAllTemplates() {
    return _templates.values.toList();
  }

  static ExampleTemplate? getTemplateById(String templateId) {
    return _templates[templateId];
  }

  static List<ExampleTemplate> getTemplatesForGrammar(String grammarFocus) {
    return _templates.values
        .where((template) => template.grammarFocus.contains(grammarFocus))
        .toList();
  }

  static List<String> getCategoriesWithTemplates() {
    return _templates.values
        .map((template) => template.categoryId)
        .toSet()
        .toList();
  }

  // カテゴリー名マッピング（既存のカテゴリーIDに対応）
  static const Map<String, List<String>> _categoryMapping = {
    // 中学レベル（13カテゴリー）
    'be_verb': ['emotions', 'daily_habits'],
    'general_verb': ['daily_habits', 'past_tense'],
    'past_tense': ['past_tense', 'weekend_plan'],
    'future_tense': ['future_plans', 'weekend_plan'],
    'question_words': ['questions', 'what_question', 'where_question'],
    'pronouns': ['daily_habits', 'comparison'],
    'adjectives_adverbs': ['comparison', 'emotions'],
    'prepositions': ['daily_habits', 'where_question'],
    'numbers_ordinals': ['questions', 'daily_habits'],
    'imperatives_exclamations': ['daily_habits', 'emotions'],
    'there_structure': ['questions', 'where_question'],
    'progressive_forms': ['daily_habits', 'emotions'],
    'basic_modals': ['emotions', 'future_plans'],

    // 高校1年（10カテゴリー）
    'present_perfect': ['past_tense', 'emotions'],
    'infinitive': ['future_plans', 'emotions'],
    'gerund': ['daily_habits', 'emotions'],
    'relative_pronoun': ['questions', 'comparison'],
    'participles': ['emotions', 'daily_habits'],
    'advanced_modals': ['emotions', 'future_plans'],
    'basic_conditionals': ['future_plans', 'weekend_plan'],
    'conjunctions': ['daily_habits', 'comparison'],
    'comparison_constructions': ['comparison', 'emotions'],
    'sentence_patterns': ['daily_habits', 'future_plans'],

    // 高校2年（10カテゴリー）
    'passive_voice': ['daily_habits', 'past_tense'],
    'comparative_superlative': ['comparison', 'emotions'],
    'conditional': ['future_plans', 'emotions'],
    'reported_speech': ['questions', 'daily_habits'],
    'perfect_progressive': ['daily_habits', 'emotions'],
    'participial_construction': ['daily_habits', 'past_tense'],
    'relative_adverbs': ['where_question', 'questions'],
    'appositive_that': ['daily_habits', 'emotions'],
    'indirect_questions': ['questions', 'what_question'],
    'inversion_patterns': ['emotions', 'daily_habits'],

    // 高校3年（10カテゴリー）
    'subjunctive_mood': ['future_plans', 'emotions'],
    'complex_sentences': ['daily_habits', 'comparison'],
    'inversion_emphasis': ['emotions', 'comparison'],
    'advanced_subjunctive': ['future_plans', 'emotions'],
    'emphasis_constructions': ['emotions', 'daily_habits'],
    'elliptical_constructions': ['daily_habits', 'questions'],
    'inanimate_subject': ['daily_habits', 'emotions'],
    'usage_idioms': ['daily_habits', 'past_tense'],
    'advanced_relative_pronouns': ['questions', 'comparison'],
    'compound_relatives': ['questions', 'daily_habits'],

    // 大学受験・TOEIC（5カテゴリー）
    'vocabulary_enhancement': ['daily_habits', 'comparison'],
    'complex_structures': ['daily_habits', 'emotions'],
    'basic_business': ['future_plans', 'daily_habits'],
    'current_affairs': ['questions', 'emotions'],
    'academic_english': ['comparison', 'questions'],

    // 実用英語（5カテゴリー）
    'daily_conversation': ['daily_habits', 'emotions', 'questions'],
    'travel_english': ['future_plans', 'where_question'],
    'phone_email': ['daily_habits', 'future_plans'],
    'presentation': ['future_plans', 'comparison'],
    'discussion': ['questions', 'comparison', 'emotions'],
  };

  static List<ExampleTemplate> getTemplatesForExistingCategory(
    String existingCategoryId,
  ) {
    List<String> templateCategories =
        _categoryMapping[existingCategoryId] ?? [];
    List<ExampleTemplate> templates = [];

    for (String templateCategory in templateCategories) {
      templates.addAll(getTemplatesForCategory(templateCategory));
    }

    return templates;
  }
}
