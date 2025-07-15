import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Current profile data (will be loaded from provider)
  String? _selectedAgeGroup;
  String? _selectedOccupation;
  String? _selectedEnglishLevel;
  
  // User account data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<String> _selectedHobbies = [];
  String? _selectedIndustry;
  List<String> _selectedLifestyle = [];
  String? _selectedLearningGoal;
  List<String> _selectedStudyTime = [];
  String? _targetStudyMinutes;
  List<String> _selectedChallenges = [];
  String? _selectedRegion;
  String? _selectedFamilyStructure;
  List<String> _selectedEnglishUsageScenarios = [];
  List<String> _selectedInterestingTopics = [];
  List<String> _selectedLearningStyles = [];
  Map<String, String> _skillLevels = {};
  List<String> _selectedStudyEnvironments = [];
  List<String> _selectedWeakAreas = [];
  String? _motivationDetail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    // Load profile after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadCurrentProfile() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final user = appProvider.currentUser;
    final profile = user?.profile;
    
    // Load user account data
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
    
    if (profile != null) {
      setState(() {
        _selectedAgeGroup = profile.ageGroup;
        _selectedOccupation = profile.occupation;
        _selectedEnglishLevel = profile.englishLevel;
        _selectedHobbies = List.from(profile.hobbies);
        _selectedIndustry = profile.industry;
        _selectedLifestyle = List.from(profile.lifestyle);
        _selectedLearningGoal = profile.learningGoal;
        _selectedStudyTime = List.from(profile.studyTime);
        _targetStudyMinutes = profile.targetStudyMinutes;
        _selectedChallenges = List.from(profile.challenges);
        _selectedRegion = profile.region;
        _selectedFamilyStructure = profile.familyStructure;
        _selectedEnglishUsageScenarios = List.from(profile.englishUsageScenarios);
        _selectedInterestingTopics = List.from(profile.interestingTopics);
        _selectedLearningStyles = List.from(profile.learningStyles);
        _skillLevels = Map.from(profile.skillLevels);
        _selectedStudyEnvironments = List.from(profile.studyEnvironments);
        _selectedWeakAreas = List.from(profile.weakAreas);
        _motivationDetail = profile.motivationDetail;
      });
    }
  }

  Future<void> _saveProfile() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    try {
      // Update user info first
      final userUpdateSuccess = await appProvider.updateUserInfo(
        _nameController.text.trim(),
        _emailController.text.trim(),
      );
      
      if (!userUpdateSuccess) {
        throw Exception('ユーザー情報の更新に失敗しました');
      }
      
      // Then update profile
      final profile = Profile(
        ageGroup: _selectedAgeGroup,
        occupation: _selectedOccupation,
        englishLevel: _selectedEnglishLevel,
        hobbies: _selectedHobbies,
        industry: _selectedIndustry,
        lifestyle: _selectedLifestyle,
        learningGoal: _selectedLearningGoal,
        studyTime: _selectedStudyTime,
        targetStudyMinutes: _targetStudyMinutes,
        challenges: _selectedChallenges,
        region: _selectedRegion,
        familyStructure: _selectedFamilyStructure,
        englishUsageScenarios: _selectedEnglishUsageScenarios,
        interestingTopics: _selectedInterestingTopics,
        learningStyles: _selectedLearningStyles,
        skillLevels: _skillLevels,
        studyEnvironments: _selectedStudyEnvironments,
        weakAreas: _selectedWeakAreas,
        motivationDetail: _motivationDetail,
      );

      final profileUpdateSuccess = await appProvider.saveProfile(profile);
      
      if (!profileUpdateSuccess) {
        throw Exception('プロフィールの更新に失敗しました');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールを更新しました'),
            backgroundColor: Colors.green,
          ),
        );
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました: $e'),
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
        title: const Text('プロフィール編集'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'アカウント'),
            Tab(text: '基本情報'),
            Tab(text: '趣味・興味'),
            Tab(text: '学習目標'),
            Tab(text: '使用環境'),
            Tab(text: '学習スタイル'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAccountTab(),
          _buildBasicInfoTab(),
          _buildInterestsTab(),
          _buildGoalsTab(),
          _buildContextTab(),
          _buildLearningStyleTab(),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'アカウント情報',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'ユーザー名、メールアドレス、パスワードを変更できます',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          const Text('ユーザー名', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'ユーザー名を入力してください',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ユーザー名を入力してください';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          const Text('メールアドレス', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'メールアドレスを入力してください',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'メールアドレスを入力してください';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '有効なメールアドレスを入力してください';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          const Text('パスワード', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _showChangePasswordDialog,
              icon: const Icon(Icons.lock),
              label: const Text('パスワードを変更'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('学習設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/settings/daily-goal'),
              icon: const Icon(Icons.flag),
              label: const Text('1日の学習目標を設定'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '注意事項',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• メールアドレスを変更すると、次回ログイン時に新しいメールアドレスが必要になります\n• パスワードは6文字以上で設定してください\n• 変更を保存するには画面上部の「保存」ボタンを押してください',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isCurrentObscure = true;
    bool isNewObscure = true;
    bool isConfirmObscure = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('パスワード変更'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: isCurrentObscure,
                      decoration: InputDecoration(
                        labelText: '現在のパスワード',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isCurrentObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isCurrentObscure = !isCurrentObscure;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: isNewObscure,
                      decoration: InputDecoration(
                        labelText: '新しいパスワード',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isNewObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isNewObscure = !isNewObscure;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: isConfirmObscure,
                      decoration: InputDecoration(
                        labelText: 'パスワード確認',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isConfirmObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isConfirmObscure = !isConfirmObscure;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    currentPasswordController.dispose();
                    newPasswordController.dispose();
                    confirmPasswordController.dispose();
                    Navigator.pop(context);
                  },
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_validatePasswordChange(
                      currentPasswordController.text,
                      newPasswordController.text,
                      confirmPasswordController.text,
                    )) {
                      await _changePassword(newPasswordController.text);
                      currentPasswordController.dispose();
                      newPasswordController.dispose();
                      confirmPasswordController.dispose();
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('変更'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _validatePasswordChange(String current, String newPassword, String confirm) {
    if (current.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('現在のパスワードを入力してください')),
      );
      return false;
    }
    
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('新しいパスワードは6文字以上で入力してください')),
      );
      return false;
    }
    
    if (newPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('パスワードが一致しません')),
      );
      return false;
    }
    
    return true;
  }

  Future<void> _changePassword(String newPassword) async {
    // In a real app, you would validate the current password and update it
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('パスワードを変更しました（デモ機能）'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本情報',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          // Debug info
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Debug: 年齢=$_selectedAgeGroup, 職業=$_selectedOccupation, レベル=$_selectedEnglishLevel',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          
          const Text('年齢層', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['10代', '20代', '30代', '40代', '50代', '60代以上'].map((age) {
              final isSelected = _selectedAgeGroup == age;
              return FilterChip(
                label: Text(age),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedAgeGroup = selected ? age : null;
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('職業', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['学生', '会社員', '公務員', '自営業', '専業主婦/主夫', 'フリーランス', '退職者', 'その他'].map((job) {
              final isSelected = _selectedOccupation == job;
              return FilterChip(
                label: Text(job),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedOccupation = selected ? job : null;
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('英語レベル', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['初級', '初中級', '中級', '中上級', '上級'].map((level) {
              final isSelected = _selectedEnglishLevel == level;
              return FilterChip(
                label: Text(level),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedEnglishLevel = selected ? level : null;
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '趣味・興味',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          const Text('趣味', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['映画・ドラマ', '音楽', '読書', 'スポーツ', '旅行', '料理', 'ゲーム', 'アニメ・漫画', 'アウトドア', 'ファッション', 'その他'].map((hobby) {
              final isSelected = _selectedHobbies.contains(hobby);
              return FilterChip(
                label: Text(hobby),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedHobbies.add(hobby);
                    } else {
                      _selectedHobbies.remove(hobby);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('業界・分野', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['IT・テクノロジー', '金融', '医療・ヘルスケア', '教育', '製造業', 'サービス業', '小売・流通', 'メディア・エンターテイメント', 'その他'].map((industry) {
              final isSelected = _selectedIndustry == industry;
              return FilterChip(
                label: Text(industry),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedIndustry = selected ? industry : null;
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('ライフスタイル', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['朝型', '夜型', '忙しい', 'のんびり', '計画的', '自由', 'アクティブ', 'インドア派'].map((lifestyle) {
              final isSelected = _selectedLifestyle.contains(lifestyle);
              return FilterChip(
                label: Text(lifestyle),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLifestyle.add(lifestyle);
                    } else {
                      _selectedLifestyle.remove(lifestyle);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学習目標',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          const Text('学習目標', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['日常会話', 'ビジネス英語', 'TOEIC対策', 'TOEFL対策', '英検対策', '海外旅行', '留学準備', '転職活動', 'その他'].map((goal) {
              final isSelected = _selectedLearningGoal == goal;
              return FilterChip(
                label: Text(goal),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedLearningGoal = selected ? goal : null;
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('1日の学習時間', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['5分', '10分', '15分', '30分', '45分', '1時間', '1時間以上'].map((time) {
              final isSelected = _selectedStudyTime.contains(time);
              return FilterChip(
                label: Text(time),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStudyTime.add(time);
                      _targetStudyMinutes = '${int.tryParse(time.replaceAll(RegExp(r'[^0-9]'), '')) ?? 15}';
                    } else {
                      _selectedStudyTime.remove(time);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('学習の課題', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['語彙力不足', '文法が苦手', '発音', 'リスニング', 'スピーキング', 'ライティング', '時間がない', 'モチベーション維持'].map((challenge) {
              final isSelected = _selectedChallenges.contains(challenge);
              return FilterChip(
                label: Text(challenge),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedChallenges.add(challenge);
                    } else {
                      _selectedChallenges.remove(challenge);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '使用環境',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          const Text('お住まいの地域', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['北海道', '東北', '関東', '中部', '関西', '中国', '四国', '九州・沖縄', '海外'].map((region) {
              final isSelected = _selectedRegion == region;
              return FilterChip(
                label: Text(region),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedRegion = selected ? region : null;
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('家族構成', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['一人暮らし', '夫婦', '子供あり（小学生以下）', '子供あり（中学生以上）', '両親と同居', 'その他'].map((family) {
              final isSelected = _selectedFamilyStructure == family;
              return FilterChip(
                label: Text(family),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFamilyStructure = selected ? family : null;
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('英語使用場面', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['職場', '学校', '旅行', 'オンライン', '友人との会話', '家族との会話', 'プレゼンテーション', 'メール・チャット'].map((scenario) {
              final isSelected = _selectedEnglishUsageScenarios.contains(scenario);
              return FilterChip(
                label: Text(scenario),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedEnglishUsageScenarios.add(scenario);
                    } else {
                      _selectedEnglishUsageScenarios.remove(scenario);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('興味のあるトピック', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['ビジネス', 'テクノロジー', '健康・医療', '教育', '環境', 'スポーツ', 'エンターテイメント', '文化', 'ニュース', '日常生活'].map((topic) {
              final isSelected = _selectedInterestingTopics.contains(topic);
              return FilterChip(
                label: Text(topic),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterestingTopics.add(topic);
                    } else {
                      _selectedInterestingTopics.remove(topic);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学習スタイル',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          const Text('学習スタイル', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['視覚的学習', '聴覚的学習', '体験的学習', '反復学習', 'ゲーム的学習', '競争的学習', '協力的学習', '自主的学習'].map((style) {
              final isSelected = _selectedLearningStyles.contains(style);
              return FilterChip(
                label: Text(style),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLearningStyles.add(style);
                    } else {
                      _selectedLearningStyles.remove(style);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('スキルレベル', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...['リスニング', 'スピーキング', 'リーディング', 'ライティング'].map((skill) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text(skill)),
                    DropdownButton<String>(
                      value: _skillLevels[skill],
                      hint: const Text('選択'),
                      items: ['初級', '初中級', '中級', '中上級', '上級'].map((level) {
                        return DropdownMenuItem(value: level, child: Text(level));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            _skillLevels[skill] = value;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
          
          const SizedBox(height: 16),
          const Text('学習環境', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['自宅', '通勤中', 'カフェ', '図書館', 'オフィス', '屋外', 'その他'].map((env) {
              final isSelected = _selectedStudyEnvironments.contains(env);
              return FilterChip(
                label: Text(env),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStudyEnvironments.add(env);
                    } else {
                      _selectedStudyEnvironments.remove(env);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('苦手分野', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['語彙', '文法', '発音', '語順', '時制', '冠詞', '前置詞', 'イディオム'].map((weakness) {
              final isSelected = _selectedWeakAreas.contains(weakness);
              return FilterChip(
                label: Text(weakness),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedWeakAreas.add(weakness);
                    } else {
                      _selectedWeakAreas.remove(weakness);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          const Text('英語学習のモチベーション', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 3,
            initialValue: _motivationDetail,
            decoration: const InputDecoration(
              hintText: '英語を学ぶ理由や目標を教えてください...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _motivationDetail = value;
              });
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}