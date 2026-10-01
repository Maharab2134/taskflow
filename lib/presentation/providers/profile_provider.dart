import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileNotifier extends AsyncNotifier<ProfileModel> {
  late final ProfileRepository _repo;

  @override
  Future<ProfileModel> build() async {
    _repo = ref.watch(profileRepositoryProvider);
    return _repo.getProfile();
  }

  Future<void> updateProfile({
    required String fullName,
    required String jobTitle,
    required String bio,
    String? avatarUrl,
  }) async {
    final current = state.value;
    if (current != null) {
      final updated = current.copyWith(
        fullName: fullName,
        jobTitle: jobTitle,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      state = AsyncValue.data(updated);
      await _repo.updateProfile(updated);
    }
  }

  Future<void> updateAvatar(String? newAvatarUrl) async {
    final current = state.value;
    if (current != null) {
      final updated = current.copyWith(avatarUrl: newAvatarUrl);
      state = AsyncValue.data(updated);
      await _repo.updateProfile(updated);
    }
  }

  Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    return await _repo.uploadAvatar(
      bytes: bytes,
      fileExtension: fileExtension,
    );
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileModel>(ProfileNotifier.new);
