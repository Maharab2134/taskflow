import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/sync_service.dart';

class SyncState {
  final SyncStatus status;
  final DateTime lastSyncTime;

  SyncState({this.status = SyncStatus.synced, DateTime? lastSyncTime})
      : lastSyncTime = lastSyncTime ?? DateTime.now();

  SyncState copyWith({SyncStatus? status, DateTime? lastSyncTime}) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => SyncState();

  void setStatus(SyncStatus status) {
    state = state.copyWith(status: status);
  }

  Future<void> triggerSync() async {
    if (state.status == SyncStatus.offline) return;
    state = state.copyWith(status: SyncStatus.syncing);
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(status: SyncStatus.synced, lastSyncTime: DateTime.now());
  }

  void toggleOfflineMode() {
    if (state.status == SyncStatus.offline) {
      triggerSync();
    } else {
      setStatus(SyncStatus.offline);
    }
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);
