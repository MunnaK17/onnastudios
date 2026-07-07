import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_enums.dart';
import '../../models/booking_model.dart';
import '../interfaces/booking_repository.dart';

class SupabaseBookingRepository implements BookingRepository {
  SupabaseBookingRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }
    return user.id;
  }

  BookingModel _mapBooking(Map<String, dynamic> data) {
    return BookingModel(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      scheduleId: data['schedule_id'] as String,
      classId: data['class_id'] as String,
      status: BookingStatus.values.byName(data['status'] as String),
      qrCodeValue: data['qr_code_value'] as String,
      bookedAt: DateTime.parse(data['booked_at'] as String),
      checkedIn: data['checked_in'] as bool? ?? false,
      checkedInAt: data['checked_in_at'] != null
          ? DateTime.parse(data['checked_in_at'] as String)
          : null,
    );
  }

  @override
  Future<List<BookingModel>> getUserBookings() async {
    final userId = _currentUserId;
    final data = await _client
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .order('booked_at', ascending: false);
    return data.map(_mapBooking).toList();
  }

  @override
  Future<BookingModel?> getBookingById(String id) async {
    final userId = _currentUserId;
    final data = await _client
        .from('bookings')
        .select()
        .eq('id', id)
        .eq('user_id', userId)
        .maybeSingle();
    return data == null ? null : _mapBooking(data);
  }

  @override
  Future<List<BookingModel>> getUpcomingBookings() async {
    final userId = _currentUserId;
    final data = await _client
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .eq('status', BookingStatus.upcoming.name)
        .order('booked_at', ascending: false);
    return data.map(_mapBooking).toList();
  }

  @override
  Future<List<BookingModel>> getPastBookings() async {
    final userId = _currentUserId;
    final data = await _client
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .neq('status', BookingStatus.upcoming.name)
        .order('booked_at', ascending: false);
    return data.map(_mapBooking).toList();
  }

  @override
  Future<BookingModel> createBooking({
    required String scheduleId,
    required String classId,
  }) async {
    final data = await _client.rpc(
      'create_booking',
      params: {'p_schedule_id': scheduleId, 'p_class_id': classId},
    );
    return _mapBooking(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _client.rpc('cancel_booking', params: {'p_booking_id': bookingId});
  }

  @override
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required String newScheduleId,
  }) async {
    final data = await _client.rpc(
      'reschedule_booking',
      params: {
        'p_booking_id': bookingId,
        'p_new_schedule_id': newScheduleId,
      },
    );
    return _mapBooking(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<bool> hasBookedSchedule(String scheduleId) async {
    final userId = _currentUserId;
    final data = await _client
        .from('bookings')
        .select('id')
        .eq('user_id', userId)
        .eq('schedule_id', scheduleId)
        .eq('status', BookingStatus.upcoming.name)
        .maybeSingle();
    return data != null;
  }

  @override
  Future<BookingModel> markAsCheckedIn(String bookingId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final data = await _client
        .from('bookings')
        .update({
          'checked_in': true,
          'checked_in_at': now,
        })
        .eq('id', bookingId)
        .select()
        .single();
    return _mapBooking(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<BookingModel> markAsNoShow(String bookingId) async {
    final data = await _client
        .from('bookings')
        .update({
          'status': BookingStatus.noShow.name,
          'checked_in': false,
        })
        .eq('id', bookingId)
        .select()
        .single();
    return _mapBooking(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<BookingModel?> getBookingByQrCode(String qrCodeValue) async {
    final data = await _client
        .from('bookings')
        .select()
        .eq('qr_code_value', qrCodeValue)
        .maybeSingle();
    return data == null ? null : _mapBooking(Map<String, dynamic>.from(data as Map));
  }
}
