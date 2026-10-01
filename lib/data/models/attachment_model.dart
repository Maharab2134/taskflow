class AttachmentModel {
  final String id;
  final String taskId;
  final String userId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String fileType;
  final DateTime createdAt;

  AttachmentModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    this.fileSize = 0,
    this.fileType = 'doc',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      fileName: json['file_name'] as String? ?? 'attachment',
      fileUrl: json['file_url'] as String? ?? '',
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      fileType: json['file_type'] as String? ?? 'doc',
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
      'file_name': fileName,
      'file_url': fileUrl,
      'file_size': fileSize,
      'file_type': fileType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
