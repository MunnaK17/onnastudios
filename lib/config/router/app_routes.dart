abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const classes = '/classes';
  static const classDetail = '/classes/:id';
  static const schedule = '/schedule';
  static const scheduleSelect = '/schedule/select/:classId';
  static const booking = '/booking';
  static const bookingConfirmation = '/booking/confirmation';
  static const bookingHistory = '/booking/history';
  static const bookingReschedule = '/booking/reschedule';
  static const wallet = '/wallet';
  static const topUp = '/wallet/topup';
  static const instructorProfile = '/instructor/:id';
  static const notification = '/notification';
  static const profile = '/profile';
  static const accountSettings = '/profile/settings';
  static const moodTab = '/mood';
  static const moodTracker = '/mood/track';
  static const moodRecommendations = '/mood/recommendations';
  static const moodHistory = '/mood/history';

  static String classDetailPath(String id) => '/classes/$id';

  static String instructorProfilePath(String id) => '/instructor/$id';

  static String bookingPath({String? scheduleId, String? classId}) {
    final queryParameters = <String, String>{
      if (scheduleId != null && scheduleId.isNotEmpty) 'scheduleId': scheduleId,
      if (classId != null && classId.isNotEmpty) 'classId': classId,
    };

    return Uri(
      path: booking,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String bookingConfirmationPath({String? bookingId}) {
    final queryParameters = <String, String>{
      if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
    };

    return Uri(
      path: bookingConfirmation,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String scheduleSelectPath(String classId) => '/schedule/select/$classId';

  static String bookingReschedulePath({
    String? bookingId,
    String? newScheduleId,
  }) {
    final queryParameters = <String, String>{
      if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
      if (newScheduleId != null && newScheduleId.isNotEmpty) 'newScheduleId': newScheduleId,
    };

    return Uri(
      path: bookingReschedule,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }
}
