import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user.dart';
import '../../router.dart';
import '../../widgets/progress_indicator.dart';

class ProfileStep5Screen extends StatefulWidget {
  const ProfileStep5Screen({super.key});

  @override
  State<ProfileStep5Screen> createState() => _ProfileStep5ScreenState();
}

class _ProfileStep5ScreenState extends State<ProfileStep5Screen> {
  final List<String> _selectedLearningStyles = [];
  final Map<String, String> _skillLevels = {
    'speaking': '',
    'listening': '',
    'reading': '',
    'writing': '',
  };
  final List<String> _selectedStudyEnvironments = [];
  final List<String> _selectedWeakAreas = [];
  String? _selectedMotivationDetail;
  String? _selectedCorrectionStyle;
  String? _selectedEncouragementFrequency;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingProfile();
    });
  }

  void _loadExistingProfile() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final profile = appProvider.currentUser?.profile;
    
    if (profile != null) {
      print('Step5: Loading existing profile data');
      setState(() {
        _selectedLearningStyles.clear();
        _selectedLearningStyles.addAll(profile.learningStyles);
        
        _skillLevels.clear();
        _skillLevels.addAll(profile.skillLevels);
        
        _selectedStudyEnvironments.clear();
        _selectedStudyEnvironments.addAll(profile.studyEnvironments);
        
        _selectedWeakAreas.clear();
        _selectedWeakAreas.addAll(profile.weakAreas);
        
        _selectedMotivationDetail = profile.motivationDetail;
        _selectedCorrectionStyle = profile.correctionStyle;
        _selectedEncouragementFrequency = profile.encouragementFrequency;
      });
    }
  }

  final List<String> _learningStyles = [
    '視覚的学習（図表、テキスト）',
    '聴覚的学習（音声、会話）',
    '体験的学習（実践、反復）',
    'ゲーム要素があると続く',
    '短時間集中型',
    'じっくり理解型',
  ];

  final List<String> _skillLevelOptions = ['苦手', '普通', '得意'];

  final List<String> _studyEnvironments = [
    '通勤電車内（立ち）',
    '通勤電車内（座り）',
    '自宅のデスク',
    'カフェ・外出先',
    'ベッド・ソファ',
    '歩きながら',
  ];

  final List<String> _weakAreas = [
    '発音・アクセント',
    '文法・語順',
    '語彙・単語',
    'リスニング',
    '読解・理解',
    '会話・コミュニケーション',
  ];

  final List<String> _motivationDetails = [
    '1ヶ月以内に成果が欲しい',
    '3ヶ月以内に成果が欲しい',
    '半年以内に成果が欲しい',
    '1年以内に成果が欲しい',
    'マイペースで続けたい',
  ];

  final List<String> _correctionStyles = [
    '優しく指摘してほしい',
    '詳しく説明してほしい',
    '簡潔に修正してほしい',
    '励ましながら教えてほしい',
  ];

  final List<String> _encouragementFrequencies = [
    '毎回励ましてほしい',
    '時々励ましてほしい',
    '最小限でよい',
    '成果が出た時だけ',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール設定'),
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
                  const StepProgressIndicator(
                    currentStep: 5,
                    totalSteps: 5,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '学習特性診断',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'あなたの学習スタイルを診断します。\nより効果的な学習方法を提案します。\n（すべて任意項目です）',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildCheckboxSection(
                            '学習スタイル',
                            '任意',
                            _learningStyles,
                            _selectedLearningStyles,
                            (value, checked) {
                              setState(() {
                                if (checked) {
                                  _selectedLearningStyles.add(value);
                                } else {
                                  _selectedLearningStyles.remove(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildSkillLevelSection(),
                          const SizedBox(height: 24),
                          _buildCheckboxSection(
                            '学習環境',
                            '任意',
                            _studyEnvironments,
                            _selectedStudyEnvironments,
                            (value, checked) {
                              setState(() {
                                if (checked) {
                                  _selectedStudyEnvironments.add(value);
                                } else {
                                  _selectedStudyEnvironments.remove(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildCheckboxSection(
                            '苦手分野',
                            '任意',
                            _weakAreas,
                            _selectedWeakAreas,
                            (value, checked) {
                              setState(() {
                                if (checked) {
                                  _selectedWeakAreas.add(value);
                                } else {
                                  _selectedWeakAreas.remove(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildRadioSection(
                            '学習の動機・目標',
                            '任意',
                            _motivationDetails,
                            _selectedMotivationDetail,
                            (value) => setState(() => _selectedMotivationDetail = value),
                          ),
                          const SizedBox(height: 24),
                          _buildRadioSection(
                            '修正・指摘の方法',
                            '任意',
                            _correctionStyles,
                            _selectedCorrectionStyle,
                            (value) => setState(() => _selectedCorrectionStyle = value),
                          ),
                          const SizedBox(height: 24),
                          _buildRadioSection(
                            '励ましの頻度',
                            '任意',
                            _encouragementFrequencies,
                            _selectedEncouragementFrequency,
                            (value) => setState(() => _selectedEncouragementFrequency = value),
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
                            context.go(AppRouter.profileStep4);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.blue[600]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '戻る',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: appProvider.isLoading ? null : _handleComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: appProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  '完了',
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

  Widget _buildCheckboxSection(
    String title,
    String required,
    List<String> options,
    List<String> selectedValues,
    Function(String, bool) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                required,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...options.map((option) {
          return CheckboxListTile(
            title: Text(option, style: const TextStyle(fontSize: 14)),
            value: selectedValues.contains(option),
            onChanged: (checked) => onChanged(option, checked ?? false),
            activeColor: Colors.blue[600],
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRadioSection(
    String title,
    String required,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                required,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option, style: const TextStyle(fontSize: 14)),
            value: option,
            groupValue: selectedValue,
            onChanged: onChanged,
            activeColor: Colors.blue[600],
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSkillLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'スキル別自己評価',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '任意',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._skillLevels.keys.map((skill) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSkillDisplayName(skill),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: _skillLevelOptions.map((level) {
                    return SizedBox(
                      width: 120,
                      child: RadioListTile<String>(
                        title: Text(level, style: const TextStyle(fontSize: 12)),
                        value: level,
                        groupValue: _skillLevels[skill],
                        onChanged: (value) {
                          setState(() {
                            _skillLevels[skill] = value ?? '';
                          });
                        },
                        activeColor: Colors.blue[600],
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getSkillDisplayName(String skill) {
    switch (skill) {
      case 'speaking':
        return 'スピーキング';
      case 'listening':
        return 'リスニング';
      case 'reading':
        return 'リーディング';
      case 'writing':
        return 'ライティング';
      default:
        return skill;
    }
  }

  void _handleComplete() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentProfile = appProvider.currentUser?.profile;
    
    print('Step5: Saving final profile with learningStyles: $_selectedLearningStyles, skillLevels: $_skillLevels');
    
    // Create updated profile with learning characteristics
    final updatedProfile = currentProfile?.copyWith(
      learningStyles: _selectedLearningStyles,
      skillLevels: _skillLevels,
      studyEnvironments: _selectedStudyEnvironments,
      weakAreas: _selectedWeakAreas,
      motivationDetail: _selectedMotivationDetail,
      correctionStyle: _selectedCorrectionStyle,
      encouragementFrequency: _selectedEncouragementFrequency,
    ) ?? Profile(
      learningStyles: _selectedLearningStyles,
      skillLevels: _skillLevels,
      studyEnvironments: _selectedStudyEnvironments,
      weakAreas: _selectedWeakAreas,
      motivationDetail: _selectedMotivationDetail,
      correctionStyle: _selectedCorrectionStyle,
      encouragementFrequency: _selectedEncouragementFrequency,
    );
    
    final success = await appProvider.saveProfile(updatedProfile);
    
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