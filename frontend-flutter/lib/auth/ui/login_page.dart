import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/http/api_error.dart';
import '../../core/http/health_service.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/app_settings_button.dart';
import '../domain/auth_models.dart';
import '../state/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.returnUrl});

  final String? returnUrl;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showSuccess = false;
  bool _passwordVisible = false;
  LoginErrorCode? _errorCode;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                        Icons.lock_outline,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.loginTitle,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (serviceUnavailable) ...[
                        _StatusBanner.error(
                          message: l10n.loginServiceUnavailable,
                          icon: Icons.cloud_off_outlined,
                        ),
                        const SizedBox(height: 16),
                      ],
                      AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                              decoration: InputDecoration(
                                labelText: l10n.loginEmail,
                              ),
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
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) {
                                if (!serviceUnavailable && !_isLoading) {
                                  _submit();
                                }
                              },
                              decoration: InputDecoration(
                                labelText: l10n.loginPassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              enabled: !serviceUnavailable && !_isLoading,
                              validator: (value) {
                                final trimmed = value ?? '';
                                if (trimmed.isEmpty) {
                                  return l10n.loginPasswordRequired;
                                }
                                if (trimmed.length < 8) {
                                  return l10n.loginPasswordMinLength;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_errorCode != null) ...[
                        _StatusBanner.error(
                          message: _errorMessage(l10n, _errorCode!),
                          icon: Icons.error_outline,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_showSuccess) ...[
                        _StatusBanner.success(
                          message: l10n.loginSuccess,
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
                                  Text(l10n.loginLoading),
                                ],
                              )
                            : Text(l10n.loginSubmit),
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
          .login(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });

      TextInput.finishAutofillContext(shouldSave: true);

      final target = widget.returnUrl ?? '/home';
      context.go(target);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorCode = mapLoginErrorCode(error);
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorCode = LoginErrorCode.generic;
      });
    }
  }

  String _errorMessage(AppLocalizations l10n, LoginErrorCode code) {
    return switch (code) {
      LoginErrorCode.error401 => l10n.loginError401,
      LoginErrorCode.error403 => l10n.loginError403,
      LoginErrorCode.accountDisabled => l10n.loginErrorAccountDisabled,
      LoginErrorCode.userDeleted => l10n.loginErrorUserDeleted,
      LoginErrorCode.emailNotVerified => l10n.loginErrorEmailNotVerified,
      LoginErrorCode.generic => l10n.loginErrorGeneric,
    };
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner.error({required this.message, required this.icon})
    : _isError = true,
      super(key: null);

  const _StatusBanner.success({required this.message, required this.icon})
    : _isError = false,
      super(key: null);

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
