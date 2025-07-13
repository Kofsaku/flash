# Flash Composition App - Firebase統合仕様書

## 1. プロジェクト概要

Flash Composition Appは、英作文学習を支援するFlutterアプリケーションです。現在は`MockDataService`を使用した静的データで構築されており、Firebase統合により永続的なデータ管理とリアルタイム同期を実現します。

### 1.1 アプリケーション構造

- **プラットフォーム**: Flutter (iOS/Android)
- **状態管理**: Provider + ChangeNotifier
- **ナビゲーション**: go_router
- **現在のデータレイヤー**: MockDataService (シングルトン)

## 2. 現在のデータモデル分析

### 2.1 コアデータモデル

#### User Model (`lib/models/user.dart`)
```dart
class User {
  final String id;
  final String email;
  final String name;
  final bool isAuthenticated;
  final Profile? profile;
}

class Profile {
  // Step 1: 基本情報
  final String? ageGroup;           // 年代
  final String? occupation;         // 職業
  final String? englishLevel;       // 英語レベル
  
  // Step 2: 興味・関心
  final List<String> hobbies;       // 趣味
  final String? industry;           // 業界
  final List<String> lifestyle;     // ライフスタイル
  
  // Step 3: 学習環境・目標
  final String? learningGoal;       // 学習目標
  final List<String> studyTime;     // 学習時間
  final String? targetStudyMinutes; // 目標時間
  final List<String> challenges;    // 課題
  
  // Step 4: 個人的背景
  final String? region;             // 地域
  final String? familyStructure;    // 家族構成
  final List<String> englishUsageScenarios; // 使用場面
  final List<String> interestingTopics;     // 興味のあるトピック
  
  // Step 5: 学習特性診断
  final List<String> learningStyles;        // 学習スタイル
  final Map<String, String> skillLevels;    // スキルレベル
  final List<String> studyEnvironments;     // 学習環境
  final List<String> weakAreas;            // 弱点
  final String? motivationDetail;          // モチベーション詳細
  final String? correctionStyle;           // 訂正スタイル
  final String? encouragementFrequency;    // 励ましの頻度
}
```

#### Level Model (`lib/models/level.dart`)
```dart
class Level {
  final String id;                    // レベルID
  final String name;                  // レベル名
  final String description;           // 説明
  final int order;                    // 順序
  final List<Category> categories;    // カテゴリ一覧
  final int totalExamples;           // 総例文数
  final int completedExamples;       // 完了例文数
  
  double get progress;               // 進捗率計算
}

class Category {
  final String id;                   // カテゴリID
  final String name;                 // カテゴリ名
  final String description;          // 説明
  final String levelId;              // 所属レベルID
  final int order;                   // 順序
  final List<Example> examples;      // 例文一覧
  final int totalExamples;          // 総例文数
  final int completedExamples;      // 完了例文数
  
  double get progress;              // 進捗率計算
  bool get isCompleted;             // 完了状態
}

class Example {
  final String id;                  // 例文ID
  final String categoryId;          // 所属カテゴリID
  final String levelId;             // 所属レベルID
  final String japanese;            // 日本語文
  final String english;             // 英語文
  final String? hint;               // ヒント
  final int order;                  // 順序
  final bool isCompleted;           // 完了状態
  final bool isFavorite;            // お気に入り状態
  final DateTime? completedAt;      // 完了日時
}
```

### 2.2 現在のデータフロー

1. **初期化**: `MockDataService.initialize()` → 静的データ読み込み
2. **認証**: Email/Password → Mock認証
3. **データ取得**: Provider → MockDataService → 静的データ返却
4. **状態管理**: `AppProvider` (ChangeNotifier) → UI更新
5. **永続化**: SharedPreferences（プロファイル情報のみ）

## 3. Firebase統合設計

### 3.1 Firebase サービス構成

#### 3.1.1 Firebase Authentication
- **目的**: ユーザー認証・セッション管理
- **機能**:
  - Email/Password認証
  - ユーザーセッション管理
  - パスワードリセット
  - アカウント削除

#### 3.1.2 Cloud Firestore
- **目的**: 構造化データの永続化
- **機能**:
  - ユーザープロファイル管理
  - 学習コンテンツ管理
  - 学習進捗データ
  - リアルタイム同期

#### 3.1.3 Firebase Remote Config（オプション）
- **目的**: アプリ設定の動的変更
- **機能**:
  - レベル・カテゴリの表示制御
  - 新機能のA/Bテスト
  - アプリ設定の遠隔更新

#### 3.1.4 Firebase Analytics（オプション）
- **目的**: 学習行動分析
- **機能**:
  - 学習セッション追跡
  - 完了率分析
  - ユーザー行動分析

### 3.2 Firestore データベース設計

#### 3.2.1 コレクション構造

```
/users/{userId}
├── profile (Profile情報)
├── progress (進捗情報)
├── favorites (お気に入り情報)
└── study_sessions (学習セッション履歴)

/levels/{levelId}
├── categories/{categoryId}
│   └── examples/{exampleId}

/app_content/
├── static_data (レベル・カテゴリ・例文データ)
└── configurations (アプリ設定)

/user_progress/{userId}/
├── examples/{exampleId} (例文別進捗)
├── categories/{categoryId} (カテゴリ別進捗)
└── levels/{levelId} (レベル別進捗)
```

