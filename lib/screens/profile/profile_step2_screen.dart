import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user.dart';
import '../../router.dart';
import '../../widgets/progress_indicator.dart';

class ProfileStep2Screen extends StatefulWidget {
  const ProfileStep2Screen({super.key});

  @override
  State<ProfileStep2Screen> createState() => _ProfileStep2ScreenState();
}

class _ProfileStep2ScreenState extends State<ProfileStep2Screen> {
  final List<String> _selectedHobbies = [];
  String? _selectedIndustry;
  final List<String> _selectedLifestyle = [];

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
      print('Step2: Loading existing profile data');
      setState(() {
        _selectedHobbies.clear();
        _selectedHobbies.addAll(profile.hobbies);
        _selectedIndustry = profile.industry;
        _selectedLifestyle.clear();
        _selectedLifestyle.addAll(profile.lifestyle);
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
                    currentStep: 2,
                    totalSteps: 5,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '興味・関心',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'あなたの興味・関心を教えてください。\nより関連性の高い例文を生成します。',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildCheckboxSection(
                            '趣味・娯楽',
                            '任意',
                            appProvider.mockDataService.hobbies,
                            _selectedHobbies,
                            (value, checked) {
                              setState(() {
                                if (checked) {
                                  _selectedHobbies.add(value);
                                } else {
                                  _selectedHobbies.remove(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildRadioSection(
                            '仕事・業界',
                            '任意',
                            appProvider.mockDataService.industries,
                            _selectedIndustry,
                            (value) => setState(() => _selectedIndustry = value),
                          ),
                          const SizedBox(height: 24),
                          _buildCheckboxSection(
                            'ライフスタイル',
                            '任意',
                            appProvider.mockDataService.lifestyles,
                            _selectedLifestyle,
                            (value, checked) {
                              setState(() {
                                if (checked) {
                                  _selectedLifestyle.add(value);
                                } else {
                                  _selectedLifestyle.remove(value);
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
                            context.go(AppRouter.profileStep1);
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
            title: Text(option),
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
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                required,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
        }).toList(),
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
    
    print('Step2: Saving profile with hobbies: $_selectedHobbies, industry: $_selectedIndustry, lifestyle: $_selectedLifestyle');
    
    final updatedProfile = currentProfile?.copyWith(
      hobbies: _selectedHobbies,
      industry: _selectedIndustry,
      lifestyle: _selectedLifestyle,
    ) ?? Profile(
      hobbies: _selectedHobbies,
      industry: _selectedIndustry,
      lifestyle: _selectedLifestyle,
    );
    
    final success = await appProvider.saveProfile(updatedProfile);
    if (success && mounted) {
      context.go(AppRouter.profileStep3);
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