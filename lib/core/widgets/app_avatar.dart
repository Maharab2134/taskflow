import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final bool isLoading;
  final Widget? badge;

  const AppAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 24,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.isLoading = false,
    this.badge,
  });

  String get _initials {
    final clean = name.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean[0].toUpperCase();
  }

  ImageProvider? _resolveImageProvider(String url) {
    if (url.isEmpty) return null;

    if (url.startsWith('data:image')) {
      try {
        final commaIndex = url.indexOf(',');
        if (commaIndex != -1) {
          final base64String = url.substring(commaIndex + 1);
          return MemoryImage(base64Decode(base64String));
        }
      } catch (_) {
        return null;
      }
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }

    if (!kIsWeb && (url.startsWith('/') || url.contains(':\\'))) {
      final file = File(url);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageProvider = avatarUrl != null ? _resolveImageProvider(avatarUrl!) : null;

    Widget avatarContent = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
      backgroundImage: imageProvider,
      onBackgroundImageError: imageProvider != null
          ? (exception, stackTrace) {
              debugPrint('Error loading avatar: $exception');
            }
          : null,
      child: imageProvider == null
          ? Text(
              _initials,
              style: TextStyle(
                fontSize: radius * 0.72,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            )
          : null,
    );

    if (isLoading) {
      avatarContent = Stack(
        alignment: Alignment.center,
        children: [
          avatarContent,
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.4),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (showBorder) {
      avatarContent = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? theme.colorScheme.primary,
            width: 2,
          ),
        ),
        child: avatarContent,
      );
    }

    if (badge != null) {
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            right: 0,
            bottom: 0,
            child: badge!,
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarContent,
      );
    }

    return avatarContent;
  }
}
