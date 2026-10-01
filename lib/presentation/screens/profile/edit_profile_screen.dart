import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../data/models/profile_model.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _bioController;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;

  static const List<String> _avatarPresets = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=300',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=300',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _jobTitleController = TextEditingController(text: widget.profile.jobTitle);
    _bioController = TextEditingController(text: widget.profile.bio);
    _avatarUrl = widget.profile.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingAvatar = true);

      final bytes = await picked.readAsBytes();
      final ext = picked.path.split('.').last.toLowerCase();

      // 1. Try uploading to Supabase Storage
      final uploadedUrl = await ref.read(profileProvider.notifier).uploadAvatar(
            bytes: bytes,
            fileExtension: ext.isNotEmpty ? ext : 'jpg',
          );

      String finalUrl;
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        finalUrl = uploadedUrl;
      } else {
        // Fallback to base64 Data URI so it works offline and without storage buckets
        final base64Image = base64Encode(bytes);
        final mime = ext == 'png' ? 'png' : 'jpeg';
        finalUrl = 'data:image/$mime;base64,$base64Image';
      }

      setState(() {
        _avatarUrl = finalUrl;
        _isUploadingAvatar = false;
      });

      if (mounted) {
        AppToast.showSuccess(
          context,
          uploadedUrl != null
              ? 'Profile picture uploaded to cloud storage!'
              : 'Profile picture saved successfully!',
        );
      }
    } catch (e) {
      setState(() => _isUploadingAvatar = false);
      if (mounted) {
        AppToast.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  void _showAvatarOptionsSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Change Profile Photo',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // 1. Take Photo (Camera)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.camera, color: theme.colorScheme.primary, size: 20),
                ),
                title: const Text('Take Photo with Camera'),
                subtitle: const Text('Snap a new picture right now'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),

              // 2. Choose from Gallery
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.image, color: Colors.teal, size: 20),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Pick an image from your photos'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),

              // 3. Choose from Curated Presets
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.sparkles, color: Colors.purple, size: 20),
                ),
                title: const Text('Choose from Presets'),
                subtitle: const Text('Select a stylish ready-made avatar'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showPresetsDialog();
                },
              ),

              // 4. Remove photo if present
              if (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                  ),
                  title: const Text('Remove Current Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    setState(() => _avatarUrl = null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showPresetsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Choose Avatar Preset'),
          content: SizedBox(
            width: 320,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _avatarPresets.length,
              itemBuilder: (context, index) {
                final url = _avatarPresets[index];
                return GestureDetector(
                  onTap: () {
                    setState(() => _avatarUrl = url);
                    Navigator.pop(dialogContext);
                  },
                  child: AppAvatar(
                    name: 'Preset',
                    avatarUrl: url,
                    radius: 28,
                    showBorder: _avatarUrl == url,
                    borderColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(profileProvider.notifier).updateProfile(
            fullName: _nameController.text.trim(),
            jobTitle: _jobTitleController.text.trim(),
            bio: _bioController.text.trim(),
            avatarUrl: _avatarUrl,
          );
      if (mounted) {
        AppToast.showSuccess(context, 'Profile updated successfully!');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppAvatar(
                      name: _nameController.text.isNotEmpty ? _nameController.text : 'User',
                      avatarUrl: _avatarUrl,
                      radius: 52,
                      isLoading: _isUploadingAvatar,
                      onTap: _showAvatarOptionsSheet,
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: GestureDetector(
                        onTap: _showAvatarOptionsSheet,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.camera, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _showAvatarOptionsSheet,
                icon: const Icon(LucideIcons.imagePlus, size: 16),
                label: const Text('Change Photo'),
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Full Name *',
                hint: 'Your name',
                controller: _nameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Job Title',
                hint: 'e.g. Lead Designer',
                controller: _jobTitleController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Bio',
                hint: 'Tell your team about yourself...',
                controller: _bioController,
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Save Changes',
                  onPressed: _save,
                  icon: LucideIcons.save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
