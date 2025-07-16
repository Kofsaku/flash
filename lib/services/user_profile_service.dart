import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference get _profilesCollection =>
      _firestore.collection('user_profiles');

  /// プロフィール情報を保存
  Future<void> saveProfile(User user) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final profileDoc = _profilesCollection.doc(userId);
      final now = DateTime.now();
      
      final profileData = {
        'id': userId,
        'email': user.email,
        'name': user.name,
        'dailyGoal': user.dailyGoal,
        'profile': user.profile?.toJson(),
        'createdAt': user.createdAt?.toIso8601String() ?? now.toIso8601String(),
        'lastUpdated': now.toIso8601String(),
      };

      await profileDoc.set(profileData, SetOptions(merge: true));

      if (kDebugMode) {
        print('👤 Profile saved successfully for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving profile: $e');
      }
      throw Exception('Failed to save profile: $e');
    }
  }

  /// プロフィール情報を取得
  Future<User?> getUserProfile() async {
    final userId = _currentUserId;
    if (userId == null) {
      if (kDebugMode) {
        print('⚠️ User not authenticated');
      }
      return null;
    }

    try {
      final doc = await _profilesCollection.doc(userId).get();
      
      if (!doc.exists) {
        if (kDebugMode) {
          print('👤 No profile found for user: $userId');
        }
        // 新規ユーザーの場合、基本情報のみでUserオブジェクトを作成
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          return User(
            id: userId,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? '',
            isAuthenticated: true,
            createdAt: DateTime.now(),
          );
        }
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      
      final user = User.fromJson({
        'id': data['id'] ?? userId,
        'email': data['email'] ?? '',
        'name': data['name'] ?? '',
        'dailyGoal': data['dailyGoal'] ?? 10,
        'profile': data['profile'],
        'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'isAuthenticated': true,
      });

      if (kDebugMode) {
        print('👤 Profile loaded for user: $userId');
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting profile: $e');
      }
      throw Exception('Failed to get profile: $e');
    }
  }

  /// プロフィール情報を更新
  Future<void> updateProfile(User user) async {
    await saveProfile(user);
  }

  /// ユーザー情報を更新（名前、メール）
  Future<void> updateUserInfo({
    required String name,
    required String email,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final profileDoc = _profilesCollection.doc(userId);
      final now = DateTime.now();
      
      final updateData = {
        'name': name,
        'email': email,
        'lastUpdated': now.toIso8601String(),
      };

      await profileDoc.update(updateData);

      if (kDebugMode) {
        print('👤 User info updated: $name, $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user info: $e');
      }
      throw Exception('Failed to update user info: $e');
    }
  }

  /// 日次目標を更新
  Future<void> updateDailyGoal(int dailyGoal) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final profileDoc = _profilesCollection.doc(userId);
      final now = DateTime.now();
      
      final updateData = {
        'dailyGoal': dailyGoal,
        'lastUpdated': now.toIso8601String(),
      };

      await profileDoc.update(updateData);

      if (kDebugMode) {
        print('👤 Daily goal updated: $dailyGoal');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating daily goal: $e');
      }
      throw Exception('Failed to update daily goal: $e');
    }
  }

  /// プロフィール情報を削除
  Future<void> deleteProfile() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _profilesCollection.doc(userId).delete();
      
      if (kDebugMode) {
        print('👤 Profile deleted for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting profile: $e');
      }
      throw Exception('Failed to delete profile: $e');
    }
  }

  /// プロフィール情報をリアルタイムで監視
  Stream<User?> watchUserProfile() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value(null);
    }

    return _profilesCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        // 新規ユーザーの場合、基本情報のみでUserオブジェクトを作成
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          return User(
            id: userId,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? '',
            isAuthenticated: true,
            createdAt: DateTime.now(),
          );
        }
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      
      return User.fromJson({
        'id': data['id'] ?? userId,
        'email': data['email'] ?? '',
        'name': data['name'] ?? '',
        'dailyGoal': data['dailyGoal'] ?? 10,
        'profile': data['profile'],
        'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'isAuthenticated': true,
      });
    });
  }

  /// プロフィール完了状態を確認
  Future<bool> isProfileCompleted() async {
    final user = await getUserProfile();
    return user?.profile?.isCompleted ?? false;
  }

  /// プロフィールの特定ステップを更新
  Future<void> updateProfileStep(User user, int step) async {
    if (step < 1 || step > 5) {
      throw Exception('Invalid profile step: $step');
    }

    await saveProfile(user);
    
    if (kDebugMode) {
      print('👤 Profile step $step updated');
    }
  }
}