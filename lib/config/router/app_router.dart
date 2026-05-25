import 'package:go_router/go_router.dart';

import '../../presentation/navigation/main_app_shell.dart';
import '../../presentation/screens/foundation_placeholder_screen.dart';
import '../../presentation/screens/booking/booking_flow_screen.dart';
import '../../presentation/screens/booking/booking_confirmation_screen.dart';
import '../../presentation/screens/booking_history/booking_history_screen.dart';
import '../../presentation/screens/package/package_screen.dart';
import '../../presentation/screens/schedule/schedule_screen.dart';
import '../../presentation/screens/class_detail/class_detail_screen.dart';
import '../../presentation/screens/classes/classes_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/notification/notification_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/wallet/wallet_screen.dart';
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
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRouteNames.register,
      builder: (context, state) => const RegisterScreen(),
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
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.classes,
          name: AppRouteNames.classes,
          builder: (context, state) => const ClassesScreen(),
        ),
        GoRoute(
          path: AppRoutes.schedule,
          name: AppRouteNames.schedule,
          builder: (context, state) => const ScheduleScreen(),
        ),
        GoRoute(
          path: AppRoutes.package,
          name: AppRouteNames.package,
          builder: (context, state) => const PackageScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: AppRouteNames.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    // Detail routes (outside shell)
    GoRoute(
      path: AppRoutes.classDetail,
      name: AppRouteNames.classDetail,
      builder: (context, state) {
        final classId = state.pathParameters['id'] ?? '';
        return ClassDetailScreen(classId: classId);
      },
    ),
    GoRoute(
      path: AppRoutes.instructorProfile,
      name: AppRouteNames.instructorProfile,
      builder: (context, state) {
        final instructorId = state.pathParameters['id'] ?? '';
        return InstructorProfileScreen(instructorId: instructorId);
      },
    ),
    GoRoute(
      path: AppRoutes.booking,
      name: AppRouteNames.booking,
      builder: (context, state) {
        final scheduleId = state.uri.queryParameters['scheduleId'];
        final classId = state.uri.queryParameters['classId'];
        return BookingFlowScreen(scheduleId: scheduleId, classId: classId);
      },
    ),
    GoRoute(
      path: AppRoutes.bookingConfirmation,
      name: AppRouteNames.bookingConfirmation,
      builder: (context, state) {
        final bookingId = state.uri.queryParameters['bookingId'];
        return BookingConfirmationScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: AppRoutes.bookingHistory,
      name: AppRouteNames.bookingHistory,
      builder: (context, state) => const BookingHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      name: AppRouteNames.wallet,
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: AppRoutes.location,
      name: AppRouteNames.location,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Location',
        subtitle: 'Studio locations placeholder.',
      ),
    ),
    GoRoute(
      path: AppRoutes.notification,
      name: AppRouteNames.notification,
      builder: (context, state) => const NotificationScreen(),
    ),
  ],
);
