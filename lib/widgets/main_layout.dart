import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../router.dart';
import '../providers/app_provider.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        elevation: 8,
        onTap: (index) => _onTabTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: '学習'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
        ],
      ),
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        // Navigate to the first level's category screen
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        final firstLevel = appProvider.levels.isNotEmpty 
            ? appProvider.levels.first 
            : null;
        if (firstLevel != null) {
          context.go('${AppRouter.category}?levelId=${firstLevel.id}');
        } else {
          // Fallback to home if no levels available
          context.go(AppRouter.home);
        }
        break;
      case 2:
        context.go(AppRouter.favorites);
        break;
      case 3:
        context.go(AppRouter.profile);
        break;
    }
  }
}
