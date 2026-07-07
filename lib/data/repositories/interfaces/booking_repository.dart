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

  /// Reschedule a booking to a new schedule.
  /// Handles credit refund/charge automatically.
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required String newScheduleId,
  });

  /// Check if user has already booked a schedule.
  Future<bool> hasBookedSchedule(String scheduleId);

  /// Mark a booking as checked in.
  /// Called by instructor scanner after successful QR scan.
  Future<BookingModel> markAsCheckedIn(String bookingId);

  /// Mark a booking as no-show (auto-expired after 30 min without check-in).
  /// This does NOT refund credits.
  Future<BookingModel> markAsNoShow(String bookingId);

  /// Get booking by QR code value (for instructor scanner).
  Future<BookingModel?> getBookingByQrCode(String qrCodeValue);
}