#### 3.2.2 詳細データ構造

**users/{userId}**
```dart
{
  'id': 'user_uuid',
  'email': 'user@example.com',
  'name': 'ユーザー名',
  'isAuthenticated': true,
  'createdAt': Timestamp,
  'updatedAt': Timestamp,
  'profile': {
    // Profile モデルのJSON表現
    'ageGroup': '30代',
    'occupation': '会社員',
    'englishLevel': '中級',
    'hobbies': ['映画・ドラマ', '読書'],
    // ... その他のプロファイル情報
  }
}
```

**levels/{levelId}**
```dart
{
  'id': 'junior_high',
  'name': '中学レベル',
  'description': '基礎的な英文法と語彙',
  'order': 1,
  'isActive': true,
  'createdAt': Timestamp,
  'updatedAt': Timestamp
}
```

**levels/{levelId}/categories/{categoryId}**
```dart
{
  'id': 'be_verb',
  'name': 'be動詞',
  'description': 'be動詞の基本的な使い方・感情・状態表現',
  'levelId': 'junior_high',
  'order': 1,
  'isActive': true,
  'totalExamples': 10,
  'createdAt': Timestamp,
  'updatedAt': Timestamp
}
```

**levels/{levelId}/categories/{categoryId}/examples/{exampleId}**
```dart
{
  'id': 'be_001',
  'categoryId': 'be_verb',
  'levelId': 'junior_high',
  'japanese': '私は学生です。',
  'english': 'I am a student.',
  'hint': null,
  'order': 1,
  'isActive': true,
  'createdAt': Timestamp,
  'updatedAt': Timestamp
}
```

**user_progress/{userId}/examples/{exampleId}**
```dart
{
  'exampleId': 'be_001',
  'userId': 'user_uuid',
  'isCompleted': true,
  'isFavorite': false,
  'completedAt': Timestamp,
  'completedCount': 3,
  'lastStudiedAt': Timestamp,
  'studyTime': 120 // 秒
}
```

### 3.3 セキュリティルール

#### 3.3.1 Firestore セキュリティルール

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーデータアクセス制御
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // ユーザー進捗データアクセス制御
    match /user_progress/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 学習コンテンツ（読み取り専用）
    match /levels/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // 管理者のみ
    }
    
    // アプリ設定（読み取り専用）
    match /app_content/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // 管理者のみ
    }
  }
}
```

## 4. 実装計画

### 4.1 フェーズ1: Firebase基盤構築

#### 4.1.1 Firebase プロジェクト設定
1. Firebase プロジェクト作成
2. Flutter アプリへのFirebase追加
3. 認証設定（Email/Password）
4. Firestore データベース作成
5. セキュリティルール設定

#### 4.1.2 依存関係追加
```yaml
dependencies:
  # Firebase Core
  firebase_core: ^2.24.2
  
  # Authentication
  firebase_auth: ^4.15.3
  
  # Firestore
  cloud_firestore: ^4.13.6
  
  # Remote Config (オプション)
  firebase_remote_config: ^4.3.17
  
  # Analytics (オプション)
  firebase_analytics: ^10.7.4
```

### 4.2 フェーズ2: 認証システム移行

#### 4.2.1 AuthService 作成
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
}
```

#### 4.2.2 認証画面の更新
- `login_screen.dart`: Firebase Auth 統合
- `register_screen.dart`: Firebase Auth 統合
- エラーハンドリング強化

### 4.3 フェーズ3: データサービス移行

#### 4.3.1 FirestoreService 作成
```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ユーザー管理
  Future<void> createUserProfile(String userId, Profile profile);
  Future<Profile?> getUserProfile(String userId);
  Future<void> updateUserProfile(String userId, Profile profile);
  
  // 学習コンテンツ
  Future<List<Level>> getLevels();
  Future<Level?> getLevel(String levelId);
  Future<List<Category>> getCategories(String levelId);
  Future<List<Example>> getExamples(String categoryId);
  
  // 進捗管理
  Future<void> updateExampleProgress(String userId, String exampleId, bool isCompleted);
  Future<void> toggleFavorite(String userId, String exampleId);
  Future<UserProgress> getUserProgress(String userId);
  
  // リアルタイム監視
  Stream<Profile> watchUserProfile(String userId);
  Stream<UserProgress> watchUserProgress(String userId);
}
```

#### 4.3.2 AppProvider の更新
```dart
class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  // 認証状態監視
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<Profile>? _profileSubscription;
  StreamSubscription<UserProgress>? _progressSubscription;
  
  // 既存のメソッドをFirebaseに対応
  Future<bool> login(String email, String password);
  Future<bool> register(String email, String password, String name);
  Future<bool> saveProfile(Profile profile);
  // ...
}
```

### 4.4 フェーズ4: データ移行とコンテンツ管理

