class SubtaskModel {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final int position;
  final DateTime createdAt;

  SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.position = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
      position: (json['position'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted,
      'position': position,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SubtaskModel copyWith({
    String? title,
    bool? isCompleted,
    int? position,
  }) {
    return SubtaskModel(
      id: id,
      taskId: taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      position: position ?? this.position,
      createdAt: createdAt,
    );
  }
}
