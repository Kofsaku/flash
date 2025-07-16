import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../models/user.dart';
import '../models/level.dart';
import '../services/auth_service.dart';
import '../services/mock_data_service.dart';
import '../services/user_profile_service.dart';
import 'dart:async';

/// Firebase認証を使用するAppProvider
/// 既存のMockDataServiceと併用して段階的に移行
class FirebaseAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final MockDataService _mockDataService = MockDataService();
  final UserProfileService _profileService = UserProfileService();

  // ========== 状態変数 ==========
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFirstTimeUser = false;

  // 認証状態監視用
  StreamSubscription<firebase.User?>? _authSubscription;
  
  // 認証状態変更コールバック
  void Function()? _onAuthStateChanged;

  // ========== ゲッター ==========
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser?.isAuthenticated ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFirstTimeUser => _isFirstTimeUser;

  // MockDataServiceのデータにアクセス
  List<Level> get levels => _mockDataService.levels;

  // ========== 初期化 ==========
  FirebaseAuthProvider() {
    _initializeServices();
  }
  
  /// 認証状態変更時のコールバックを設定
  void setOnAuthStateChanged(void Function()? callback) {
    _onAuthStateChanged = callback;
  }

  Future<void> _initializeServices() async {
    try {
      _isLoading = true;
      notifyListeners();

      // MockDataServiceを初期化（学習データ用）
      await _mockDataService.initialize();

      // Firebase認証状態の監視を開始
      _initializeAuthListener();

      // 初期認証状態の確認を待つ
      await Future.delayed(const Duration(milliseconds: 1000));

      print(
        '🔐 FirebaseAuth初期化完了: isAuthenticated=$isAuthenticated, currentUser=${currentUser?.email}',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'サービス初期化エラー: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initializeAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((
      firebase.User? firebaseUser,
    ) {
      _handleAuthStateChange(firebaseUser);
    });
  }

  void _handleAuthStateChange(firebase.User? firebaseUser) async {
    try {
      if (firebaseUser != null) {
        print('🔐 認証状態変更: ログイン済み (${firebaseUser.email})');

        // FirebaseユーザーからアプリのUserオブジェクトを作成
        await _createUserFromFirebaseUser(firebaseUser);
      } else {
        print('🔐 認証状態変更: ログアウト');
        _currentUser = null;
        _errorMessage = null;
        // MockDataServiceからもユーザーをクリア
        _mockDataService.setCurrentUser(null);
      }

      notifyListeners();
      
      // コールバックを呼び出し
      _onAuthStateChanged?.call();
    } catch (e) {
      print('🔐 認証状態変更エラー: $e');
      _errorMessage = '認証状態の処理でエラーが発生しました: $e';
      notifyListeners();
    }
  }

  Future<void> _createUserFromFirebaseUser(firebase.User firebaseUser) async {
    try {
      // Firebaseからプロファイル情報を取得
      User? existingUser = await _profileService.getUserProfile();
      
      if (existingUser != null) {
        print('🔐 既存プロファイル読み込み成功: isCompleted=${existingUser.profile?.isCompleted}');
        _currentUser = existingUser;
      } else {
        print('🔐 新規ユーザーまたはプロファイルが見つかりません');
        
        // 新規ユーザーのUserオブジェクトを作成
        _currentUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? '',
          isAuthenticated: true,
          createdAt: DateTime.now(),
          dailyGoal: 10, // デフォルト値
        );
        
        // Firebaseに新規ユーザーを保存
        await _profileService.saveProfile(_currentUser!);
        print('🔐 新規ユーザープロファイル保存完了');
      }

      // MockDataServiceにもユーザーを設定（学習データ用）
      _mockDataService.setCurrentUser(_currentUser!);

      print('🔐 ユーザーオブジェクト作成完了: ${_currentUser!.email}');
      print('🔐 プロファイル状態: ${_currentUser!.profile?.isCompleted == true ? "完了" : "未完了"}');
    } catch (e) {
      print('🔐 ユーザーオブジェクト作成エラー: $e');
      throw Exception('ユーザー情報の作成に失敗しました: $e');
    }
  }

  // ========== 認証関連メソッド ==========

  /// Googleでサインイン
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      _isFirstTimeUser = false;

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        // Firebase側の新規ユーザー判定
        final isFirebaseNewUser =
            userCredential.additionalUserInfo?.isNewUser ?? false;

        // プロフィール完了状態を確認（認証状態変更後に_currentUserが設定される）
        // 少し待ってから現在のユーザー状態を確認
        await Future.delayed(const Duration(milliseconds: 500));

        // プロフィールが完了していない場合のみ初回ユーザーとして扱う
        final hasCompletedProfile = _currentUser?.profile?.isCompleted ?? false;
        _isFirstTimeUser = isFirebaseNewUser || !hasCompletedProfile;

        print('🔐 Google サインイン成功');
        print('🔐 Firebase新規ユーザー: $isFirebaseNewUser');
        print('🔐 プロフィール完了済み: $hasCompletedProfile');
        print('🔐 初回ユーザー判定: $_isFirstTimeUser');

        return true;
      } else {
        print('🔐 Google サインインがキャンセルされました');
        return false;
      }
    } catch (e) {
      print('🔐 Google サインインエラー: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// テストアカウントでサインイン（開発時のみ）
  Future<bool> signInWithTestAccount() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // テスト用のダミーユーザーを作成
      final testUser = User(
        id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@example.com',
        name: 'テストユーザー',
        profile: Profile(
          englishLevel: 'beginner',
          learningGoal: 'conversation',
          isCompleted: true,
        ),
        isAuthenticated: true,
      );

      _currentUser = testUser;
      _isFirstTimeUser = false;

      print('🔐 テストログイン成功');

      notifyListeners();
      return true;
    } catch (e) {
      print('🔐 テストログインエラー: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// メール/パスワードでログイン
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.signInWithEmailAndPassword(email, password);
      print('🔐 メール/パスワード ログイン成功');
      return true;
    } catch (e) {
      print('🔐 ログインエラー: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// メール/パスワードで新規登録
  Future<bool> register(String email, String password, String name) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.createUserWithEmailAndPassword(
        email,
        password,
        displayName: name,
      );

      print('🔐 新規登録成功');
      return true;
    } catch (e) {
      print('🔐 新規登録エラー: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// サインアウト
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      print('🔐 サインアウト完了');
    } catch (e) {
      print('🔐 サインアウトエラー: $e');
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// パスワードリセット
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.sendPasswordResetEmail(email);
      print('🔐 パスワードリセットメール送信成功');
      return true;
    } catch (e) {
      print('🔐 パスワードリセットエラー: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== プロファイル管理（MockDataServiceを使用） ==========

  /// プロファイル保存
  Future<bool> saveProfile(Profile profile) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      if (_currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      print('🔐 プロファイル保存開始: isCompleted=${profile.isCompleted}');
      print('🔐 ユーザーID: ${_currentUser!.id}');

      // 現在のユーザーオブジェクトを更新
      _currentUser = _currentUser!.copyWith(profile: profile);

      // Firebaseにプロファイルを保存
      await _profileService.saveProfile(_currentUser!);

      // MockDataServiceにも保存（学習データ用）
      await _mockDataService.saveProfile(profile);

      // プロフィール保存後、初回ユーザーフラグをリセット
      _isFirstTimeUser = false;

      // 保存確認のためのログ
      print('🔐 プロファイル保存成功');
      print(
        '🔐 保存されたプロファイル: isCompleted=${_currentUser!.profile?.isCompleted}',
      );
      print('🔐 初回ユーザーフラグリセット: $_isFirstTimeUser');

      notifyListeners();
      return true;
    } catch (e) {
      print('🔐 プロファイル保存エラー: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// ユーザー情報更新（ニックネーム）
  Future<bool> updateUserInfo(String name, String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      if (_currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      // Firebase側の表示名を更新
      await _authService.updateDisplayName(name);

      // 現在のユーザーオブジェクトを更新（ニックネームとして保存）
      _currentUser = _currentUser!.copyWith(name: name, email: email);

      // Firebaseにユーザー情報を保存
      await _profileService.updateUserInfo(name: name, email: email);

      print('🔐 ユーザー情報更新成功（ニックネーム: $name）');
      notifyListeners();
      return true;
    } catch (e) {
      print('🔐 ユーザー情報更新エラー: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 日次目標更新
  Future<bool> updateDailyGoal(int dailyGoal) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      if (_currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      print('🔐 ========== UPDATE DAILY GOAL ==========');
      print('🔐 Input dailyGoal = $dailyGoal');
      print('🔐 _currentUser?.dailyGoal (before) = ${_currentUser?.dailyGoal}');
      
      // 現在のユーザーオブジェクトを更新
      _currentUser = _currentUser!.copyWith(dailyGoal: dailyGoal);

      // Firebaseに日次目標を保存
      await _profileService.updateDailyGoal(dailyGoal);

      // MockDataServiceにも保存（学習データ用）
      await _mockDataService.updateDailyGoal(dailyGoal);

      print('🔐 _currentUser?.dailyGoal (after) = ${_currentUser?.dailyGoal}');
      print('🔐 MockDataService.currentUser?.dailyGoal = ${_mockDataService.currentUser?.dailyGoal}');
      print('🔐 日次目標更新成功: $dailyGoal');
      print('🔐 ======================================');
      
      notifyListeners();
      return true;
    } catch (e) {
      print('🔐 日次目標更新エラー: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== 学習データ関連（MockDataServiceを使用） ==========

  Future<Level?> getLevel(String levelId) async {
    try {
      return await _mockDataService.getLevel(levelId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Category?> getCategory(String categoryId) async {
    try {
      return await _mockDataService.getCategory(categoryId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Example>> getExamples(String categoryId) async {
    try {
      return await _mockDataService.getExamples(categoryId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Example>> getMixedExamples(String levelId) async {
    try {
      final level = await getLevel(levelId);
      if (level == null) return [];

      List<Example> allExamples = [];
      for (final category in level.categories) {
        final examples = await getExamples(category.id);
        allExamples.addAll(examples);
      }

      allExamples.shuffle();
      return allExamples;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Example>> getAllMixedExamples() async {
    try {
      List<Example> allExamples = [];
      for (final level in levels) {
        for (final category in level.categories) {
          final examples = await getExamples(category.id);
          allExamples.addAll(examples);
        }
      }
      allExamples.shuffle();
      return allExamples;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // 進捗管理（MockDataServiceを使用）
  Future<void> updateExampleCompletion(
    String exampleId,
    bool isCompleted,
  ) async {
    try {
      await _mockDataService.updateExampleCompletion(exampleId, isCompleted);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String exampleId) async {
    try {
      await _mockDataService.toggleFavorite(exampleId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  List<Example> getFavoriteExamples() {
    // return _mockDataService.getFavoriteExamples();
    return []; // 一時的に空リストを返す
  }

  // ========== ヘルパーメソッド ==========

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 現在のFirebaseユーザー情報を取得
  Map<String, dynamic>? getFirebaseUserInfo() {
    return _authService.getCurrentUserInfo();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
