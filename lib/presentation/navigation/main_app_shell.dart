import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/router/app_routes.dart';
import '../../shared/widgets/layout/app_scaffold.dart';
import '../../shared/widgets/navigation/app_bottom_navigation.dart';
import '../providers/notification_provider.dart';
import '../providers/booking_provider.dart';

class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Process expired bookings on init
    _processExpiredBookings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Process expired bookings when app resumes
      _processExpiredBookings();
    }
  }

  Future<void> _processExpiredBookings() async {
    await processExpiredBookings(ref);
  }

  static const _tabRoutes = [
    AppRoutes.home,
    AppRoutes.classes,
    AppRoutes.schedule,
    AppRoutes.moodTab,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return AppScaffold(
      headerTitle: 'Onna Studios',
      headerActionIcon: Icons.notifications_outlined,
      onHeaderActionPressed: () => context.push(AppRoutes.notification),
      notificationBadgeCount: unreadCountAsync.when(
        data: (count) => count,
        loading: () => 0,
        error: (e, s) => 0,
      ),
      bottomNavigation: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => context.go(_tabRoutes[index]),
      ),
      body: widget.child,
    );
  }

  int get _currentIndex {
    if (widget.location.startsWith(AppRoutes.classes)) {
      return 1;
    }
    if (widget.location.startsWith(AppRoutes.schedule)) {
      return 2;
    }
    if (widget.location.startsWith(AppRoutes.moodTab)) {
      return 3;
    }
    if (widget.location.startsWith(AppRoutes.profile)) {
      return 4;
    }
    return 0;
  }
}
