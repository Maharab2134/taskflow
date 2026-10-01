import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  static ProfileModel _currentProfile = ProfileModel(
    id: '',
    email: '',
    fullName: '',
    jobTitle: '',
    bio: '',
  );

  Future<ProfileModel> getProfile() async {
    final client = _supabase.client;
    final user = _supabase.currentUser;

    if (client != null && user != null && _supabase.isConfigured) {
      try {
        final res = await client.from('profiles').select().eq('id', user.id).single();
        _currentProfile = ProfileModel.fromJson(res);
        return _currentProfile;
      } catch (e) {
        debugPrint('Note: Profile fetch error (may need insert): $e');
        // Return profile populated with current user metadata if profile table row not yet created
        final fallback = ProfileModel(
          id: user.id,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name'] as String? ?? user.email?.split('@').first ?? 'User',
          avatarUrl: user.userMetadata?['avatar_url'] as String?,
        );
        _currentProfile = fallback;
        return fallback;
      }
    }

    if (user != null) {
      return ProfileModel(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String? ?? user.email?.split('@').first ?? 'User',
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      );
    }

    return _currentProfile;
  }

  Future<void> updateProfile(ProfileModel updated) async {
    final client = _supabase.client;
    final user = _supabase.currentUser;

    if (client != null && _supabase.isConfigured) {
      try {
        final json = updated.toJson();
        if (user != null) {
          json['id'] = user.id;
        }
        await client.from('profiles').upsert(json);
      } catch (e) {
        debugPrint('Profile update error: $e');
      }
    }

    _currentProfile = updated;
  }

  Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final client = _supabase.client;
    final user = _supabase.currentUser;

    if (client != null && user != null && _supabase.isConfigured) {
      try {
        final ext = fileExtension.replaceAll('.', '').toLowerCase();
        final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
        
        await client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$ext',
            upsert: true,
          ),
        );

        final publicUrl = client.storage.from('avatars').getPublicUrl(path);
        return publicUrl;
      } catch (e) {
        debugPrint('Supabase avatar storage upload failed: $e');
        return null;
      }
    }
    return null;
  }
}

