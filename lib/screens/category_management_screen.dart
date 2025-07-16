import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../models/level.dart';
import '../widgets/category_statistics.dart';
import '../widgets/app_drawer.dart';
import '../router.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  String _searchQuery = '';
  String? _selectedLevelId;
  String? _filterStatus;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カテゴリー管理'),
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
            icon: const Icon(Icons.home),
            onPressed: () => context.go(AppRouter.home),
            tooltip: 'ホームに戻る',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final filteredCategories = _getFilteredCategories(appProvider);

          return SingleChildScrollView(
            child: Column(
              children: [
                const CategoryStatistics(),
                _buildSearchAndFilters(appProvider),
                _buildQuickActions(appProvider),
                _buildCategoryList(filteredCategories),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(AppProvider appProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'カテゴリーを検索...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLevelId,
                  decoration: InputDecoration(
                    labelText: 'レベル',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('すべてのレベル'),
                    ),
                    ...appProvider.levels.map(
                      (level) => DropdownMenuItem<String>(
                        value: level.id,
                        child: Text(level.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLevelId = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: InputDecoration(
                    labelText: '完了状態',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<String>(value: null, child: Text('すべて')),
                    DropdownMenuItem<String>(
                      value: 'completed',
                      child: Text('完了済み'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'incomplete',
                      child: Text('未完了'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppProvider appProvider) {
    final recentCategories = appProvider.getRecentlyStudiedCategories();
    final favoriteCategories = appProvider.getFavoriteExampleCategories();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentCategories.isNotEmpty) ...[
            const Text(
              '最近学習したカテゴリー',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentCategories.take(5).length,
                itemBuilder: (context, index) {
                  final category = recentCategories[index];
                  return _buildQuickActionCard(category);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (favoriteCategories.isNotEmpty) ...[
            const Text(
              'お気に入りのあるカテゴリー',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: favoriteCategories.take(5).length,
                itemBuilder: (context, index) {
                  final category = favoriteCategories[index];
                  return _buildQuickActionCard(category);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(Category category) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            context.go('${AppRouter.exampleList}?categoryId=${category.id}');
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: category.progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    category.isCompleted ? Colors.green : Colors.blue[600]!,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(category.progress * 100).toInt()}%',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'カテゴリー一覧 (${categories.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedLevelId = null;
                    _filterStatus = null;
                  });
                },
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('クリア'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (categories.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryListItem(category);
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryListItem(Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.isCompleted ? Colors.green : Colors.blue[600],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            category.isCompleted ? Icons.check : Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: category.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      category.isCompleted ? Colors.green : Colors.blue[600]!,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${category.completedExamples}/${category.totalExamples}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(category.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: category.isCompleted ? Colors.green : Colors.blue[600],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          context.go('${AppRouter.exampleList}?categoryId=${category.id}');
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '条件に一致するカテゴリーが見つかりませんでした',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '検索条件やフィルターを変更してみてください',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Category> _getFilteredCategories(AppProvider appProvider) {
    return appProvider.getFilteredCategories(
      levelId: _selectedLevelId,
      isCompleted:
          _filterStatus == 'completed'
              ? true
              : _filterStatus == 'incomplete'
              ? false
              : null,
      searchQuery: _searchQuery,
    );
  }
}
