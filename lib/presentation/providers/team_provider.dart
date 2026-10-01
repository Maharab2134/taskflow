import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/team_member.dart';

class TeamNotifier extends Notifier<List<TeamMember>> {
  @override
  List<TeamMember> build() {
    final cached = StorageService.getCachedTeamMembers();
    if (cached.isNotEmpty) {
      _syncSupabaseProfiles();
      return cached;
    }
    final initial = List<TeamMember>.from(TeamMember.defaultTeam);
    StorageService.cacheTeamMembers(initial);
    _syncSupabaseProfiles();
    return initial;
  }

  Future<void> _syncSupabaseProfiles() async {
    final client = SupabaseService.instance.client;
    if (client != null && SupabaseService.instance.isConfigured) {
      try {
        final res = await client.from('profiles').select();
        if (res.isNotEmpty) {
          final cloudMembers = res.map((row) {
            final data = row;
            return TeamMember(
              id: data['id'] as String? ?? '',
              name: data['full_name'] as String? ?? (data['email'] as String? ?? 'User').split('@').first,
              email: data['email'] as String? ?? '',
              role: data['job_title'] as String? ?? 'Member',
              avatarUrl: data['avatar_url'] as String? ?? '',
            );
          }).where((m) => m.name.isNotEmpty).toList();

          if (cloudMembers.isNotEmpty) {
            // Merge cloud members with current members avoiding duplicate IDs/emails
            final currentMap = {for (var m in state) m.email.toLowerCase(): m};
            for (var cm in cloudMembers) {
              if (cm.email.isNotEmpty) {
                currentMap[cm.email.toLowerCase()] = cm;
              }
            }
            state = currentMap.values.toList();
            await StorageService.cacheTeamMembers(state);
          }
        }
      } catch (_) {}
    }
  }

  Future<void> addMember({
    required String name,
    required String email,
    required String role,
    String? avatarUrl,
  }) async {
    final client = SupabaseService.instance.client;

    // Try to fetch real profile from Supabase (optional enhancement)
    String resolvedName = name.trim();
    String resolvedAvatar = avatarUrl?.trim().isNotEmpty == true
        ? avatarUrl!.trim()
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name.trim())}&background=random&size=150';

    if (client != null && SupabaseService.instance.isConfigured) {
      try {
        final res = await client
            .from('profiles')
            .select()
            .eq('email', email.trim())
            .maybeSingle();

        if (res != null) {
          // Member is registered — use their real info
          resolvedName = res['full_name'] as String? ?? resolvedName;
          resolvedAvatar = res['avatar_url'] as String? ?? resolvedAvatar;
        }
        // If not found, no problem — add with provided info anyway
      } catch (_) {
        // Ignore Supabase error, just add locally
      }
    }

    final newMember = TeamMember(
      id: 'member-${DateTime.now().millisecondsSinceEpoch}',
      name: resolvedName,
      email: email.trim(),
      role: role.trim(),
      avatarUrl: resolvedAvatar,
    );

    state = [...state, newMember];
    await StorageService.cacheTeamMembers(state);
  }

  Future<void> removeMember(String id) async {
    state = state.where((m) => m.id != id).toList();
    await StorageService.cacheTeamMembers(state);
  }

  Future<void> updateRole(String id, String newRole) async {
    state = state.map((m) {
      if (m.id == id) {
        return m.copyWith(role: newRole);
      }
      return m;
    }).toList();
    await StorageService.cacheTeamMembers(state);
  }
}

final teamProvider = NotifierProvider<TeamNotifier, List<TeamMember>>(TeamNotifier.new);
