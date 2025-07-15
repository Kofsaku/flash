import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/level.dart';
import '../models/user.dart';
import 'mock_data_service.dart';

/// MockDataServiceからFirestoreへのデータ移行を行うスクリプト
/// 
/// 使用方法：
/// 1. Firebaseプロジェクトが作成済みであることを確認
/// 2. アプリを起動して管理者権限でログイン
/// 3. DataMigrationScript.runFullMigration() を実行
class DataMigrationScript {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MockDataService _mockService = MockDataService();
  
  /// 完全なデータ移行を実行
  /// 注意: 本番環境では慎重に実行すること
  Future<bool> runFullMigration({
    bool overwriteExisting = false,
    Function(String)? onProgress,
  }) async {
    try {
      onProgress?.call('🚀 データ移行を開始します...');
      
      // 1. MockDataServiceを初期化
      onProgress?.call('📚 既存データを読み込み中...');
      await _mockService.initialize();
      
      // 2. 学習コンテンツを移行
      onProgress?.call('📖 学習コンテンツを移行中...');
      await _migrateLearningContent(overwriteExisting, onProgress);
      
      // 3. アプリ設定を移行
      onProgress?.call('⚙️ アプリ設定を移行中...');
      await _migrateAppSettings(overwriteExisting, onProgress);
      
      // 4. データ整合性を確認
      onProgress?.call('✅ データ整合性を確認中...');
      final isValid = await _validateMigratedData(onProgress);
      
      if (isValid) {
        onProgress?.call('🎉 データ移行が完了しました！');
        return true;
      } else {
        onProgress?.call('❌ データ整合性チェックに失敗しました');
        return false;
      }
      
    } catch (e) {
      onProgress?.call('💥 移行エラー: $e');
      if (kDebugMode) {
        print('Migration error details: $e');
      }
      return false;
    }
  }
  
  /// 学習コンテンツ（レベル・カテゴリー・例文）の移行
  Future<void> _migrateLearningContent(
    bool overwriteExisting,
    Function(String)? onProgress,
  ) async {
    final levels = _mockService.levels;
    
    for (int i = 0; i < levels.length; i++) {
      final level = levels[i];
      onProgress?.call('📚 レベル "${level.name}" を移行中... (${i + 1}/${levels.length})');
      
      // レベルドキュメントを作成
      final levelRef = _firestore.collection('levels').doc(level.id);
      
      // 既存チェック
      if (!overwriteExisting) {
        final existingLevel = await levelRef.get();
        if (existingLevel.exists) {
          onProgress?.call('⏭️ レベル "${level.name}" は既に存在するためスキップ');
          continue;
        }
      }
      
      // レベルデータを保存
      await levelRef.set({
        'id': level.id,
        'name': level.name,
        'description': level.description,
        'order': level.order,
        'isActive': true,
        'totalCategories': level.categories.length,
        'totalExamples': level.totalExamples,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'migrationSource': 'MockDataService',
        'migrationDate': FieldValue.serverTimestamp(),
      });
      
      // カテゴリーを移行
      await _migrateCategories(level, levelRef, onProgress);
    }
  }
  
