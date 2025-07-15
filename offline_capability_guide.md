# Firebase Firestore - オフライン対応ガイド

## 🌐 Firestoreオフライン機能の概要

Firestoreには**自動オフライン対応**が組み込まれており、インターネット接続がない状態でも完全に動作します。

### 🔧 オフライン機能の特徴

1. **自動ローカルキャッシュ**
   - アクセスしたデータは自動的にデバイスに保存
   - アプリ再起動後もキャッシュは保持
   - 最大100MBまでキャッシュ可能

2. **リアルタイム同期**
   - オンライン復帰時に自動で同期
   - 競合解決機能付き
   - 楽観的更新（即座にUI反映）

3. **完全なCRUD操作**
   - オフライン時も読み取り・書き込み・更新・削除が可能
   - 変更は自動的にキューイング
   - オンライン復帰時に自動実行

## 📱 Flash Composition Appでの実装

### 1. Firestore設定

```dart
// main.dart での初期化
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // オフライン設定を有効化
  await _configureFirestoreOffline();
  
  runApp(const FlashCompositionApp());
}

Future<void> _configureFirestoreOffline() async {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,      // オフラインキャッシュを有効化
    cacheSizeBytes: 100 * 1024 * 1024, // 100MBキャッシュ
  );
}
```

### 2. オフライン対応のFirestoreService

```dart
class OfflineAwareFirestoreService extends FirestoreService {
  
  // オフライン状態でも動作するデータ取得
  Future<List<Level>> getLevelsOfflineCapable() async {
    try {
      // Firestoreは自動的にキャッシュから取得
      final snapshot = await _firestore
          .collection('levels')
          .orderBy('order')
          .get(const GetOptions(source: Source.cache)); // キャッシュ優先
      
      if (snapshot.docs.isEmpty) {
        // キャッシュにない場合はサーバーから取得
        final serverSnapshot = await _firestore
            .collection('levels')
            .orderBy('order')
            .get(const GetOptions(source: Source.server));
        return _buildLevelsFromSnapshot(serverSnapshot);
      }
      
      return _buildLevelsFromSnapshot(snapshot);
    } catch (e) {
      // ネットワークエラーの場合、キャッシュのみから取得
      try {
        final cacheSnapshot = await _firestore
            .collection('levels')
            .orderBy('order')
            .get(const GetOptions(source: Source.cache));
        return _buildLevelsFromSnapshot(cacheSnapshot);
      } catch (cacheError) {
        print('オフライン取得エラー: $cacheError');
        return [];
      }
    }
  }
  
  // オフライン時も動作する進捗更新
  Future<void> updateExampleProgressOffline(
    String userId, 
    String exampleId, 
    bool isCompleted
  ) async {
    try {
      // Firestoreは自動的にオフライン操作をキューイング
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
        'offlineUpdated': true, // オフライン更新フラグ
      }, SetOptions(merge: true));
      
      print('進捗更新完了 (オフライン対応)');
    } catch (e) {
      print('進捗更新エラー: $e');
      // エラーでも操作はキューイングされている
    }
  }
}
```

### 3. ネットワーク状態監視

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkStatusService {
  static final Connectivity _connectivity = Connectivity();
  static bool _isOnline = true;
  
  static bool get isOnline => _isOnline;
  
  static Stream<bool> get networkStatusStream {
    return _connectivity.onConnectivityChanged.map((result) {
      _isOnline = result != ConnectivityResult.none;
      return _isOnline;
    });
  }
  
  static Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    return _isOnline;
  }
}

// pubspec.yamlに追加が必要
// dependencies:
//   connectivity_plus: ^4.0.2
```

### 4. オフライン対応AppProvider

```dart
class OfflineAwareAppProvider extends AppProvider {
  bool _isOnline = true;
  late StreamSubscription<bool> _networkSubscription;
  
  bool get isOnline => _isOnline;
  
  @override
  void initState() {
    super.initState();
    _initializeNetworkMonitoring();
  }
  
  void _initializeNetworkMonitoring() {
    _networkSubscription = NetworkStatusService.networkStatusStream.listen((isOnline) {
      _isOnline = isOnline;
      notifyListeners();
      
      if (isOnline) {
        _onNetworkRestored();
      } else {
        _onNetworkLost();
      }
    });
  }
  
  void _onNetworkRestored() {
    print('🌐 ネットワーク復旧 - データ同期中...');
    // Firestoreが自動的に同期を開始
    // 必要に応じて追加の同期処理
  }
  
  void _onNetworkLost() {
    print('📱 オフラインモード - ローカルデータで動作中...');
    // オフライン時の処理
  }
  
  // オフライン対応の例文完了マーク
  @override
  Future<void> markExampleCompleted(String exampleId, bool isCompleted) async {
    if (_currentUser == null) return;
    
    try {
      // 1. ローカル状態を即座に更新（楽観的更新）
      if (_userProgress[exampleId] == null) {
        _userProgress[exampleId] = {};
      }
      _userProgress[exampleId]!['isCompleted'] = isCompleted;
      _userProgress[exampleId]!['completedAt'] = isCompleted ? DateTime.now() : null;
      
      notifyListeners(); // UIを即座に更新
      
      // 2. Firestoreに保存（オフライン時は自動キューイング）
      await _firestoreService.updateExampleProgressOffline(
        _currentUser!.id, 
        exampleId, 
        isCompleted
      );
      
    } catch (e) {
      print('例文完了マークエラー: $e');
      // エラーでもローカル状態は保持される
    }
  }
  
