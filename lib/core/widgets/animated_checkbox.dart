import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';

class AnimatedCheckbox extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final double size;

  const AnimatedCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.activeColor,
    this.size = 22.0,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isChecked) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isChecked != widget.isChecked) {
      if (widget.isChecked) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onChanged(!widget.isChecked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = widget.activeColor ?? AppColors.completed;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.isChecked ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(widget.size * 0.3),
              border: Border.all(
                color: widget.isChecked ? primary : theme.colorScheme.outline.withOpacity(0.8),
                width: 1.8,
              ),
            ),
            child: widget.isChecked
                ? const Center(
                    child: Icon(
                      LucideIcons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
