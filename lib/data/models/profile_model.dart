class ProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String jobTitle;
  final String bio;
  final String themeMode;
  final String accentColor;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.jobTitle = 'Productivity Specialist',
    this.bio = 'Organizing work & life with TaskFlow.',
    this.themeMode = 'system',
    this.accentColor = '#6366F1',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'TaskFlow User',
      avatarUrl: json['avatar_url'] as String?,
      jobTitle: json['job_title'] as String? ?? 'Productivity Specialist',
      bio: json['bio'] as String? ?? '',
      themeMode: json['theme_mode'] as String? ?? 'system',
      accentColor: json['accent_color'] as String? ?? '#6366F1',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'job_title': jobTitle,
      'bio': bio,
      'theme_mode': themeMode,
      'accent_color': accentColor,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? jobTitle,
    String? bio,
    String? themeMode,
    String? accentColor,
  }) {
    return ProfileModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      jobTitle: jobTitle ?? this.jobTitle,
      bio: bio ?? this.bio,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      createdAt: createdAt,
    );
  }
}
