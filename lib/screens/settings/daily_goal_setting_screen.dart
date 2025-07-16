import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../widgets/app_drawer.dart';

class DailyGoalSettingScreen extends StatefulWidget {
  const DailyGoalSettingScreen({super.key});

  @override
  State<DailyGoalSettingScreen> createState() => _DailyGoalSettingScreenState();
}

class _DailyGoalSettingScreenState extends State<DailyGoalSettingScreen> {
  int _selectedGoal = 50; // デフォルト値
  final List<int> _goalOptions = [20, 50, 100, 150, 200, 300];

  @override
  void initState() {
    super.initState();
    // 現在の設定値を読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<FirebaseAuthProvider>(context, listen: false);
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final currentGoal = authProvider.currentUser?.dailyGoal ?? 50;
      
      // 詳細デバッグ
      print('🎯 ========== GOAL SETTING DEBUG ==========');
      print('🎯 authProvider.currentUser = ${authProvider.currentUser}');
      print('🎯 authProvider.currentUser?.dailyGoal = ${authProvider.currentUser?.dailyGoal}');
      print('🎯 appProvider.currentUser = ${appProvider.currentUser}');
      print('🎯 appProvider.currentUser?.dailyGoal = ${appProvider.currentUser?.dailyGoal}');
      print('🎯 currentGoal (final) = $currentGoal');
      print('🎯 =========================================');
      
      setState(() {
        _selectedGoal = currentGoal;
      });
    });
  }

  Future<void> _saveGoal() async {
    final authProvider = Provider.of<FirebaseAuthProvider>(context, listen: false);

    print('💾 ========== SAVING DAILY GOAL ==========');
    print('💾 _selectedGoal = $_selectedGoal');
    print('💾 authProvider.currentUser?.dailyGoal (before) = ${authProvider.currentUser?.dailyGoal}');
    
    try {
      final success = await authProvider.updateDailyGoal(_selectedGoal);
      
      print('💾 updateDailyGoal success = $success');
      print('💾 authProvider.currentUser?.dailyGoal (after) = ${authProvider.currentUser?.dailyGoal}');
      print('💾 ========================================');

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('1日の学習目標を更新しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('目標の更新に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1日の学習目標'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveGoal,
            child: const Text(
              '保存',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.flag, size: 48, color: Colors.blue[600]),
                  const SizedBox(height: 16),
                  Text(
                    '現在の目標',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1日 $_selectedGoal 例文',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              '1日の学習目標を選択してください',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '無理のない範囲で継続できる目標を設定しましょう',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            ...(_goalOptions.map((goal) => _buildGoalOption(goal))),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '目標設定のコツ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• 最初は少ない数から始めて、慣れてきたら増やしましょう\n• 平日と休日で時間の取れ方が違うことを考慮しましょう\n• 継続が最も重要です。無理をせず続けられる目標にしましょう\n• 1例文につき約10-20秒程度です（考える時間含む）',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '所要時間の目安',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._goalOptions.map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_getTimeDescription((goal * 0.3).toInt())}'),
                          Text(
                            '$goal例文',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildGoalOption(int goal) {
    final isSelected = _selectedGoal == goal;
    final estimatedMinutes = (goal * 0.3).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGoal = goal;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.blue[600] : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Colors.blue[600]! : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getTimeDescription(estimatedMinutes)} - $goal例文',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.blue[600] : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getGoalDescription(goal)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Colors.blue[600], size: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeDescription(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}時間で完了';
      } else {
        return '${hours}時間${remainingMinutes}分で完了';
      }
    } else {
      return '${minutes}分で完了';
    }
  }

  String _getGoalDescription(int goal) {
    if (goal <= 30) return '(初心者向け)';
    if (goal <= 100) return '(標準)';
    if (goal <= 200) return '(やる気十分)';
    return '(上級者向け)';
  }
}
