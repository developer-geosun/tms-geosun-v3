import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Успіх — 5 с, помилка — 10 с; кільце таймера з кнопкою закриття всередині.
enum AppSnackKind {
  success,
  error;

  Duration get duration => switch (this) {
    AppSnackKind.success => const Duration(seconds: 5),
    AppSnackKind.error => const Duration(seconds: 10),
  };
}

/// Показати єдиний snackbar застосунку (замінює поточний).
void showAppSnack(
  BuildContext context, {
  required String message,
  required AppSnackKind kind,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final colorScheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context);
  final background = kind == AppSnackKind.error
      ? colorScheme.error
      : colorScheme.primary;
  final foreground = kind == AppSnackKind.error
      ? colorScheme.onError
      : colorScheme.onPrimary;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: kind.duration,
      backgroundColor: background,
      behavior: SnackBarBehavior.floating,
      content: AppSnackContent(
        message: message,
        duration: kind.duration,
        foreground: foreground,
        closeLabel: l10n.snackbarClose,
        onClose: messenger.hideCurrentSnackBar,
      ),
    ),
  );
}

/// Текст + кільце зворотного відліку з хрестом у центрі.
class AppSnackContent extends StatefulWidget {
  const AppSnackContent({
    super.key,
    required this.message,
    required this.duration,
    required this.foreground,
    required this.closeLabel,
    required this.onClose,
  });

  final String message;
  final Duration duration;
  final Color foreground;
  final String closeLabel;
  final VoidCallback onClose;

  static const timerSize = 34.0;

  @override
  State<AppSnackContent> createState() => _AppSnackContentState();
}

class _AppSnackContentState extends State<AppSnackContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.foreground;

    return Row(
      children: [
        Expanded(
          child: Text(widget.message, style: TextStyle(color: foreground)),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: AppSnackContent.timerSize,
          height: AppSnackContent.timerSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _progress,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: 1 - _progress.value,
                    strokeWidth: 2,
                    color: foreground.withValues(alpha: 0.75),
                    backgroundColor: foreground.withValues(alpha: 0.2),
                  );
                },
              ),
              IconButton(
                key: const Key('app-snack-close'),
                tooltip: widget.closeLabel,
                onPressed: widget.onClose,
                style: IconButton.styleFrom(
                  foregroundColor: foreground,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size.square(26),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  iconSize: 16,
                ),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
