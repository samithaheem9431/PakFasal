import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_toggle_button.dart';
import '../providers/auth_form_provider.dart';
import '../providers/auth_session_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthFormProvider(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
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
    final err = await session.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
    form.setLoading(false);
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.t(err)),
          backgroundColor: Colors.redAccent,
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.6, 1.0],
            colors: [
              isDark ? const Color(0xFF102017) : const Color(0xFFF1FBF2),
              isDark ? const Color(0xFF162A1D) : AppTheme.lightGreen,
              isDark ? const Color(0xFF1D3325) : const Color(0xFFD8EDD9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background blobs
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: -70,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: FadeTransition(
                      opacity: _fadeHeader,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.eco_rounded,
                              color: AppTheme.primaryGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.t('login'),
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
                          const LanguageToggleButton(),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Hero illustration area
                          FadeTransition(
                            opacity: _fadeHeader,
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 18),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: scheme.surface,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryGreen
                                              .withValues(alpha: 0.20),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.agriculture_rounded,
                                      color: AppTheme.primaryGreen,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    l10n.t('welcome'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryGreen,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.t('authSubtitle'),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      color: AppTheme.primaryGreen
                                          .withValues(alpha: 0.7),
                                      height: 1.4,
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
                                        // Email field
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
                                        const SizedBox(height: 18),

                                        // Password field
                                        _FieldLabel(l10n.t('password')),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: form.obscurePassword,
                                          textInputAction:
                                          TextInputAction.done,
                                          onFieldSubmitted: (_) => _submit(
                                            context,
                                            form,
                                            session,
                                            l10n,
                                          ),
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
                                              return l10n.t('passwordMin');
                                            }
                                            return null;
                                          },
                                        ),

                                        // Forgot password
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () =>
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.forgotPassword,
                                                ),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                              AppTheme.primaryGreen,
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 4),
                                            ),
                                            child: Text(
                                              l10n.t('forgotPassword'),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        // Login button
                                        _GreenButton(
                                          isLoading: form.isLoading,
                                          label: l10n.t('login'),
                                          loadingLabel:
                                          l10n.t('authLoggingIn'),
                                          onPressed: () => _submit(
                                              context, form, session, l10n),
                                        ),

                                        const SizedBox(height: 12),

                                        // Divider
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Divider(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.3))),
                                            Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: Text(
                                                l10n.t('or'),
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: Divider(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.3))),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // Sign up button
                                        OutlinedButton(
                                          onPressed: form.isLoading
                                              ? null
                                              : () => Navigator.pushNamed(
                                            context,
                                            AppRoutes.signup,
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                            AppTheme.primaryGreen,
                                            side: BorderSide(
                                                color: AppTheme.primaryGreen
                                                    .withValues(alpha: 0.5)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(14),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                          ),
                                          child: Text(
                                            l10n.t('signup'),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
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

// ── Shared helper widgets ─────────────────────────────────────────────────────

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
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
        ),
        color: isLoading ? Colors.grey.shade300 : null,
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
        color: Colors.transparent,
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
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(loadingLabel,
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              )
                  : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
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