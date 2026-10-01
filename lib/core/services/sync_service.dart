import 'dart:async';
import 'package:flutter/foundation.dart';

enum SyncStatus {
  synced,
  syncing,
  offline,
}

class SyncService extends ChangeNotifier {
  SyncService._();
  static final SyncService instance = SyncService._();

  SyncStatus _status = SyncStatus.synced;
  DateTime _lastSyncTime = DateTime.now();

  SyncStatus get status => _status;
  DateTime get lastSyncTime => _lastSyncTime;

  void setStatus(SyncStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      if (newStatus == SyncStatus.synced) {
        _lastSyncTime = DateTime.now();
      }
      notifyListeners();
    }
  }

  Future<void> triggerSync() async {
    if (_status == SyncStatus.offline) return;
    setStatus(SyncStatus.syncing);
    await Future.delayed(const Duration(milliseconds: 1200));
    setStatus(SyncStatus.synced);
  }

  void toggleOfflineMode() {
    if (_status == SyncStatus.offline) {
      triggerSync();
    } else {
      setStatus(SyncStatus.offline);
    }
  }
}
