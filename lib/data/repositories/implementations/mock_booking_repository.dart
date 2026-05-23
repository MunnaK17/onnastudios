import '../../models/booking_model.dart';
import '../../models/app_enums.dart';
import '../../mock/mock_onna_data.dart';
import '../interfaces/booking_repository.dart';

/// Mock implementation of BookingRepository.
class MockBookingRepository implements BookingRepository {
  final List<BookingModel> _bookings =
      List<BookingModel>.from(MockOnnaData.bookings);

  @override
  Future<List<BookingModel>> getUserBookings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _bookings;
  }

  @override
  Future<BookingModel?> getBookingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BookingModel>> getUpcomingBookings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _bookings
        .where((b) => b.status == BookingStatus.upcoming)
        .toList();
  }

  @override
  Future<List<BookingModel>> getPastBookings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _bookings
        .where((b) =>
            b.status == BookingStatus.completed ||
            b.status == BookingStatus.cancelled)
        .toList();
  }

  @override
  Future<BookingModel> createBooking({
    required String scheduleId,
    required String classId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newBooking = BookingModel(
      id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
      userId: MockOnnaData.sampleUser.id,
      scheduleId: scheduleId,
      classId: classId,
      status: BookingStatus.upcoming,
      qrCodeValue: 'booking-${DateTime.now().millisecondsSinceEpoch}:checkin',
      bookedAt: DateTime.now(),
    );
    _bookings.add(newBooking);
    return newBooking;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = BookingModel(
        id: _bookings[index].id,
        userId: _bookings[index].userId,
        scheduleId: _bookings[index].scheduleId,
        classId: _bookings[index].classId,
        status: BookingStatus.cancelled,
        qrCodeValue: _bookings[index].qrCodeValue,
        bookedAt: _bookings[index].bookedAt,
      );
    }
  }

  @override
  Future<bool> hasBookedSchedule(String scheduleId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _bookings.any((b) =>
        b.scheduleId == scheduleId &&
        b.status == BookingStatus.upcoming);
  }
}