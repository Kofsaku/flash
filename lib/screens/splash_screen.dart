import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    try {
      print('Starting app initialization...');
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      print('Got app provider, calling initialize...');
      await appProvider.initialize();
      print('Initialize completed, waiting 2 seconds...');
      
      await Future.delayed(const Duration(seconds: 2));
      print('Wait completed, navigating to login...');
      
      if (mounted) {
        // ダミーデータなので常にログイン画面に遷移
        context.go(AppRouter.login);
        print('Navigation to login attempted');
      }
    } catch (e) {
      print('Initialization error: $e');
      if (mounted) {
        context.go(AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flash_on,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              '瞬間英作文',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Flash Composition',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'アプリを起動しています...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}