  /// カテゴリーと例文の移行
  Future<void> _migrateCategories(
    Level level,
    DocumentReference levelRef,
    Function(String)? onProgress,
  ) async {
    for (int i = 0; i < level.categories.length; i++) {
      final category = level.categories[i];
      onProgress?.call('  📁 カテゴリー "${category.name}" を移行中... (${i + 1}/${level.categories.length})');
      
      final categoryRef = levelRef.collection('categories').doc(category.id);
      
      // カテゴリーデータを保存
      await categoryRef.set({
        'id': category.id,
        'name': category.name,
        'description': category.description,
        'levelId': level.id,
        'order': category.order,
        'isActive': true,
        'totalExamples': category.examples.length,
        'difficulty': _calculateDifficulty(category),
        'tags': _generateCategoryTags(category),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // 例文を移行
      await _migrateExamples(category, categoryRef, onProgress);
    }
  }
  
  /// 例文の移行
  Future<void> _migrateExamples(
    Category category,
    DocumentReference categoryRef,
    Function(String)? onProgress,
  ) async {
    // バッチ処理で効率的に保存
    WriteBatch batch = _firestore.batch();
    int batchCount = 0;
    const batchSize = 500; // Firestoreのバッチ制限
    
    for (int i = 0; i < category.examples.length; i++) {
      final example = category.examples[i];
      
      final exampleRef = categoryRef.collection('examples').doc(example.id);
      
      batch.set(exampleRef, {
        'id': example.id,
        'categoryId': category.id,
        'levelId': category.levelId,
        'japanese': example.japanese,
        'english': example.english,
        'hint': example.hint,
        'order': example.order,
        'isActive': true,
        'difficulty': _calculateExampleDifficulty(example),
        'wordCount': example.english.split(' ').length,
        'tags': _generateExampleTags(example),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      batchCount++;
      
      // バッチサイズに達したら実行
      if (batchCount >= batchSize) {
        await batch.commit();
        batch = _firestore.batch();
        batchCount = 0;
        onProgress?.call('    💾 ${i + 1}/${category.examples.length} 例文を保存済み');
      }
    }
    
    // 残りのバッチを実行
    if (batchCount > 0) {
      await batch.commit();
    }
    
    onProgress?.call('    ✅ カテゴリー "${category.name}" の全例文移行完了 (${category.examples.length}件)');
  }
  
  /// アプリ設定の移行
  Future<void> _migrateAppSettings(
    bool overwriteExisting,
    Function(String)? onProgress,
  ) async {
    final settingsRef = _firestore.collection('app_content').doc('settings');
    
    if (!overwriteExisting) {
      final existing = await settingsRef.get();
      if (existing.exists) {
        onProgress?.call('⏭️ アプリ設定は既に存在するためスキップ');
        return;
      }
    }
    
    // MockDataServiceから設定データを取得
    final mockService = _mockService;
    
    await settingsRef.set({
      'version': '1.0.0',
      'supportedLanguages': ['ja', 'en'],
      'defaultDailyGoal': 10,
      'maxDailyGoal': 100,
      'difficultyLevels': ['初級', '中級', '上級'],
      'availableAgeGroups': mockService.ageGroups,
      'availableOccupations': mockService.occupations,
      'availableEnglishLevels': mockService.englishLevels,
      'availableHobbies': mockService.hobbies,
      'availableIndustries': mockService.industries,
      'availableLifestyles': mockService.lifestyle,
      'availableLearningGoals': mockService.learningGoals,
      'availableStudyTimes': mockService.studyTime,
      'availableChallenges': mockService.challenges,
      'availableRegions': mockService.regions,
      'availableFamilyStructures': mockService.familyStructures,
      'availableEnglishUsageScenarios': mockService.englishUsageScenarios,
      'availableLearningStyles': mockService.learningStyles,
      'availableStudyEnvironments': mockService.studyEnvironments,
      'availableWeakAreas': mockService.weakAreas,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'migrationSource': 'MockDataService',
    });
    
    onProgress?.call('✅ アプリ設定の移行完了');
  }
  
  /// 移行されたデータの整合性をチェック
  Future<bool> _validateMigratedData(Function(String)? onProgress) async {
    try {
      onProgress?.call('🔍 レベルデータを検証中...');
      
      // レベル数をチェック
      final levelsSnapshot = await _firestore.collection('levels').get();
      final originalLevelsCount = _mockService.levels.length;
      
      if (levelsSnapshot.docs.length != originalLevelsCount) {
        onProgress?.call('❌ レベル数が一致しません: 期待値=${originalLevelsCount}, 実際=${levelsSnapshot.docs.length}');
        return false;
      }
      
      // 各レベルのカテゴリー数をチェック
      int totalCategoriesExpected = 0;
      int totalCategoriesActual = 0;
      int totalExamplesExpected = 0;
      int totalExamplesActual = 0;
      
      for (final level in _mockService.levels) {
        totalCategoriesExpected += level.categories.length;
        totalExamplesExpected += level.totalExamples;
        
        final levelDoc = await _firestore.collection('levels').doc(level.id).get();
        if (!levelDoc.exists) {
          onProgress?.call('❌ レベル "${level.id}" が見つかりません');
          return false;
        }
        
        final categoriesSnapshot = await _firestore
            .collection('levels')
            .doc(level.id)
            .collection('categories')
            .get();
        
        totalCategoriesActual += categoriesSnapshot.docs.length;
        
        // 各カテゴリーの例文数をチェック
        for (final categoryDoc in categoriesSnapshot.docs) {
          final examplesSnapshot = await _firestore
              .collection('levels')
              .doc(level.id)
              .collection('categories')
              .doc(categoryDoc.id)
              .collection('examples')
              .get();
          
          totalExamplesActual += examplesSnapshot.docs.length;
        }
      }
      
      onProgress?.call('📊 データ統計:');
      onProgress?.call('  - レベル: ${levelsSnapshot.docs.length}/${originalLevelsCount}');
      onProgress?.call('  - カテゴリー: $totalCategoriesActual/$totalCategoriesExpected');
      onProgress?.call('  - 例文: $totalExamplesActual/$totalExamplesExpected');
      
      if (totalCategoriesActual != totalCategoriesExpected) {
        onProgress?.call('❌ カテゴリー数が一致しません');
        return false;
      }
      
      if (totalExamplesActual != totalExamplesExpected) {
        onProgress?.call('❌ 例文数が一致しません');
        return false;
      }
      
      // アプリ設定をチェック
      onProgress?.call('🔍 アプリ設定を検証中...');
      final settingsDoc = await _firestore.collection('app_content').doc('settings').get();
      if (!settingsDoc.exists) {
        onProgress?.call('❌ アプリ設定が見つかりません');
        return false;
      }
      
      onProgress?.call('✅ データ整合性チェック完了 - すべて正常です');
      return true;
      
    } catch (e) {
      onProgress?.call('❌ 検証エラー: $e');
      return false;
    }
  }
  
  /// カテゴリーの難易度を計算
  String _calculateDifficulty(Category category) {
    // 例文数や内容に基づいて難易度を決定
    if (category.examples.length < 5) return '初級';
    if (category.examples.length < 15) return '中級';
    return '上級';
  }
  
  /// カテゴリーのタグを生成
  List<String> _generateCategoryTags(Category category) {
    List<String> tags = [];
    
    // カテゴリー名から基本タグを生成
    if (category.name.contains('動詞')) tags.add('動詞');
    if (category.name.contains('時制')) tags.add('時制');
    if (category.name.contains('疑問')) tags.add('疑問文');
    if (category.name.contains('否定')) tags.add('否定文');
    
    // レベルベースタグ
    tags.add('${category.levelId}_level');
    
    return tags;
  }
  
  /// 例文の難易度を計算
  String _calculateExampleDifficulty(Example example) {
    final wordCount = example.english.split(' ').length;
    
    if (wordCount <= 5) return '初級';
    if (wordCount <= 10) return '中級';
    return '上級';
  }
  
  /// 例文のタグを生成
  List<String> _generateExampleTags(Example example) {
    List<String> tags = [];
    
    // 英文の特徴からタグを生成
    if (example.english.contains('?')) tags.add('疑問文');
    if (example.english.toLowerCase().contains('not') || 
        example.english.toLowerCase().contains("n't")) tags.add('否定文');
    if (example.english.toLowerCase().contains('can') ||
        example.english.toLowerCase().contains('could') ||
        example.english.toLowerCase().contains('will') ||
        example.english.toLowerCase().contains('would')) tags.add('助動詞');
    
    // 語数ベース
    final wordCount = example.english.split(' ').length;
    if (wordCount <= 5) {
      tags.add('短文');
    } else if (wordCount <= 10) {
      tags.add('中文');
    } else {
      tags.add('長文');
    }
    
    return tags;
  }
  
  /// 移行の進捗状況を取得
  Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      final levelsSnapshot = await _firestore.collection('levels').get();
      final settingsDoc = await _firestore.collection('app_content').doc('settings').get();
      
      int totalCategories = 0;
      int totalExamples = 0;
      
      for (final levelDoc in levelsSnapshot.docs) {
        final categoriesSnapshot = await _firestore
            .collection('levels')
            .doc(levelDoc.id)
            .collection('categories')
            .get();
        
        totalCategories += categoriesSnapshot.docs.length;
        
        for (final categoryDoc in categoriesSnapshot.docs) {
          final examplesSnapshot = await _firestore
              .collection('levels')
              .doc(levelDoc.id)
              .collection('categories')
              .doc(categoryDoc.id)
              .collection('examples')
              .get();
          
          totalExamples += examplesSnapshot.docs.length;
        }
      }
      
      return {
        'levels': levelsSnapshot.docs.length,
        'categories': totalCategories,
        'examples': totalExamples,
        'settings': settingsDoc.exists,
        'lastMigration': settingsDoc.exists 
            ? settingsDoc.data()?['updatedAt'] 
            : null,
      };
      
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
  
  /// 既存データをクリア（開発用）
  /// 注意: 本番環境では絶対に使用しないこと
  Future<void> clearAllData() async {
    if (kDebugMode) {
      print('⚠️ 全データを削除中... (DEBUGモードのみ)');
      
      // レベルデータを削除
      final levelsSnapshot = await _firestore.collection('levels').get();
      for (final levelDoc in levelsSnapshot.docs) {
        await _deleteLevelRecursively(levelDoc.reference);
      }
      
      // アプリ設定を削除
      await _firestore.collection('app_content').doc('settings').delete();
      
      print('✅ 全データ削除完了');
    } else {
      throw Exception('データ削除はDEBUGモードでのみ実行可能です');
    }
  }
  
  /// レベルとその配下のデータを再帰的に削除
  Future<void> _deleteLevelRecursively(DocumentReference levelRef) async {
    // カテゴリーを削除
    final categoriesSnapshot = await levelRef.collection('categories').get();
    for (final categoryDoc in categoriesSnapshot.docs) {
      // 例文を削除
      final examplesSnapshot = await categoryDoc.reference.collection('examples').get();
      WriteBatch batch = _firestore.batch();
      for (final exampleDoc in examplesSnapshot.docs) {
        batch.delete(exampleDoc.reference);
      }
      if (examplesSnapshot.docs.isNotEmpty) {
        await batch.commit();
      }
      
      // カテゴリーを削除
      await categoryDoc.reference.delete();
    }
    
    // レベルを削除
    await levelRef.delete();
  }
}