import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isSignUp = false; // 会員登録モードかどうか

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<FirebaseAuthProvider>(
      context,
      listen: false,
    );

    final success = await authProvider.signInWithGoogle();

    setState(() => _isLoading = false);

    if (success && mounted) {
      // 初回登録かどうかを判定
      if (authProvider.isFirstTimeUser) {
        context.go(AppRouter.profileSetup);
      } else {
        context.go(AppRouter.home);
      }
    } else if (authProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleTestLogin() async {
    setState(() => _isLoading = true);

    try {
      // シミュレーター用のテストログイン
      final authProvider = Provider.of<FirebaseAuthProvider>(
        context,
        listen: false,
      );
      final success = await authProvider.signInWithTestAccount();

      if (success && mounted) {
        context.go(AppRouter.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('テストログインエラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<FirebaseAuthProvider>(
          builder: (context, appProvider, child) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flash_on, size: 80, color: Colors.blue[600]),
                    const SizedBox(height: 16),
                    Text(
                      '瞬間英作文',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp ? '会員登録' : 'ログイン',
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),

                    // Googleサインインボタン
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed:
                            (_isLoading || appProvider.isLoading)
                                ? null
                                : _handleGoogleSignIn,
                        icon: Icon(
                          Icons.g_mobiledata,
                          size: 24,
                          color:
                              (_isLoading || appProvider.isLoading)
                                  ? Colors.grey
                                  : Colors.red[600],
                        ),
                        label: Text(
                          _isSignUp ? 'Googleで会員登録' : 'Googleでサインイン',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                (_isLoading || appProvider.isLoading)
                                    ? Colors.grey
                                    : Colors.red[600],
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                (_isLoading || appProvider.isLoading)
                                    ? Colors.grey
                                    : Colors.red[600]!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _isSignUp
                          ? 'Googleアカウントで会員登録してください'
                          : 'Googleアカウントでサインインしてください',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),

                    const SizedBox(height: 24),

                    // 会員登録/ログイン切り替え
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp ? 'すでにアカウントをお持ちですか？' : 'アカウントをお持ちでないですか？',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp ? 'ログイン' : '会員登録',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // デバッグ用のテストログイン（開発時のみ）
                    if (const bool.fromEnvironment('dart.vm.product') ==
                        false) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'デバッグ用（開発時のみ）',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleTestLogin,
                          child: const Text('テストログイン'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
