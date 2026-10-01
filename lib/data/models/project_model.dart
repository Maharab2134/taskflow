class ProjectModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String color;
  final String icon;
  final String status;
  final DateTime? startDate;
  final DateTime? deadline;
  final int progress;
  final bool isFavorite;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description = '',
    this.color = '#6366F1',
    this.icon = 'folder',
    this.status = 'active',
    this.startDate,
    this.deadline,
    this.progress = 0,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Project',
      description: json['description'] as String? ?? '',
      color: json['color'] as String? ?? '#6366F1',
      icon: json['icon'] as String? ?? 'folder',
      status: json['status'] as String? ?? 'active',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'] as String) : null,
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline'] as String) : null,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'progress': progress,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProjectModel copyWith({
    String? name,
    String? description,
    String? color,
    String? icon,
    String? status,
    DateTime? startDate,
    DateTime? deadline,
    int? progress,
    bool? isFavorite,
  }) {
    return ProjectModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      progress: progress ?? this.progress,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}
