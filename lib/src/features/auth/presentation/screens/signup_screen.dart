import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_form_provider.dart';
import '../providers/auth_session_controller.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthFormProvider(),
      child: const _SignupView(),
    );
  }
}

class _SignupView extends StatefulWidget {
  const _SignupView();

  @override
  State<_SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<_SignupView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();

  late final AnimationController _entryController;
  late final Animation<double> _fadeHeader;
  late final Animation<double> _fadeCard;
  late final Animation<Offset> _slideCard;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeHeader = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _fadeCard = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
    );
    _slideCard = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
    ));
    _entryController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _submit(
      BuildContext context,
      AuthFormProvider form,
      AuthSessionController session,
      AppLocalizations l10n,
      ) async {
    if (!_formKey.currentState!.validate()) return;
    form.setLoading(true);
    final err = await session.registerWithEmail(
      username: _usernameController.text.trim(),
      email: _emailController.text,
      password: _passwordController.text,
    );
    form.setLoading(false);
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.t(err)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final form = context.watch<AuthFormProvider>();
    final session = context.watch<AuthSessionController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [
              isDark ? AppColors.darkSurface : AppColors.softSurfaceGreen,
              isDark ? AppColors.darkSurfaceMid : AppColors.paleGreen,
              isDark ? AppColors.darkSurfaceHigh : AppColors.divider,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: FadeTransition(
                      opacity: _fadeHeader,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              l10n.t('signup'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryGreen,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          FadeTransition(
                            opacity: _fadeHeader,
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: scheme.surface,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryGreen
                                              .withValues(alpha: 0.18),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: AppTheme.primaryGreen,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.t('welcome'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        ),
                                        Text(
                                          l10n.t('authSubtitle'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                            color: AppTheme.primaryGreen
                                                .withValues(alpha: 0.65),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Form card
                          SlideTransition(
                            position: _slideCard,
                            child: FadeTransition(
                              opacity: _fadeCard,
                              child: Card(
                                elevation: 0,
                                color: scheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: BorderSide(
                                    color: AppTheme.primaryGreen
                                        .withValues(alpha: 0.14),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                      children: [
                                        _FieldLabel(l10n.t('username')),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _usernameController,
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            hintText: l10n.t('usernameHint'),
                                            prefixIcon: const Icon(
                                              Icons.person_outline_rounded,
                                            ),
                                          ),
                                          validator: (value) {
                                            final username = value?.trim() ?? '';
                                            if (username.isEmpty) {
                                              return l10n.t('usernameRequired');
                                            }
                                            if (username.length < 3) {
                                              return l10n.t('usernameMinLength');
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        _FieldLabel(l10n.t('email')),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                          TextInputType.emailAddress,
                                          textInputAction:
                                          TextInputAction.next,
                                          decoration: InputDecoration(
                                            hintText: l10n.t('emailHint'),
                                            prefixIcon: const Icon(
                                                Icons.email_outlined),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return l10n.t('emailRequired');
                                            }
                                            if (!value.contains('@')) {
                                              return l10n.t('invalidEmail');
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        _FieldLabel(l10n.t('password')),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: form.obscurePassword,
                                          textInputAction:
                                          TextInputAction.next,
                                          decoration: InputDecoration(
                                            hintText: l10n.t('passwordHint'),
                                            prefixIcon: const Icon(
                                                Icons.lock_outline_rounded),
                                            suffixIcon: IconButton(
                                              onPressed:
                                              form.togglePasswordVisibility,
                                              icon: Icon(
                                                form.obscurePassword
                                                    ? Icons
                                                    .visibility_off_outlined
                                                    : Icons
                                                    .visibility_outlined,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.length < 6) {
                                              return l10n
                                                  .t('weakPasswordForm');
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        _FieldLabel(
                                            l10n.t('confirmPassword')),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _confirmController,
                                          obscureText: form.obscurePassword,
                                          textInputAction:
                                          TextInputAction.next,
                                          decoration: InputDecoration(
                                            hintText: l10n.t('passwordHint'),
                                            prefixIcon: const Icon(
                                                Icons.verified_user_outlined),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return l10n.t('confirmPasswordRequired');
                                            }
                                            if (value != _passwordController.text) {
                                              return l10n
                                                  .t('passwordsMismatch');
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        _FieldLabel(l10n.t('phone')),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          textInputAction:
                                          TextInputAction.done,
                                          decoration: InputDecoration(
                                            hintText: l10n.t('phoneHint'),
                                            prefixIcon: const Icon(
                                                Icons.phone_android_rounded),
                                          ),
                                          validator: (value) {
                                            final phone = value?.trim() ?? '';
                                            if (phone.isEmpty) return null;
                                            final digitsOnly =
                                                phone.replaceAll(RegExp(r'\D'), '');
                                            if (digitsOnly.length < 10 ||
                                                digitsOnly.length > 15) {
                                              return l10n.t('invalidPhone');
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 24),

                                        _GreenButton(
                                          isLoading: form.isLoading,
                                          label: l10n.t('signup'),
                                          loadingLabel:
                                          l10n.t('authCreatingAccount'),
                                          onPressed: () => _submit(
                                              context, form, session, l10n),
                                        ),

                                        const SizedBox(height: 16),

                                        // Already have account
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              l10n.t('alreadyHaveAccount'),
                                              style: TextStyle(
                                                  color: AppColors.mutedTextDark,
                                                  fontSize: 13),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                AppTheme.primaryGreen,
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6),
                                              ),
                                              child: Text(
                                                l10n.t('login'),
                                                style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight.w700,
                                                    fontSize: 13),
                                              ),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers (copy from login_screen.dart or extract to shared file) ────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
      letterSpacing: 0.2,
    ),
  );
}

class _GreenButton extends StatelessWidget {
  const _GreenButton({
    required this.isLoading,
    required this.label,
    required this.loadingLabel,
    required this.onPressed,
  });

  final bool isLoading;
  final String label;
  final String loadingLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isLoading
            ? null
            : const LinearGradient(
          colors: [AppColors.lightGreen, AppColors.primaryGreen],
        ),
        color: isLoading ? AppColors.lightGrey : null,
        boxShadow: isLoading
            ? []
            : [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: isLoading
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.mutedTextDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(loadingLabel,
                      style: const TextStyle(color: AppColors.mutedTextDark)),
                ],
              )
                  : Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}