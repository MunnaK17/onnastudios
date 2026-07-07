import 'package:flutter/material.dart';

import '../navigation/app_bottom_navigation.dart';
import '../navigation/app_header.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.headerTitle,
    this.showBackButton = false,
    this.onBackPressed,
    this.headerActionIcon,
    this.onHeaderActionPressed,
    this.bottomNavigation,
    this.notificationBadgeCount = 0,
    super.key,
  });

  final Widget body;
  final String? headerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final IconData? headerActionIcon;
  final VoidCallback? onHeaderActionPressed;
  final AppBottomNavigation? bottomNavigation;
  final int notificationBadgeCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerTitle == null
          ? null
          : AppHeader(
              title: headerTitle!,
              showBackButton: showBackButton,
              onBackPressed: onBackPressed,
              actionIcon: headerActionIcon,
              onActionPressed: onHeaderActionPressed,
              badgeCount: notificationBadgeCount,
            ),
      body: body,
      bottomNavigationBar: bottomNavigation,
    );
  }
}
