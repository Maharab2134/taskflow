import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/attachment_model.dart';
import '../../providers/task_provider.dart';

class TaskAttachmentsScreen extends ConsumerStatefulWidget {
  final TaskModel task;

  const TaskAttachmentsScreen({super.key, required this.task});

  @override
  ConsumerState<TaskAttachmentsScreen> createState() => _TaskAttachmentsScreenState();
}

class _TaskAttachmentsScreenState extends ConsumerState<TaskAttachmentsScreen> {
  List<AttachmentModel> _attachments = [];

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  void _loadAttachments() {
    final list = ref.read(taskRepositoryProvider).getAttachments(widget.task.id);
    setState(() => _attachments = List.from(list));
  }

  void _uploadSimulatedAttachment() async {
    // Adds a demo attachment or triggers file picker
    await ref.read(taskRepositoryProvider).addAttachment(
      widget.task.id,
      'Product_Specification_v1.pdf',
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      2450000,
      'pdf',
    );
    _loadAttachments();
    if (mounted) {
      AppToast.showSuccess(context, 'File uploaded to Supabase Storage');
    }
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return LucideIcons.image;
      case 'pdf':
        return LucideIcons.fileText;
      case 'video':
        return LucideIcons.video;
      default:
        return LucideIcons.file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attachments'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _attachments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.paperclip, size: 40, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(height: 12),
                        Text('No attachments yet', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Upload images, PDFs, or design assets for this task.', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.spacing16),
                    itemCount: _attachments.length,
                    itemBuilder: (context, index) {
                      final item = _attachments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Icon(
                                    _getFileIcon(item.fileType),
                                    size: 22,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.fileName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.formattedSize} • ${item.fileType.toUpperCase()}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.downloadCloud, size: 18),
                                onPressed: () {
                                  AppToast.showInfo(context, 'Downloading ${item.fileName}...');
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Upload Attachment (Supabase Storage)',
                onPressed: _uploadSimulatedAttachment,
                icon: LucideIcons.uploadCloud,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
