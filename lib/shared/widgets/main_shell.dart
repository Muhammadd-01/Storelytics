import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storelytics/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const MainShell({super.key, required this.child, required this.state});

  static final _tabs = [
    const _TabItem(icon: Icons.dashboard_rounded, label: 'Home'),
    const _TabItem(icon: Icons.inventory_2_rounded, label: 'Inventory'),
    const _TabItem(icon: Icons.receipt_long_rounded, label: 'Sales'),
    const _TabItem(icon: Icons.trending_up_rounded, label: 'Demand'),
    const _TabItem(icon: Icons.description_rounded, label: 'Reports'),
    const _TabItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  int _currentIndex(String location) {
    if (location.startsWith('/inventory')) return 1;
    if (location.startsWith('/sales')) return 2;
    if (location.startsWith('/demand')) return 3;
    if (location.startsWith('/reports')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/inventory');
        break;
      case 2:
        context.go('/sales');
        break;
      case 3:
        context.go('/demand');
        break;
      case 4:
        context.go('/reports');
        break;
      case 5:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _currentIndex(state.uri.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: child,
      floatingActionButtonLocation:
          const _RaisedFabLocation(), // Lift FAB above navbar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 70,
        decoration: BoxDecoration(
          color:
              isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final isSelected = currentIdx == index;
              return GestureDetector(
                onTap: () => _onTap(context, index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.secondary.withValues(alpha: 0.15)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _tabs[index].icon,
                        color:
                            isSelected
                                ? AppColors.secondary
                                : (isDark ? Colors.white54 : Colors.black38),
                        size: isSelected ? 26 : 24,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        height: 4,
                        width: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

class _RaisedFabLocation extends FloatingActionButtonLocation {
  const _RaisedFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Standard endFloat offset
    final Offset standardOffset = FloatingActionButtonLocation.endFloat
        .getOffset(scaffoldGeometry);
    // Lift it up by 100 pixels to clear the floating navbar
    return Offset(standardOffset.dx, standardOffset.dy - 100);
  }
}
