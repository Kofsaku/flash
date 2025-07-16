import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_auth_provider.dart';
import '../router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Static method to show search dialog from other widgets
  static void showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('検索'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: '例文を検索...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  '日本語または英語で例文を検索できます',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  searchController.dispose();
                  Navigator.pop(context);
                },
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () {
                  final query = searchController.text.trim();
                  searchController.dispose();
                  Navigator.pop(context);
                  if (query.isNotEmpty) {
                    AppDrawer._performSearch(context, query);
                  }
                },
                child: const Text('検索'),
              ),
            ],
          ),
    );
  }

  static void _performSearch(BuildContext context, String query) {
    // TODO: Implement actual search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('「$query」の検索結果（今後実装予定）'),
        action: SnackBarAction(label: '閉じる', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<FirebaseAuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;
              final email =
                  authProvider.currentUser?.email ?? 'メールアドレスが取得できません';

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(
                  user?.name ?? 'ニックネームを設定してください',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(email, style: const TextStyle(fontSize: 14)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue[600]),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('ホーム'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('マイページ'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('お気に入り'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.favorites);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('カテゴリー管理'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.categoryManagement);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('検索'),
            onTap: () {
              Navigator.pop(context);
              AppDrawer.showSearchDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('プロフィール編集'),
            onTap: () {
              Navigator.pop(context);
              _navigateToProfileEdit(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            onTap: () {
              Navigator.pop(context);
              _showSettingsDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('ヘルプ'),
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('ログアウト'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToProfileEdit(BuildContext context) {
    context.go(AppRouter.profileEdit);
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('設定'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('ダークモード'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ダークモードは今後実装予定です')),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('通知設定'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('通知設定は今後実装予定です')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('データのバックアップ'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('バックアップ機能は今後実装予定です')),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ヘルプ'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'アプリの使い方',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('1. レベルを選択して学習を開始'),
                Text('2. カテゴリーから好きなトピックを選択'),
                Text('3. 例文を見て英語で答える練習'),
                Text('4. お気に入りに登録して復習'),
                SizedBox(height: 16),
                Text(
                  'お困りの場合',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('プロフィール編集から学習設定を調整できます'),
                Text('設定からアプリの動作をカスタマイズできます'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ログアウト'),
            content: const Text('本当にログアウトしますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final authProvider = Provider.of<FirebaseAuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout();
                  if (context.mounted) {
                    context.go(AppRouter.login);
                  }
                },
                child: Text('ログアウト', style: TextStyle(color: Colors.red[600])),
              ),
            ],
          ),
    );
  }
}
