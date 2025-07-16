import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/level.dart';
import '../services/mock_data_service.dart';
import 'firebase_auth_provider.dart';

class AppProvider extends ChangeNotifier {
  final MockDataService _mockDataService = MockDataService();
  FirebaseAuthProvider? _authProvider;
  
  User? _currentUser;
  List<Level> _levels = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  User? get currentUser => _authProvider?.currentUser ?? _currentUser;
  List<Level> get levels => _levels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authProvider?.isAuthenticated ?? (_currentUser?.isAuthenticated ?? false);

  void setAuthProvider(FirebaseAuthProvider authProvider) {
    _authProvider = authProvider;
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      await _mockDataService.initialize();
      _currentUser = _mockDataService.currentUser;
      _levels = _mockDataService.levels;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _mockDataService.login(email, password);
      // ログイン後、プロフィールが設定されている場合はパーソナライズされた例文数を反映
      _levels = await _mockDataService.getLevels();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _setLoading(true);
    try {
      _currentUser = await _mockDataService.register(email, password, name);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveProfile(Profile profile) async {
    _setLoading(true);
    try {
      await _mockDataService.saveProfile(profile);
      _currentUser = _mockDataService.currentUser;
      // プロフィール保存後、パーソナライズされた例文数を反映するためレベル情報を再読み込み
      _levels = await _mockDataService.getLevels();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserInfo(String name, String email) async {
    _setLoading(true);
    try {
      await _mockDataService.updateUserInfo(name, email);
      _currentUser = _mockDataService.currentUser;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDailyGoal(int dailyGoal) async {
    _setLoading(true);
    try {
      await _mockDataService.updateDailyGoal(dailyGoal);
      _currentUser = _mockDataService.currentUser;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadLevels() async {
    _setLoading(true);
    try {
      _levels = await _mockDataService.getLevels();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

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
      // パーソナライズ例文を含む例文リストを取得
      return await _mockDataService.getPersonalizedExamples(categoryId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// 基本例文のみを取得（パーソナライゼーション無し）
  Future<List<Example>> getBaseExamples(String categoryId) async {
    try {
      return await _mockDataService.getBaseExamples(categoryId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// パーソナライズ例文を含む例文リストを取得（明示的メソッド）
  Future<List<Example>> getPersonalizedExamples(String categoryId) async {
    try {
      return await _mockDataService.getPersonalizedExamples(categoryId);
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
        allExamples.addAll(category.examples);
      }
      
      allExamples.shuffle();
      return allExamples;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> updateExampleCompletion(String exampleId, bool isCompleted) async {
    try {
      await _mockDataService.updateExampleCompletion(exampleId, isCompleted);
      _levels = _mockDataService.levels;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String exampleId) async {
    try {
      await _mockDataService.toggleFavorite(exampleId);
      _levels = _mockDataService.levels;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _mockDataService.logout();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  MockDataService get mockDataService => _mockDataService;

  List<Category> getAllCategories() {
    List<Category> allCategories = [];
    for (final level in _levels) {
      allCategories.addAll(level.categories);
    }
    return allCategories;
  }

  List<Category> getCategoriesByLevel(String levelId) {
    final level = _levels.firstWhere(
      (level) => level.id == levelId,
      orElse: () => Level(id: '', name: '', description: '', order: 0),
    );
    return level.categories;
  }

  List<Category> searchCategories(String query) {
    if (query.isEmpty) return getAllCategories();
    
    final allCategories = getAllCategories();
    return allCategories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase()) ||
             category.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Category> getFilteredCategories({
    String? levelId,
    bool? isCompleted,
    String? searchQuery,
  }) {
    List<Category> categories;
    
    if (levelId != null) {
      categories = getCategoriesByLevel(levelId);
    } else {
      categories = getAllCategories();
    }
    
    if (isCompleted != null) {
      categories = categories.where((category) => category.isCompleted == isCompleted).toList();
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      categories = categories.where((category) {
        return category.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               category.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    return categories;
  }

  Map<String, dynamic> getCategoryStatistics() {
    final allCategories = getAllCategories();
    final completedCategories = allCategories.where((cat) => cat.isCompleted).length;
    final totalCategories = allCategories.length;
    
    Map<String, int> levelCategoryCounts = {};
    Map<String, int> levelCompletedCounts = {};
    
    for (final level in _levels) {
      levelCategoryCounts[level.name] = level.categories.length;
      levelCompletedCounts[level.name] = level.categories.where((cat) => cat.isCompleted).length;
    }
    
    return {
      'totalCategories': totalCategories,
      'completedCategories': completedCategories,
      'completionRate': totalCategories > 0 ? completedCategories / totalCategories : 0.0,
      'levelCategoryCounts': levelCategoryCounts,
      'levelCompletedCounts': levelCompletedCounts,
    };
  }

  List<Category> getFavoriteExampleCategories() {
    final allCategories = getAllCategories();
    return allCategories.where((category) {
      return category.examples.any((example) => example.isFavorite);
    }).toList();
  }

  List<Category> getRecentlyStudiedCategories() {
    final allCategories = getAllCategories();
    final categoriesWithRecentActivity = allCategories.where((category) {
      return category.examples.any((example) => 
        example.completedAt != null &&
        DateTime.now().difference(example.completedAt!).inDays <= 7
      );
    }).toList();
    
    categoriesWithRecentActivity.sort((a, b) {
      final aLatest = a.examples
          .where((e) => e.completedAt != null)
          .map((e) => e.completedAt!)
          .fold<DateTime?>(null, (latest, date) => 
            latest == null || date.isAfter(latest) ? date : latest);
      
      final bLatest = b.examples
          .where((e) => e.completedAt != null)
          .map((e) => e.completedAt!)
          .fold<DateTime?>(null, (latest, date) => 
            latest == null || date.isAfter(latest) ? date : latest);
      
      if (aLatest == null && bLatest == null) return 0;
      if (aLatest == null) return 1;
      if (bLatest == null) return -1;
      
      return bLatest.compareTo(aLatest);
    });
    
    return categoriesWithRecentActivity;
  }
}