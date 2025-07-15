import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user.dart';
import '../../router.dart';

class RegisterProfileScreen extends StatefulWidget {
  const RegisterProfileScreen({super.key});

  @override
  State<RegisterProfileScreen> createState() => _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends State<RegisterProfileScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Step 1: Basic info
  String? _selectedAgeGroup;
  String? _selectedOccupation;
  String? _selectedEnglishLevel;
  
  // Step 2: Interests
  final List<String> _selectedHobbies = [];
  String? _selectedIndustry;
  final List<String> _selectedLifestyle = [];
  
  // Step 3: Learning goals
  String? _selectedLearningGoal;
  final List<String> _selectedStudyTime = [];
  String? _targetStudyMinutes;
  final List<String> _selectedChallenges = [];
  
  // Step 4: Context
  String? _selectedRegion;
  String? _selectedFamilyStructure;
  final List<String> _selectedEnglishUsageScenarios = [];
  final List<String> _selectedInterestingTopics = [];
  
  // Step 5: Learning style
  final List<String> _selectedLearningStyles = [];
  final Map<String, String> _skillLevels = {};
  final List<String> _selectedStudyEnvironments = [];
  final List<String> _selectedWeakAreas = [];
  String? _motivationDetail;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedAgeGroup != null && 
               _selectedOccupation != null && 
               _selectedEnglishLevel != null;
      case 1:
        return _selectedHobbies.isNotEmpty && 
               _selectedIndustry != null && 
               _selectedLifestyle.isNotEmpty;
      case 2:
        return _selectedLearningGoal != null && 
               _selectedStudyTime.isNotEmpty && 
               _selectedChallenges.isNotEmpty;
      case 3:
        return _selectedRegion != null && 
               _selectedFamilyStructure != null && 
               _selectedEnglishUsageScenarios.isNotEmpty && 
               _selectedInterestingTopics.isNotEmpty;
      case 4:
        return _selectedLearningStyles.isNotEmpty && 
               _skillLevels.isNotEmpty && 
               _selectedStudyEnvironments.isNotEmpty && 
               _selectedWeakAreas.isNotEmpty && 
               _motivationDetail != null && _motivationDetail!.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _completeRegistration() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    final profile = Profile(
      ageGroup: _selectedAgeGroup!,
      occupation: _selectedOccupation!,
      englishLevel: _selectedEnglishLevel!,
      hobbies: _selectedHobbies,
      industry: _selectedIndustry!,
      lifestyle: _selectedLifestyle,
      learningGoal: _selectedLearningGoal!,
      studyTime: _selectedStudyTime,
      targetStudyMinutes: _targetStudyMinutes,
      challenges: _selectedChallenges,
      region: _selectedRegion!,
      familyStructure: _selectedFamilyStructure!,
      englishUsageScenarios: _selectedEnglishUsageScenarios,
      interestingTopics: _selectedInterestingTopics,
      learningStyles: _selectedLearningStyles,
      skillLevels: _skillLevels,
      studyEnvironments: _selectedStudyEnvironments,
      weakAreas: _selectedWeakAreas,
      motivationDetail: _motivationDetail!,
    );

    await appProvider.saveProfile(profile);
    
    if (mounted) {
      context.go(AppRouter.loading);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('プロフィール設定 (${_currentStep + 1}/5)'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _previousStep,
            )
          : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _currentStep == 4 ? '登録完了' : '次へ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本情報',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'あなたの基本的な情報を教えてください',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '趣味・興味',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'あなたの趣味や興味のある分野を教えてください',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学習目標',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '英語学習の目標と時間を設定してください',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '使用環境',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '英語を使う場面や環境を教えてください',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学習スタイル',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '最後に、あなたの学習スタイルを教えてください',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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
        ],
      ),
    );
  }
}