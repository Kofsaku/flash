import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/level.dart';
import '../../router.dart';
import '../../widgets/app_drawer.dart';

class StudyScreen extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final int initialIndex;
  final bool isMixed;
  final bool isAllLevels;

  const StudyScreen({
    super.key,
    required this.categoryId,
    this.initialIndex = 0,
  }) : levelId = null, isMixed = false, isAllLevels = false;

  const StudyScreen.mixed({
    super.key,
    required String levelId,
    this.initialIndex = 0,
  }) : categoryId = '', levelId = levelId, isMixed = true, isAllLevels = false;

  const StudyScreen.allLevels({
    super.key,
    this.initialIndex = 0,
  }) : categoryId = '', levelId = null, isMixed = false, isAllLevels = true;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late PageController _pageController;
  Category? _category;
  List<Example> _examples = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showEnglish = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _loadExamples();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadExamples() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    try {
      if (widget.isAllLevels) {
        // All levels comprehensive test mode
        if (appProvider.levels.isEmpty) {
          await appProvider.loadLevels();
        }
        
        List<Example> allExamples = [];
        
        for (final level in appProvider.levels) {
          for (final category in level.categories) {
            allExamples.addAll(category.examples);
          }
        }
        
        // Shuffle the examples for random order
        allExamples.shuffle();
        
        if (mounted) {
          setState(() {
            _category = Category(
              id: 'all_levels_test',
              name: '総合力テスト',
              description: '全レベルからランダム出題',
              levelId: 'all',
              order: 0,
              examples: allExamples,
              totalExamples: allExamples.length,
              completedExamples: 0,
            );
            _examples = allExamples;
            _isLoading = false;
          });
        }
      } else if (widget.isMixed && widget.levelId != null) {
        // Mixed study mode - get all examples from the level
        // Ensure levels are loaded
        if (appProvider.levels.isEmpty) {
          await appProvider.loadLevels();
        }
        
        final level = await appProvider.getLevel(widget.levelId!);
        if (level == null) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
        
        List<Example> allExamples = [];
        
        for (final category in level.categories) {
          allExamples.addAll(category.examples);
        }
        
        // Shuffle the examples for random order
        allExamples.shuffle();
        
        if (mounted) {
          setState(() {
            _category = Category(
              id: 'mixed_${widget.levelId}',
              name: '${level.name} - 全ミックス',
              description: '全カテゴリーからランダム出題',
              levelId: widget.levelId!,
              order: 0,
              examples: allExamples,
              totalExamples: allExamples.length,
              completedExamples: 0,
            );
            _examples = allExamples;
            _isLoading = false;
          });
        }
      } else {
        // Normal study mode - single category
        final category = await appProvider.getCategory(widget.categoryId);
        final examples = await appProvider.getExamples(widget.categoryId);
        
        if (mounted) {
          setState(() {
            _category = category;
            _examples = examples;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_category?.name ?? '学習'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'メニュー',
          ),
        ),
        actions: [
          if (_examples.isNotEmpty)
            IconButton(
              icon: Icon(
                _examples[_currentIndex].isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              onPressed: _toggleFavorite,
              tooltip: 'お気に入り',
            ),
          if (!widget.isMixed && !widget.isAllLevels)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: _showCategorySwitcher,
              tooltip: 'カテゴリー切り替え',
            ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _goToExampleList,
            tooltip: 'セクション選択に戻る',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.isMixed ? '全ミックス問題を準備中...' : '例文を読み込み中...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : _examples.isEmpty
              ? _buildErrorWidget()
              : _buildStudyContent(),
      bottomNavigationBar: _examples.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          const Text(
            '例文が見つかりませんでした',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'データの読み込みに問題が発生した可能性があります',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go(AppRouter.home),
                icon: const Icon(Icons.home),
                label: const Text('ホームに戻る'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _loadExamples();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudyContent() {
    return Column(
      children: [
        _buildProgressIndicator(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _showEnglish = false;
              });
            },
            itemCount: _examples.length,
            itemBuilder: (context, index) {
              return _buildExampleCard(_examples[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentIndex + 1) / _examples.length;
    final completedCount = _examples.where((e) => e.isCompleted).length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_currentIndex + 1} / ${_examples.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '完了: $completedCount問',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(Example example) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6, // Reduced minimum height
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // Add some top spacing
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_showEnglish ? 0.15 : 0.1),
                  blurRadius: _showEnglish ? 25 : 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '日本語',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (example.isCompleted)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  example.japanese,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _showEnglish = !_showEnglish;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _showEnglish ? Colors.green[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showEnglish ? Colors.green[200]! : Colors.grey[300]!,
                        width: _showEnglish ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _showEnglish ? Colors.green[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '英語',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _showEnglish ? Colors.green[600] : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          constraints: BoxConstraints(
                            minHeight: 80, // Minimum height for consistency
                          ),
                          child: Center(
                            child: _showEnglish
                                ? Text(
                                    example.english,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.touch_app,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'タップして英語を表示',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 48, // Fixed height to prevent layout shift
            child: _showEnglish
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _markAsCompleted(false),
                          icon: Icon(Icons.refresh, size: 18),
                          label: Text('復習する'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange[400]!, width: 2),
                            foregroundColor: Colors.orange[600],
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _markAsCompleted(true),
                          icon: Icon(Icons.check, size: 18),
                          label: Text('覚えた！'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(), // Empty space when not showing
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentIndex > 0 ? _previousExample : null,
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 24,
          ),
          Expanded(
            child: Text(
              '${_currentIndex + 1} / ${_examples.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _currentIndex < _examples.length - 1 ? _nextExample : _finishStudy,
            icon: Icon(
              _currentIndex < _examples.length - 1
                  ? Icons.arrow_forward_ios
                  : Icons.check,
            ),
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  void _previousExample() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextExample() {
    if (_currentIndex < _examples.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _markAsCompleted(bool isCompleted) async {
    // Add haptic feedback
    if (isCompleted) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final example = _examples[_currentIndex];
    
    await appProvider.updateExampleCompletion(example.id, isCompleted);
    
    setState(() {
      _examples[_currentIndex] = example.copyWith(isCompleted: isCompleted);
    });
    
    if (isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('完了しました！'),
            ],
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_currentIndex < _examples.length - 1) {
        _nextExample();
      } else {
        _finishStudy();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.refresh, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('もう一度復習しましょう'),
            ],
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _toggleFavorite() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final example = _examples[_currentIndex];
    
    await appProvider.toggleFavorite(example.id);
    
    setState(() {
      _examples[_currentIndex] = example.copyWith(isFavorite: !example.isFavorite);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          example.isFavorite ? 'お気に入りから削除しました' : 'お気に入りに追加しました',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _goToExampleList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isMixed ? 'カテゴリー選択に戻る' : 'セクション選択に戻る'),
        content: Text(widget.isMixed 
          ? '学習を中断してカテゴリー選択画面に戻りますか？' 
          : '学習を中断してセクション選択画面に戻りますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.isMixed && widget.levelId != null) {
                context.go('${AppRouter.category}?levelId=${widget.levelId}');
              } else {
                context.go('${AppRouter.exampleList}?categoryId=${widget.categoryId}');
              }
            },
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }

  void _showCategorySwitcher() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Get the current level to find all categories
    String? currentLevelId;
    if (_category != null) {
      currentLevelId = _category!.levelId;
    }
    
    if (currentLevelId == null) return;
    
    final level = await appProvider.getLevel(currentLevelId);
    if (level == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'カテゴリーを選択',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: level.categories.length,
                itemBuilder: (context, index) {
                  final category = level.categories[index];
                  final isSelected = category.id == widget.categoryId;
                  final completedCount = category.examples.where((e) => e.isCompleted).length;
                  final progressPercent = category.totalExamples > 0 
                      ? (completedCount / category.totalExamples * 100).round()
                      : 0;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: isSelected ? null : () {
                        Navigator.of(context).pop();
                        context.go('${AppRouter.study}?categoryId=${category.id}');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[50] : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue[600] : Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.blue[600] : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[600],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check, color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          '選択中',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: progressPercent == 100 ? Colors.green[100] : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$progressPercent%',
                                      style: TextStyle(
                                        color: progressPercent == 100 ? Colors.green[600] : Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  '$completedCount/${category.totalExamples}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finishStudy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('学習完了'),
        content: const Text('お疲れ様でした！\n学習を終了しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('続ける'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.isMixed && widget.levelId != null) {
                context.go('${AppRouter.category}?levelId=${widget.levelId}');
              } else {
                context.go('${AppRouter.exampleList}?categoryId=${widget.categoryId}');
              }
            },
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }
}