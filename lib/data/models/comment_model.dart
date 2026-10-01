class CommentModel {
  final String id;
  final String taskId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: profile?['full_name'] as String? ?? json['user_name'] as String? ?? 'User',
      userAvatar: profile?['avatar_url'] as String? ?? json['user_avatar'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
