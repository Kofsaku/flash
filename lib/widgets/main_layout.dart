import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router.dart';

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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '学習',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'お気に入り',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    print('Debug: Tab tapped, index = $index');
    switch (index) {
      case 0:
        print('Debug: Navigating to home');
        context.go(AppRouter.home);
        break;
      case 1:
        print('Debug: Navigating to first level category');
        // Navigate to the first level's category screen (中学レベル)
        context.go('${AppRouter.category}?levelId=junior_high');
        break;
      case 2:
        print('Debug: Navigating to favorites');
        context.go(AppRouter.favorites);
        break;
      case 3:
        print('Debug: Navigating to profile');
        context.go(AppRouter.profile);
        break;
    }
  }


}