# Flash Composition App - Firebase統合実装ガイド

## 🎯 概要

このガイドは、Flash Composition AppにFirebaseを統合するための実用的な手順書です。既存のMockDataServiceからFirebaseへの完全移行をステップバイステップで説明します。

## 📋 前提条件

- Flutter SDK 3.7.2+
- Android Studio / Xcode（プラットフォーム別）
- Googleアカウント（Firebaseプロジェクト作成用）
- 現在のアプリがMockDataServiceで動作していること

## 🗂️ 現在のアプリ構成（分析結果）

### データ構造
- **User**: 認証情報 + 詳細Profile（5ステップ）
- **Level**: 学習レベル（中学、高校1-3年）
- **Category**: 文法カテゴリー（be動詞、一般動詞等）
- **Example**: 学習例文（日本語→英語）
- **Progress**: 学習進捗・お気に入り状態

### 主要画面
- 認証系（Splash, Login, Register, Profile設定5ステップ）
- 学習系（Home, Category, ExampleList, Study）
- 管理系（Profile, Favorites, Settings）

---

## 🚀 実装手順

## Phase 1: Firebase環境構築

### 1.1 Firebaseプロジェクト作成

**作業者が行う手順：**

1. **Firebase Console にアクセス**
   - https://console.firebase.google.com/ にアクセス
   - Googleアカウントでログイン

2. **新しいプロジェクトを作成**
   - 「プロジェクトを追加」クリック
   - プロジェクト名：`flash-composition-app`
   - Google Analytics: 有効（推奨）
   - 作成完了まで待機

3. **認証方法を設定**
   - 左サイドバー「Authentication」→「始める」
   - 「Sign-in method」タブ
   - 「メール/パスワード」を有効化
   - （必要に応じて）「Googleサインイン」も有効化

4. **Firestoreデータベース作成**
   - 左サイドバー「Firestore Database」→「データベースの作成」
   - セキュリティルール：「テストモードで開始」（後で変更）
   - ロケーション：`asia-northeast1`（東京）を選択

### 1.2 Flutter プロジェクトへのFirebase追加

**作業者が行う手順：**

1. **Firebase CLI インストール**
   ```bash
   # macOS/Linux
   curl -sL https://firebase.tools | bash
   
   # Windows
   npm install -g firebase-tools
   ```

2. **Firebase CLI ログイン**
   ```bash
   firebase login
   ```

3. **FlutterFire CLI インストール**
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. **プロジェクトディレクトリでFirebaseを設定**
   ```bash
   cd /Users/kt/flash_composition/flash_composition_app
   flutterfire configure
   ```
   - プロジェクト選択：`flash-composition-app`
   - プラットフォーム選択：iOS, Android（必要に応じて）
   - 自動的に設定ファイルが生成される

### 1.3 依存関係の追加

**コンソールで実行：**

```bash
cd /Users/kt/flash_composition/flash_composition_app
flutter pub add firebase_core firebase_auth cloud_firestore
flutter pub get
```

### 1.4 Firebase初期化コードの追加

**main.dart の更新が必要：**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FlashCompositionApp());
}
```

---

## Phase 2: Firestoreセキュリティルール設定

### 2.1 セキュリティルールの設定

**Firebase Console での作業：**

1. **Firestore Database** → **ルール** タブ
2. 以下のルールをコピー＆ペースト：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーデータ - 認証済みユーザーのみアクセス可
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // ユーザー進捗データ - 認証済みユーザーのみアクセス可
    match /user_progress/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 学習コンテンツ - 認証済みユーザーは読み取り専用
    match /levels/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // 管理者のみ（後で設定）
    }
    
    // アプリ設定 - 認証済みユーザーは読み取り専用
    match /app_content/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // 管理者のみ（後で設定）
    }
  }
}
```

3. **公開** ボタンをクリック

### 2.2 データベース構造の作成

**Firebase Console での作業：**

1. **Firestore Database** → **データ** タブ
2. 以下のコレクションを手動作成：

```
/levels (コレクション)
├── /junior_high (ドキュメント)
│   ├── id: "junior_high"
│   ├── name: "中学レベル"
│   ├── description: "基礎的な英文法と語彙"
│   ├── order: 1
│   ├── isActive: true
│   └── /categories (サブコレクション)
│       └── /be_verb (ドキュメント)
│           ├── id: "be_verb"
│           ├── name: "be動詞"
│           ├── description: "be動詞の基本的な使い方・感情・状態表現"
│           ├── levelId: "junior_high"
│           ├── order: 1
│           └── /examples (サブコレクション)
│               └── /be_001 (ドキュメント)
│                   ├── id: "be_001"
│                   ├── japanese: "私は学生です。"
│                   ├── english: "I am a student."
│                   ├── hint: null
│                   └── order: 1
```

