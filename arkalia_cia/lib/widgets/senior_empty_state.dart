import 'package:flutter/material.dart';

/// Empty state senior : colorScheme, textes ≥ 14sp, copy vouvoyée côté appelant.
class SeniorEmptyState extends StatelessWidget {
  const SeniorEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.useErrorAccent = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool useErrorAccent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onVariant = scheme.onSurfaceVariant;
    final accent = useErrorAccent ? scheme.error : scheme.primary;
    final container =
        useErrorAccent ? scheme.errorContainer : scheme.primaryContainer;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: container.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: accent),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: onVariant, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
