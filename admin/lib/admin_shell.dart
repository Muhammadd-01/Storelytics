import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/stores_screen.dart';
import 'theme.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const _screens = [DashboardScreen(), UsersScreen(), StoresScreen()];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AdminColors.secondary, AdminColors.accent],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Storelytics Admin',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color:
                    isDark
                        ? AdminColors.darkTextPrimary
                        : AdminColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          isWide
              ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected:
                        (i) => setState(() => _selectedIndex = i),
                    extended: MediaQuery.of(context).size.width > 1100,
                    minWidth: 72,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: Text('Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.people_outline),
                        selectedIcon: Icon(Icons.people),
                        label: Text('Users'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.store_outlined),
                        selectedIcon: Icon(Icons.store),
                        label: Text('Stores'),
                      ),
                    ],
                  ),
                  VerticalDivider(
                    width: 1,
                    color:
                        isDark
                            ? AdminColors.darkBorder
                            : AdminColors.lightBorder,
                  ),
                  Expanded(child: _screens[_selectedIndex]),
                ],
              )
              : _screens[_selectedIndex],
      bottomNavigationBar:
          isWide
              ? null
              : NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected:
                    (i) => setState(() => _selectedIndex = i),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people),
                    label: 'Users',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.store_outlined),
                    selectedIcon: Icon(Icons.store),
                    label: 'Stores',
                  ),
                ],
              ),
    );
  }
}
