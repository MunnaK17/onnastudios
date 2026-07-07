/// Supabase configuration.
///
/// Credentials can still be overridden via --dart-define at run time:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zslcmdomlizkcxpweqlh.supabase.co',
  );
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzbGNtZG9tbGl6a2N4cHdlcWxoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyNTgyMzYsImV4cCI6MjA5NzgzNDIzNn0.'
        'HzWDu_cf389ZhtNMilnFq6BSyD8E5GfA12c-udXGeNk',
  );

  /// Returns true when both credentials have been provided.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static List<String> get missingKeys {
    return [
      if (url.isEmpty) 'SUPABASE_URL',
      if (anonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
  }

  static String get missingKeysMessage {
    return 'Missing Supabase configuration: ${missingKeys.join(', ')}.';
  }
}
