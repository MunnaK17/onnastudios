import 'package:go_router/go_router.dart';

import '../../presentation/screens/foundation_placeholder_screen.dart';
import 'app_route_names.dart';
import 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRouteNames.onboarding,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Onna Studios',
        subtitle: 'Project foundation is ready.',
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
    GoRoute(
      path: AppRoutes.home,
      name: AppRouteNames.home,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Home',
        subtitle: 'Main app shell will be implemented later.',
      ),
    ),
    GoRoute(
      path: AppRoutes.classes,
      name: AppRouteNames.classes,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Classes',
        subtitle: 'Class discovery will be implemented later.',
      ),
      routes: [
        GoRoute(
          path: ':id',
          name: AppRouteNames.classDetail,
          builder: (context, state) => FoundationPlaceholderScreen(
            title: 'Class Detail',
            subtitle: 'Class id: ${state.pathParameters['id']}',
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.schedule,
      name: AppRouteNames.schedule,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Schedule',
        subtitle: 'Timetable will be implemented later.',
      ),
    ),
    GoRoute(
      path: AppRoutes.booking,
      name: AppRouteNames.booking,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Booking',
        subtitle: 'Booking flow will be implemented later.',
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingConfirmation,
      name: AppRouteNames.bookingConfirmation,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Booking Confirmation',
        subtitle: 'QR confirmation will be implemented later.',
      ),
    ),
    GoRoute(
      path: AppRoutes.bookingHistory,
      name: AppRouteNames.bookingHistory,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Booking History',
        subtitle: 'Reservation history will be implemented later.',
      ),
    ),
    GoRoute(
      path: AppRoutes.package,
      name: AppRouteNames.package,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Package',
        subtitle: 'Membership packages will be implemented later.',
      ),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      name: AppRouteNames.wallet,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Wallet',
        subtitle: 'Credit wallet will be implemented later.',
      ),
    ),
    GoRoute(
      path: AppRoutes.location,
      name: AppRouteNames.location,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Location',
        subtitle: 'Studio locations will be implemented later.',
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
        subtitle: 'Studio updates will be implemented later.',
      ),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: AppRouteNames.profile,
      builder: (context, state) => const FoundationPlaceholderScreen(
        title: 'Profile',
        subtitle: 'Member profile will be implemented later.',
      ),
    ),
  ],
);
