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

  
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<FirebaseAuthProvider>(context, listen: false);
    
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
                      Icon(
                        Icons.flash_on,
                        size: 80,
                        color: Colors.blue[600],
                      ),
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
                        'ログイン',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Googleサインインボタン
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: (_isLoading || appProvider.isLoading) ? null : _handleGoogleSignIn,
                          icon: Icon(
                            Icons.g_mobiledata,
                            size: 24,
                            color: (_isLoading || appProvider.isLoading) ? Colors.grey : Colors.red[600],
                          ),
                          label: Text(
                            'Googleでサインイン',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: (_isLoading || appProvider.isLoading) ? Colors.grey : Colors.red[600],
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: (_isLoading || appProvider.isLoading) ? Colors.grey : Colors.red[600]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      Text(
                        'Googleアカウントでサインインしてください',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
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