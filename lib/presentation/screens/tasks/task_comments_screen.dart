import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/comment_model.dart';
import '../../providers/task_provider.dart';

class TaskCommentsScreen extends ConsumerStatefulWidget {
  final TaskModel task;

  const TaskCommentsScreen({super.key, required this.task});

  @override
  ConsumerState<TaskCommentsScreen> createState() => _TaskCommentsScreenState();
}

class _TaskCommentsScreenState extends ConsumerState<TaskCommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    final list = ref.read(taskRepositoryProvider).getComments(widget.task.id);
    setState(() => _comments = List.from(list));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() async {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      await ref.read(taskRepositoryProvider).addComment(widget.task.id, text);
      _commentController.clear();
      _loadComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Comments'),
            Text(
              widget.task.title,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.messageSquare, size: 40, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(height: 12),
                        Text('No comments yet', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Start the conversation or mention teammates with @', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.spacing16),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.18),
                              child: Text(
                                comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          DateFormatter.formatTime(comment.createdAt),
                                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      comment.content,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Chat Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(top: BorderSide(color: theme.colorScheme.outline)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment... use @ to mention',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _postComment,
                    icon: const Icon(LucideIcons.send, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