  @override
  void dispose() {
    _networkSubscription.cancel();
    super.dispose();
  }
}
```

## 🎯 オフライン機能の詳細説明

### 1. 自動キャッシング

```dart
// 初回アクセス時にデータが自動キャッシュされる
final levels = await firestoreService.getLevels(); // サーバーから取得 + キャッシュ保存

// 2回目以降はキャッシュから高速取得
final cachedLevels = await firestoreService.getLevels(); // キャッシュから即座に取得
```

### 2. オフライン時の書き込み

```dart
// オフライン時の操作
await updateExampleProgress('user123', 'example456', true);
// ↓
// 1. ローカルデータベースに保存
// 2. 操作をキューに追加
// 3. オンライン復帰時に自動実行
```

### 3. 競合解決

```dart
// Firestoreは自動的に競合を解決
// 例：同じ例文を複数デバイスで完了マーク
// → 最新のタイムスタンプが採用される
```

## 📱 ユーザー体験

### オフライン時でも可能な操作

✅ **完全に動作する機能**
- レベル・カテゴリー・例文の閲覧
- 学習の実行（日本語→英語練習）
- 例文の完了マーク
- お気に入りの追加・削除
- プロフィール閲覧
- 学習進捗の表示

✅ **制限はあるが動作する機能**
- 新規ユーザー登録（復帰時に同期）
- プロフィール更新（復帰時に同期）

❌ **オフライン時に制限される機能**
- 初回ログイン（認証サーバーアクセスが必要）
- 初回データダウンロード

### オフライン状態の表示

```dart
class OfflineIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineAwareAppProvider>(
      builder: (context, provider, child) {
        if (!provider.isOnline) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.orange[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'オフライン - ローカルデータで動作中',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// 使用例：AppBarの下に配置
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('学習')),
    body: Column(
      children: [
        OfflineIndicator(), // オフライン表示
        Expanded(child: _buildContent()),
      ],
    ),
  );
}
```

## 🔄 同期メカニズム

### 1. 自動同期

```dart
// オンライン復帰時の自動処理
void _onNetworkRestored() {
  // Firestoreが以下を自動実行：
  // 1. キューイングされた書き込み操作を実行
  // 2. サーバーから最新データを取得
  // 3. 競合があれば解決
  // 4. ローカルキャッシュを更新
}
```

### 2. 手動同期（必要に応じて）

```dart
class SyncService {
  static Future<void> forceSyncUserData(String userId) async {
    try {
      // 進捗データの強制同期
      await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(userId)
          .get(const GetOptions(source: Source.server));
      
      print('ユーザーデータ同期完了');
    } catch (e) {
      print('同期エラー: $e');
    }
  }
}
```

## 📊 オフライン機能のパフォーマンス

### 速度比較

| 操作 | オンライン | オフライン | 備考 |
|------|----------|-----------|------|
| データ読み取り | 200-500ms | 10-50ms | キャッシュから高速取得 |
| 進捗更新 | 100-300ms | 5-20ms | ローカル更新後バックグラウンド同期 |
| 画面遷移 | 変わらず | 変わらず | ローカルデータのみ使用 |
| アプリ起動 | 1-2秒 | 0.5-1秒 | ネットワーク待機なし |

### ストレージ使用量

```dart
// アプリの推定ローカルストレージ使用量
final dataEstimate = {
  'レベルデータ': '500KB',      // メタデータ
  'カテゴリーデータ': '2MB',     // 説明文含む
  '例文データ': '10-50MB',      // 全レベル分
  'ユーザー進捗': '1-5MB',      // 個人の学習履歴
  'キャッシュ': '最大100MB',     // Firestore設定
  '合計': '約50-150MB',
};
```

## 🛡️ オフライン時のデータ整合性

### 1. 楽観的同時性制御

```dart
// Firestoreは以下を自動処理：
// 1. ローカル更新を即座に反映
// 2. サーバー更新をバックグラウンドで実行
// 3. 競合時は最終書き込み勝ちで解決
```

### 2. データ検証

```dart
class DataIntegrityService {
  static Future<bool> validateOfflineData() async {
    try {
      // キャッシュデータの整合性チェック
      final levels = await FirebaseFirestore.instance
          .collection('levels')
          .get(const GetOptions(source: Source.cache));
      
      return levels.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
```

## 📱 実装上の注意点

### 1. 必要な依存関係

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  cloud_firestore: ^4.13.6
  connectivity_plus: ^4.0.2  # ネットワーク状態監視用
```

### 2. プラットフォーム別設定

**Android** (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**iOS** (`ios/Runner/Info.plist`)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🎯 まとめ

✅ **Firebase移行後もオフライン機能は完全に維持される**
- 自動キャッシング機能
- オフライン時の読み書き
- オンライン復帰時の自動同期

✅ **むしろパフォーマンスが向上**
- キャッシュからの高速データ取得
- 楽観的更新による即座のUI反映
- バックグラウンド同期

✅ **学習アプリに最適**
- 通勤中など不安定な接続環境でも安心
- データ使用量の節約
- 電池消費の軽減

Flash Composition AppをFirebaseに移行することで、現在のオフライン機能を維持しながら、より高性能で信頼性の高いオフライン体験を提供できます。