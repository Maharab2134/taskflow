import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import 'filter_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

class TaskState {
  final List<TaskModel> allTasks;
  final List<TaskModel> archivedTasks;
  final List<TaskModel> trashTasks;
  final bool isLoading;
  final String? errorMessage;
  final TaskModel? selectedTask;

  TaskState({
    this.allTasks = const [],
    this.archivedTasks = const [],
    this.trashTasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedTask,
  });

  TaskState copyWith({
    List<TaskModel>? allTasks,
    List<TaskModel>? archivedTasks,
    List<TaskModel>? trashTasks,
    bool? isLoading,
    String? errorMessage,
    TaskModel? selectedTask,
    bool clearSelected = false,
  }) {
    return TaskState(
      allTasks: allTasks ?? this.allTasks,
      archivedTasks: archivedTasks ?? this.archivedTasks,
      trashTasks: trashTasks ?? this.trashTasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedTask: clearSelected ? null : (selectedTask ?? this.selectedTask),
    );
  }
}

class TaskNotifier extends Notifier<TaskState> {
  late final TaskRepository _repo;

  @override
  TaskState build() {
    _repo = ref.watch(taskRepositoryProvider);
    Future.microtask(() => loadAll());
    return TaskState(isLoading: true);
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tasks = await _repo.getTasks();
      final archived = await _repo.getArchivedTasks();
      final trash = await _repo.getTrashTasks();
      state = state.copyWith(
        allTasks: tasks,
        archivedTasks: archived,
        trashTasks: trash,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectTask(TaskModel? task) {
    state = state.copyWith(selectedTask: task);
  }

  Future<void> createTask(TaskModel task) async {
    await _repo.createTask(task);
    await loadAll();
  }

  Future<void> updateTask(TaskModel task) async {
    await _repo.updateTask(task);
    if (state.selectedTask?.id == task.id) {
      state = state.copyWith(selectedTask: task);
    }
    await loadAll();
  }

  Future<void> toggleComplete(String taskId, bool isCompleted) async {
    final updatedList = state.allTasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(
          status: isCompleted ? 'completed' : 'todo',
          completedAt: isCompleted ? DateTime.now() : null,
        );
      }
      return t;
    }).toList();

    state = state.copyWith(allTasks: updatedList);
    if (state.selectedTask?.id == taskId) {
      state = state.copyWith(
        selectedTask: state.selectedTask!.copyWith(
          status: isCompleted ? 'completed' : 'todo',
          completedAt: isCompleted ? DateTime.now() : null,
        ),
      );
    }

    await _repo.toggleTaskComplete(taskId, isCompleted);
    await loadAll();
  }

  Future<void> updateStatus(String taskId, String newStatus) async {
    await _repo.updateTaskStatus(taskId, newStatus);
    await loadAll();
  }

  Future<void> archiveTask(String taskId) async {
    await _repo.archiveTask(taskId);
    await loadAll();
  }

  Future<void> moveToTrash(String taskId) async {
    await _repo.softDeleteTask(taskId);
    await loadAll();
  }

  Future<void> restoreFromTrash(String taskId) async {
    await _repo.restoreTask(taskId);
    await loadAll();
  }

  Future<void> permanentlyDelete(String taskId) async {
    await _repo.permanentlyDeleteTask(taskId);
    await loadAll();
  }

  // Subtasks
  Future<void> addSubtask(String taskId, String title) async {
    await _repo.addSubtask(taskId, title);
    final updated = await _repo.getTaskById(taskId);
    if (updated != null && state.selectedTask?.id == taskId) {
      state = state.copyWith(selectedTask: updated);
    }
    await loadAll();
  }

  Future<void> toggleSubtask(String taskId, String subtaskId, bool isCompleted) async {
    await _repo.toggleSubtask(taskId, subtaskId, isCompleted);
    final updated = await _repo.getTaskById(taskId);
    if (updated != null && state.selectedTask?.id == taskId) {
      state = state.copyWith(selectedTask: updated);
    }
    await loadAll();
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    await _repo.deleteSubtask(taskId, subtaskId);
    final updated = await _repo.getTaskById(taskId);
    if (updated != null && state.selectedTask?.id == taskId) {
      state = state.copyWith(selectedTask: updated);
    }
    await loadAll();
  }
}

final taskProvider = NotifierProvider<TaskNotifier, TaskState>(TaskNotifier.new);

// Filtered Tasks Provider combining taskProvider and filterProvider
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final taskState = ref.watch(taskProvider);
  final filter = ref.watch(filterProvider);

  var list = List<TaskModel>.from(taskState.allTasks);

  // Status Filter
  if (filter.status != 'all') {
    list = list.where((t) => t.status.toLowerCase() == filter.status.toLowerCase()).toList();
  }

  // Priority Filter
  if (filter.priority != 'all') {
    list = list.where((t) => t.priority.toLowerCase() == filter.priority.toLowerCase()).toList();
  }

  // Project Filter
  if (filter.projectId != null) {
    list = list.where((t) => t.projectId == filter.projectId).toList();
  }

  // Category Filter
  if (filter.category != null) {
    list = list.where((t) => t.category.toLowerCase() == filter.category!.toLowerCase()).toList();
  }

  // Search Query
  if (filter.searchQuery.trim().isNotEmpty) {
    final q = filter.searchQuery.toLowerCase();
    list = list.where((t) {
      final inTitle = t.title.toLowerCase().contains(q);
      final inDesc = t.description.toLowerCase().contains(q);
      final inTags = t.tags.any((tag) => tag.toLowerCase().contains(q));
      final inProject = t.projectName?.toLowerCase().contains(q) ?? false;
      return inTitle || inDesc || inTags || inProject;
    }).toList();
  }

  // Sort
  switch (filter.sortBy) {
    case 'due_date':
      list.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      break;
    case 'priority':
      final priorityWeight = {'urgent': 4, 'high': 3, 'medium': 2, 'low': 1};
      list.sort((a, b) => (priorityWeight[b.priority] ?? 0).compareTo(priorityWeight[a.priority] ?? 0));
      break;
    case 'newest':
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case 'oldest':
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
  }

  return list;
});

// Today Tasks Provider
final todayTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskProvider).allTasks;
  final now = DateTime.now();
  return tasks.where((t) {
    if (t.dueDate == null) return false;
    return t.dueDate!.year == now.year &&
        t.dueDate!.month == now.month &&
        t.dueDate!.day == now.day;
  }).toList();
});

// Upcoming Tasks Provider
final upcomingTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskProvider).allTasks;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return tasks.where((t) {
    if (t.dueDate == null) return false;
    final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
    return due.isAfter(today);
  }).toList();
});
