import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/level.dart';
import '../router.dart';
import '../widgets/app_drawer.dart';

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
            icon: const Icon(Icons.edit),
            onPressed: () => context.go(AppRouter.profileEdit),
            tooltip: 'プロフィール編集',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTodayProgress(appProvider),
                  const SizedBox(height: 20),
                  _buildWeeklyActivity(appProvider),
                  const SizedBox(height: 20),
                  _buildLevelProgress(appProvider),
                  const SizedBox(height: 20),
                  _buildStudyStats(appProvider),
                  const SizedBox(height: 20),
                  _buildRecommendations(appProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayProgress(AppProvider appProvider) {
    final todayCompleted = _getTodayCompleted(appProvider);
    final todayTarget = appProvider.currentUser?.dailyGoal ?? 10; // ユーザー設定の目標値
    final progress = (todayCompleted / todayTarget).clamp(0.0, 1.0);
    final user = appProvider.currentUser;
    final streak = _getStreakDays(appProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'こんにちは、${user?.name ?? 'ゲスト'}さん',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '今日の学習目標: $todayCompleted / $todayTarget 例文',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context.go(AppRouter.dailyGoalSetting),
                        child: Icon(
                          Icons.settings,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange[700],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak日',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress >= 1.0 ? '今日の目標達成！🎉' : '${(progress * 100).toInt()}% 完了',
            style: TextStyle(
              fontSize: 12,
              color: progress >= 1.0 ? Colors.green : Colors.grey[600],
              fontWeight: progress >= 1.0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivity(AppProvider appProvider) {
    final weekData = _getWeeklyData(appProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今週の学習活動',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final day in weekData)
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: day['completed'] > 0
                            ? Colors.blue.withValues(alpha: day['completed'] / 20)
                            : Colors.grey[100],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: day['isToday'] ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day['completed'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: day['completed'] > 0 ? Colors.blue[800] : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day['name'],
                      style: TextStyle(
                        fontSize: 10,
                        color: day['isToday'] ? Colors.blue : Colors.grey[600],
                        fontWeight: day['isToday'] ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  int _getTodayCompleted(AppProvider appProvider) {
    // モックデータ: 実際の実装では今日の完了数を取得
    // 今日は12時間のうち、どれくらい進んでいるかで計算
    final now = DateTime.now();
    final hourOfDay = now.hour;
    final baseCompleted = (hourOfDay * 0.6).floor(); // 1時間に0.6例文のペース
    return baseCompleted.clamp(0, 15); // 最大15例文
  }

  int _getStreakDays(AppProvider appProvider) {
    // TODO: 実際の連続学習日数を取得する実装
    return 5;
  }

  List<Map<String, dynamic>> _getWeeklyData(AppProvider appProvider) {
    final days = ['月', '火', '水', '木', '金', '土', '日'];
    final today = DateTime.now().weekday - 1;
    
    // モックデータ: 過去の学習パターンを生成
    final data = List.generate(7, (index) {
      if (index == today) {
        return _getTodayCompleted(appProvider);
      } else if (index < today) {
        // 過去の日は10-20の範囲でランダム
        return 10 + (index * 3) % 11;
      } else {
        // 未来の日は0
        return 0;
      }
    });
    
    return List.generate(7, (index) => {
      'name': days[index],
      'completed': data[index],
      'isToday': index == today,
    });
  }

  int _getAccuracyRate(AppProvider appProvider) {
    // TODO: 実際の正解率を計算する実装
    return 85;
  }

  List<Map<String, dynamic>> _getWeakCategories(AppProvider appProvider) {
    List<Map<String, dynamic>> weakCategories = [];
    
    try {
      for (final level in appProvider.levels) {
        for (final category in level.categories) {
          if (category.examples.isEmpty) continue;
          
          final completedExamples = category.examples.where((e) => e.isCompleted == true).length;
          final totalExamples = category.examples.length;
          final accuracy = _getCategoryAccuracy(category);
          
          // 苦手条件: 正解率が70%以下、または完了率が50%以下
          if ((accuracy < 70 && completedExamples > 0) || 
              (totalExamples > 0 && completedExamples / totalExamples < 0.5)) {
            weakCategories.add({
              'id': category.id,
              'name': category.name,
              'accuracyRate': accuracy,
              'completionRate': totalExamples > 0 ? (completedExamples / totalExamples * 100).toInt() : 0,
              'priority': accuracy < 50 ? 'high' : 'medium',
            });
          }
        }
      }
      
      // 正解率の低い順にソート
      weakCategories.sort((a, b) => (a['accuracyRate'] as int).compareTo(b['accuracyRate'] as int));
    } catch (e) {
      // Error occurred while calculating weak categories
    }
    
    return weakCategories;
  }
  
  int _getCategoryAccuracy(dynamic category) {
    if (category.examples == null || category.examples.isEmpty) return 100;
    
    final completedExamples = category.examples.where((e) => e.isCompleted == true);
    if (completedExamples.isEmpty) return 100; // 未学習の場合は100%として扱う
    
    // モックデータとして、カテゴリー名に基づいて正解率を計算
    final hash = category.name.hashCode;
    return 60 + (hash.abs() % 30); // 60-89%の範囲でランダムな正解率
  }
  
  List<Map<String, dynamic>> _getRecommendations(AppProvider appProvider) {
    List<Map<String, dynamic>> recommendations = [];
    
    try {
      // 1. 苦手カテゴリーの復習
      final weakCategories = _getWeakCategories(appProvider);
      for (final weak in weakCategories.take(2)) {
        recommendations.add({
          'type': 'review',
          'title': '${weak['name']}を復習',
          'subtitle': '正解率: ${weak['accuracyRate']}%',
          'icon': Icons.refresh,
          'color': Colors.orange,
          'action': () => context.go('${AppRouter.exampleList}?categoryId=${weak['id']}'),
        });
      }
      
      // 2. 未完了のカテゴリー
      final incompleteCategories = _getIncompleteCategories(appProvider);
      for (final incomplete in incompleteCategories.take(2)) {
        recommendations.add({
          'type': 'continue',
          'title': '${incomplete['name']}を続ける',
          'subtitle': '進捗: ${incomplete['completionRate']}%',
          'icon': Icons.play_arrow,
          'color': Colors.blue,
          'action': () => context.go('${AppRouter.exampleList}?categoryId=${incomplete['id']}'),
        });
      }
      
      // 3. お気に入りの復習
      final favoriteCategories = _getFavoriteCategories(appProvider);
      if (favoriteCategories.isNotEmpty) {
        final favorite = favoriteCategories.first;
        recommendations.add({
          'type': 'favorite',
          'title': 'お気に入りを復習',
          'subtitle': '${favorite['name']} (${favorite['count']}件)',
          'icon': Icons.favorite,
          'color': Colors.red,
          'action': () => context.go(AppRouter.favorites),
        });
      }
      
      // 4. 今日の目標達成のための提案
      final todayCompleted = _getTodayCompleted(appProvider);
      final todayTarget = appProvider.currentUser?.dailyGoal ?? 10;
      if (todayCompleted < todayTarget) {
        final remaining = todayTarget - todayCompleted;
        recommendations.add({
          'type': 'daily_goal',
          'title': '今日の目標達成',
          'subtitle': 'あと$remaining例文で目標達成！',
          'icon': Icons.flag,
          'color': Colors.green,
          'action': () => context.go(AppRouter.home),
        });
      }
    } catch (e) {
      // Error occurred while getting recommendations
    }
    
    return recommendations;
  }
  
  List<Map<String, dynamic>> _getIncompleteCategories(AppProvider appProvider) {
    List<Map<String, dynamic>> incomplete = [];
    
    try {
      for (final level in appProvider.levels) {
        for (final category in level.categories) {
          if (category.examples.isEmpty) continue;
          
          final completedExamples = category.examples.where((e) => e.isCompleted == true).length;
          final totalExamples = category.examples.length;
          final completionRate = totalExamples > 0 ? (completedExamples / totalExamples * 100).toInt() : 0;
          
          // 未完了条件: 完了率が80%以下で、1つ以上は完了している
          if (completionRate < 80 && completedExamples > 0) {
            incomplete.add({
              'id': category.id,
              'name': category.name,
              'completionRate': completionRate,
            });
          }
        }
      }
      
      // 完了率の高い順にソート（続けやすいものから）
      incomplete.sort((a, b) => (b['completionRate'] as int).compareTo(a['completionRate'] as int));
    } catch (e) {
      // Error occurred while getting incomplete categories
    }
    
    return incomplete;
  }
  
  List<Map<String, dynamic>> _getFavoriteCategories(AppProvider appProvider) {
    Map<String, Map<String, dynamic>> favoriteCounts = {};
    
    try {
      for (final level in appProvider.levels) {
        for (final category in level.categories) {
          if (category.examples.isEmpty) continue;
          
          final favoriteCount = category.examples.where((e) => e.isFavorite == true).length;
          if (favoriteCount > 0) {
            final categoryId = category.id;
            favoriteCounts[categoryId] = {
              'id': categoryId,
              'name': category.name,
              'count': favoriteCount,
            };
          }
        }
      }
      
      final result = favoriteCounts.values.toList();
      result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      
      return result;
    } catch (e) {
      // Error occurred while getting favorite categories
      return [];
    }
  }

  Widget _buildLevelProgress(AppProvider appProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'レベル別進捗',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRouter.home),
                child: const Text(
                  'すべて見る',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...appProvider.levels.take(3).map((level) => _buildCompactLevelProgress(level)),
        ],
      ),
    );
  }

  Widget _buildCompactLevelProgress(Level level) {
    final progress = level.progress;
    final color = _getLevelColor(level.order);

    return InkWell(
      onTap: () {
        context.go('${AppRouter.category}?levelId=${level.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  level.order.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        level.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${level.completedExamples}/${level.totalExamples}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyStats(AppProvider appProvider) {
    final totalCompleted = _getTotalCompleted(appProvider);
    final totalExamples = _getTotalExamples(appProvider);
    final favoriteCount = _getTotalFavorites(appProvider);
    final accuracyRate = _getAccuracyRate(appProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学習統計',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: '完了率',
                  value: '${((totalCompleted / totalExamples) * 100).toInt()}%',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: '正解率',
                  value: '$accuracyRate%',
                  icon: Icons.insights,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'お気に入り',
                  value: favoriteCount.toString(),
                  icon: Icons.favorite,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(AppProvider appProvider) {
    final recommendations = _getRecommendations(appProvider);
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'おすすめ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.take(4).map((recommendation) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: recommendation['action'],
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: recommendation['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: recommendation['color'].withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: recommendation['color'].withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          recommendation['icon'],
                          color: recommendation['color'],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendation['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: recommendation['color'],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              recommendation['subtitle'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: recommendation['color'].withValues(alpha: 0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalCompleted(AppProvider appProvider) {
    int total = 0;
    try {
      for (final level in appProvider.levels) {
        total += level.completedExamples;
      }
    } catch (e) {
      // Error occurred while calculating total completed
    }
    return total;
  }

  int _getTotalFavorites(AppProvider appProvider) {
    int total = 0;
    try {
      for (final level in appProvider.levels) {
        for (final category in level.categories) {
          if (category.examples.isNotEmpty) {
            total += category.examples.where((e) => e.isFavorite == true).length;
          }
        }
      }
    } catch (e) {
      // Error occurred while calculating total favorites
    }
    return total;
  }

  int _getTotalExamples(AppProvider appProvider) {
    int total = 0;
    try {
      for (final level in appProvider.levels) {
        total += level.totalExamples;
      }
    } catch (e) {
      // Error occurred while calculating total examples
    }
    return total;
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
      case 5:
        return Colors.red;
      case 6:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }


}