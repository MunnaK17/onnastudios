import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/router/app_routes.dart';
import '../../shared/widgets/layout/app_scaffold.dart';
import '../../shared/widgets/navigation/app_bottom_navigation.dart';

class MainAppShell extends StatelessWidget {
  const MainAppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _tabRoutes = [
    AppRoutes.home,
    AppRoutes.classes,
    AppRoutes.schedule,
    AppRoutes.package,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      headerTitle: 'Onna Studios',
      headerActionIcon: Icons.notifications_outlined,
      onHeaderActionPressed: () => context.push(AppRoutes.notification),
      bottomNavigation: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => context.go(_tabRoutes[index]),
      ),
      body: child,
    );
  }

  int get _currentIndex {
    if (location.startsWith(AppRoutes.classes)) {
      return 1;
    }
    if (location.startsWith(AppRoutes.schedule)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.package)) {
      return 3;
    }
    if (location.startsWith(AppRoutes.profile)) {
      return 4;
    }
    return 0;
  }
}
