import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaharab/data/models/task_model.dart';
import 'package:taskmaharab/data/models/project_model.dart';
import 'package:taskmaharab/data/models/subtask_model.dart';

void main() {
  group('Model Serialization & Deserialization', () {
    test('TaskModel round-trip json with multiple assignees', () {
      final task = TaskModel(
        id: 't-100',
        userId: 'user-1',
        title: 'Complete architecture review',
        description: 'Verify RLS and clean riverpod architecture',
        status: 'in_progress',
        priority: 'high',
        dueDate: DateTime(2026, 10, 15, 14, 0),
        tags: const ['architecture', 'mobile'],
        assigneeIds: const ['u1', 'u2'],
        assigneeNames: const ['Maharab Hossain', 'Sarah Connor'],
        assigneeAvatars: const [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'
        ],
        subtasks: [
          SubtaskModel(id: 's-1', taskId: 't-100', title: 'Audit schema', isCompleted: true),
          SubtaskModel(id: 's-2', taskId: 't-100', title: 'Check indexes', isCompleted: false),
        ],
        createdAt: DateTime(2026, 9, 30),
      );

      final json = task.toJson();
      final fromJson = TaskModel.fromJson(json);

      expect(fromJson.id, 't-100');
      expect(fromJson.title, 'Complete architecture review');
      expect(fromJson.status, 'in_progress');
      expect(fromJson.priority, 'high');
      expect(fromJson.tags.length, 2);
      expect(fromJson.assigneeIds.length, 2);
      expect(fromJson.assigneeNames, contains('Maharab Hossain'));
      expect(fromJson.assigneeNames, contains('Sarah Connor'));
      expect(fromJson.assigneeId, 'u1');
      expect(fromJson.assigneeName, 'Maharab Hossain');
    });

    test('ProjectModel round-trip json', () {
      final project = ProjectModel(
        id: 'p-100',
        userId: 'user-1',
        name: 'TaskFlow Mobile',
        description: 'Production Task Manager',
        color: '#6366F1',
        icon: 'folder',
        progress: 75,
        deadline: DateTime(2026, 12, 31),
        createdAt: DateTime(2026, 9, 30),
      );

      final json = project.toJson();
      final fromJson = ProjectModel.fromJson(json);

      expect(fromJson.id, 'p-100');
      expect(fromJson.name, 'TaskFlow Mobile');
      expect(fromJson.color, '#6366F1');
      expect(fromJson.progress, 75);
    });
  });
}
