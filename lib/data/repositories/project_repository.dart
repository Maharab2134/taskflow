import 'package:uuid/uuid.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/storage_service.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  final Uuid _uuid = const Uuid();

  // In-memory store initialized with realistic demo projects
  static final List<ProjectModel> _projects = [
    ProjectModel(
      id: 'proj-1',
      userId: 'demo-user-12345',
      name: 'Portfolio Website',
      description: 'Personal developer portfolio with modern animations & showcase',
      color: '#6366F1',
      icon: 'globe',
      status: 'active',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      deadline: DateTime.now().add(const Duration(days: 14)),
      progress: 75,
      isFavorite: true,
    ),
    ProjectModel(
      id: 'proj-2',
      userId: 'demo-user-12345',
      name: 'E-commerce App',
      description: 'Full-stack cross-platform shop application with checkout and Stripe',
      color: '#EC4899',
      icon: 'shopping_bag',
      status: 'active',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      deadline: DateTime.now().add(const Duration(days: 28)),
      progress: 45,
      isFavorite: true,
    ),
    ProjectModel(
      id: 'proj-3',
      userId: 'demo-user-12345',
      name: 'Mobile Banking App',
      description: 'Fintech UI with encrypted transfers, biometrics, and analytics',
      color: '#10B981',
      icon: 'credit_card',
      status: 'active',
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      deadline: DateTime.now().add(const Duration(days: 40)),
      progress: 20,
      isFavorite: false,
    ),
    ProjectModel(
      id: 'proj-4',
      userId: 'demo-user-12345',
      name: 'University Project',
      description: 'Distributed algorithms research paper and benchmark code',
      color: '#F59E0B',
      icon: 'book_open',
      status: 'active',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      deadline: DateTime.now().add(const Duration(days: 18)),
      progress: 60,
      isFavorite: false,
    ),
    ProjectModel(
      id: 'proj-5',
      userId: 'demo-user-12345',
      name: 'Personal Development',
      description: 'Habit tracking, morning routine, reading list and workouts',
      color: '#8B5CF6',
      icon: 'smile',
      status: 'active',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      deadline: DateTime.now().add(const Duration(days: 90)),
      progress: 30,
      isFavorite: false,
    ),
  ];

  Future<List<ProjectModel>> getProjects() async {
    final client = _supabase.client;
    if (client != null && _supabase.isConfigured) {
      try {
        final res = await client.from('projects').select().order('created_at', ascending: false);
        final list = (res as List).map((item) => ProjectModel.fromJson(item)).toList();
        await StorageService.cacheProjects(list);
        return list;
      } catch (_) {
        // Fallback to offline cache
        final cached = StorageService.getCachedProjects();
        if (cached.isNotEmpty) return cached;
        return [];
      }
    }
    if (_supabase.isConfigured) {
      return [];
    }
    return List.from(_projects);
  }

  Future<ProjectModel?> getProjectById(String id) async {
    final list = await getProjects();
    try {
      return list.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ProjectModel> createProject({
    required String name,
    required String description,
    required String color,
    required String icon,
    DateTime? startDate,
    DateTime? deadline,
  }) async {
    final newProject = ProjectModel(
      id: _uuid.v4(),
      userId: _supabase.currentUser?.id ?? '',
      name: name,
      description: description,
      color: color,
      icon: icon,
      startDate: startDate,
      deadline: deadline,
      progress: 0,
      status: 'active',
    );

    final client = _supabase.client;
    if (client != null && _supabase.isConfigured) {
      try {
        await client.from('projects').insert(newProject.toJson());
      } catch (_) {}
    }

    _projects.insert(0, newProject);
    await StorageService.cacheProjects(_projects);
    return newProject;
  }

  Future<void> updateProject(ProjectModel project) async {
    final client = _supabase.client;
    if (client != null && _supabase.isConfigured) {
      try {
        await client.from('projects').update(project.toJson()).eq('id', project.id);
      } catch (_) {}
    }

    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      await StorageService.cacheProjects(_projects);
    }
  }

  Future<void> deleteProject(String id) async {
    final client = _supabase.client;
    if (client != null && _supabase.isConfigured) {
      try {
        await client.from('projects').delete().eq('id', id);
      } catch (_) {}
    }

    _projects.removeWhere((p) => p.id == id);
    await StorageService.cacheProjects(_projects);
  }
}
