import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/level.dart';
import '../router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'メニュー',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go(AppRouter.home),
            tooltip: 'ホームに戻る',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(appProvider),
                  const SizedBox(height: 24),
                  _buildStatsSection(appProvider),
                  const SizedBox(height: 24),
                  _buildLearningProgressSection(appProvider),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(AppProvider appProvider) {
    final user = appProvider.currentUser;
    final completedTotal = _getTotalCompleted(appProvider);
    final totalExamples = _getTotalExamples(appProvider);
    final progressPercentage = totalExamples > 0 ? (completedTotal / totalExamples * 100).toDouble() : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue[600],
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'ゲストユーザー',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'guest@example.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getLevelIcon(progressPercentage),
                  color: Colors.blue[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _getLevelName(progressPercentage),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AppProvider appProvider) {
    final completedCount = _getTotalCompleted(appProvider);
    final favoriteCount = _getTotalFavorites(appProvider);
    final totalExamples = _getTotalExamples(appProvider);
    final studyDays = _getStudyDays(); // Mock data

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '学習統計',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.assignment_turned_in,
                value: completedCount.toString(),
                label: '完了済み',
                color: Colors.green,
                subtitle: '例文',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite,
                value: favoriteCount.toString(),
                label: 'お気に入り',
                color: Colors.red,
                subtitle: '例文',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.library_books,
                value: totalExamples.toString(),
                label: '総例文数',
                color: Colors.blue,
                subtitle: '例文',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                value: studyDays.toString(),
                label: '学習日数',
                color: Colors.orange,
                subtitle: '日',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningProgressSection(AppProvider appProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '学習進捗',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...appProvider.levels.map((level) => _buildLevelProgressCard(level)),
      ],
    );
  }

  Widget _buildLevelProgressCard(Level level) {
    final progress = level.progress;
    final color = _getLevelColor(level.order);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.go('${AppRouter.category}?levelId=${level.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    level.order.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${level.completedExamples}/${level.totalExamples} 例文完了',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'クイックアクション',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.favorite,
                label: 'お気に入り',
                color: Colors.red,
                onTap: () => context.go(AppRouter.favorites),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.home,
                label: 'ホームに戻る',
                color: Colors.blue,
                onTap: () => context.go(AppRouter.home),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalCompleted(AppProvider appProvider) {
    int total = 0;
    for (final level in appProvider.levels) {
      total += level.completedExamples;
    }
    return total;
  }

  int _getTotalFavorites(AppProvider appProvider) {
    int total = 0;
    for (final level in appProvider.levels) {
      for (final category in level.categories) {
        total += category.examples.where((e) => e.isFavorite).length;
      }
    }
    return total;
  }

  int _getTotalExamples(AppProvider appProvider) {
    int total = 0;
    for (final level in appProvider.levels) {
      total += level.totalExamples;
    }
    return total;
  }

  int _getStudyDays() {
    // Mock data - in real app, this would come from user statistics
    return 15;
  }

  Color _getLevelColor(int order) {
    switch (order) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getLevelIcon(double progressPercentage) {
    if (progressPercentage >= 80) return Icons.star;
    if (progressPercentage >= 60) return Icons.trending_up;
    if (progressPercentage >= 40) return Icons.school;
    if (progressPercentage >= 20) return Icons.play_circle_filled;
    return Icons.play_arrow;
  }

  String _getLevelName(double progressPercentage) {
    if (progressPercentage >= 80) return 'エキスパート';
    if (progressPercentage >= 60) return '上級者';
    if (progressPercentage >= 40) return '中級者';
    if (progressPercentage >= 20) return '初級者';
    return 'ビギナー';
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              final user = appProvider.currentUser;
              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(
                  user?.name ?? 'ゲストユーザー',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  user?.email ?? 'guest@example.com',
                  style: const TextStyle(fontSize: 14),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue[600],
                  ),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            onTap: () {
              Navigator.pop(context);
              _showSettingsDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('ヘルプ'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Help functionality
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  // TODO: ダークモード実装
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
}