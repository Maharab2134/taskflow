import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

class ProjectState {
  final List<ProjectModel> projects;
  final bool isLoading;
  final String? errorMessage;
  final ProjectModel? selectedProject;

  ProjectState({
    this.projects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedProject,
  });

  ProjectState copyWith({
    List<ProjectModel>? projects,
    bool? isLoading,
    String? errorMessage,
    ProjectModel? selectedProject,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedProject: selectedProject ?? this.selectedProject,
    );
  }
}

class ProjectNotifier extends Notifier<ProjectState> {
  late final ProjectRepository _repo;

  @override
  ProjectState build() {
    _repo = ref.watch(projectRepositoryProvider);
    // Trigger initial load
    Future.microtask(() => loadProjects());
    return ProjectState(isLoading: true);
  }

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getProjects();
      state = state.copyWith(projects: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectProject(ProjectModel? project) {
    state = state.copyWith(selectedProject: project);
  }

  Future<ProjectModel> addProject({
    required String name,
    required String description,
    required String color,
    required String icon,
    DateTime? startDate,
    DateTime? deadline,
  }) async {
    final created = await _repo.createProject(
      name: name,
      description: description,
      color: color,
      icon: icon,
      startDate: startDate,
      deadline: deadline,
    );
    await loadProjects();
    return created;
  }

  Future<void> updateProject(ProjectModel project) async {
    await _repo.updateProject(project);
    await loadProjects();
  }

  Future<void> deleteProject(String id) async {
    await _repo.deleteProject(id);
    await loadProjects();
  }
}

final projectProvider = NotifierProvider<ProjectNotifier, ProjectState>(ProjectNotifier.new);
