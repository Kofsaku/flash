import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/level.dart';
import '../services/mock_data_service.dart';

class AppProvider extends ChangeNotifier {
  final MockDataService _mockDataService = MockDataService();
  
  User? _currentUser;
  List<Level> _levels = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  User? get currentUser => _currentUser;
  List<Level> get levels => _levels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser?.isAuthenticated ?? false;

  Future<void> initialize() async {
    try {
      await _mockDataService.initialize();
      _currentUser = _mockDataService.currentUser;
      _levels = _mockDataService.levels;
      _errorMessage = null;
      print('App initialization completed successfully');
    } catch (e) {
      _errorMessage = e.toString();
      print('App initialization error: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _mockDataService.login(email, password);
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
    } catch (e) {
      _errorMessage = e.toString();
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
      return await _mockDataService.getExamples(categoryId);
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
}