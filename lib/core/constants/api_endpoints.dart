abstract final class ApiEndpoints {
  static const basePath = '/api/v1';

  static const login = '$basePath/auth/login';
  static const register = '$basePath/auth/register';
  static const logout = '$basePath/auth/logout';
  static const forgotPassword = '$basePath/auth/forgot-password';

  static const classes = '$basePath/classes';
  static String classById(String id) => '$classes/$id';
  static const classCategories = '$basePath/classes/categories';

  static const schedule = '$basePath/schedule';
  static String scheduleByDate(String date) => '$schedule/$date';

  static const booking = '$basePath/booking';
  static const bookingHistory = '$basePath/booking/history';
  static const cancelBooking = '$basePath/booking/cancel';
  static String bookingById(String id) => '$booking/$id';

  static const wallet = '$basePath/wallet';
  static const walletHistory = '$basePath/wallet/history';

  static const notifications = '$basePath/notifications';
  static const readNotification = '$basePath/notifications/read';

  static const profile = '$basePath/profile';
}
