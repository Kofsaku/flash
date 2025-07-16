import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/level.dart';
import '../router.dart';
import '../widgets/app_drawer.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Example> _favoriteExamples = [];
  bool _isLoading = true;
  String _filterLevel = 'all';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      if (appProvider.levels.isEmpty) {
        await appProvider.loadLevels();
      }

      List<Example> allFavorites = [];
      for (final level in appProvider.levels) {
        for (final category in level.categories) {
          final favoriteExamples =
              category.examples.where((e) => e.isFavorite).toList();
          allFavorites.addAll(favoriteExamples);
        }
      }

      if (mounted) {
        setState(() {
          _favoriteExamples = allFavorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Example> get _filteredExamples {
    if (_filterLevel == 'all') {
      return _favoriteExamples;
    }
    return _favoriteExamples.where((e) => e.levelId == _filterLevel).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お気に入り'),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadFavorites();
            },
            tooltip: '更新',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildFavoritesContent(),
    );
  }

  Widget _buildFavoritesContent() {
    final filteredExamples = _filteredExamples;

    if (_favoriteExamples.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child:
              filteredExamples.isEmpty
                  ? _buildNoResultsState()
                  : _buildFavoritesList(filteredExamples),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final levels = appProvider.levels;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('すべて'),
              selected: _filterLevel == 'all',
              onSelected: (_) => setState(() => _filterLevel = 'all'),
              selectedColor: Colors.blue[100],
            ),
            const SizedBox(width: 8),
            ...levels.map(
              (level) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(level.name),
                  selected: _filterLevel == level.id,
                  onSelected: (_) => setState(() => _filterLevel = level.id),
                  selectedColor: Colors.blue[100],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'お気に入りがありません',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '学習中に♡ボタンを押して\nお気に入りに追加しましょう',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRouter.home),
            icon: const Icon(Icons.home),
            label: const Text('ホームに戻る'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'フィルター条件に一致する\nお気に入りがありません',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<Example> examples) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: examples.length,
      itemBuilder: (context, index) {
        final example = examples[index];
        return _buildFavoriteCard(example, index);
      },
    );
  }

  Widget _buildFavoriteCard(Example example, int index) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final level = appProvider.levels.firstWhere((l) => l.id == example.levelId);
    final category = level.categories.firstWhere(
      (c) => c.id == example.categoryId,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _startStudyFromExample(example),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      level.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _toggleFavorite(example),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                example.japanese,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                example.english,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (example.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 14, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text(
                            '完了済み',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startStudyFromExample(Example example) {
    context.go(
      '${AppRouter.study}?categoryId=${example.categoryId}&index=${example.order - 1}',
    );
  }

  void _toggleFavorite(Example example) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.toggleFavorite(example.id);

    // Remove from local list immediately for better UX
    setState(() {
      _favoriteExamples.removeWhere((e) => e.id == example.id);
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('お気に入りから削除しました'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
