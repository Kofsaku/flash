import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user.dart';
import '../../router.dart';
import '../../widgets/progress_indicator.dart';

class ProfileStep3Screen extends StatefulWidget {
  const ProfileStep3Screen({super.key});

  @override
  State<ProfileStep3Screen> createState() => _ProfileStep3ScreenState();
}

class _ProfileStep3ScreenState extends State<ProfileStep3Screen> {
  String? _selectedLearningGoal;
  final List<String> _selectedStudyTimes = [];
  String? _selectedTargetStudyMinutes;
  final List<String> _selectedChallenges = [];

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
      // Loading existing profile data
      setState(() {
        _selectedLearningGoal = profile.learningGoal;
        _selectedStudyTimes.clear();
        _selectedStudyTimes.addAll(profile.studyTime);
        _selectedTargetStudyMinutes = profile.targetStudyMinutes;
        _selectedChallenges.clear();
        _selectedChallenges.addAll(profile.challenges);
      });
    }
  }

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
                    currentStep: 3,
                    totalSteps: 5,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '学習環境・目標',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'あなたの学習環境と目標を教えてください。\n継続しやすい学習プランを提案します。',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildRadioSection(
                            '学習目標',
                            '任意',
                            appProvider.mockDataService.learningGoals,
                            _selectedLearningGoal,
                            (value) => setState(() => _selectedLearningGoal = value),
                          ),
                          const SizedBox(height: 24),
                          _buildCheckboxSection(
                            '学習時間帯',
                            '任意',
                            appProvider.mockDataService.studyTimes,
                            _selectedStudyTimes,
                            (value, checked) {
                              setState(() {
                                if (checked) {
                                  _selectedStudyTimes.add(value);
                                } else {
                                  _selectedStudyTimes.remove(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildRadioSection(
                            '1日の目標学習時間',
                            '任意',
                            appProvider.mockDataService.targetStudyMinutes,
                            _selectedTargetStudyMinutes,
                            (value) => setState(() => _selectedTargetStudyMinutes = value),
                          ),
                          const SizedBox(height: 24),
                          _buildCheckboxSection(
                            '学習継続の課題',
                            '任意',
                            appProvider.mockDataService.challenges,
                            _selectedChallenges,
                            (value, checked) {
                              setState(() {
                                if (checked) {
                                  _selectedChallenges.add(value);
                                } else {
                                  _selectedChallenges.remove(value);
                                }
                              });
                            },
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
                            context.go(AppRouter.profileStep2);
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
                          onPressed: _canProceed() ? _handleNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '次へ',
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
                color: required.contains('必須') ? Colors.red[100] : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                required,
                style: TextStyle(
                  fontSize: 12,
                  color: required.contains('必須') ? Colors.red[600] : Colors.grey[600],
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
        }),
      ],
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
                color: required.contains('必須') ? Colors.red[100] : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                required,
                style: TextStyle(
                  fontSize: 12,
                  color: required.contains('必須') ? Colors.red[600] : Colors.grey[600],
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
        }),
      ],
    );
  }

  bool _canProceed() {
    // For development: allow proceeding with minimal data
    return true;
  }

  void _handleNext() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentProfile = appProvider.currentUser?.profile;
    
    // Saving profile data
    
    final updatedProfile = currentProfile?.copyWith(
      learningGoal: _selectedLearningGoal,
      studyTime: _selectedStudyTimes,
      targetStudyMinutes: _selectedTargetStudyMinutes,
      challenges: _selectedChallenges,
    ) ?? Profile(
      learningGoal: _selectedLearningGoal,
      studyTime: _selectedStudyTimes,
      targetStudyMinutes: _selectedTargetStudyMinutes,
      challenges: _selectedChallenges,
    );
    
    final success = await appProvider.saveProfile(updatedProfile);
    if (success && mounted) {
      context.go(AppRouter.profileStep4);
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