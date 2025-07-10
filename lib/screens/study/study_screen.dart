import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/level.dart';
import '../../router.dart';

class StudyScreen extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final int initialIndex;
  final bool isMixed;

  const StudyScreen({
    super.key,
    required this.categoryId,
    this.initialIndex = 0,
  }) : levelId = null, isMixed = false;

  const StudyScreen.mixed({
    super.key,
    required String levelId,
    this.initialIndex = 0,
  }) : categoryId = '', levelId = levelId, isMixed = true;

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
      if (widget.isMixed && widget.levelId != null) {
        // Mixed study mode - get all examples from the level
        print('Mixed study mode: Loading level ${widget.levelId}');
        
        // Ensure levels are loaded
        if (appProvider.levels.isEmpty) {
          print('Levels not loaded, loading them first...');
          await appProvider.loadLevels();
        }
        
        print('Available levels: ${appProvider.levels.map((l) => '${l.id}: ${l.name}').toList()}');
        final level = await appProvider.getLevel(widget.levelId!);
        print('Level result: $level');
        if (level == null) {
          print('Level not found for ID: ${widget.levelId}');
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
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _goToExampleList,
            tooltip: 'セクション選択に戻る',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _examples.isEmpty
              ? _buildErrorWidget()
              : _buildStudyContent(),
      bottomNavigationBar: _examples.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            '例文が見つかりませんでした',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentIndex + 1} / ${_examples.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(((_currentIndex + 1) / _examples.length) * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _examples.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(Example example) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showEnglish = !_showEnglish;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _showEnglish ? Colors.green[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showEnglish ? Colors.green[200]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                        if (_showEnglish)
                          Text(
                            example.english,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          )
                        else
                          Row(
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
                        child: OutlinedButton(
                          onPressed: () => _markAsCompleted(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'まだ覚えていない',
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _markAsCompleted(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('覚えた！'),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(), // Empty space when not showing
          ),
        ],
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
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final example = _examples[_currentIndex];
    
    await appProvider.updateExampleCompletion(example.id, isCompleted);
    
    setState(() {
      _examples[_currentIndex] = example.copyWith(isCompleted: isCompleted);
    });
    
    if (isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('完了しました！'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_currentIndex < _examples.length - 1) {
        _nextExample();
      } else {
        _finishStudy();
      }
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