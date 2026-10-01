import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _isInitialized = false;
  bool _isConfigured = false;
  String _activeUrl = '';

  bool get isInitialized => _isInitialized;
  bool get isConfigured => _isConfigured;
  String get activeUrl => _activeUrl;

  SupabaseClient? get client {
    if (_isInitialized && _isConfigured) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  User? get currentUser => client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<void> init({String? supabaseUrl, String? supabaseAnonKey}) async {
    // 1. Try loading .env file if not already loaded
    try {
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: ".env");
      }
    } catch (e) {
      debugPrint('Note: .env file loading: $e');
    }

    // 2. Read URL and Anon Key from:
    // a) direct method argument
    // b) dotenv (.env file)
    // c) --dart-define environment variable
    final envUrl = dotenv.isInitialized ? dotenv.maybeGet('SUPABASE_URL') : null;
    final envAnonKey = dotenv.isInitialized ? dotenv.maybeGet('SUPABASE_ANON_KEY') : null;

    final url = (supabaseUrl != null && supabaseUrl.isNotEmpty ? supabaseUrl : null) ??
        (envUrl != null && envUrl.isNotEmpty ? envUrl : null) ??
        const String.fromEnvironment('SUPABASE_URL', defaultValue: '');

    final anonKey = (supabaseAnonKey != null && supabaseAnonKey.isNotEmpty ? supabaseAnonKey : null) ??
        (envAnonKey != null && envAnonKey.isNotEmpty ? envAnonKey : null) ??
        const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    final cleanUrl = url.trim();
    final cleanAnonKey = anonKey.trim();

    if (cleanUrl.isNotEmpty &&
        cleanAnonKey.isNotEmpty &&
        !cleanUrl.contains('your-project-id') &&
        !cleanUrl.contains('your-supabase-url')) {
      try {
        await Supabase.initialize(
          url: cleanUrl,
          anonKey: cleanAnonKey,
          debug: kDebugMode,
        );
        _isInitialized = true;
        _isConfigured = true;
        _activeUrl = cleanUrl;
        debugPrint('✅ Supabase successfully connected to live project: $cleanUrl');
        return;
      } catch (e) {
        debugPrint('⚠️ Failed to connect to Supabase: $e');
      }
    }

    // Fallback: mark as initialized in offline/local demo mode
    _isInitialized = true;
    _isConfigured = false;
    _activeUrl = '';
    debugPrint('ℹ️ Supabase initialized in Offline/Local Mode (No live credentials detected).');
  }
}
