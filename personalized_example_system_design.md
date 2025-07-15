# パーソナライズド例文システム設計仕様書（ローカル実装版）

## 概要

このドキュメントは、Flash Composition Appにおけるユーザープロファイルベースの例文パーソナライゼーションシステムの設計仕様です。既存の530例文を保持しつつ、ユーザープロファイルに応じたパーソナライズ例文を追加で表示し、各ユーザーに最適化された学習体験を提供します。

## 目標

- **既存例文保持**: 現在の530例文は基本例文として全ユーザーに表示
- **パーソナライズ例文追加**: ユーザープロファイルに基づく追加例文を動的生成
- **ローカル実装**: アプリ内でのテンプレートベース例文管理システム
- **学習効果向上**: 個人に関連性の高い文脈での追加学習機会

## 現在のシステム分析

### レベル・カテゴリー構造
| レベル | カテゴリー数 | 例文数 | 説明 |
|--------|-------------|--------|------|
| 中学レベル | 13 | 130 | 基礎文法・語彙 |
| 高校1年 | 10 | 100 | 初級文法 |
| 高校2年 | 10 | 100 | 中級文法 |
| 高校3年 | 10 | 100 | 上級文法 |
| 大学受験・TOEIC | 5 | 50 | 試験対策 |
| 実用英語 | 5 | 50 | 日常・ビジネス |
| **合計** | **53** | **530** | |

### 主要カテゴリー詳細

#### 文法カテゴリー（480例文）
- **基礎文法**: be動詞、一般動詞、時制、疑問詞、代名詞
- **応用文法**: 関係代名詞、仮定法、受動態、分詞構文、複文構造
- **表現系**: 感情表現、推量表現、義務表現、願望表現

#### 実用カテゴリー（50例文）
- **ビジネス**: プレゼンテーション、ディスカッション、メール
- **日常**: 日常会話、旅行、電話対応

## ローカル実装戦略

### 基本方針
1. **既存例文の保持**: 現在の530例文は基本例文として維持
2. **パーソナライズ例文の追加**: ユーザープロファイルに基づく追加例文をローカル生成
3. **混合表示**: 基本例文 + パーソナライズ例文を自然に混合して表示
4. **段階的実装**: 既存システムへの影響を最小限に抑えた実装

### システム構成
```
例文表示 = 基本例文（530例文）+ パーソナライズ例文（プロファイル依存）
```

## パーソナライゼーション戦略

### 1. プロファイル要素マッピング

#### A. レベル決定要素
```
englishLevel + skillLevels → 基本表示カテゴリー
- 初級: 中学レベル重視（60%）+ 高校1年（30%）+ 実用英語（10%）
- 中級: 高校1-2年重視（50%）+ 高校3年（30%）+ 実用英語（20%）
- 上級: 高校3年（40%）+ 実用英語（40%）+ 全般（20%）
```

#### B. コンテンツ重み付け要素

**職業・業界マッピング**
```
occupation + industry → 例文テンプレート選択
- 会社員 + IT: ビジネス系テンプレート重視 +40%
- 学生: 学習・友人関係テンプレート重視 +35%
- 医療従事者: 専門職・ケア系テンプレート重視 +30%
- 主婦・主夫: 日常生活・家族系テンプレート重視 +35%
```

**学習目標マッピング**
```
learningGoal → カテゴリー優先度
- ビジネス英語: 実用英語カテゴリー +50%
- 日常会話: 日常会話・旅行カテゴリー +45%
- 試験対策: 文法カテゴリー全般 +30%
- 旅行: 旅行英語・基本会話 +60%
```

**使用シナリオマッピング**
```
englishUsageScenarios → 文脈設定
- 職場: フォーマルな表現中心
- 日常生活: カジュアルな表現含む
- 旅行: 実用的な場面設定
- オンライン: 現代的な表現・SNS風
```

### 2. ローカルテンプレートベース例文生成システム

