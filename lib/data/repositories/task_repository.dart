import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/storage_service.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';
import '../models/comment_model.dart';
import '../models/attachment_model.dart';

class TaskRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  final Uuid _uuid = const Uuid();

  // In-memory realistic initial task dataset
  static final List<TaskModel> _tasks = [
    TaskModel(
      id: 'task-1',
      userId: 'demo-user-12345',
      projectId: 'proj-1',
      projectName: 'Portfolio Website',
      projectColor: '#6366F1',
      title: 'Design landing page hero section in Figma',
      description: 'Craft sleek dark mode hero with glassmorphism badges and dynamic CTA',
      status: 'completed',
      priority: 'high',
      dueDate: DateTime.now(),
      dueTime: const TimeOfDay(hour: 15, minute: 0),
      category: 'Design',
      tags: ['figma', 'ui', 'hero'],
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
      assigneeIds: const ['u4'],
      assigneeNames: const ['Elena Rostova'],
      assigneeAvatars: const ['https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150'],
      subtasks: [
        SubtaskModel(id: 'sub-1', taskId: 'task-1', title: 'Pick vibrant gradient palette', isCompleted: true, position: 0),
        SubtaskModel(id: 'sub-2', taskId: 'task-1', title: 'Design mobile responsive layout', isCompleted: true, position: 1),
        SubtaskModel(id: 'sub-3', taskId: 'task-1', title: 'Export vector SVG assets', isCompleted: true, position: 2),
      ],
      commentsCount: 3,
      attachmentsCount: 1,
    ),
    TaskModel(
      id: 'task-2',
      userId: 'demo-user-12345',
      projectId: 'proj-1',
      projectName: 'Portfolio Website',
      projectColor: '#6366F1',
      title: 'Implement responsive navbar & routing',
      description: 'Set up GoRouter with smooth transition routes and mobile hamburger menu',
      status: 'in_progress',
      priority: 'high',
      dueDate: DateTime.now(),
      dueTime: const TimeOfDay(hour: 18, minute: 30),
      category: 'Engineering',
      tags: ['flutter', 'gorouter'],
      assigneeIds: const ['u1', 'u3'],
      assigneeNames: const ['Maharab Hossain', 'Alex River'],
      assigneeAvatars: const [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'
      ],
      subtasks: [
        SubtaskModel(id: 'sub-4', taskId: 'task-2', title: 'Create NavigationBar and NavigationRail', isCompleted: true, position: 0),
        SubtaskModel(id: 'sub-5', taskId: 'task-2', title: 'Implement Command Palette shortcut (Ctrl+K)', isCompleted: false, position: 1),
      ],
      commentsCount: 1,
    ),
    TaskModel(
      id: 'task-3',
      userId: 'demo-user-12345',
      projectId: 'proj-2',
      projectName: 'E-commerce App',
      projectColor: '#EC4899',
      title: 'Integrate Stripe payment checkout sheet',
      description: 'Configure webhooks, verify Apple Pay & Google Pay tokens securely',
      status: 'todo',
      priority: 'urgent',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      dueTime: const TimeOfDay(hour: 14, minute: 0),
      category: 'Payments',
      tags: ['stripe', 'backend'],
      assigneeIds: const ['u5', 'u2'],
      assigneeNames: const ['David Kim', 'Sarah Connor'],
      assigneeAvatars: const [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'
      ],
      subtasks: [
        SubtaskModel(id: 'sub-6', taskId: 'task-3', title: 'Create payment intent endpoint', isCompleted: false, position: 0),
        SubtaskModel(id: 'sub-7', taskId: 'task-3', title: 'Test 3D Secure fallback', isCompleted: false, position: 1),
      ],
    ),
    TaskModel(
      id: 'task-4',
      userId: 'demo-user-12345',
      projectId: 'proj-3',
      projectName: 'Mobile Banking App',
      projectColor: '#10B981',
      title: 'Audit security encryption and biometric login',
      description: 'Validate FaceID / TouchID biometric prompt fallback and token refresh',
      status: 'review',
      priority: 'urgent',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      dueTime: const TimeOfDay(hour: 11, minute: 0),
      category: 'Security',
      tags: ['security', 'auth'],
      assigneeIds: const ['u1', 'u5', 'u2'],
      assigneeNames: const ['Maharab Hossain', 'David Kim', 'Sarah Connor'],
      assigneeAvatars: const [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'
      ],
      subtasks: [
        SubtaskModel(id: 'sub-8', taskId: 'task-4', title: 'Verify PKCE flow', isCompleted: true, position: 0),
        SubtaskModel(id: 'sub-9', taskId: 'task-4', title: 'Check key chain secure storage', isCompleted: true, position: 1),
      ],
    ),
    TaskModel(
      id: 'task-5',
      userId: 'demo-user-12345',
      projectId: 'proj-5',
      projectName: 'Personal Development',
      projectColor: '#8B5CF6',
      title: 'Read 2 chapters of "Designing Data-Intensive Applications"',
      description: 'Take markdown notes on partition rebalancing and consensus protocols',
      status: 'todo',
      priority: 'low',
      dueDate: DateTime.now(),
      dueTime: const TimeOfDay(hour: 21, minute: 0),
      category: 'Learning',
      tags: ['books', 'growth'],
    ),
    TaskModel(
      id: 'task-6',
      userId: 'demo-user-12345',
      projectId: 'proj-4',
      projectName: 'University Project',
      projectColor: '#F59E0B',
      title: 'Benchmark Raft vs Paxos replication latency',
      description: 'Run simulation on 5-node cluster and record throughput under network partition',
      status: 'in_progress',
      priority: 'medium',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      category: 'Research',
      tags: ['distributed-systems'],
    ),
  ];

  static final Map<String, List<CommentModel>> _taskComments = {
    'task-1': [
      CommentModel(
        id: 'c-1',
        taskId: 'task-1',
        userId: 'demo-user-12345',
        userName: 'Alex Vance',
        content: 'Completed the dark theme palette in Figma. Exported all SVG assets.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      CommentModel(
        id: 'c-2',
        taskId: 'task-1',
        userId: 'member-2',
        userName: 'Elena Rostova',
        content: 'Looks gorgeous! The glassmorphism card elevation has great contrast.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
    'task-2': [
      CommentModel(
        id: 'c-3',
        taskId: 'task-2',
        userId: 'demo-user-12345',
        userName: 'Alex Vance',
        content: 'Working on the responsive navigation shell right now. Very smooth animations.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
    ],
  };

  static final Map<String, List<AttachmentModel>> _taskAttachments = {
    'task-1': [
      AttachmentModel(
        id: 'att-1',
        taskId: 'task-1',
        userId: 'demo-user-12345',
        fileName: 'Hero_Design_Preview_v2.png',
        fileUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800',
        fileSize: 1420000,
        fileType: 'image',
      ),
    ],
  };

  Future<List<TaskModel>> getTasks({bool includeDeleted = false, bool includeArchived = false}) async {
    final client = _supabase.client;
    if (client != null && _supabase.isConfigured) {
      try {
        var query = client.from('tasks').select('*, projects(name, color), subtasks(*)');
        if (!includeDeleted) {
          query = query.eq('is_deleted', false);
        }
        if (!includeArchived) {
          query = query.neq('status', 'archived');
        }
        final res = await query.order('due_date', ascending: true);
        final list = (res as List).map((item) => TaskModel.fromJson(item)).toList();
        await StorageService.cacheTasks(list);
        return list;
      } catch (_) {
        final cached = StorageService.getCachedTasks();
        if (cached.isNotEmpty) {
          return cached.where((t) {
            if (!includeDeleted && t.isDeleted) return false;
            if (!includeArchived && t.status == 'archived') return false;
            return true;
          }).toList();
        }
        return [];
      }
    }

    if (_supabase.isConfigured) {
      return [];
    }

    return _tasks.where((t) {
      if (!includeDeleted && t.isDeleted) return false;
      if (!includeArchived && t.status == 'archived') return false;
      return true;
    }).toList();
  }

  Future<List<TaskModel>> getTodayTasks() async {
    final all = await getTasks();
    final now = DateTime.now();
    return all.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).toList();
  }

  Future<List<TaskModel>> getUpcomingTasks() async {
    final all = await getTasks();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return all.where((t) {
      if (t.dueDate == null) return false;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return due.isAfter(today);
    }).toList();
  }

  Future<List<TaskModel>> getArchivedTasks() async {
    return _tasks.where((t) => t.status == 'archived' && !t.isDeleted).toList();
  }

  Future<List<TaskModel>> getTrashTasks() async {
    return _tasks.where((t) => t.isDeleted).toList();
  }

  Future<TaskModel?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final client = _supabase.client;
    if (client != null && _supabase.isConfigured) {
      try {
        await client.from('tasks').insert(task.toJson());
      } catch (_) {}
    }

    _tasks.insert(0, task);
    await StorageService.cacheTasks(_tasks);
    return task;
  }

  Future<void> updateTask(TaskModel task) async {
    final client = _supabase.client;
    if (client != null && _supabase.isConfigured) {
      try {
        await client.from('tasks').update(task.toJson()).eq('id', task.id);
      } catch (_) {}
    }

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await StorageService.cacheTasks(_tasks);
    }
  }

  Future<void> toggleTaskComplete(String id, bool isCompleted) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _tasks[index];
      final newStatus = isCompleted ? 'completed' : 'todo';
      final updated = old.copyWith(
        status: newStatus,
        completedAt: isCompleted ? DateTime.now() : null,
      );
      await updateTask(updated);
    }
  }

  Future<void> updateTaskStatus(String id, String newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _tasks[index];
      final updated = old.copyWith(
        status: newStatus,
        completedAt: newStatus == 'completed' ? DateTime.now() : null,
      );
      await updateTask(updated);
    }
  }

  Future<void> archiveTask(String id) async {
    await updateTaskStatus(id, 'archived');
  }

  Future<void> softDeleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _tasks[index];
      final updated = old.copyWith(isDeleted: true, deletedAt: DateTime.now());
      await updateTask(updated);
    }
  }

  Future<void> restoreTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _tasks[index];
      final updated = old.copyWith(isDeleted: false, deletedAt: null);
      await updateTask(updated);
    }
  }

  Future<void> permanentlyDeleteTask(String id) async {
    final client = _supabase.client;
    if (client != null && _supabase.isConfigured) {
      try {
        await client.from('tasks').delete().eq('id', id);
      } catch (_) {}
    }

    _tasks.removeWhere((t) => t.id == id);
    await StorageService.cacheTasks(_tasks);
  }

  // Subtasks Operations
  Future<void> addSubtask(String taskId, String title) async {
    final newSubtask = SubtaskModel(
      id: _uuid.v4(),
      taskId: taskId,
      title: title,
      position: 100,
    );

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updatedList = List<SubtaskModel>.from(_tasks[index].subtasks)..add(newSubtask);
      _tasks[index] = _tasks[index].copyWith(subtasks: updatedList);
      await StorageService.cacheTasks(_tasks);
    }
  }

  Future<void> toggleSubtask(String taskId, String subtaskId, bool isCompleted) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updatedList = _tasks[index].subtasks.map((s) {
        if (s.id == subtaskId) {
          return s.copyWith(isCompleted: isCompleted);
        }
        return s;
      }).toList();

      _tasks[index] = _tasks[index].copyWith(subtasks: updatedList);
      await StorageService.cacheTasks(_tasks);
    }
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updatedList = _tasks[index].subtasks.where((s) => s.id != subtaskId).toList();
      _tasks[index] = _tasks[index].copyWith(subtasks: updatedList);
      await StorageService.cacheTasks(_tasks);
    }
  }

  // Comments Operations
  List<CommentModel> getComments(String taskId) {
    return _taskComments[taskId] ?? [];
  }

  Future<void> addComment(String taskId, String content) async {
    final user = _supabase.currentUser;
    final newComment = CommentModel(
      id: _uuid.v4(),
      taskId: taskId,
      userId: user?.id ?? '',
      userName: user?.userMetadata?['full_name'] as String? ?? user?.email?.split('@').first ?? 'User',
      content: content,
    );

    final list = _taskComments[taskId] ?? [];
    list.add(newComment);
    _taskComments[taskId] = list;

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(commentsCount: list.length);
    }
  }

  // Attachments Operations
  List<AttachmentModel> getAttachments(String taskId) {
    return _taskAttachments[taskId] ?? [];
  }

  Future<void> addAttachment(String taskId, String fileName, String fileUrl, int fileSize, String fileType) async {
    final newAttachment = AttachmentModel(
      id: _uuid.v4(),
      taskId: taskId,
      userId: _supabase.currentUser?.id ?? '',
      fileName: fileName,
      fileUrl: fileUrl,
      fileSize: fileSize,
      fileType: fileType,
    );

    final list = _taskAttachments[taskId] ?? [];
    list.add(newAttachment);
    _taskAttachments[taskId] = list;

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(attachmentsCount: list.length);
    }
  }
}
