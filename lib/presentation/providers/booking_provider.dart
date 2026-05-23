import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/booking_model.dart';
import '../../data/repositories/interfaces/booking_repository.dart';
import '../../data/repositories/implementations/mock_booking_repository.dart';

/// Provider for BookingRepository instance.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return MockBookingRepository();
});

/// Provider for all user bookings.
final userBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUserBookings();
});

/// Provider for upcoming bookings.
final upcomingBookingsProvider = FutureProvider<List<BookingModel>>((
  ref,
) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUpcomingBookings();
});

/// Provider for past bookings.
final pastBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getPastBookings();
});

/// Provider for a single booking by ID.
final bookingByIdProvider = FutureProvider.family<BookingModel?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBookingById(id);
});

/// Booking state notifier using Riverpod 3.x Notifier.
class BookingNotifier extends Notifier<AsyncValue<List<BookingModel>>> {
  @override
  AsyncValue<List<BookingModel>> build() => const AsyncValue.loading();

  Future<void> loadBookings() async {
    state = const AsyncValue.loading();
    try {
      final bookings = await ref
          .read(bookingRepositoryProvider)
          .getUserBookings();
      state = AsyncValue.data(bookings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createBooking({
    required String scheduleId,
    required String classId,
  }) async {
    try {
      await ref
          .read(bookingRepositoryProvider)
          .createBooking(scheduleId: scheduleId, classId: classId);
      await loadBookings();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await ref.read(bookingRepositoryProvider).cancelBooking(bookingId);
      await loadBookings();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// NotifierProvider for booking state.
final bookingNotifierProvider =
    NotifierProvider<BookingNotifier, AsyncValue<List<BookingModel>>>(() {
      return BookingNotifier();
    });