#### A. ローカルデータ構造
```dart
class PersonalizationTemplateService {
  static const Map<String, ExampleTemplate> templates = {
    'worry_emotion': ExampleTemplate(
      id: 'worry_emotion',
      baseJapanese: '私は{target}が心配です。',
      baseEnglish: 'I am worried about the {target}.',
      categoryId: 'emotions',
      grammarFocus: ['present_tense', 'emotions'],
      variables: {
        'target': {
          'occupation': {
            '会社員': ['会議', 'プロジェクト', '締切', 'プレゼン'],
            '学生': ['試験', '課題', '発表', '成績'],
            '医師': ['患者', '手術', '診断', '治療'],
            '主婦': ['子供', '家計', '家事', '健康']
          },
          'hobby': {
            '映画・ドラマ': ['新作映画', 'ドラマの結末', '俳優', 'レビュー'],
            'スポーツ': ['試合結果', 'トレーニング', 'チーム', 'コーチ']
          }
        }
      }
    ),
    
    'daily_activity': ExampleTemplate(
      id: 'daily_activity', 
      baseJapanese: '私は毎日{activity}をします。',
      baseEnglish: 'I {activity} every day.',
      categoryId: 'daily_life',
      grammarFocus: ['present_tense', 'habits'],
      variables: {
        'activity': {
          'occupation': {
            '会社員': ['会議に参加', 'メールを確認', '資料を作成'],
            '学生': ['勉強', '講義に出席', '友人と話す'],
            '主婦': ['料理', '掃除', '子供と遊ぶ']
          }
        }
      }
    )
  };
}

#### B. ローカル例文生成エンジン
```dart
class LocalPersonalizationEngine {
  // 既存例文 + パーソナライズ例文を混合して返す
  List<Example> generateMixedExamples(
    String categoryId, 
    Profile? profile
  ) {
    // 1. 既存の基本例文を取得
    List<Example> baseExamples = MockDataService().getBaseExamples(categoryId);
    
    // 2. プロファイルが無い場合は基本例文のみ返す
    if (profile == null) return baseExamples;
    
    // 3. パーソナライズ例文を生成
    List<Example> personalizedExamples = _generatePersonalizedExamples(
      categoryId, profile
    );
    
    // 4. 基本例文とパーソナライズ例文を混合
    return _mixExamples(baseExamples, personalizedExamples);
  }
  
  List<Example> _generatePersonalizedExamples(
    String categoryId, 
    Profile profile
  ) {
    List<Example> examples = [];
    
    // カテゴリーに関連するテンプレートを取得
    List<ExampleTemplate> relevantTemplates = 
        PersonalizationTemplateService.getTemplatesForCategory(categoryId);
    
    for (ExampleTemplate template in relevantTemplates) {
      // プロファイルに基づいて変数を選択
      Map<String, String> variables = _selectVariables(template, profile);
      
      // テンプレートに変数を適用して例文生成
      Example personalizedExample = _applyTemplate(template, variables);
      examples.add(personalizedExample);
    }
    
    return examples;
  }
  
  Map<String, String> _selectVariables(
    ExampleTemplate template, 
    Profile profile
  ) {
    Map<String, String> selectedVariables = {};
    
    // 職業ベース選択
    if (profile.occupation != null && 
        template.variables.containsKey('occupation')) {
      var occupationVars = template.variables['occupation'][profile.occupation];
      if (occupationVars != null && occupationVars.isNotEmpty) {
        selectedVariables['target'] = occupationVars.first;
      }
    }
    
    // 趣味ベース選択
    if (profile.hobbies.isNotEmpty && 
        template.variables.containsKey('hobby')) {
      for (String hobby in profile.hobbies) {
        var hobbyVars = template.variables['hobby'][hobby];
        if (hobbyVars != null && hobbyVars.isNotEmpty) {
          selectedVariables['target'] = hobbyVars.first;
          break;
        }
      }
    }
    
    return selectedVariables;
  }
  
  List<Example> _mixExamples(
    List<Example> baseExamples, 
    List<Example> personalizedExamples
  ) {
    List<Example> mixed = [...baseExamples];
    
    // パーソナライズ例文を基本例文の間に挿入
    int insertPosition = (baseExamples.length / 3).round();
    for (int i = 0; i < personalizedExamples.length; i++) {
      mixed.insert(
        insertPosition + (i * 2), 
        personalizedExamples[i]
      );
    }
    
    return mixed;
  }
}
```

## ローカル実装での例文設計

### 1. 例文構成

#### A. 基本例文（既存維持）
```
現在の530例文をそのまま維持:
- 中学レベル: 130例文
- 高校1年: 100例文  
- 高校2年: 100例文
- 高校3年: 100例文
- 大学受験・TOEIC: 50例文
- 実用英語: 50例文

