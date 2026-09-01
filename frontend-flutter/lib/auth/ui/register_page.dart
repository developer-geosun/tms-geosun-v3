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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showSuccess = false;
  bool _passwordVisible = false;
  RegisterErrorCode? _errorCode;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_revalidateConfirmPassword);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_revalidateConfirmPassword);
    _emailController.dispose();
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
                        Icons.person_add_outlined,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.registerTitle,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.registerSubtitle,
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
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                              decoration: InputDecoration(
                                labelText: l10n.loginPassword,
                                suffixIcon: IconButton(
                                  onPressed: _togglePasswordVisible,
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              enabled: !serviceUnavailable && !_isLoading,
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
                              controller: _confirmPasswordController,
                              obscureText: !_passwordVisible,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              onFieldSubmitted: (_) {
                                if (!serviceUnavailable && !_isLoading) {
                                  _submit();
                                }
                              },
                              decoration: InputDecoration(
                                labelText: l10n.registerConfirmPassword,
                                suffixIcon: IconButton(
                                  onPressed: _togglePasswordVisible,
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              enabled: !serviceUnavailable && !_isLoading,
                              validator: (value) {
                                final confirm = value ?? '';
                                if (confirm.isEmpty) {
                                  return l10n.loginPasswordRequired;
                                }
                                if (confirm.length < 8) {
                                  return l10n.loginPasswordMinLength;
                                }
                                if (confirm != _passwordController.text) {
                                  return l10n.registerPasswordMismatch;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
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
                          message: l10n.registerSuccess,
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
                                  Text(l10n.registerLoading),
                                ],
                              )
                            : Text(l10n.registerSubmit),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(l10n.registerHaveAccount),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.go('/login'),
                            child: Text(l10n.authLogin),
                          ),
                        ],
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

  void _togglePasswordVisible() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
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
          .register(email: _emailController.text, password: password);

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
        _errorCode = mapRegisterErrorCode(error);
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorCode = RegisterErrorCode.generic;
      });
    }
  }

  String _errorMessage(AppLocalizations l10n, RegisterErrorCode code) {
    return switch (code) {
      RegisterErrorCode.conflict => l10n.registerError409,
      RegisterErrorCode.rateLimited => l10n.registerError429,
      RegisterErrorCode.generic => l10n.registerErrorGeneric,
    };
  }
}
