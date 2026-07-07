import 'package:supabase_flutter/supabase_flutter.dart';

String appErrorMessage(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  final raw = switch (error) {
    PostgrestException(:final message) => message,
    AuthException(:final message) => message,
    Exception() => error.toString().replaceFirst('Exception: ', ''),
    _ => error.toString(),
  };

  final message = raw.trim();
  if (message.isEmpty) return fallback;

  final normalized = message.toLowerCase();
  if (normalized.contains('insufficient credits')) {
    return 'You do not have enough credits. Please contact the studio.';
  }
  if (normalized.contains('already booked')) {
    return 'You have already booked this schedule.';
  }
  if (normalized.contains('already full')) {
    return 'This class is already full. Please choose another schedule.';
  }
  if (normalized.contains('no available')) {
    return 'No available schedule was found for this class.';
  }
  if (normalized.contains('not found')) {
    return message;
  }
  if (normalized.contains('sign in')) {
    return 'Please sign in again to continue.';
  }

  return message == 'null' ? fallback : message;
}
