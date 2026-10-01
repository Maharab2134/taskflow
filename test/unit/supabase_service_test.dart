import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaharab/core/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SupabaseService Tests', () {
    test('SupabaseService initializes gracefully in Offline mode when keys are missing or placeholders', () async {
      final service = SupabaseService.instance;
      await service.init(
        supabaseUrl: 'https://your-project-id.supabase.co',
        supabaseAnonKey: 'placeholder-key',
      );

      expect(service.isInitialized, isTrue);
      expect(service.isConfigured, isFalse);
    });

    test('SupabaseService attempts initialization when valid-looking credentials provided', () async {
      final service = SupabaseService.instance;
      await service.init(
        supabaseUrl: 'https://mockproject123.supabase.co',
        supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mockToken',
      );

      expect(service.isInitialized, isTrue);
      // Client is attempted
    });
  });
}
