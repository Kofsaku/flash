import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user.dart';
import '../../router.dart';
import '../../widgets/progress_indicator.dart';

class ProfileStep4Screen extends StatefulWidget {
  const ProfileStep4Screen({super.key});

  @override
  State<ProfileStep4Screen> createState() => _ProfileStep4ScreenState();
}

class _ProfileStep4ScreenState extends State<ProfileStep4Screen> {
  String? _selectedRegion;
  String? _selectedFamilyStructure;
  final List<String> _selectedEnglishUsageScenarios = [];
  final List<TextEditingController> _topicControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    for (var controller in _topicControllers) {
      controller.dispose();
    }
    super.dispose();
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
                    currentStep: 4,
                    totalSteps: 4,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '個人的背景・詳細',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'より詳細な情報を教えてください。\n超個別化された学習体験を提供します。\n（すべて任意項目です）',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildRadioSection(
                            '居住地域',
                            '任意',
                            appProvider.mockDataService.regions,
                            _selectedRegion,
                            (value) => setState(() => _selectedRegion = value),
                          ),
                          const SizedBox(height: 24),
                          _buildRadioSection(
                            '家族構成',
                            '任意',
                            appProvider.mockDataService.familyStructures,
                            _selectedFamilyStructure,
                            (value) => setState(() => _selectedFamilyStructure = value),
                          ),
                          const SizedBox(height: 24),
                          _buildCheckboxSection(
                            '英語使用場面',
                            '任意',
                            appProvider.mockDataService.englishUsageScenarios,
                            _selectedEnglishUsageScenarios,
                            (value, checked) {
                              setState(() {
                                if (checked) {
                                  _selectedEnglishUsageScenarios.add(value);
                                } else {
                                  _selectedEnglishUsageScenarios.remove(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildTextInputSection(),
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
                            context.go(AppRouter.profileStep3);
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

  Widget _buildTextInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '興味のあるトピック',
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
        const SizedBox(height: 8),
        const Text(
          '最近関心のあることを3つまで入力してください\n例：「最新のAI技術」「韓国ドラマ」「キャンプ」',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _topicControllers[index],
              decoration: InputDecoration(
                labelText: 'トピック${index + 1}',
                border: const OutlineInputBorder(),
                hintText: '例：AI技術、韓国ドラマ、キャンプ',
              ),
            ),
          );
        }),
      ],
    );
  }

  void _handleComplete() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentProfile = appProvider.currentUser?.profile ?? Profile();
    
    final interestingTopics = _topicControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    final updatedProfile = currentProfile.copyWith(
      region: _selectedRegion,
      familyStructure: _selectedFamilyStructure,
      englishUsageScenarios: _selectedEnglishUsageScenarios,
      interestingTopics: interestingTopics,
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