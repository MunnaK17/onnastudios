import 'package:go_router/go_router.dart';

import '../../presentation/navigation/main_app_shell.dart';
import '../../presentation/screens/foundation_placeholder_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/placeholder_content.dart';
import 'app_route_names.dart';
import 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRouteNames.splash,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Onna Studios',
        subtitle: 'Splash placeholder. Onboarding will come next.',
      ),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRouteNames.onboarding,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Onboarding',
        subtitle: 'Welcome experience will be implemented later.',
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRouteNames.login,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Login',
        subtitle: 'Authentication UI will be implemented later.',
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRouteNames.register,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Register',
        subtitle: 'Registration UI will be implemented later.',
      ),
    ),
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
          builder: (context, state) => const PlaceholderContent(
            title: 'Classes',
            subtitle: 'Class discovery tab placeholder.',
          ),
        ),
        GoRoute(
          path: AppRoutes.schedule,
          name: AppRouteNames.schedule,
          builder: (context, state) => const PlaceholderContent(
            title: 'Schedule',
            subtitle: 'Timetable tab placeholder.',
          ),
        ),
        GoRoute(
          path: AppRoutes.package,
          name: AppRouteNames.package,
          builder: (context, state) => const PlaceholderContent(
            title: 'Package',
            subtitle: 'Membership tab placeholder.',
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: AppRouteNames.profile,
          builder: (context, state) => const PlaceholderContent(
            title: 'Profile',
            subtitle: 'Member profile tab placeholder.',
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.classDetail,
      name: AppRouteNames.classDetail,
      builder: (context, state) => FoundationPlaceholderScreen(
        title: 'Class Detail',
        subtitle: 'Class id: ${state.pathParameters['id']}',
      ),
    ),
    GoRoute(
      path: AppRoutes.booking,
      name: AppRouteNames.booking,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Booking Flow',
        subtitle: 'Booking flow placeholder.',
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingConfirmation,
      name: AppRouteNames.bookingConfirmation,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Booking Confirmation',
        subtitle: 'QR confirmation placeholder.',
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingHistory,
      name: AppRouteNames.bookingHistory,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Booking History',
        subtitle: 'Reservation history placeholder.',
      ),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      name: AppRouteNames.wallet,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'My Credit',
        subtitle: 'Credit wallet placeholder.',
      ),
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
      path: AppRoutes.instructorProfile,
      name: AppRouteNames.instructorProfile,
      builder: (context, state) => FoundationPlaceholderScreen(
        title: 'Instructor Profile',
        subtitle: 'Instructor id: ${state.pathParameters['id']}',
      ),
    ),
    GoRoute(
      path: AppRoutes.notification,
      name: AppRouteNames.notification,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Notifications',
        subtitle: 'Studio updates placeholder.',
      ),
    ),
  ],
);
