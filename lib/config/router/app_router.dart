import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/navigation/main_app_shell.dart';
import '../../presentation/screens/booking/booking_flow_screen.dart';
import '../../presentation/screens/booking/booking_confirmation_screen.dart';
import '../../presentation/screens/booking/booking_reschedule_screen.dart';
import '../../presentation/screens/booking_history/booking_history_screen.dart';
import '../../presentation/screens/schedule/schedule_screen.dart';
import '../../presentation/screens/schedule/schedule_select_screen.dart';
import '../../presentation/screens/class_detail/class_detail_screen.dart';
import '../../presentation/screens/classes/classes_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/mood/mood_tab_screen.dart';
import '../../presentation/screens/mood/mood_tracker_screen.dart';
import '../../presentation/screens/mood/mood_recommendations_screen.dart';
import '../../presentation/screens/mood/mood_history_screen.dart';
import '../../presentation/screens/notification/notification_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/account_settings_screen.dart';
import '../../presentation/screens/wallet/wallet_screen.dart';
import '../../presentation/screens/topup/topup_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/instructor_profile/instructor_profile_screen.dart';
import 'app_route_names.dart';
import 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Auth routes (no shell)
    GoRoute(
      path: AppRoutes.splash,
      name: AppRouteNames.splash,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const SplashScreen()),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRouteNames.onboarding,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const OnboardingScreen()),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRouteNames.login,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRouteNames.register,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const RegisterScreen()),
    ),
    // Main app shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        return MainAppShell(location: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: AppRouteNames.home,
          pageBuilder: (context, state) =>
              _buildPage(state: state, child: const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.classes,
          name: AppRouteNames.classes,
          pageBuilder: (context, state) =>
              _buildPage(state: state, child: const ClassesScreen()),
        ),
        GoRoute(
          path: AppRoutes.schedule,
          name: AppRouteNames.schedule,
          pageBuilder: (context, state) =>
              _buildPage(state: state, child: const ScheduleScreen()),
        ),
        GoRoute(
          path: AppRoutes.moodTab,
          name: AppRouteNames.moodTab,
          pageBuilder: (context, state) =>
              _buildPage(state: state, child: const MoodTabScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: AppRouteNames.profile,
          pageBuilder: (context, state) =>
              _buildPage(state: state, child: const ProfileScreen()),
        ),
      ],
    ),
    // Detail routes (outside shell)
    GoRoute(
      path: AppRoutes.classDetail,
      name: AppRouteNames.classDetail,
      pageBuilder: (context, state) {
        final classId = state.pathParameters['id'] ?? '';
        return _buildPage(
          state: state,
          child: ClassDetailScreen(classId: classId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.instructorProfile,
      name: AppRouteNames.instructorProfile,
      pageBuilder: (context, state) {
        final instructorId = state.pathParameters['id'] ?? '';
        return _buildPage(
          state: state,
          child: InstructorProfileScreen(instructorId: instructorId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.scheduleSelect,
      name: AppRouteNames.scheduleSelect,
      pageBuilder: (context, state) {
        final classId = state.pathParameters['classId'] ?? '';
        final bookingId = state.uri.queryParameters['bookingId'];
        return _buildPage(
          state: state,
          child: ScheduleSelectScreen(classId: classId, bookingId: bookingId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.booking,
      name: AppRouteNames.booking,
      pageBuilder: (context, state) {
        final scheduleId = state.uri.queryParameters['scheduleId'];
        final classId = state.uri.queryParameters['classId'];
        return _buildPage(
          state: state,
          child: BookingFlowScreen(scheduleId: scheduleId, classId: classId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bookingConfirmation,
      name: AppRouteNames.bookingConfirmation,
      pageBuilder: (context, state) {
        final bookingId = state.uri.queryParameters['bookingId'];
        return _buildPage(
          state: state,
          child: BookingConfirmationScreen(bookingId: bookingId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bookingReschedule,
      name: AppRouteNames.bookingReschedule,
      pageBuilder: (context, state) {
        final bookingId = state.uri.queryParameters['bookingId'];
        final newScheduleId = state.uri.queryParameters['newScheduleId'];
        return _buildPage(
          state: state,
          child: BookingRescheduleScreen(bookingId: bookingId, newScheduleId: newScheduleId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bookingHistory,
      name: AppRouteNames.bookingHistory,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const BookingHistoryScreen()),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      name: AppRouteNames.wallet,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const WalletScreen()),
    ),
    GoRoute(
      path: AppRoutes.topUp,
      name: AppRouteNames.topUp,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const TopUpScreen()),
    ),
    GoRoute(
      path: AppRoutes.notification,
      name: AppRouteNames.notification,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const NotificationScreen()),
    ),
    GoRoute(
      path: AppRoutes.accountSettings,
      name: AppRouteNames.accountSettings,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const AccountSettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.moodRecommendations,
      name: AppRouteNames.moodRecommendations,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const MoodRecommendationsScreen()),
    ),
    GoRoute(
      path: AppRoutes.moodHistory,
      name: AppRouteNames.moodHistory,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const MoodHistoryScreen()),
    ),
    GoRoute(
      path: AppRoutes.moodTracker,
      name: AppRouteNames.moodTracker,
      pageBuilder: (context, state) =>
          _buildPage(state: state, child: const MoodTrackerScreen()),
    ),
  ],
);

CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}
