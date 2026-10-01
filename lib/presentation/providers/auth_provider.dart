import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/app_toast.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthStateData {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final ProfileModel? profile;

  AuthStateData({
    required this.isAuthenticated,
    this.isLoading = false,
    this.errorMessage,
    this.profile,
  });

  AuthStateData copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    ProfileModel? profile,
  }) {
    return AuthStateData(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      profile: profile ?? this.profile,
    );
  }
}

class AuthNotifier extends Notifier<AuthStateData> {
  late final AuthRepository _repo;

  @override
  AuthStateData build() {
    _repo = ref.watch(authRepositoryProvider);
    return AuthStateData(
      isAuthenticated: _repo.isAuthenticated,
      profile: _repo.currentUserProfile,
    );
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.signIn(email: email, password: password);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        profile: _repo.currentUserProfile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppToast.cleanMessage(e),
      );
      return false;
    }
  }

  Future<bool> signUp({required String email, required String password, required String fullName}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.signUp(email: email, password: password, fullName: fullName);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        profile: _repo.currentUserProfile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppToast.cleanMessage(e),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repo.signOut();
    state = AuthStateData(isAuthenticated: false);
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.resetPasswordForEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppToast.cleanMessage(e),
      );
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.updatePassword(newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppToast.cleanMessage(e),
      );
      return false;
    }
  }

  Future<bool> verifyEmailOtp({required String email, required String token}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _repo.verifyEmailOtp(email: email, token: token);
      state = state.copyWith(
        isAuthenticated: success,
        isLoading: false,
        profile: _repo.currentUserProfile,
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppToast.cleanMessage(e),
      );
      return false;
    }
  }

  Future<bool> resendVerificationEmail(String email) async {
    try {
      await _repo.resendVerificationEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthStateData>(AuthNotifier.new);
