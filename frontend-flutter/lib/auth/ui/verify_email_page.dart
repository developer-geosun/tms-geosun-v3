import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/http/api_error.dart';
import '../../core/http/health_service.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/app_settings_button.dart';
import '../domain/auth_models.dart';
import '../state/auth_controller.dart';
import 'auth_status_banner.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key, this.token});

  final String? token;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  late final String _token;
  late final bool _missingToken;

  bool _isLoading = false;
  bool _showSuccess = false;
  VerifyEmailErrorCode? _errorCode;

  @override
  void initState() {
    super.initState();
    _token = widget.token?.trim() ?? '';
    _missingToken = _token.isEmpty;
    if (!_missingToken) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verify();
      });
    }
  }

  Future<void> _verify() async {
    setState(() {
      _isLoading = true;
      _errorCode = null;
      _showSuccess = false;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .verifyEmail(token: _token);
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorCode = mapVerifyEmailErrorCode(error);
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorCode = VerifyEmailErrorCode.generic;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final backendAvailable = ref.watch(backendAvailabilityProvider);
    final serviceUnavailable = backendAvailable == false;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const [AppSettingsButton()],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.verifyEmailTitle,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.verifyEmailSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (serviceUnavailable) ...[
                      AuthStatusBanner.error(
                        message: l10n.loginServiceUnavailable,
                        icon: Icons.cloud_off_outlined,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_missingToken)
                      AuthStatusBanner.error(
                        message: l10n.verifyEmailInvalid,
                        icon: Icons.error_outline,
                      )
                    else if (_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.verifyEmailLoading),
                        ],
                      )
                    else if (_showSuccess)
                      AuthStatusBanner.success(
                        message: l10n.verifyEmailSuccess,
                        icon: Icons.check_circle_outline,
                      )
                    else if (_errorCode != null)
                      AuthStatusBanner.error(
                        message: _errorMessage(l10n, _errorCode!),
                        icon: Icons.error_outline,
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go('/login'),
                      child: Text(l10n.verifyEmailToLogin),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, VerifyEmailErrorCode code) {
    return switch (code) {
      VerifyEmailErrorCode.invalid => l10n.verifyEmailInvalid,
      VerifyEmailErrorCode.generic => l10n.verifyEmailError,
    };
  }
}
