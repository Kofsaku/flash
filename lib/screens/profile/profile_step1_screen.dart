import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user.dart';
import '../../router.dart';
import '../../widgets/progress_indicator.dart';

class ProfileStep1Screen extends StatefulWidget {
  const ProfileStep1Screen({super.key});

  @override
  State<ProfileStep1Screen> createState() => _ProfileStep1ScreenState();
}

class _ProfileStep1ScreenState extends State<ProfileStep1Screen> {
  String? _selectedAgeGroup;
  String? _selectedOccupation;
  String? _selectedEnglishLevel;

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
                    currentStep: 1,
                    totalSteps: 4,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '基本情報',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'あなたの基本情報を教えてください。\nパーソナライズされた学習体験を提供します。',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSection(
                            '年齢層',
                            '必須',
                            appProvider.mockDataService.ageGroups,
                            _selectedAgeGroup,
                            (value) => setState(() => _selectedAgeGroup = value),
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            '職業',
                            '必須',
                            appProvider.mockDataService.occupations,
                            _selectedOccupation,
                            (value) => setState(() => _selectedOccupation = value),
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            '英語学習歴',
                            '必須',
                            appProvider.mockDataService.englishLevels,
                            _selectedEnglishLevel,
                            (value) => setState(() => _selectedEnglishLevel = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(
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
    return _selectedAgeGroup != null &&
        _selectedOccupation != null &&
        _selectedEnglishLevel != null;
  }

  void _handleNext() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentProfile = appProvider.currentUser?.profile ?? Profile();
    
    final updatedProfile = currentProfile.copyWith(
      ageGroup: _selectedAgeGroup,
      occupation: _selectedOccupation,
      englishLevel: _selectedEnglishLevel,
    );
    
    appProvider.saveProfile(updatedProfile);
    context.go(AppRouter.profileStep2);
  }
}