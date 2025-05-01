import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/notifiers/admin_notifier.dart';
import 'package:trusted/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:trusted/features/admin/presentation/screens/admin_history_screen.dart';
import 'package:trusted/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:trusted/features/admin/presentation/screens/blacklist/blacklist_dashboard_screen.dart';
import 'package:trusted/features/auth/domain/notifiers/auth_notifier.dart';
import 'package:trusted/core/constants/app_constants.dart';

/// Main admin screen with bottom navigation
class AdminMainScreen extends ConsumerStatefulWidget {
  /// Constructor
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminUsersScreen(),
    const AdminHistoryScreen(),
    const BlacklistDashboardScreen(),
  ];
  
  // Navigation items for the drawer
  final List<Map<String, dynamic>> _navigationItems = [
    {
      'title': 'لوحة تحكم المسؤول',
      'icon': Icons.dashboard,
      'index': 0,
    },
    {
      'title': 'المستخدمين',
      'icon': Icons.people,
      'index': 1,
    },
    {
      'title': 'سجل المستخدمين',
      'icon': Icons.history,
      'index': 2,
    },
    {
      'title': 'القائمة السوداء',
      'icon': Icons.block,
      'index': 3,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize admin state when the screen is loaded
    Future.microtask(() {
      ref.read(adminStateProvider.notifier).initAdminState();
    });
  }

  // Helper method to get the screen title based on the current index
  String _getScreenTitle() {
    switch (_currentIndex) {
      case 0:
        return 'لوحة تحكم المسؤول';
      case 1:
        return 'المستخدمين';
      case 2:
        return 'سجل المستخدمين';
      case 3:
        return 'القائمة السوداء';
      default:
        return 'لوحة تحكم المسؤول';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.brightness == Brightness.light 
            ? AppColors.primary.withOpacity(0.1) 
            : AppColors.primary.withOpacity(0.2),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer header with admin info
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Admin name
                  Text(
                    'المسؤول',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Admin email
                  Text(
                    AppConstants.adminEmail,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            // Drawer items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _navigationItems.length,
                itemBuilder: (context, index) {
                  final item = _navigationItems[index];
                  final isSelected = _currentIndex == item['index'];
                  
                  return ListTile(
                    leading: Icon(
                      item['icon'],
                      color: isSelected ? AppColors.primary : null,
                    ),
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        _currentIndex = item['index'];
                      });
                      Navigator.pop(context); // Close the drawer
                    },
                  );
                },
              ),
            ),
            
            // Divider and version info at the bottom
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'نسخة 1.0.0',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }
}