---

## Phase 3: 認証システムの実装

### 3.1 AuthService の作成

**新しいファイル：** `lib/services/auth_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 現在のユーザー
  User? get currentUser => _auth.currentUser;
  
  // 認証状態の監視
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // サインイン
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // アカウント作成
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // サインアウト
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // パスワードリセット
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  // エラーハンドリング
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'ユーザーが見つかりません';
      case 'wrong-password':
        return 'パスワードが間違っています';
      case 'weak-password':
        return 'パスワードが弱すぎます（6文字以上で設定してください）';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています';
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません';
      default:
        return '認証エラーが発生しました: ${e.message}';
    }
  }
}
```

### 3.2 FirestoreService の作成

**新しいファイル：** `lib/services/firestore_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/level.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ========== ユーザー管理 ==========
  
  // ユーザープロファイル作成
  Future<void> createUserProfile(String userId, Profile profile) async {
    await _firestore.collection('users').doc(userId).set({
      'id': userId,
      'profile': profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // ユーザープロファイル取得
  Future<Profile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['profile'] != null) {
          return Profile.fromMap(data['profile']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
  
  // ユーザープロファイル更新
  Future<void> updateUserProfile(String userId, Profile profile) async {
    await _firestore.collection('users').doc(userId).update({
      'profile': profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // ========== 学習コンテンツ管理 ==========
  
  // レベル一覧取得
  Future<List<Level>> getLevels() async {
    try {
      final snapshot = await _firestore
          .collection('levels')
          .orderBy('order')
          .get();
      
      List<Level> levels = [];
      for (final doc in snapshot.docs) {
        final level = await _buildLevelFromDoc(doc);
        levels.add(level);
      }
      return levels;
    } catch (e) {
      print('Error getting levels: $e');
      return [];
    }
  }
  
  // レベル詳細取得（カテゴリー含む）
  Future<Level?> getLevel(String levelId) async {
    try {
      final doc = await _firestore.collection('levels').doc(levelId).get();
      if (doc.exists) {
        return await _buildLevelFromDoc(doc);
      }
      return null;
    } catch (e) {
      print('Error getting level: $e');
      return null;
    }
  }
  
  // カテゴリー一覧取得
  Future<List<Category>> getCategories(String levelId) async {
    try {
      final snapshot = await _firestore
          .collection('levels')
          .doc(levelId)
          .collection('categories')
          .orderBy('order')
          .get();
      
      List<Category> categories = [];
      for (final doc in snapshot.docs) {
        final category = await _buildCategoryFromDoc(doc);
        categories.add(category);
      }
      return categories;
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }
  
  // 例文一覧取得
  Future<List<Example>> getExamples(String levelId, String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('levels')
          .doc(levelId)
          .collection('categories')
          .doc(categoryId)
          .collection('examples')
          .orderBy('order')
          .get();
      
      return snapshot.docs.map((doc) => _buildExampleFromDoc(doc)).toList();
    } catch (e) {
      print('Error getting examples: $e');
      return [];
    }
  }
  
  // ========== 進捗管理 ==========
  
  // 例文完了状態更新
  Future<void> updateExampleProgress(
    String userId, 
    String exampleId, 
    bool isCompleted
  ) async {
    await _firestore
        .collection('user_progress')
        .doc(userId)
        .collection('examples')
        .doc(exampleId)
        .set({
      'exampleId': exampleId,
      'userId': userId,
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
      'lastStudiedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  
  // お気に入り状態更新
  Future<void> toggleFavorite(String userId, String exampleId) async {
    final docRef = _firestore
        .collection('user_progress')
        .doc(userId)
        .collection('examples')
        .doc(exampleId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final currentFavorite = snapshot.data()?['isFavorite'] ?? false;
      
      transaction.set(docRef, {
        'exampleId': exampleId,
        'userId': userId,
        'isFavorite': !currentFavorite,
        'lastStudiedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
  
  // ユーザー進捗取得
  Future<Map<String, Map<String, dynamic>>> getUserProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('examples')
          .get();
      
      Map<String, Map<String, dynamic>> progress = {};
      for (final doc in snapshot.docs) {
        progress[doc.id] = doc.data();
      }
      return progress;
    } catch (e) {
      print('Error getting user progress: $e');
      return {};
    }
  }
  
  // ========== プライベートヘルパーメソッド ==========
  
  Future<Level> _buildLevelFromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final categories = await getCategories(doc.id);
    
    return Level(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
      categories: categories,
    );
  }
  
  Future<Category> _buildCategoryFromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final examples = await getExamples(data['levelId'], doc.id);
    
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      levelId: data['levelId'] ?? '',
      order: data['order'] ?? 0,
      examples: examples,
    );
  }
  
  Example _buildExampleFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Example(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      levelId: data['levelId'] ?? '',
      japanese: data['japanese'] ?? '',
      english: data['english'] ?? '',
      hint: data['hint'],
      order: data['order'] ?? 0,
      isCompleted: false, // 進捗は別途取得
      isFavorite: false,  // 進捗は別途取得
      completedAt: null,
    );
  }
}
```

