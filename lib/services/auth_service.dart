import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication サービス
/// Gmail認証とメール/パスワード認証を提供
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // 現在のユーザー
  User? get currentUser => _auth.currentUser;
  
  // 認証状態の監視
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // 認証済みかどうか
  bool get isAuthenticated => _auth.currentUser != null;
  
  /// Gmail（Google）でサインイン
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('🔐 Google サインイン開始');
      }
      
      // Google サインインフローを開始
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        if (kDebugMode) {
          print('🔐 Google サインインがキャンセルされました');
        }
        return null; // ユーザーがキャンセルした場合
      }
      
      if (kDebugMode) {
        print('🔐 Google アカウント取得: ${googleUser.email}');
      }
      
      // Google 認証情報を取得
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Firebase 認証情報を作成
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Firebase にサインイン
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (kDebugMode) {
        print('🔐 Firebase サインイン成功: ${userCredential.user?.email}');
      }
      
      return userCredential;
      
    } catch (e) {
      if (kDebugMode) {
        print('🔐 Google サインインエラー: $e');
      }
      throw _handleAuthException(e);
    }
  }
  
  /// メール/パスワードでサインイン
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      if (kDebugMode) {
        print('🔐 メール/パスワード サインイン開始: $email');
      }
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      
      if (kDebugMode) {
        print('🔐 メール/パスワード サインイン成功: ${userCredential.user?.email}');
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('🔐 メール/パスワード サインインエラー: ${e.code}');
      }
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('🔐 サインインエラー: $e');
      }
      throw Exception('サインインに失敗しました: $e');
    }
  }
  
  /// メール/パスワードでアカウント作成
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password,
    {String? displayName}
  ) async {
    try {
      if (kDebugMode) {
        print('🔐 アカウント作成開始: $email');
      }
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      
      // 表示名を設定
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }
      
      if (kDebugMode) {
        print('🔐 アカウント作成成功: ${userCredential.user?.email}');
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('🔐 アカウント作成エラー: ${e.code}');
      }
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('🔐 アカウント作成エラー: $e');
      }
      throw Exception('アカウント作成に失敗しました: $e');
    }
  }
  
  /// サインアウト
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print('🔐 サインアウト開始');
      }
      
      // Google サインアウト
      await _googleSignIn.signOut();
      
      // Firebase サインアウト
      await _auth.signOut();
      
      if (kDebugMode) {
        print('🔐 サインアウト完了');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔐 サインアウトエラー: $e');
      }
      throw Exception('サインアウトに失敗しました: $e');
    }
  }
  
  /// パスワードリセットメール送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (kDebugMode) {
        print('🔐 パスワードリセットメール送信: $email');
      }
      
      await _auth.sendPasswordResetEmail(email: email.trim());
      
      if (kDebugMode) {
        print('🔐 パスワードリセットメール送信完了');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('🔐 パスワードリセットエラー: ${e.code}');
      }
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('🔐 パスワードリセットエラー: $e');
      }
      throw Exception('パスワードリセットに失敗しました: $e');
    }
  }
  
  /// アカウント削除
  Future<void> deleteAccount() async {
    try {
      if (kDebugMode) {
        print('🔐 アカウント削除開始');
      }
      
      await _auth.currentUser?.delete();
      
      if (kDebugMode) {
        print('🔐 アカウント削除完了');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('🔐 アカウント削除エラー: ${e.code}');
      }
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('🔐 アカウント削除エラー: $e');
      }
      throw Exception('アカウント削除に失敗しました: $e');
    }
  }
  
  /// ユーザー情報更新
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (kDebugMode) {
        print('🔐 表示名更新完了: $displayName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔐 表示名更新エラー: $e');
      }
      throw Exception('表示名の更新に失敗しました: $e');
    }
  }
  
  /// 現在のユーザー情報を取得
  Map<String, dynamic>? getCurrentUserInfo() {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'emailVerified': user.emailVerified,
      'isAnonymous': user.isAnonymous,
      'creationTime': user.metadata.creationTime,
      'lastSignInTime': user.metadata.lastSignInTime,
      'providerData': user.providerData.map((info) => {
        'providerId': info.providerId,
        'uid': info.uid,
        'email': info.email,
        'displayName': info.displayName,
        'photoURL': info.photoURL,
      }).toList(),
    };
  }
  
  /// Firebase Auth エラーハンドリング
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'このメールアドレスのアカウントが見つかりません';
      case 'wrong-password':
        return 'パスワードが間違っています';
      case 'weak-password':
        return 'パスワードが弱すぎます（6文字以上で設定してください）';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています';
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません';
      case 'user-disabled':
        return 'このアカウントは無効になっています';
      case 'too-many-requests':
        return 'しばらく時間をおいてから再度お試しください';
      case 'operation-not-allowed':
        return 'この認証方法は現在利用できません';
      case 'invalid-credential':
        return '認証情報が無効です';
      case 'account-exists-with-different-credential':
        return '別の認証方法で既に登録されているアカウントです';
      case 'credential-already-in-use':
        return 'この認証情報は既に別のアカウントで使用されています';
      case 'requires-recent-login':
        return 'セキュリティのため、再度ログインしてください';
      default:
        return '認証エラーが発生しました: ${e.message ?? e.code}';
    }
  }
  
  /// 一般的なエラーハンドリング
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      return _handleFirebaseAuthException(e);
    }
    
    if (e.toString().contains('network')) {
      return 'ネットワーク接続を確認してください';
    }
    
    return '認証エラーが発生しました: $e';
  }
}