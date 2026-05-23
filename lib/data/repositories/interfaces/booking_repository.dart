import '../../models/booking_model.dart';

/// Repository interface for booking operations.
abstract class BookingRepository {
  /// Get all bookings for the current user.
  Future<List<BookingModel>> getUserBookings();

  /// Get a booking by ID.
  Future<BookingModel?> getBookingById(String id);

  /// Get upcoming bookings.
  Future<List<BookingModel>> getUpcomingBookings();

  /// Get past/completed bookings.
  Future<List<BookingModel>> getPastBookings();

  /// Create a new booking.
  Future<BookingModel> createBooking({
    required String scheduleId,
    required String classId,
  });

  /// Cancel a booking.
  Future<void> cancelBooking(String bookingId);

  /// Check if user has already booked a schedule.
  Future<bool> hasBookedSchedule(String scheduleId);
}
