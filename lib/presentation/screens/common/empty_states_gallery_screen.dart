import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/widgets/empty_state_view.dart';

class EmptyStatesGalleryScreen extends StatefulWidget {
  const EmptyStatesGalleryScreen({super.key});

  @override
  State<EmptyStatesGalleryScreen> createState() => _EmptyStatesGalleryScreenState();
}

class _EmptyStatesGalleryScreenState extends State<EmptyStatesGalleryScreen> {
  int _selectedIdx = 0;

  final List<String> _types = [
    'No Tasks',
    'No Projects',
    'No Notifications',
    'Search Empty',
    'Archive Empty',
    'Trash Empty',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empty States Gallery'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_types.length, (idx) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_types[idx]),
                      selected: _selectedIdx == idx,
                      onSelected: (_) => setState(() => _selectedIdx = idx),
                    ),
                  );
                }),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Center(
              child: _buildSelectedEmptyState(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedEmptyState() {
    switch (_selectedIdx) {
      case 0:
        return EmptyStateView.tasks(onAddTask: () {});
      case 1:
        return EmptyStateView.projects(onAddProject: () {});
      case 2:
        return EmptyStateView.notifications();
      case 3:
        return EmptyStateView.search();
      case 4:
        return EmptyStateView.archive();
      case 5:
        return EmptyStateView.trash();
      default:
        return EmptyStateView.tasks();
    }
  }
}
