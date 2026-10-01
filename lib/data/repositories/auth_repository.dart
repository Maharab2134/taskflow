import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/profile_model.dart';

class AuthRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  // Stream of auth changes
  Stream<AuthState?> get authStateChanges {
    final client = _supabaseService.client;
    if (client != null) {
      return client.auth.onAuthStateChange.map((data) => data);
    }
    return const Stream.empty();
  }

  bool get isAuthenticated {
    if (_supabaseService.isConfigured) {
      return _supabaseService.isAuthenticated;
    }
    return false;
  }

  ProfileModel? get currentUserProfile {
    final user = _supabaseService.currentUser;
    if (user != null) {
      return ProfileModel(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String? ??
            user.email?.split('@').first ??
            'User',
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      );
    }
    return null;
  }

  Future<void> signIn({required String email, required String password}) async {
    final client = _supabaseService.client;
    if (client != null && _supabaseService.isConfigured) {
      await client.auth.signInWithPassword(email: email, password: password);
    } else {
      throw Exception('Supabase is not configured or offline. Please check your credentials in .env');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final client = _supabaseService.client;
    if (client != null && _supabaseService.isConfigured) {
      await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
        emailRedirectTo: 'taskflow://login-callback',
      );
    } else {
      throw Exception('Supabase is not configured or offline. Please check your credentials in .env');
    }
  }

  Future<void> signOut() async {
    final client = _supabaseService.client;
    if (client != null && _supabaseService.isConfigured) {
      await client.auth.signOut();
    }
  }

  Future<void> resetPasswordForEmail(String email) async {
    final client = _supabaseService.client;
    if (client != null && _supabaseService.isConfigured) {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'taskflow://reset-password',
      );
    } else {
      throw Exception('Supabase connection is not available.');
    }
  }

  Future<bool> verifyEmailOtp({required String email, required String token}) async {
    final client = _supabaseService.client;
    if (client != null && _supabaseService.isConfigured) {
      final res = await client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
      return res.session != null || res.user != null;
    }
    return true;
  }

  Future<void> resendVerificationEmail(String email) async {
    final client = _supabaseService.client;
    if (client != null && _supabaseService.isConfigured) {
      await client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'io.supabase.taskflow://login-callback',
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final client = _supabaseService.client;
    if (client != null && _supabaseService.isConfigured) {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
