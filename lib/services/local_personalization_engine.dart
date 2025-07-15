import 'dart:math';
import '../models/user.dart';
import '../models/level.dart';
import '../models/example_template.dart';
import 'personalization_template_service.dart';
import 'mock_data_service.dart';

class LocalPersonalizationEngine {
  static final LocalPersonalizationEngine _instance = LocalPersonalizationEngine._internal();
  factory LocalPersonalizationEngine() => _instance;
  LocalPersonalizationEngine._internal();

  // MockDataServiceとの循環参照を避けるため、直接初期化せずに必要時に参照
  final Random _random = Random();

  /// 既存例文 + パーソナライズ例文を混合して返す
  Future<List<Example>> generateMixedExamples(
    String categoryId, 
    Profile? profile,
    List<Example> baseExamples
  ) async {
    // 1. プロファイルが無い場合は基本例文のみ返す
    if (profile == null) {
      print('LocalPersonalizationEngine: No profile provided, returning base examples only');
      return baseExamples;
    }
    
    // 2. パーソナライズ例文を生成
    List<Example> personalizedExamples = _generatePersonalizedExamples(
      categoryId, profile
    );
    
    print('LocalPersonalizationEngine: Generated ${personalizedExamples.length} personalized examples for category $categoryId');
    
    // 3. 基本例文とパーソナライズ例文を混合
    return _mixExamples(baseExamples, personalizedExamples);
  }

  /// 基本例文を取得（レベルデータから直接取得）
  Future<List<Example>> _getBaseExamples(String categoryId) async {
    try {
      // 循環参照を避けるため、レベルデータを引数で受け取る方式に変更
      return [];
    } catch (e) {
      print('LocalPersonalizationEngine: Error getting base examples: $e');
      return [];
    }
  }

  /// プロファイルに基づいてパーソナライズ例文を生成
  List<Example> _generatePersonalizedExamples(
    String categoryId, 
    Profile profile
  ) {
    List<Example> examples = [];
    
    try {
      print('LocalPersonalizationEngine: Generating for category: $categoryId');
      print('LocalPersonalizationEngine: Profile occupation: ${profile.occupation}');
      print('LocalPersonalizationEngine: Profile hobbies: ${profile.hobbies}');
      
      // カテゴリーに関連するテンプレートを取得
      List<ExampleTemplate> relevantTemplates = 
          PersonalizationTemplateService.getTemplatesForExistingCategory(categoryId);
      
      print('LocalPersonalizationEngine: Found ${relevantTemplates.length} templates for category $categoryId');
      
      if (relevantTemplates.isEmpty) {
        print('LocalPersonalizationEngine: No templates found for category $categoryId');
        return examples;
      }

      // 各テンプレートに対してパーソナライズ例文を生成（最大3つまで）
      int maxExamplesPerCategory = 3;
      int generatedCount = 0;
      
      for (ExampleTemplate template in relevantTemplates) {
        if (generatedCount >= maxExamplesPerCategory) break;
        
        // プロファイルに基づいて変数を選択
        Map<String, String> selectedVariables = _selectVariables(template, profile);
        
        print('LocalPersonalizationEngine: Template ${template.id} - selected variables: $selectedVariables');
        
        if (selectedVariables.isNotEmpty) {
          // テンプレートに変数を適用して例文生成
          Example? personalizedExample = _applyTemplate(
            template, 
            selectedVariables, 
            categoryId,
            generatedCount
          );
          
          if (personalizedExample != null) {
            examples.add(personalizedExample);
            generatedCount++;
          } else {
            print('LocalPersonalizationEngine: Failed to apply template ${template.id}');
          }
        } else {
          print('LocalPersonalizationEngine: No variables selected for template ${template.id}');
        }
      }
      
      print('LocalPersonalizationEngine: Generated $generatedCount personalized examples from ${relevantTemplates.length} templates');
      
    } catch (e) {
      print('LocalPersonalizationEngine: Error generating personalized examples: $e');
    }
    
    return examples;
  }

  /// プロファイルに基づいて適切な変数を選択
  Map<String, String> _selectVariables(
    ExampleTemplate template, 
    Profile profile
  ) {
    Map<String, String> selectedVariables = {};
    
    try {
      // テンプレートの各変数に対して最適な値を選択
      for (String variableKey in template.variables.keys) {
        Map<String, String>? selectedPair = _selectBestVariableValue(
          template.variables[variableKey]!, 
          profile
        );
        
        if (selectedPair != null) {
          selectedVariables[variableKey] = selectedPair['japanese']!;
          selectedVariables['${variableKey}_en'] = selectedPair['english']!;
        }
      }
    } catch (e) {
      print('LocalPersonalizationEngine: Error selecting variables: $e');
    }
    
    return selectedVariables;
  }

