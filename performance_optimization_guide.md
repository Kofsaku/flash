# Firebase統合 - パフォーマンス最適化ガイド

## 🚀 ローディング速度最適化

### 1. 段階的データ読み込み

**問題：** 全データを一度に読み込むと初期ローディングが遅い
**解決策：** 必要な分だけ段階的に読み込み

```dart
class OptimizedFirestoreService extends FirestoreService {
  
  // 1. レベルのメタデータのみを先に読み込み
  Future<List<Level>> getLevelsMetadataOnly() async {
    final snapshot = await _firestore
        .collection('levels')
        .orderBy('order')
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Level(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        order: data['order'] ?? 0,
        categories: [], // 空のリスト（後で読み込み）
      );
    }).toList();
  }
  
  // 2. 必要な時だけカテゴリーを読み込み
  Future<List<Category>> getCategoriesLazy(String levelId) async {
    final snapshot = await _firestore
        .collection('levels')
        .doc(levelId)
        .collection('categories')
        .orderBy('order')
        .limit(10) // 最初は10件のみ
        .get();
    
    // 例文は含めない（必要な時に別途読み込み）
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Category(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        levelId: levelId,
        order: data['order'] ?? 0,
        examples: [], // 空のリスト
      );
    }).toList();
  }
}
```

### 2. キャッシュ戦略

```dart
class CachedFirestoreService extends FirestoreService {
  // メモリキャッシュ
  static final Map<String, dynamic> _cache = {};
  static const Duration _cacheExpiry = Duration(minutes: 30);
  
  Future<List<Level>> getLevelsWithCache() async {
    const cacheKey = 'levels_metadata';
    
    // キャッシュチェック
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'] as List<Level>;
      }
    }
    
    // キャッシュがない場合は読み込み
    final levels = await getLevelsMetadataOnly();
    
    // キャッシュに保存
    _cache[cacheKey] = {
      'data': levels,
      'timestamp': DateTime.now(),
    };
    
    return levels;
  }
}
```

### 3. オフライン優先設定

```dart
// Firestore初期化時（main.dartで実行）
void configureFirestore() {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,   // オフラインキャッシュ有効
    cacheSizeBytes: 40000000,   // 40MB キャッシュ
  );
}
```

### 4. 進捗ローディングの最適化

```dart
class ProgressOptimizedProvider extends AppProvider {
  
  @override
  Future<void> _loadUserData(firebase.User user) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 1. ユーザープロファイルを最優先で読み込み
      final profile = await _firestoreService.getUserProfile(user.uid);
      _currentUser = User(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        isAuthenticated: true,
        profile: profile,
      );
      
      // この時点でUIを更新（プロファイルは表示可能）
      _isLoading = false;
      notifyListeners();
      
      // 2. レベルデータを非同期で読み込み（UI更新なし）
      _loadLevelsInBackground();
      
      // 3. 進捗データを非同期で読み込み（UI更新なし）
      _loadUserProgressInBackground();
      
    } catch (e) {
      _error = 'ユーザーデータの読み込みに失敗しました: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _loadLevelsInBackground() async {
    try {
      _levels = await _firestoreService.getLevelsWithCache();
      notifyListeners(); // レベルデータ読み込み完了を通知
    } catch (e) {
      print('Background level loading failed: $e');
    }
  }
  
  void _loadUserProgressInBackground() async {
    try {
      if (_currentUser != null) {
        _userProgress = await _firestoreService.getUserProgress(_currentUser!.id);
        notifyListeners(); // 進捗データ読み込み完了を通知
      }
    } catch (e) {
      print('Background progress loading failed: $e');
    }
  }
}
```

## ⚡ パフォーマンス指標

### 期待値（1000ユーザー規模）
- **初期ローディング**: 1-2秒
- **画面遷移**: 200-500ms
- **データ同期**: 100-300ms
- **オフライン復帰時**: 500-1000ms

### モニタリング方法

```dart
class PerformanceMonitor {
  static void measureLoadTime(String operation, Future<void> Function() task) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      await task();
      stopwatch.stop();
      
      // Firebase Analytics にパフォーマンスデータを送信
      await FirebaseAnalytics.instance.logEvent(
        name: 'performance_timing',
        parameters: {
          'operation': operation,
          'duration_ms': stopwatch.elapsedMilliseconds,
        },
      );
      
      print('$operation took ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      stopwatch.stop();
      print('$operation failed after ${stopwatch.elapsedMilliseconds}ms: $e');
    }
  }
}

// 使用例
await PerformanceMonitor.measureLoadTime('load_levels', () async {
  await _firestoreService.getLevels();
});
```