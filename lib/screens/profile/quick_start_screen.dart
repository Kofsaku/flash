import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user.dart';
import '../../router.dart';

class QuickStartScreen extends StatefulWidget {
  const QuickStartScreen({super.key});

  @override
  State<QuickStartScreen> createState() => _QuickStartScreenState();
}

class _QuickStartScreenState extends State<QuickStartScreen> {
  String? _selectedAgeGroup;
  String? _selectedEnglishLevel;
  String? _selectedLearningGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('クイックスタート'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'すぐに始める',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.flash_on, color: Colors.blue[600], size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'クイックスタート',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '最低限の情報で今すぐ学習を開始できます。\n後からいつでも詳細設定が可能です。',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSection(
                            '年齢層',
                            appProvider.mockDataService.ageGroups,
                            _selectedAgeGroup,
                            (value) => setState(() => _selectedAgeGroup = value),
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            '英語学習歴',
                            appProvider.mockDataService.englishLevels,
                            _selectedEnglishLevel,
                            (value) => setState(() => _selectedEnglishLevel = value),
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            '学習目標',
                            appProvider.mockDataService.learningGoals,
                            _selectedLearningGoal,
                            (value) => setState(() => _selectedLearningGoal = value),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'スマートデフォルト機能',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '・学習時間は1日15分に設定\n・趣味は人気の「映画・ドラマ」「読書」を選択\n・職業は「会社員」に設定\n・詳細はホーム画面から後で変更可能',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.go(AppRouter.profileStep1);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '詳細設定',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _canProceed() ? _handleQuickStart : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '学習開始',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedValue,
            onChanged: onChanged,
            activeColor: Colors.blue[600],
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  bool _canProceed() {
    return _selectedAgeGroup != null &&
        _selectedEnglishLevel != null &&
        _selectedLearningGoal != null;
  }

  void _handleQuickStart() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Creating quick profile
    
    // Create minimal profile with smart defaults
    final quickProfile = Profile(
      // Required selections
      ageGroup: _selectedAgeGroup,
      englishLevel: _selectedEnglishLevel,
      learningGoal: _selectedLearningGoal,
      
      // Smart defaults based on popularity
      occupation: '会社員',
      targetStudyMinutes: '15分',
      hobbies: ['映画・ドラマ', '読書'],
      industry: 'IT・テクノロジー',
      studyTime: ['朝（6-9時）'],
      lifestyle: ['健康志向'],
      challenges: ['継続するのが難しい'],
      
      // Optional fields left empty for later completion
      region: null,
      familyStructure: null,
      englishUsageScenarios: [],
      interestingTopics: [],
      learningStyles: [],
      skillLevels: {},
      studyEnvironments: [],
      weakAreas: [],
      motivationDetail: null,
      correctionStyle: null,
      encouragementFrequency: null,
    );
    
    final success = await appProvider.saveProfile(quickProfile);
    
    if (success && mounted) {
      context.go(AppRouter.loading);
    } else if (appProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}