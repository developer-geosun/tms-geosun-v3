import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/http/api_error.dart';
import '../../core/http/health_service.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/app_settings_button.dart';
import '../domain/auth_models.dart';
import '../domain/password_rules.dart';
import '../state/auth_controller.dart';
import 'auth_status_banner.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, this.token});

  final String? token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final String _token;
  late final bool _missingToken;

  bool _isLoading = false;
  bool _isResolvingAccount = false;
  bool _showSuccess = false;
  bool _passwordVisible = false;
  String? _accountEmail;
  ResetPasswordErrorCode? _errorCode;

  @override
  void initState() {
    super.initState();
    _token = widget.token?.trim() ?? '';
    _missingToken = _token.isEmpty;
    _passwordController.addListener(_revalidateConfirmPassword);
    if (!_missingToken) {
      _loadAccountEmail();
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_revalidateConfirmPassword);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _revalidateConfirmPassword() {
    if (_confirmPasswordController.text.isEmpty) {
      return;
    }
    _formKey.currentState?.validate();
  }

  Future<void> _loadAccountEmail() async {
    setState(() {
      _isResolvingAccount = true;
      _errorCode = null;
    });

    try {
      final email = await ref
          .read(authControllerProvider.notifier)
          .passwordResetInfo(token: _token);
      if (!mounted) {
        return;
      }
      setState(() {
        _accountEmail = email;
        _isResolvingAccount = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isResolvingAccount = false;
        _errorCode = mapResetPasswordErrorCode(error);
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _isResolvingAccount = false;
        _errorCode = ResetPasswordErrorCode.generic;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final backendAvailable = ref.watch(backendAvailabilityProvider);
    final serviceUnavailable = backendAvailable == false;
    final showForm =
        !_missingToken && !_isResolvingAccount && _accountEmail != null;

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
                      Icons.password_outlined,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.resetPasswordTitle,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.resetPasswordSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_accountEmail != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _accountEmail!,
                        style: theme.textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (serviceUnavailable) ...[
                      AuthStatusBanner.error(
                        message: l10n.loginServiceUnavailable,
                        icon: Icons.cloud_off_outlined,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_missingToken)
                      _ResetLinkError(
                        message: l10n.resetPasswordMissingToken,
                        actionLabel: l10n.resetPasswordRequestAgain,
                        onAction: () => context.go('/forgot-password'),
                      )
                    else if (_isResolvingAccount)
                      Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(l10n.resetPasswordResolvingAccount),
                        ],
                      )
                    else if (!showForm &&
                        _errorCode == ResetPasswordErrorCode.invalid)
                      _ResetLinkError(
                        message: l10n.resetPasswordErrorInvalid,
                        actionLabel: l10n.resetPasswordRequestAgain,
                        onAction: () => context.go('/forgot-password'),
                      )
                    else if (!showForm &&
                        _errorCode == ResetPasswordErrorCode.generic)
                      _ResetLinkError(
                        message: l10n.resetPasswordErrorGeneric,
                        actionLabel: l10n.forgotPasswordBackToLogin,
                        onAction: () => context.go('/login'),
                      )
                    else
                      _ResetPasswordForm(
                        formKey: _formKey,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        passwordVisible: _passwordVisible,
                        isLoading: _isLoading,
                        serviceUnavailable: serviceUnavailable,
                        errorCode: _errorCode,
                        showSuccess: _showSuccess,
                        onToggleVisible: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                        onSubmit: _submit,
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

  Future<void> _submit() async {
    if (_missingToken ||
        _accountEmail == null ||
        _isResolvingAccount ||
        !_formKey.currentState!.validate()) {
      return;
    }

    final password = _passwordController.text;
    if (password != _confirmPasswordController.text) {
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
          .resetPassword(token: _token, newPassword: password);

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });

      context.go('/login');
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorCode = mapResetPasswordErrorCode(error);
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorCode = ResetPasswordErrorCode.generic;
      });
    }
  }
}

class _ResetLinkError extends StatelessWidget {
  const _ResetLinkError({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthStatusBanner.error(message: message, icon: Icons.error_outline),
        const SizedBox(height: 8),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _ResetPasswordForm extends StatelessWidget {
  const _ResetPasswordForm({
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.passwordVisible,
    required this.isLoading,
    required this.serviceUnavailable,
    required this.errorCode,
    required this.showSuccess,
    required this.onToggleVisible,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool passwordVisible;
  final bool isLoading;
  final bool serviceUnavailable;
  final ResetPasswordErrorCode? errorCode;
  final bool showSuccess;
  final VoidCallback onToggleVisible;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final enabled = !serviceUnavailable && !isLoading;

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: passwordController,
            obscureText: !passwordVisible,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: l10n.resetPasswordPassword,
              suffixIcon: IconButton(
                onPressed: onToggleVisible,
                icon: Icon(
                  passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            enabled: enabled,
            validator: (value) {
              final password = value ?? '';
              if (password.isEmpty) {
                return l10n.loginPasswordRequired;
              }
              if (password.length < 8) {
                return l10n.loginPasswordMinLength;
              }
              if (!meetsPasswordPolicy(password)) {
                return l10n.registerPasswordRule;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: !passwordVisible,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onFieldSubmitted: (_) {
              if (enabled) {
                onSubmit();
              }
            },
            decoration: InputDecoration(
              labelText: l10n.registerConfirmPassword,
              suffixIcon: IconButton(
                onPressed: onToggleVisible,
                icon: Icon(
                  passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            enabled: enabled,
            validator: (value) {
              final confirm = value ?? '';
              if (confirm.isEmpty) {
                return l10n.loginPasswordRequired;
              }
              if (confirm.length < 8) {
                return l10n.loginPasswordMinLength;
              }
              if (confirm != passwordController.text) {
                return l10n.registerPasswordMismatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (errorCode != null) ...[
            AuthStatusBanner.error(
              message: switch (errorCode!) {
                ResetPasswordErrorCode.invalid =>
                  l10n.resetPasswordErrorInvalid,
                ResetPasswordErrorCode.rateLimited => l10n.registerError429,
                ResetPasswordErrorCode.generic =>
                  l10n.resetPasswordErrorGeneric,
              },
              icon: Icons.error_outline,
            ),
            const SizedBox(height: 16),
          ],
          if (showSuccess) ...[
            AuthStatusBanner.success(
              message: l10n.resetPasswordSuccess,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: enabled ? onSubmit : null,
            child: isLoading
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
                      Text(l10n.resetPasswordLoading),
                    ],
                  )
                : Text(l10n.resetPasswordSubmit),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: isLoading ? null : () => context.go('/login'),
            child: Text(l10n.forgotPasswordBackToLogin),
          ),
        ],
      ),
    );
  }
}
