import 'package:flutter/material.dart';

/// Банер помилки / успіху на auth-екранах (login, register).
class AuthStatusBanner extends StatelessWidget {
  const AuthStatusBanner.error({
    required this.message,
    required this.icon,
    super.key,
  }) : _isError = true;

  const AuthStatusBanner.success({
    required this.message,
    required this.icon,
    super.key,
  }) : _isError = false;

  final String message;
  final IconData icon;
  final bool _isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = _isError
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.primaryContainer;
    final foreground = _isError
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onPrimaryContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: TextStyle(color: foreground)),
            ),
          ],
        ),
      ),
    );
  }
}