→ 全ユーザーに表示される基本例文
```

#### B. パーソナライズ例文（動的生成）
```
テンプレートベースで生成（カテゴリーあたり2-5例文追加）:
- 職業ベース例文: プロファイルの職業に応じて生成
- 趣味ベース例文: プロファイルの趣味に応じて生成  
- 家族構成ベース例文: プロファイルの家族構成に応じて生成
- 地域ベース例文: プロファイルの地域に応じて生成

→ ユーザーのプロファイルに応じて基本例文に追加表示
```

#### C. 表示例文総数（ユーザーによって変動）
```
表示例文数 = 基本例文530 + パーソナライズ例文（50-150例文）
- プロファイル未設定: 530例文（基本例文のみ）
- プロファイル部分設定: 580-650例文
- プロファイル完全設定: 680-780例文

→ 最大約1.5倍の例文で学習可能
```

### 2. 具体的な例文テンプレート例

#### A. 基本感情表現の拡張
```
基本テンプレート: "私は{対象}が心配です。"
英語テンプレート: "I am worried about the {対象}."

パーソナライズ変数:
職業別:
- 会社員: "meeting", "project", "deadline", "presentation"
- 学生: "exam", "assignment", "grade", "graduation"  
- 医師: "patient", "surgery", "diagnosis", "treatment"
- 主婦: "children", "family", "household", "budget"

実例:
- 会社員: "私は明日の会議が心配です。" → "I am worried about tomorrow's meeting."
- 学生: "私は試験の結果が心配です。" → "I am worried about the exam results."
- 医師: "私は患者の容態が心配です。" → "I am worried about the patient's condition."
```

#### B. 日常行動表現の拡張
```
基本テンプレート: "私は毎日{活動}をします。"
英語テンプレート: "I {活動} every day."

パーソナライズ変数:
趣味別:
- 映画好き: "watch movies", "read reviews", "discuss films"
- スポーツ好き: "exercise", "train", "play sports"
- 料理好き: "cook", "try recipes", "visit restaurants"

家族構成別:
- 独身: "work late", "meet friends", "pursue hobbies"
- 夫婦: "discuss plans", "share meals", "watch TV together"
- 子供有り: "help with homework", "read bedtime stories", "play games"

実例:
- 映画好き独身: "私は毎日映画を見ます。" → "I watch movies every day."
- 子供有り: "私は毎日子供と遊びます。" → "I play with my children every day."
```

#### C. 未来計画表現の拡張
```
基本テンプレート: "私は{時期}に{計画}するつもりです。"
英語テンプレート: "I am going to {計画} {時期}."

パーソナライズ変数:
学習目標別:
- ビジネス英語: "attend a meeting", "give a presentation", "negotiate a deal"
- 旅行: "visit Tokyo", "try local food", "take photos"
- 日常会話: "talk to neighbors", "make friends", "join a club"

地域別:
- 関東: "visit Tokyo Tower", "go to Shibuya", "see Mt. Fuji"
- 関西: "visit Osaka Castle", "try takoyaki", "go to Kyoto"

実例:
- ビジネス+関東: "私は来月東京で会議に参加するつもりです。" 
  → "I am going to attend a meeting in Tokyo next month."
```

### 3. 文法フォーカス別テンプレート

#### A. 時制練習テンプレート
```
現在形テンプレート群:
1. "私は{職業活動}をしています。" → "I am {職業活動}."
2. "彼は{趣味活動}が好きです。" → "He likes {趣味活動}."
3. "{家族}は{特徴}です。" → "My {家族} is {特徴}."

過去形テンプレート群:
1. "昨日{過去活動}をしました。" → "I {過去活動} yesterday."
2. "先週{イベント}がありました。" → "There was {イベント} last week."
3. "{期間}前に{体験}をしました。" → "I {体験} {期間} ago."

