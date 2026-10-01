import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TaskFlowLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;
  final TextStyle? textStyle;

  const TaskFlowLogo({
    super.key,
    this.size = 36.0,
    this.showText = true,
    this.color,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = color ?? theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Image.asset(
            'assets/images/taskflow_logo.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      AppColors.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(size * 0.28),
                ),
                child: Center(
                  child: CustomPaint(
                    size: Size(size * 0.55, size * 0.55),
                    painter: _LogoGlyphPainter(),
                  ),
                ),
              );
            },
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.3),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Task',
                  style: textStyle ??
                      theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                ),
                TextSpan(
                  text: 'Flow',
                  style: textStyle?.copyWith(color: primaryColor) ??
                      theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: primaryColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.52);
    path.lineTo(size.width * 0.42, size.height * 0.75);
    path.lineTo(size.width * 0.85, size.height * 0.28);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