---

## Phase 4: AppProviderの更新

### 4.1 AppProvider をFirebase対応に更新

**lib/providers/app_provider.dart を更新：**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../models/user.dart';
import '../models/level.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'dart:async';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  // ========== 状態変数 ==========
  User? _currentUser;
  List<Level> _levels = [];
  Map<String, Map<String, dynamic>> _userProgress = {};
  bool _isLoading = false;
  String? _error;
  
  // 認証状態監視用
  StreamSubscription<firebase.User?>? _authSubscription;
  
  // ========== ゲッター ==========
  User? get currentUser => _currentUser;
  List<Level> get levels => _levels;
  bool get isAuthenticated => _currentUser?.isAuthenticated ?? false;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ========== 初期化 ==========
  AppProvider() {
    _initializeAuth();
  }
  
  void _initializeAuth() {
    _authSubscription = _authService.authStateChanges.listen((firebase.User? user) {
      if (user != null) {
        _loadUserData(user);
      } else {
        _currentUser = null;
        _userProgress.clear();
        notifyListeners();
      }
    });
  }
  
  Future<void> _loadUserData(firebase.User user) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // プロファイル取得
      final profile = await _firestoreService.getUserProfile(user.uid);
      
      // ユーザーオブジェクト作成
      _currentUser = User(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        isAuthenticated: true,
        profile: profile,
      );
      
      // 学習データ取得
      await _loadLevels();
      await _loadUserProgress();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'ユーザーデータの読み込みに失敗しました: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ========== 認証関連 ==========
  
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final credential = await _authService.createUserWithEmailAndPassword(email, password);
      
      // ユーザー名を設定
      await credential.user?.updateDisplayName(name);
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _authService.signOut();
  }
  
  // ========== プロファイル管理 ==========
  
  Future<bool> saveProfile(Profile profile) async {
    try {
      if (_currentUser == null) return false;
      
      _isLoading = true;
      notifyListeners();
      
      await _firestoreService.createUserProfile(_currentUser!.id, profile);
      
      // ローカル状態更新
      _currentUser = _currentUser!.copyWith(profile: profile);
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'プロファイルの保存に失敗しました: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // ========== 学習データ管理 ==========
  
  Future<void> _loadLevels() async {
    try {
      _levels = await _firestoreService.getLevels();
    } catch (e) {
      _error = '学習データの読み込みに失敗しました: $e';
    }
  }
  
  Future<void> _loadUserProgress() async {
    try {
      if (_currentUser != null) {
        _userProgress = await _firestoreService.getUserProgress(_currentUser!.id);
      }
    } catch (e) {
      print('Progress loading error: $e');
    }
  }
  
  // ========== 学習進捗管理 ==========
  
  Future<void> markExampleCompleted(String exampleId, bool isCompleted) async {
    if (_currentUser == null) return;
    
    try {
      await _firestoreService.updateExampleProgress(
        _currentUser!.id, 
        exampleId, 
        isCompleted
      );
      
      // ローカル状態更新
      if (_userProgress[exampleId] == null) {
        _userProgress[exampleId] = {};
      }
      _userProgress[exampleId]!['isCompleted'] = isCompleted;
      _userProgress[exampleId]!['completedAt'] = isCompleted ? DateTime.now() : null;
      
      notifyListeners();
    } catch (e) {
      _error = '進捗の保存に失敗しました: $e';
      notifyListeners();
    }
  }
  
  Future<void> toggleFavorite(String exampleId) async {
    if (_currentUser == null) return;
    
    try {
      await _firestoreService.toggleFavorite(_currentUser!.id, exampleId);
      
      // ローカル状態更新
      if (_userProgress[exampleId] == null) {
        _userProgress[exampleId] = {};
      }
      final currentFavorite = _userProgress[exampleId]!['isFavorite'] ?? false;
      _userProgress[exampleId]!['isFavorite'] = !currentFavorite;
      
      notifyListeners();
    } catch (e) {
      _error = 'お気に入りの更新に失敗しました: $e';
      notifyListeners();
    }
  }
  
  // ========== ヘルパーメソッド ==========
  
  bool isExampleCompleted(String exampleId) {
    return _userProgress[exampleId]?['isCompleted'] ?? false;
  }
  
  bool isExampleFavorite(String exampleId) {
    return _userProgress[exampleId]?['isFavorite'] ?? false;
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
```

---

## Phase 5: データモデルの拡張

### 5.1 Profile モデルにtoMap/fromMapメソッド追加

**lib/models/user.dart を更新（Profileクラスに追加）：**

```dart
class Profile {
  // 既存のフィールド...
  
  // Firestoreへの保存用
  Map<String, dynamic> toMap() {
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
      'learningStyles': learningStyles,
      'skillLevels': skillLevels,
      'studyEnvironments': studyEnvironments,
      'weakAreas': weakAreas,
      'motivationDetail': motivationDetail,
      'correctionStyle': correctionStyle,
      'encouragementFrequency': encouragementFrequency,
    };
  }
  
  // Firestoreからの復元用
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      ageGroup: map['ageGroup'],
      occupation: map['occupation'],
      englishLevel: map['englishLevel'],
      hobbies: List<String>.from(map['hobbies'] ?? []),
      industry: map['industry'],
      lifestyle: List<String>.from(map['lifestyle'] ?? []),
      learningGoal: map['learningGoal'],
      studyTime: List<String>.from(map['studyTime'] ?? []),
      targetStudyMinutes: map['targetStudyMinutes'],
      challenges: List<String>.from(map['challenges'] ?? []),
      region: map['region'],
      familyStructure: map['familyStructure'],
      englishUsageScenarios: List<String>.from(map['englishUsageScenarios'] ?? []),
      interestingTopics: List<String>.from(map['interestingTopics'] ?? []),
      learningStyles: List<String>.from(map['learningStyles'] ?? []),
      skillLevels: Map<String, String>.from(map['skillLevels'] ?? {}),
      studyEnvironments: List<String>.from(map['studyEnvironments'] ?? []),
      weakAreas: List<String>.from(map['weakAreas'] ?? []),
      motivationDetail: map['motivationDetail'],
      correctionStyle: map['correctionStyle'],
      encouragementFrequency: map['encouragementFrequency'],
    );
  }
}
```

---

## Phase 6: データ移行スクリプト

### 6.1 既存データのFirestore移行

**新しいファイル：** `lib/services/data_migration_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/level.dart';
import 'mock_data_service.dart';

class DataMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MockDataService _mockService = MockDataService();
  
  // 管理者専用：静的データをFirestoreに移行
  Future<void> migrateStaticData() async {
    try {
      // MockDataServiceから既存データを取得
      await _mockService.initialize();
      final levels = _mockService.levels;
      
      final batch = _firestore.batch();
      
      for (final level in levels) {
        // レベルデータを作成
        final levelRef = _firestore.collection('levels').doc(level.id);
        batch.set(levelRef, {
          'id': level.id,
          'name': level.name,
          'description': level.description,
          'order': level.order,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // カテゴリーデータを作成
        for (final category in level.categories) {
          final categoryRef = levelRef.collection('categories').doc(category.id);
          batch.set(categoryRef, {
            'id': category.id,
            'name': category.name,
            'description': category.description,
            'levelId': level.id,
            'order': category.order,
            'isActive': true,
            'totalExamples': category.examples.length,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
          // 例文データを作成
          for (final example in category.examples) {
            final exampleRef = categoryRef.collection('examples').doc(example.id);
            batch.set(exampleRef, {
              'id': example.id,
              'categoryId': category.id,
              'levelId': level.id,
              'japanese': example.japanese,
              'english': example.english,
              'hint': example.hint,
              'order': example.order,
              'isActive': true,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
      
      // バッチ実行
      await batch.commit();
      print('データ移行が完了しました');
      
    } catch (e) {
      print('データ移行エラー: $e');
      rethrow;
    }
  }
}
```

### 6.2 移行実行用のデバッグ画面

**管理者用の一時的な移行画面を作成（デプロイ前に削除）：**

```dart
// デバッグ用：admin_migration_screen.dart
import 'package:flutter/material.dart';
import '../services/data_migration_service.dart';

class AdminMigrationScreen extends StatelessWidget {
  final DataMigrationService _migrationService = DataMigrationService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('データ移行（管理者専用）')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await _migrationService.migrateStaticData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('移行完了！')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('移行失敗: $e')),
              );
            }
          },
          child: Text('データ移行を実行'),
        ),
      ),
    );
  }
}
```

---

## Phase 7: UI更新とテスト

### 7.1 認証画面の更新

**lib/screens/auth/login_screen.dart の_submitメソッドを更新：**

```dart
Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  
  final provider = Provider.of<AppProvider>(context, listen: false);
  
  setState(() => _isLoading = true);
  
  final success = await provider.login(_emailController.text, _passwordController.text);
  
  if (success && mounted) {
    context.go(AppRouter.home);
  } else if (mounted) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.error ?? 'ログインに失敗しました')),
    );
  }
}
```

### 7.2 エラーハンドリングの追加

**共通エラーウィジェット：** `lib/widgets/error_retry_widget.dart`

```dart
import 'package:flutter/material.dart';

class ErrorRetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  
  const ErrorRetryWidget({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('再試行'),
          ),
        ],
      ),
    );
  }
}
```

---

## Phase 8: テストとデプロイ準備

### 8.1 テスト手順

**作業者が行うテスト：**

1. **認証テスト**
   ```bash
   flutter test test/auth_test.dart
   ```

2. **実機テスト**
   - アカウント作成→プロフィール設定→学習→ログアウト→ログイン
   - データの永続化確認
   - オフライン動作確認

3. **パフォーマンステスト**
   - Firebase Console でFirestore読み書き回数確認
   - アプリのメモリ使用量確認

### 8.2 本番環境の準備

**Firebase Console での作業：**

1. **本番用セキュリティルールに更新**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == userId
        && validateUserData(request.resource.data);
    }
    
    match /user_progress/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /levels/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin(request.auth.uid);
    }
    
    function validateUserData(data) {
      return data.keys().hasAll(['profile']) 
        && data.profile is map;
    }
    
    function isAdmin(uid) {
      return exists(/databases/$(database)/documents/admins/$(uid));
    }
  }
}
```

2. **複合インデックスの作成**
   - Firestore Console → インデックス
   - 必要に応じて自動提案されるインデックスを有効化

3. **バックアップの設定**
   - Cloud Scheduler でDaily backup設定

---

## 📊 運用監視

### 監視項目

**Firebase Console で確認：**

1. **Authentication**
   - 新規登録数
   - アクティブユーザー数
   - 認証エラー率

2. **Firestore**
   - 読み取り/書き込み回数
   - データベースサイズ
   - レスポンス時間

3. **Performance**
   - アプリ起動時間
   - 画面遷移時間
   - クラッシュレート

### コスト最適化

**推定月額コスト（1000ユーザー）：**
- Firestore: $15-25
- Authentication: 無料
- Hosting: $1-5
- **総計: $16-30/月**

---

## 🚨 トラブルシューティング

### よくある問題と解決法

1. **認証エラー**
   ```
   [firebase_auth/network-request-failed]
   → インターネット接続確認
   → Firebase設定確認
   ```

2. **Firestore権限エラー**
   ```
   [cloud_firestore/permission-denied]
   → セキュリティルール確認
   → 認証状態確認
   ```

3. **データ取得失敗**
   ```
   → インデックス作成確認
   → ネットワーク状態確認
   → オフライン設定確認
   ```

### ログ確認方法

```bash
# Firebaseデバッグログ有効化
flutter run --dart-define=FIREBASE_DEBUG=true

# Android ログ確認
adb logcat | grep Flutter

# iOS ログ確認
xcrun simctl spawn booted log stream --predicate 'subsystem contains "flutter"'
```

---

## 📝 まとめ

このガイドに従って実装することで：

✅ **完全なFirebase統合**
- 認証（Email/Password）
- リアルタイムデータベース（Firestore）  
- 進捗の永続化
- セキュリティルール

✅ **スケーラブルな設計**
- ユーザー数に応じた自動スケーリング
- 効率的なデータ構造
- コスト最適化

✅ **優れたUX**
- オフライン対応
- リアルタイム同期
- エラーハンドリング

この実装により、Flash Composition Appは本格的なクラウド対応学習アプリとして運用可能になります。

---

**🎯 次のステップ：**
1. Phase 1から順次実装
2. 各Phaseごとにテスト実行
3. 問題発生時はトラブルシューティング参照
4. 本番リリース前に必ず移行用画面削除

実装中に不明点があれば、Firebase公式ドキュメントも併せて参照してください。