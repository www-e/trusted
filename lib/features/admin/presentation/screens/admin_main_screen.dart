import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/notifiers/admin_notifier.dart';
import 'package:trusted/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:trusted/features/admin/presentation/screens/admin_history_screen.dart';
import 'package:trusted/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:trusted/features/auth/domain/notifiers/auth_notifier.dart';

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
    const AdminHistoryScreen(),
    const AdminUsersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize admin state when the screen is loaded
    Future.microtask(() {
      ref.read(adminStateProvider.notifier).initAdminState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'لوحة تحكم المسؤول' : _currentIndex == 1 ? 'سجل المستخدمين' : 'المستخدمين'),
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
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: theme.brightness == Brightness.light 
              ? Colors.white 
              : AppColors.darkBackground,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: theme.brightness == Brightness.light
              ? AppColors.darkText.withOpacity(0.6)
              : AppColors.lightText.withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'السجل',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'المستخدمين',
            ),
          ],
        ),
      ),
    );
  }
}
