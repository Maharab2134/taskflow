class ProjectMemberModel {
  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final String role; // 'owner', 'admin', 'member', 'viewer'
  final DateTime joinedAt;

  ProjectMemberModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
    this.role = 'member',
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return ProjectMemberModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: profile?['full_name'] as String? ?? json['user_name'] as String? ?? 'Team Member',
      userEmail: profile?['email'] as String? ?? json['user_email'] as String? ?? '',
      userAvatar: profile?['avatar_url'] as String? ?? json['user_avatar'] as String?,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
