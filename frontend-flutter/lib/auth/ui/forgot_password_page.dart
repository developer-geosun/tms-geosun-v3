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

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _showSuccess = false;
  ForgotPasswordErrorCode? _errorCode;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.lock_reset_outlined,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.forgotPasswordTitle,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.forgotPasswordSubtitle,
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
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        onFieldSubmitted: (_) {
                          if (!serviceUnavailable && !_isLoading) {
                            _submit();
                          }
                        },
                        decoration: InputDecoration(labelText: l10n.loginEmail),
                        enabled: !serviceUnavailable && !_isLoading,
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return l10n.loginEmailRequired;
                          }
                          if (!trimmed.contains('@')) {
                            return l10n.loginEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_errorCode != null) ...[
                        AuthStatusBanner.error(
                          message: _errorMessage(l10n, _errorCode!),
                          icon: Icons.error_outline,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_showSuccess) ...[
                        AuthStatusBanner.success(
                          message: l10n.forgotPasswordSuccess,
                          icon: Icons.check_circle_outline,
                        ),
                        const SizedBox(height: 16),
                      ],
                      FilledButton(
                        onPressed: serviceUnavailable || _isLoading
                            ? null
                            : _submit,
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(l10n.forgotPasswordLoading),
                                ],
                              )
                            : Text(l10n.forgotPasswordSubmit),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => context.go('/login'),
                        child: Text(l10n.forgotPasswordBackToLogin),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorCode = null;
      _showSuccess = false;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .forgotPassword(email: _emailController.text);

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
        _errorCode = mapForgotPasswordErrorCode(error);
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorCode = ForgotPasswordErrorCode.generic;
      });
    }
  }

  String _errorMessage(AppLocalizations l10n, ForgotPasswordErrorCode code) {
    return switch (code) {
      ForgotPasswordErrorCode.rateLimited => l10n.registerError429,
      ForgotPasswordErrorCode.accountDisabled => l10n.loginErrorAccountDisabled,
      ForgotPasswordErrorCode.userDeleted => l10n.loginErrorUserDeleted,
      ForgotPasswordErrorCode.generic => l10n.forgotPasswordErrorGeneric,
    };
  }
}
