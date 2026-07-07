import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/booking_model.dart';
import '../../data/repositories/interfaces/booking_repository.dart';
import '../../data/repositories/implementations/supabase_booking_repository.dart';
import 'profile_provider.dart';
import 'schedule_provider.dart';
import 'wallet_provider.dart';

/// Provider for BookingRepository instance.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return SupabaseBookingRepository();
});

/// Provider for all user bookings.
final userBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUserBookings();
});

/// Provider for upcoming bookings.
final upcomingBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUpcomingBookings();
});

/// Provider for past bookings.
final pastBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getPastBookings();
});

/// Provider for a single booking by ID.
final bookingByIdProvider = FutureProvider.family<BookingModel?, String>((ref, id) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBookingById(id);
});

/// Provider for watching a single booking.
final bookingWatcherProvider = FutureProvider.family<BookingModel?, String>((ref, id) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBookingById(id);
});

/// Helper to refresh booking data after check-in
/// Call this after manual check-in to immediately update all providers
void refreshBookingData(WidgetRef ref, String bookingId) {
  // Invalidate all booking-related providers to force refresh
  ref.invalidate(bookingByIdProvider(bookingId));
  ref.invalidate(bookingWatcherProvider(bookingId));
  ref.invalidate(userBookingsProvider);
  ref.invalidate(upcomingBookingsProvider);
  ref.invalidate(pastBookingsProvider);
}

/// Booking state notifier using Riverpod 3.x Notifier.
class BookingNotifier extends Notifier<AsyncValue<List<BookingModel>>> {
  @override
  AsyncValue<List<BookingModel>> build() {
    Future.microtask(loadBookings);
    return const AsyncValue.loading();
  }

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

  Future<BookingModel> createBooking({
    required String scheduleId,
    required String classId,
  }) async {
    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .createBooking(scheduleId: scheduleId, classId: classId);
      await loadBookings();
      return booking;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> cancelBooking({
    required String bookingId,
    required String scheduleId,
  }) async {
    try {
      await ref.read(bookingRepositoryProvider).cancelBooking(bookingId);
      await loadBookings();
      ref.invalidate(userBookingsProvider);
      ref.invalidate(upcomingBookingsProvider);
      ref.invalidate(pastBookingsProvider);
      ref.invalidate(bookingByIdProvider(bookingId));
      ref.invalidate(allSchedulesProvider);
      ref.invalidate(availableSchedulesProvider);
      ref.invalidate(schedulesByDateProvider);
      ref.invalidate(schedulesForSelectedDateProvider);
      ref.invalidate(schedulesByClassIdProvider);
      ref.invalidate(scheduleByIdProvider(scheduleId));
      ref.invalidate(remainingCreditsProvider);
      ref.invalidate(transactionHistoryProvider);
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(walletSummaryProvider);
      ref.invalidate(userProfileProvider);
      await Future.wait([
        ref.read(scheduleListNotifierProvider.notifier).loadSchedules(),
        ref.read(walletNotifierProvider.notifier).loadWallet(),
        ref.read(profileNotifierProvider.notifier).loadProfile(),
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required String newScheduleId,
    required String oldScheduleId,
  }) async {
    try {
      final newBooking = await ref.read(bookingRepositoryProvider).rescheduleBooking(
        bookingId: bookingId,
        newScheduleId: newScheduleId,
      );

      // Refresh all related providers
      await loadBookings();
      ref.invalidate(userBookingsProvider);
      ref.invalidate(upcomingBookingsProvider);
      ref.invalidate(pastBookingsProvider);
      ref.invalidate(bookingByIdProvider(bookingId));
      ref.invalidate(allSchedulesProvider);
      ref.invalidate(availableSchedulesProvider);
      ref.invalidate(schedulesByDateProvider);
      ref.invalidate(schedulesForSelectedDateProvider);
      ref.invalidate(schedulesByClassIdProvider);
      ref.invalidate(scheduleByIdProvider(oldScheduleId));
      ref.invalidate(scheduleByIdProvider(newScheduleId));
      ref.invalidate(remainingCreditsProvider);
      ref.invalidate(transactionHistoryProvider);
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(walletSummaryProvider);
      ref.invalidate(userProfileProvider);

      await Future.wait([
        ref.read(scheduleListNotifierProvider.notifier).loadSchedules(),
        ref.read(walletNotifierProvider.notifier).loadWallet(),
        ref.read(profileNotifierProvider.notifier).loadProfile(),
      ]);

      return newBooking;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      Error.throwWithStackTrace(e, st);
    }
  }

  /// Mark a booking as checked in (for manual check-in from mobile).
  Future<BookingModel> markAsCheckedIn(String bookingId) async {
    try {
      final updatedBooking = await ref
          .read(bookingRepositoryProvider)
          .markAsCheckedIn(bookingId);

      // Force refresh all booking providers
      await loadBookings();
      ref.invalidate(userBookingsProvider);
      ref.invalidate(upcomingBookingsProvider);
      ref.invalidate(pastBookingsProvider);
      ref.invalidate(bookingByIdProvider(bookingId));
      ref.invalidate(bookingWatcherProvider(bookingId));

      return updatedBooking;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      Error.throwWithStackTrace(e, st);
    }
  }
}

/// NotifierProvider for booking state.
final bookingNotifierProvider =
    NotifierProvider<BookingNotifier, AsyncValue<List<BookingModel>>>(
  BookingNotifier.new,
);

// ==================== AUTO-COMPLETE & NO-SHOW LOGIC ====================

/// Helper function to check if a booking should be auto-completed.
/// Call this when app resumes or bookings are loaded.
Future<void> processExpiredBookings(WidgetRef ref) async {
  final bookingRepository = ref.read(bookingRepositoryProvider);
  final scheduleRepository = ref.read(scheduleRepositoryProvider);

  try {
    // Get upcoming bookings that might need to be expired
    final bookings = await bookingRepository.getUpcomingBookings();

    for (final booking in bookings) {
      // Get the schedule to check expiration
      final schedule = await scheduleRepository.getScheduleById(booking.scheduleId);
      if (schedule == null) continue;

      // Check if schedule is expired (30 min after start time)
      if (schedule.isExpired && !booking.checkedIn) {
        // Auto mark as no-show (no credit refund)
        await bookingRepository.markAsNoShow(booking.id);

        // Refresh booking providers
        ref.invalidate(userBookingsProvider);
        ref.invalidate(upcomingBookingsProvider);
        ref.invalidate(pastBookingsProvider);
        ref.invalidate(bookingByIdProvider(booking.id));
      }
    }
  } catch (e) {
    // Silently fail - don't disrupt user experience
    // Log error in production
  }
}