未来形テンプレート群:
1. "明日{予定}をします。" → "I will {予定} tomorrow."
2. "来年{目標}をする予定です。" → "I am planning to {目標} next year."
3. "{条件}なら{結果}をします。" → "If {条件}, I will {結果}."
```

#### B. 疑問文練習テンプレート
```
What疑問文:
- 職業: "あなたの仕事は何ですか？" → "What is your job?"
- 趣味: "あなたの趣味は何ですか？" → "What is your hobby?"
- 計画: "今日は何をしますか？" → "What will you do today?"

Where疑問文:
- 職場: "どこで働いていますか？" → "Where do you work?"
- 住居: "どこに住んでいますか？" → "Where do you live?"
- 出身: "どこの出身ですか？" → "Where are you from?"

How疑問文:
- 方法: "どうやって{活動}しますか？" → "How do you {活動}?"
- 頻度: "どのくらい{習慣}しますか？" → "How often do you {習慣}?"
- 感想: "{対象}はどうでしたか？" → "How was the {対象}?"
```

## ローカル実装フェーズ

### Phase 1: ローカルエンジン構築
1. **パーソナライゼーションエンジン実装**
   - `LocalPersonalizationEngine`クラス作成
   - `PersonalizationTemplateService`クラス作成
   - `ExampleTemplate`モデル作成

2. **既存システム統合**
   - `MockDataService`への統合
   - 例文混合ロジック実装
   - プロファイル連携機能

### Phase 2: テンプレート作成
1. **基本テンプレート作成（50-80テンプレート）**
   - 主要文法カテゴリー用テンプレート
   - 職業・趣味・家族構成変数定義
   - 英語翻訳とバリデーション

2. **カテゴリー別テンプレート配布**
   - 各カテゴリーに2-5個のテンプレート配置
   - プロファイル要素との適切なマッピング
   - 表示順序の最適化

### Phase 3: 統合テストと調整
1. **既存機能との互換性確保**
   - 既存例文表示の動作確認
   - パーソナライズ例文の自然な混合
   - パフォーマンス影響の最小化

2. **多様なプロファイルでのテスト**
   - 異なる職業・趣味・家族構成でのテスト
   - 例文生成品質の確認
   - エラーハンドリングの実装

### Phase 4: 段階的リリース
1. **フィーチャーフラグでの制御**
   - パーソナライゼーション機能のON/OFF切り替え
   - 段階的ユーザー展開
   - 問題発生時の即座ロールバック

2. **継続的改善**
   - ユーザー利用データの分析
   - 新テンプレートの追加
   - 変数辞書の拡充

## 期待効果

### 学習効果の向上
- **関連性**: 個人に関連する文脈での学習により記憶定着率向上
- **モチベーション**: 自分の生活に密着した例文による学習意欲向上
- **実用性**: 実際の使用場面を想定した実践的な英語力育成

### システム効率の向上
- **ローカル処理**: オフライン完全対応による高速動作
- **実装シンプル性**: 既存システムへの最小限の影響
- **保守性**: アプリ内完結による保守の容易さ
- **デバッグ容易性**: ローカルでの完全制御とデバッグ

### ビジネス価値の向上
- **ユーザー満足度**: パーソナライズされた学習体験による満足度向上
- **継続率**: 関連性の高いコンテンツによる学習継続率向上
- **差別化**: 競合サービスとの明確な差別化要素
- **開発効率**: Firebase設定不要による開発スピード向上

## ローカル実装の技術的メリット

### 1. 既存システムとの互換性
- 現在の`MockDataService`をベースとした拡張
- 既存例文の完全保持
- 段階的実装による安全性

### 2. パフォーマンス
- ネットワーク通信不要
- 即座の例文表示
- オフライン完全対応

### 3. 開発・運用の簡素化
- 外部サービス依存なし
- シンプルなデバッグ環境
- 予測可能な動作

## まとめ

このローカル実装によるパーソナライズド例文システムにより、Flash Composition Appは既存の530例文を保持しながら、各ユーザーに最適化された追加例文を提供します。Firebase統合の複雑さを避けつつ、実用的で効果的なパーソナライゼーション機能を実現し、より継続しやすい英語学習環境を提供します。

最大の特徴は、**基本例文の確実性** + **パーソナライズ例文の関連性** の両方を兼ね備えることで、全ユーザーに質の高い学習体験を保証しながら、個人に最適化された学習機会を追加提供する点です。