  /// 特定の変数に対して最適な値を選択（日本語と英語のペアを返す）
  Map<String, String>? _selectBestVariableValue(
    Map<String, Map<String, dynamic>> variableOptions,
    Profile profile
  ) {
    print('LocalPersonalizationEngine: Variable options keys: ${variableOptions.keys}');
    
    // 1. 職業ベースの選択を優先
    if (variableOptions.containsKey('occupation') && profile.occupation != null) {
      print('LocalPersonalizationEngine: Looking for occupation ${profile.occupation} in ${variableOptions['occupation']!.keys}');
      var occupationOptions = variableOptions['occupation']![profile.occupation];
      if (occupationOptions != null && occupationOptions is List && occupationOptions.isNotEmpty) {
        List<dynamic> selected = _randomSelect(occupationOptions);
        if (selected.length >= 2) {
          print('LocalPersonalizationEngine: Selected occupation-based value: ${selected[0]} → ${selected[1]}');
          return {'japanese': selected[0], 'english': selected[1]};
        }
      }
    }
    
    // 2. 趣味ベースの選択
    if (variableOptions.containsKey('hobby') && profile.hobbies.isNotEmpty) {
      for (String hobby in profile.hobbies) {
        var hobbyOptions = variableOptions['hobby']![hobby];
        if (hobbyOptions != null && hobbyOptions is List && hobbyOptions.isNotEmpty) {
          dynamic selected = _randomSelect(hobbyOptions);
          if (selected is List && selected.length >= 2) {
            print('LocalPersonalizationEngine: Selected hobby-based value: ${selected[0]} → ${selected[1]}');
            return {'japanese': selected[0], 'english': selected[1]};
          }
        }
      }
    }
    
    // 3. 家族構成ベースの選択
    if (variableOptions.containsKey('familyStructure') && profile.familyStructure != null) {
      var familyOptions = variableOptions['familyStructure']![profile.familyStructure];
      if (familyOptions != null && familyOptions is List && familyOptions.isNotEmpty) {
        dynamic selected = _randomSelect(familyOptions);
        if (selected is List && selected.length >= 2) {
          print('LocalPersonalizationEngine: Selected family-based value: ${selected[0]} → ${selected[1]}');
          return {'japanese': selected[0], 'english': selected[1]};
        }
      }
    }
    
    // 4. 一般的な選択肢がある場合
    if (variableOptions.containsKey('general')) {
      var generalOptions = variableOptions['general']!['all'];
      if (generalOptions != null && generalOptions is List && generalOptions.isNotEmpty) {
        dynamic selected = _randomSelect(generalOptions);
        if (selected is List && selected.length >= 2) {
          print('LocalPersonalizationEngine: Selected general value: ${selected[0]} → ${selected[1]}');
          return {'japanese': selected[0], 'english': selected[1]};
        }
      }
    }
    
    return null;
  }

  /// リストからランダムに要素を選択
  dynamic _randomSelect(List<dynamic> options) {
    if (options.isEmpty) return null;
    return options[_random.nextInt(options.length)];
  }

  /// テンプレートに変数を適用して例文を生成
  Example? _applyTemplate(
    ExampleTemplate template,
    Map<String, String> variables,
    String categoryId,
    int order
  ) {
    try {
      String japanese = template.baseJapanese;
      String english = template.baseEnglish;
      
      // 変数を日本語と英語の文に適用
      variables.forEach((key, value) {
        if (key.endsWith('_en')) {
          // 英語変数の適用
          String baseKey = key.substring(0, key.length - 3);
          english = english.replaceAll('{$baseKey}', value);
        } else {
          // 日本語変数の適用
          japanese = japanese.replaceAll('{$key}', value);
        }
      });
      
      // 変数が残っている場合は無効とする
      if (japanese.contains('{') || english.contains('{')) {
        print('LocalPersonalizationEngine: Template application failed, variables remain in text');
        return null;
      }
      
      Example personalizedExample = Example(
        id: 'personalized_${template.id}_${categoryId}_$order',
        categoryId: categoryId,
        levelId: _getLevelIdForCategory(categoryId),
        japanese: japanese,
        english: english,
        order: 1000 + order, // 基本例文より後に表示されるよう大きな番号
        isCompleted: false,
        isFavorite: false,
      );
      
      print('LocalPersonalizationEngine: Created personalized example: $japanese → $english');
      return personalizedExample;
      
    } catch (e) {
      print('LocalPersonalizationEngine: Error applying template: $e');
      return null;
    }
  }