#### 4.4.1 静的データのFirestore移行
1. 現在の`MockDataService`からレベル・カテゴリ・例文データを抽出
2. Firestoreバッチ処理でデータ投入
3. データ整合性確認

#### 4.4.2 データ移行スクリプト
```dart
class DataMigrationService {
  Future<void> migrateStaticData() async {
    final batch = FirebaseFirestore.instance.batch();
    
    // レベルデータ移行
    for (final level in mockLevels) {
      final levelRef = FirebaseFirestore.instance
          .collection('levels')
          .doc(level.id);
      batch.set(levelRef, level.toFirestoreJson());
      
      // カテゴリデータ移行
      for (final category in level.categories) {
        final categoryRef = levelRef
            .collection('categories')
            .doc(category.id);
        batch.set(categoryRef, category.toFirestoreJson());
        
        // 例文データ移行
        for (final example in category.examples) {
          final exampleRef = categoryRef
              .collection('examples')
              .doc(example.id);
          batch.set(exampleRef, example.toFirestoreJson());
        }
      }
    }
    
    await batch.commit();
  }
}
```

### 4.5 フェーズ5: 高度な機能実装

#### 4.5.1 オフライン対応
- Firestore オフラインキャッシュ有効化
- ネットワーク状態監視
- 同期状態のUI表示

#### 4.5.2 リアルタイム機能
- 進捗のリアルタイム同期
- 複数デバイス間でのデータ同期

#### 4.5.3 分析機能
- Firebase Analytics 統合
- 学習パターン分析
- パフォーマンス監視

## 5. 実装上の考慮事項

### 5.1 パフォーマンス最適化

#### 5.1.1 データ取得最適化
- Composite Index 設計
- ページネーション実装
- キャッシュ戦略

#### 5.1.2 コスト最適化
- 読み取り回数の最小化
- 適切なセキュリティルール設計
- 不要なリアルタイム監視を避ける

### 5.2 エラーハンドリング

#### 5.2.1 ネットワークエラー
```dart
class FirebaseErrorHandler {
  static String getErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'ユーザーが見つかりません';
      case 'wrong-password':
        return 'パスワードが間違っています';
      case 'weak-password':
        return 'パスワードが弱すぎます';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています';
      default:
        return 'エラーが発生しました: ${e.message}';
    }
  }
}
```

#### 5.2.2 オフライン対応
```dart
class ConnectivityService {
  Stream<ConnectivityResult> get connectivityStream;
  bool get isOnline;
  
  Future<bool> checkInternetConnection();
  void handleOfflineMode();
  void handleOnlineMode();
}
```

### 5.3 テスト戦略

#### 5.3.1 Unit Tests
- AuthService のテスト
- FirestoreService のテスト（モック使用）
- データモデルのテスト

#### 5.3.2 Integration Tests
- 認証フローのテスト
- データ同期のテスト
- オフライン機能のテスト

#### 5.3.3 Firestore Emulator
```dart
void main() async {
  setUpAll(() async {
    // Firestore Emulator 接続
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  });
  
  // テストケース...
}
```

## 6. セキュリティ考慮事項

### 6.1 認証セキュリティ
- 強固なパスワード要件
- アカウントロックアウト機能
- 二要素認証（将来的な拡張）

### 6.2 データセキュリティ
- Firestore セキュリティルールの厳格化
- 個人情報の暗号化
- GDPR対応（データ削除要求）

### 6.3 アプリセキュリティ
- Firebase App Check（将来的）
- API キーの適切な管理
- セキュリティアップデートの定期適用

## 7. 移行スケジュール

### 週1: 環境構築
- Firebase プロジェクト作成
- Flutter プロジェクトへの統合
- 基本設定完了

### 週2-3: 認証システム
- AuthService 実装
- 認証画面の更新
- テスト実装

### 週4-5: データサービス
- FirestoreService 実装
- AppProvider 更新
- データモデル拡張

### 週6-7: データ移行
- 静的データのFirestore移行
- 移行スクリプト作成・実行
- データ整合性確認

### 週8: 最終調整・テスト
- 統合テスト
- パフォーマンス調整
- デプロイ準備

## 8. 運用・保守

### 8.1 監視
- Firebase Console でのメトリクス監視
- Crashlytics による問題追跡
- Performance Monitoring

### 8.2 バックアップ
- Firestore データのバックアップ戦略
- 災害復旧計画

### 8.3 アップデート
- コンテンツ更新プロセス
- アプリバージョン管理
- 段階的ロールアウト

## 9. 費用見積もり

### 9.1 Firebase 料金
- Firestore: 読み取り・書き込み回数ベース
- Authentication: 無料（基本機能）
- Storage: 使用量ベース
- Hosting: 使用量ベース

### 9.2 想定コスト
- 月間アクティブユーザー1,000人
- 1ユーザーあたり1日10回の学習セッション
- 月額約$10-30（使用パターンによる）

この仕様書に基づいて、Flash Composition AppをFirebaseと統合することで、スケーラブルで信頼性の高い学習プラットフォームを構築できます。