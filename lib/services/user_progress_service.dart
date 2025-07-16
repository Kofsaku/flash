import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';

class UserProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference get _progressCollection =>
      _firestore.collection('user_progress');

  Future<void> saveExampleProgress({
    required String exampleId,
    required bool isCompleted,
    required bool isFavorite,
    DateTime? completedAt,
    int? attemptCount,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final progressDoc = _progressCollection.doc(userId);
      final now = DateTime.now();
      
      final progressData = {
        'exampleProgress.$exampleId': {
          'exampleId': exampleId,
          'isCompleted': isCompleted,
          'isFavorite': isFavorite,
          'completedAt': completedAt?.toIso8601String(),
          'attemptCount': attemptCount ?? 0,
        },
        'lastUpdated': now.toIso8601String(),
      };

      await progressDoc.set(progressData, SetOptions(merge: true));

      if (kDebugMode) {
        print('📊 Example progress saved: $exampleId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving example progress: $e');
      }
      throw Exception('Failed to save example progress: $e');
    }
  }

  Future<void> updateCategoryProgress({
    required String categoryId,
    required int completedExamples,
    required int totalExamples,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final progressDoc = _progressCollection.doc(userId);
      final now = DateTime.now();
      
      final progressData = {
        'categoryProgress.$categoryId': {
          'categoryId': categoryId,
          'completedExamples': completedExamples,
          'totalExamples': totalExamples,
          'lastStudiedAt': now.toIso8601String(),
        },
        'lastUpdated': now.toIso8601String(),
      };

      await progressDoc.set(progressData, SetOptions(merge: true));

      if (kDebugMode) {
        print('📊 Category progress updated: $categoryId ($completedExamples/$totalExamples)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating category progress: $e');
      }
      throw Exception('Failed to update category progress: $e');
    }
  }

  Future<void> updateLevelProgress({
    required String levelId,
    required int completedExamples,
    required int totalExamples,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final progressDoc = _progressCollection.doc(userId);
      final now = DateTime.now();
      
      final progressData = {
        'levelProgress.$levelId': {
          'levelId': levelId,
          'completedExamples': completedExamples,
          'totalExamples': totalExamples,
          'lastStudiedAt': now.toIso8601String(),
        },
        'lastUpdated': now.toIso8601String(),
      };

      await progressDoc.set(progressData, SetOptions(merge: true));

      if (kDebugMode) {
        print('📊 Level progress updated: $levelId ($completedExamples/$totalExamples)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating level progress: $e');
      }
      throw Exception('Failed to update level progress: $e');
    }
  }

  Future<UserProgress?> getUserProgress() async {
    final userId = _currentUserId;
    if (userId == null) {
      if (kDebugMode) {
        print('⚠️ User not authenticated');
      }
      return null;
    }

    try {
      final doc = await _progressCollection.doc(userId).get();
      
      if (!doc.exists) {
        if (kDebugMode) {
          print('📊 No progress data found for user: $userId');
        }
        return UserProgress(
          userId: userId,
          lastUpdated: DateTime.now(),
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      
      final userProgress = UserProgress.fromJson({
        'userId': userId,
        'exampleProgress': data['exampleProgress'] ?? {},
        'categoryProgress': data['categoryProgress'] ?? {},
        'levelProgress': data['levelProgress'] ?? {},
        'lastUpdated': data['lastUpdated'] ?? DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('📊 User progress loaded: ${userProgress.exampleProgress.length} examples');
      }

      return userProgress;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user progress: $e');
      }
      throw Exception('Failed to get user progress: $e');
    }
  }

  Future<ExampleProgress?> getExampleProgress(String exampleId) async {
    final userProgress = await getUserProgress();
    return userProgress?.exampleProgress[exampleId];
  }

  Future<CategoryProgress?> getCategoryProgress(String categoryId) async {
    final userProgress = await getUserProgress();
    return userProgress?.categoryProgress[categoryId];
  }

  Future<LevelProgress?> getLevelProgress(String levelId) async {
    final userProgress = await getUserProgress();
    return userProgress?.levelProgress[levelId];
  }

  Future<void> toggleFavorite(String exampleId) async {
    final currentProgress = await getExampleProgress(exampleId);
    final newFavoriteStatus = !(currentProgress?.isFavorite ?? false);
    
    await saveExampleProgress(
      exampleId: exampleId,
      isCompleted: currentProgress?.isCompleted ?? false,
      isFavorite: newFavoriteStatus,
      completedAt: currentProgress?.completedAt,
      attemptCount: currentProgress?.attemptCount,
    );
  }

  Future<void> markExampleCompleted(String exampleId) async {
    final currentProgress = await getExampleProgress(exampleId);
    final now = DateTime.now();
    
    await saveExampleProgress(
      exampleId: exampleId,
      isCompleted: true,
      isFavorite: currentProgress?.isFavorite ?? false,
      completedAt: now,
      attemptCount: (currentProgress?.attemptCount ?? 0) + 1,
    );
  }

  Future<void> resetExampleProgress(String exampleId) async {
    final currentProgress = await getExampleProgress(exampleId);
    
    await saveExampleProgress(
      exampleId: exampleId,
      isCompleted: false,
      isFavorite: currentProgress?.isFavorite ?? false,
      completedAt: null,
      attemptCount: currentProgress?.attemptCount ?? 0,
    );
  }

  Future<void> clearAllProgress() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _progressCollection.doc(userId).delete();
      
      if (kDebugMode) {
        print('📊 All progress cleared for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing progress: $e');
      }
      throw Exception('Failed to clear progress: $e');
    }
  }

  Stream<UserProgress?> watchUserProgress() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value(null);
    }

    return _progressCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return UserProgress(
          userId: userId,
          lastUpdated: DateTime.now(),
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      
      return UserProgress.fromJson({
        'userId': userId,
        'exampleProgress': data['exampleProgress'] ?? {},
        'categoryProgress': data['categoryProgress'] ?? {},
        'levelProgress': data['levelProgress'] ?? {},
        'lastUpdated': data['lastUpdated'] ?? DateTime.now().toIso8601String(),
      });
    });
  }
}