  /// カテゴリーIDから対応するレベルIDを取得（既知のマッピングを使用）
  String _getLevelIdForCategory(String categoryId) {
    // 既知のカテゴリーマッピングを使用（循環参照回避）
    final Map<String, String> categoryToLevel = {
      // 中学レベル
      'be_verb': 'junior_high',
      'general_verb': 'junior_high',
      'past_tense': 'junior_high',
      'future_tense': 'junior_high',
      'question_words': 'junior_high',
      'pronouns': 'junior_high',
      'adjectives_adverbs': 'junior_high',
      'prepositions': 'junior_high',
      'numbers_ordinals': 'junior_high',
      'imperative_exclamatory': 'junior_high',
      'there_is_are': 'junior_high',
      'progressive': 'junior_high',
      'auxiliary_basic': 'junior_high',
      
      // 高校レベル
      'present_perfect': 'high_school_1',
      'infinitive': 'high_school_1',
      'gerund': 'high_school_1',
      'relative_pronouns': 'high_school_1',
      'participle': 'high_school_1',
      'auxiliary_advanced': 'high_school_1',
      'conditional_intro': 'high_school_1',
      'conjunction': 'high_school_1',
      'comparison_structure': 'high_school_1',
      'sentence_patterns': 'high_school_1',
      
      // 実用英語
      'daily_conversation': 'practical_english',
      'travel_english': 'practical_english',
      'phone_email': 'practical_english',
      'presentation': 'practical_english',
      'discussion': 'practical_english',
    };
    
    return categoryToLevel[categoryId] ?? 'unknown_level';
  }

  /// 基本例文とパーソナライズ例文を自然に混合
  List<Example> _mixExamples(
    List<Example> baseExamples, 
    List<Example> personalizedExamples
  ) {
    if (personalizedExamples.isEmpty) {
      return baseExamples;
    }
    
    List<Example> mixed = [...baseExamples];
    
    // パーソナライズ例文を基本例文の間に適切に挿入
    // 基本例文の1/3, 2/3の位置に挿入して自然な混合を実現
    if (baseExamples.length >= 3 && personalizedExamples.isNotEmpty) {
      int insertInterval = (baseExamples.length / (personalizedExamples.length + 1)).floor();
      if (insertInterval < 1) insertInterval = 1;
      
      for (int i = 0; i < personalizedExamples.length; i++) {
        int insertPosition = insertInterval * (i + 1) + i;
        if (insertPosition <= mixed.length) {
          mixed.insert(insertPosition, personalizedExamples[i]);
        } else {
          mixed.add(personalizedExamples[i]);
        }
      }
    } else {
      // 基本例文が少ない場合は末尾に追加
      mixed.addAll(personalizedExamples);
    }
    
    print('LocalPersonalizationEngine: Mixed ${baseExamples.length} base examples with ${personalizedExamples.length} personalized examples');
    
    return mixed;
  }

  /// デバッグ用：生成可能なパーソナライズ例文数を確認
  int getPersonalizableExamplesCount(String categoryId, Profile? profile) {
    if (profile == null) return 0;
    
    List<ExampleTemplate> templates = 
        PersonalizationTemplateService.getTemplatesForExistingCategory(categoryId);
    
    int count = 0;
    for (ExampleTemplate template in templates) {
      Map<String, String> variables = _selectVariables(template, profile);
      if (variables.isNotEmpty) {
        count++;
      }
    }
    
    return count;
  }

  /// デバッグ用：プロファイル情報を出力
  void debugProfile(Profile profile) {
    print('=== Profile Debug Info ===');
    print('Occupation: ${profile.occupation}');
    print('Hobbies: ${profile.hobbies}');
    print('Family Structure: ${profile.familyStructure}');
    print('Industry: ${profile.industry}');
    print('Learning Goal: ${profile.learningGoal}');
    print('English Level: ${profile.englishLevel}');
    print('==========================');
  }
}