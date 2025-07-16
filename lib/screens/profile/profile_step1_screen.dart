import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../models/user.dart';
import '../../router.dart';
import '../../widgets/progress_indicator.dart';
import '../../widgets/app_drawer.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingProfile();
    });
  }

  void _loadExistingProfile() {
    final authProvider = Provider.of<FirebaseAuthProvider>(
      context,
      listen: false,
    );
    final profile = authProvider.currentUser?.profile;

    if (profile != null) {
      // Loading existing profile data
      setState(() {
        _selectedAgeGroup = profile.ageGroup;
        _selectedOccupation = profile.occupation;
        _selectedEnglishLevel = profile.englishLevel;
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
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Consumer<FirebaseAuthProvider>(
          builder: (context, authProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const StepProgressIndicator(currentStep: 1, totalSteps: 5),
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
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          _buildSection(
                            '年齢層',
                            '任意',
                            ['10代', '20代', '30代', '40代', '50代', '60代以上'],
                            _selectedAgeGroup,
                            (value) =>
                                setState(() => _selectedAgeGroup = value),
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            '職業',
                            '任意',
                            [
                              '学生',
                              '会社員',
                              '公務員',
                              '自営業',
                              '専業主婦/主夫',
                              'フリーランス',
                              '退職者',
                              'その他',
                            ],
                            _selectedOccupation,
                            (value) =>
                                setState(() => _selectedOccupation = value),
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            '英語学習歴',
                            '任意',
                            ['初級', '初中級', '中級', '中上級', '上級'],
                            _selectedEnglishLevel,
                            (value) =>
                                setState(() => _selectedEnglishLevel = value),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    // For development: allow proceeding with minimal data
    return true;
  }

  void _handleNext() async {
    final authProvider = Provider.of<FirebaseAuthProvider>(
      context,
      listen: false,
    );
    final currentProfile = authProvider.currentUser?.profile;

    // Saving profile data

    final updatedProfile =
        currentProfile?.copyWith(
          ageGroup: _selectedAgeGroup,
          occupation: _selectedOccupation,
          englishLevel: _selectedEnglishLevel,
        ) ??
        Profile(
          ageGroup: _selectedAgeGroup,
          occupation: _selectedOccupation,
          englishLevel: _selectedEnglishLevel,
        );

    final success = await authProvider.saveProfile(updatedProfile);
    if (success && mounted) {
      context.go(AppRouter.profileStep2);
    } else if (authProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
