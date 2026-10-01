import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/sync_service.dart';
import '../constants/app_colors.dart';

class OfflineIndicator extends StatelessWidget {
  final SyncStatus status;
  final VoidCallback? onTap;

  const OfflineIndicator({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status) {
      case SyncStatus.offline:
        bg = AppColors.error.withOpacity(0.12);
        fg = AppColors.error;
        icon = LucideIcons.wifiOff;
        label = 'Offline Mode';
        break;
      case SyncStatus.syncing:
        bg = AppColors.inProgress.withOpacity(0.12);
        fg = AppColors.inProgress;
        icon = LucideIcons.refreshCw;
        label = 'Syncing...';
        break;
      case SyncStatus.synced:
        bg = AppColors.completed.withOpacity(0.12);
        fg = AppColors.completed;
        icon = LucideIcons.checkCheck;
        label = 'Synced';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: fg.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == SyncStatus.syncing)
              _RotatingIcon(icon: icon, color: fg)
            else
              Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RotatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _RotatingIcon({required this.icon, required this.color});

  @override
  State<_RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<_RotatingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _anim,
      child: Icon(widget.icon, size: 13, color: widget.color),
    );
  }
}
