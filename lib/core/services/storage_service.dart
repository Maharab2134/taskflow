import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../data/models/task_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/team_member.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static final Map<String, Object> _memoryCache = {};

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('StorageService: SharedPreferences plugin unavailable ($e). Using in-memory cache.');
      _prefs = null;
    }
  }

  // Theme settings
  static Future<void> saveThemeMode(String mode) async {
    _memoryCache[AppConstants.keyThemeMode] = mode;
    try {
      await _prefs?.setString(AppConstants.keyThemeMode, mode);
    } catch (_) {}
  }

  static String getThemeMode() {
    if (_prefs != null) {
      try {
        final val = _prefs!.getString(AppConstants.keyThemeMode);
        if (val != null) return val;
      } catch (_) {}
    }
    return (_memoryCache[AppConstants.keyThemeMode] as String?) ?? 'system';
  }

  // Accent color
  static Future<void> saveAccentColor(String hexColor) async {
    _memoryCache[AppConstants.keyAccentColor] = hexColor;
    try {
      await _prefs?.setString(AppConstants.keyAccentColor, hexColor);
    } catch (_) {}
  }

  static String getAccentColor() {
    if (_prefs != null) {
      try {
        final val = _prefs!.getString(AppConstants.keyAccentColor);
        if (val != null) return val;
      } catch (_) {}
    }
    return (_memoryCache[AppConstants.keyAccentColor] as String?) ?? '#6366F1';
  }

  // Onboarding
  static Future<void> setOnboardingCompleted() async {
    _memoryCache[AppConstants.keyOnboardingCompleted] = true;
    try {
      await _prefs?.setBool(AppConstants.keyOnboardingCompleted, true);
    } catch (_) {}
  }

  static bool isOnboardingCompleted() {
    if (_prefs != null) {
      try {
        final val = _prefs!.getBool(AppConstants.keyOnboardingCompleted);
        if (val != null) return val;
      } catch (_) {}
    }
    return (_memoryCache[AppConstants.keyOnboardingCompleted] as bool?) ?? false;
  }

  // Offline Tasks Cache
  static Future<void> cacheTasks(List<TaskModel> tasks) async {
    final jsonList = tasks.map((t) => t.toJson()).toList();
    final encoded = jsonEncode(jsonList);
    _memoryCache[AppConstants.keyOfflineTasks] = encoded;
    try {
      await _prefs?.setString(AppConstants.keyOfflineTasks, encoded);
    } catch (_) {}
  }

  static List<TaskModel> getCachedTasks() {
    String? raw;
    if (_prefs != null) {
      try {
        raw = _prefs!.getString(AppConstants.keyOfflineTasks);
      } catch (_) {}
    }
    raw ??= _memoryCache[AppConstants.keyOfflineTasks] as String?;
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Offline Projects Cache
  static Future<void> cacheProjects(List<ProjectModel> projects) async {
    final jsonList = projects.map((p) => p.toJson()).toList();
    final encoded = jsonEncode(jsonList);
    _memoryCache[AppConstants.keyOfflineProjects] = encoded;
    try {
      await _prefs?.setString(AppConstants.keyOfflineProjects, encoded);
    } catch (_) {}
  }

  static List<ProjectModel> getCachedProjects() {
    String? raw;
    if (_prefs != null) {
      try {
        raw = _prefs!.getString(AppConstants.keyOfflineProjects);
      } catch (_) {}
    }
    raw ??= _memoryCache[AppConstants.keyOfflineProjects] as String?;
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((item) => ProjectModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Team Members Cache
  static const String keyTeamMembers = 'workspace_team_members';
  static Future<void> cacheTeamMembers(List<TeamMember> members) async {
    final jsonList = members.map((m) => m.toJson()).toList();
    final encoded = jsonEncode(jsonList);
    _memoryCache[keyTeamMembers] = encoded;
    try {
      await _prefs?.setString(keyTeamMembers, encoded);
    } catch (_) {}
  }

  static List<TeamMember> getCachedTeamMembers() {
    String? raw;
    if (_prefs != null) {
      try {
        raw = _prefs!.getString(keyTeamMembers);
      } catch (_) {}
    }
    raw ??= _memoryCache[keyTeamMembers] as String?;
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((item) => TeamMember.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Clear all cached local data
  static Future<void> clearAll() async {
    _memoryCache.clear();
    try {
      await _prefs?.clear();
    } catch (_) {}
  }
}
