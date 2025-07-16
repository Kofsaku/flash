import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/level.dart';
import '../router.dart';
import '../widgets/app_drawer.dart';

class ExampleListScreen extends StatefulWidget {
  final String categoryId;

  const ExampleListScreen({super.key, required this.categoryId});

  @override
  State<ExampleListScreen> createState() => _ExampleListScreenState();
}

class _ExampleListScreenState extends State<ExampleListScreen> {
  Category? _category;
  List<Example> _examples = [];
  bool _isLoading = true;
  String? _levelId;

  @override
  void initState() {
    super.initState();
    _loadExamples();
  }

  Future<void> _loadExamples() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      print(
        'ExampleListScreen: Loading examples for category ${widget.categoryId}',
      );
      final category = await appProvider.getCategory(widget.categoryId);
      final examples = await appProvider.getExamples(widget.categoryId);

      print('ExampleListScreen: Received ${examples.length} examples');

      // Find the levelId for this category
      String? levelId;
      for (final level in appProvider.levels) {
        for (final cat in level.categories) {
          if (cat.id == widget.categoryId) {
            levelId = level.id;
            break;
          }
        }
        if (levelId != null) break;
      }

      if (mounted) {
        setState(() {
          _category = category;
          _examples = examples;
          _levelId = levelId;
          _isLoading = false;
        });
        print('ExampleListScreen: Set state with ${_examples.length} examples');
      }
    } catch (e) {
      print('ExampleListScreen: Error loading examples: $e');
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
        title: Text(_category?.name ?? '例文一覧'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'メニュー',
              ),
        ),
        actions: [
          if (_examples.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shuffle),
              onPressed: _shuffleExamples,
              tooltip: 'シャッフル',
            ),
          if (_levelId != null)
            IconButton(
              icon: const Icon(Icons.list_alt),
              onPressed:
                  () => context.go('${AppRouter.category}?levelId=$_levelId'),
              tooltip: 'カテゴリー選択に戻る',
            ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go(AppRouter.home),
            tooltip: 'ホームに戻る',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _category == null
              ? _buildErrorWidget()
              : _buildExampleList(),
      floatingActionButton:
          _examples.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: () => _startStudy(0),
                backgroundColor: Colors.blue[600],
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  '学習開始',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : null,
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'カテゴリーが見つかりませんでした',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleList() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryInfo(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '例文一覧',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_examples.length}件',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _examples.length,
                itemBuilder: (context, index) {
                  final example = _examples[index];
                  return _buildExampleCard(example, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _category!.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _category!.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '進捗: ${_category!.completedExamples}/${_category!.totalExamples}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _category!.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[600]!,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(_category!.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showCategorySwitcher,
                child: Icon(
                  Icons.swap_horiz,
                  color: Colors.blue[600],
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(Example example, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _startStudy(index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      example.isCompleted
                          ? Colors.green[600]
                          : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      example.isCompleted
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                          : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                      example.japanese,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      example.english,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  if (example.isFavorite)
                    Icon(Icons.favorite, color: Colors.red[400], size: 20),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shuffleExamples() {
    setState(() {
      _examples.shuffle();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('例文をシャッフルしました'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _startStudy(int startIndex) {
    context.go(
      '${AppRouter.study}?categoryId=${widget.categoryId}&index=$startIndex',
    );
  }

  void _showCategorySwitcher() async {
    if (_levelId == null) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final level = await appProvider.getLevel(_levelId!);
    if (level == null) return;

    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // ignore: use_build_context_synchronously
      builder:
          (context) => Container(
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
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
                      final completedCount =
                          category.examples.where((e) => e.isCompleted).length;
                      final progressPercent =
                          category.totalExamples > 0
                              ? (completedCount / category.totalExamples * 100)
                                  .round()
                              : 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap:
                              isSelected
                                  ? null
                                  : () {
                                    Navigator.of(context).pop();
                                    context.go(
                                      '${AppRouter.exampleList}?categoryId=${category.id}',
                                    );
                                  },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.blue[50] : Colors.white,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.blue[300]!
                                        : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.1),
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
                                    color:
                                        isSelected
                                            ? Colors.blue[600]
                                            : Colors.grey[400],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isSelected
                                                  ? Colors.blue[600]
                                                  : Colors.black87,
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[600],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            ),
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              progressPercent == 100
                                                  ? Colors.green[100]
                                                  : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '$progressPercent%',
                                          style: TextStyle(
                                            color:
                                                progressPercent == 100
                                                    ? Colors.green[600]
                                                    : Colors.grey[600],
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
}
