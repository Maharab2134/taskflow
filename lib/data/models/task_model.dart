import 'package:flutter/material.dart';
import 'subtask_model.dart';

class TaskModel {
  final String id;
  final String userId;
  final String? projectId;
  final String? projectName;
  final String? projectColor;
  final String title;
  final String description;
  final String status; // 'todo', 'in_progress', 'review', 'completed', 'archived'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final DateTime? startDate;
  final int estimatedDurationMinutes;
  final String category;
  final List<String> tags;
  final List<String> assigneeIds;
  final List<String> assigneeNames;
  final List<String> assigneeAvatars;
  final bool isRecurring;
  final String? recurrencePattern;
  final DateTime? reminderAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final List<SubtaskModel> subtasks;
  final int commentsCount;
  final int attachmentsCount;

  // Convenient getters for single-assignee backwards compatibility
  String? get assigneeId => assigneeIds.isNotEmpty ? assigneeIds.first : null;
  String? get assigneeName => assigneeNames.isNotEmpty ? assigneeNames.first : null;
  String? get assigneeAvatar => assigneeAvatars.isNotEmpty ? assigneeAvatars.first : null;

  TaskModel({
    required this.id,
    required this.userId,
    this.projectId,
    this.projectName,
    this.projectColor,
    required this.title,
    this.description = '',
    this.status = 'todo',
    this.priority = 'medium',
    this.dueDate,
    this.dueTime,
    this.startDate,
    this.estimatedDurationMinutes = 30,
    this.category = 'General',
    this.tags = const [],
    List<String>? assigneeIds,
    List<String>? assigneeNames,
    List<String>? assigneeAvatars,
    String? assigneeId,
    String? assigneeName,
    String? assigneeAvatar,
    this.isRecurring = false,
    this.recurrencePattern,
    this.reminderAt,
    this.isDeleted = false,
    this.deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.completedAt,
    this.subtasks = const [],
    this.commentsCount = 0,
    this.attachmentsCount = 0,
  })  : assigneeIds = assigneeIds ?? (assigneeId != null ? [assigneeId] : const []),
        assigneeNames = assigneeNames ?? (assigneeName != null ? [assigneeName] : const []),
        assigneeAvatars = assigneeAvatars ?? (assigneeAvatar != null ? [assigneeAvatar] : const []),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isCompleted => status == 'completed';

  int get completedSubtasksCount => subtasks.where((s) => s.isCompleted).length;
  double get subtasksProgress =>
      subtasks.isEmpty ? 0.0 : completedSubtasksCount / subtasks.length;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parsedDueTime;
    if (json['due_time'] != null) {
      final parts = (json['due_time'] as String).split(':');
      if (parts.length >= 2) {
        parsedDueTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final project = json['projects'] as Map<String, dynamic>?;
    final assignee = json['assignee'] as Map<String, dynamic>?;

    List<SubtaskModel> parsedSubtasks = [];
    if (json['subtasks'] != null && json['subtasks'] is List) {
      parsedSubtasks = (json['subtasks'] as List)
          .map((item) => SubtaskModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<String> parsedTags = [];
    if (json['tags'] != null && json['tags'] is List) {
      parsedTags = List<String>.from(json['tags']);
    }

    List<String> parsedAssigneeIds = [];
    if (json['assignee_ids'] != null && json['assignee_ids'] is List) {
      parsedAssigneeIds = List<String>.from(json['assignee_ids']);
    } else if (json['assignee_id'] != null) {
      parsedAssigneeIds = [json['assignee_id'] as String];
    }

    List<String> parsedAssigneeNames = [];
    if (json['assignee_names'] != null && json['assignee_names'] is List) {
      parsedAssigneeNames = List<String>.from(json['assignee_names']);
    } else if (assignee?['full_name'] != null) {
      parsedAssigneeNames = [assignee!['full_name'] as String];
    } else if (json['assignee_name'] != null) {
      parsedAssigneeNames = [json['assignee_name'] as String];
    }

    List<String> parsedAssigneeAvatars = [];
    if (json['assignee_avatars'] != null && json['assignee_avatars'] is List) {
      parsedAssigneeAvatars = List<String>.from(json['assignee_avatars']);
    } else if (assignee?['avatar_url'] != null) {
      parsedAssigneeAvatars = [assignee!['avatar_url'] as String];
    } else if (json['assignee_avatar'] != null) {
      parsedAssigneeAvatars = [json['assignee_avatar'] as String];
    }

    return TaskModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      projectId: json['project_id'] as String?,
      projectName: project?['name'] as String? ?? json['project_name'] as String?,
      projectColor: project?['color'] as String? ?? json['project_color'] as String?,
      title: json['title'] as String? ?? 'Untitled Task',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'todo',
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      dueTime: parsedDueTime,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'] as String) : null,
      estimatedDurationMinutes: (json['estimated_duration_minutes'] as num?)?.toInt() ?? 30,
      category: json['category'] as String? ?? 'General',
      tags: parsedTags,
      assigneeIds: parsedAssigneeIds,
      assigneeNames: parsedAssigneeNames,
      assigneeAvatars: parsedAssigneeAvatars,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrencePattern: json['recurrence_pattern'] as String?,
      reminderAt: json['reminder_at'] != null ? DateTime.tryParse(json['reminder_at'] as String) : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now() : DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      subtasks: parsedSubtasks,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      attachmentsCount: (json['attachments_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate != null ? '${dueDate!.year.toString().padLeft(4, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}' : null,
      'due_time': dueTime != null ? '${dueTime!.hour.toString().padLeft(2, '0')}:${dueTime!.minute.toString().padLeft(2, '0')}:00' : null,
      'start_date': startDate != null ? '${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}' : null,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'category': category,
      'tags': tags,
      'assignee_id': assigneeId,
      'assignee_ids': assigneeIds,
      'assignee_names': assigneeNames,
      'assignee_avatars': assigneeAvatars,
      'is_recurring': isRecurring,
      'recurrence_pattern': recurrencePattern,
      'reminder_at': reminderAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    String? projectId,
    String? projectName,
    String? projectColor,
    String? status,
    String? priority,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    DateTime? startDate,
    int? estimatedDurationMinutes,
    String? category,
    List<String>? tags,
    List<String>? assigneeIds,
    List<String>? assigneeNames,
    List<String>? assigneeAvatars,
    String? assigneeId,
    String? assigneeName,
    String? assigneeAvatar,
    bool? isRecurring,
    String? recurrencePattern,
    DateTime? reminderAt,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? completedAt,
    List<SubtaskModel>? subtasks,
    int? commentsCount,
    int? attachmentsCount,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      projectColor: projectColor ?? this.projectColor,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      startDate: startDate ?? this.startDate,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      assigneeIds: assigneeIds ?? (assigneeId != null ? [assigneeId] : this.assigneeIds),
      assigneeNames: assigneeNames ?? (assigneeName != null ? [assigneeName] : this.assigneeNames),
      assigneeAvatars: assigneeAvatars ?? (assigneeAvatar != null ? [assigneeAvatar] : this.assigneeAvatars),
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      reminderAt: reminderAt ?? this.reminderAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      completedAt: completedAt ?? this.completedAt,
      subtasks: subtasks ?? this.subtasks,
      commentsCount: commentsCount ?? this.commentsCount,
      attachmentsCount: attachmentsCount ?? this.attachmentsCount,
    );
  }
}
