import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  final String status;
  final String priority;
  final String? projectId;
  final String? category;
  final String searchQuery;
  final String sortBy; // 'newest', 'oldest', 'priority', 'due_date'

  FilterState({
    this.status = 'all',
    this.priority = 'all',
    this.projectId,
    this.category,
    this.searchQuery = '',
    this.sortBy = 'due_date',
  });

  bool get hasActiveFilters =>
      status != 'all' ||
      priority != 'all' ||
      projectId != null ||
      category != null ||
      searchQuery.isNotEmpty;

  FilterState copyWith({
    String? status,
    String? priority,
    String? projectId,
    bool clearProject = false,
    String? category,
    bool clearCategory = false,
    String? searchQuery,
    String? sortBy,
  }) {
    return FilterState(
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: clearProject ? null : (projectId ?? this.projectId),
      category: clearCategory ? null : (category ?? this.category),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  FilterState reset() {
    return FilterState();
  }
}

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() => FilterState();

  void setStatus(String status) => state = state.copyWith(status: status);
  void setPriority(String priority) => state = state.copyWith(priority: priority);
  void setProject(String? projectId) {
    if (projectId == null) {
      state = state.copyWith(clearProject: true);
    } else {
      state = state.copyWith(projectId: projectId);
    }
  }
  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(category: category);
    }
  }
  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setSortBy(String sortBy) => state = state.copyWith(sortBy: sortBy);
  void reset() => state = state.reset();
}

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(FilterNotifier.new);
