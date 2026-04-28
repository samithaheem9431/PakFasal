import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_form_provider.dart';
import '../providers/auth_session_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _entryController;
  late final Animation<double> _fadeAll;
  late final Animation<Offset> _slideAll;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAll = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAll = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));
    _entryController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
    final err =
    await session.sendPasswordResetEmail(_emailController.text);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.t('resetEmailSent')),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => AuthFormProvider(),
      child: Consumer2<AuthFormProvider, AuthSessionController>(
        builder: (context, form, session, _) {
          return Scaffold(
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    isDark ? const Color(0xFF102017) : const Color(0xFFF1FBF2),
                    isDark ? const Color(0xFF162A1D) : AppTheme.lightGreen,
                    isDark ? const Color(0xFF1D3325) : const Color(0xFFD8EDD9),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative blobs
                  Positioned(
                    top: -60,
                    right: -40,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                        AppTheme.primaryGreen.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -60,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                        AppTheme.primaryGreen.withValues(alpha: 0.05),
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
                            opacity: _fadeAll,
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
                                    l10n.t('resetPassword'),
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
                            padding:
                            const EdgeInsets.fromLTRB(22, 16, 22, 28),
                            child: SlideTransition(
                              position: _slideAll,
                              child: FadeTransition(
                                opacity: _fadeAll,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    // Illustration
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 24),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: scheme.surface,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.primaryGreen
                                                      .withValues(alpha: 0.20),
                                                  blurRadius: 24,
                                                  offset:
                                                  const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.lock_reset_rounded,
                                              color: AppTheme.primaryGreen,
                                              size: 44,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          Text(
                                            l10n.t('resetPassword'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color:
                                              AppTheme.primaryGreen,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text(
                                              l10n.t('resetPasswordHint'),
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                color: AppTheme
                                                    .primaryGreen
                                                    .withValues(
                                                    alpha: 0.65),
                                                height: 1.45,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Form card
                                    Card(
                                      elevation: 0,
                                      color: scheme.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(24),
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
                                              _FieldLabel(l10n.t('email')),
                                              const SizedBox(height: 6),
                                              TextFormField(
                                                controller:
                                                _emailController,
                                                keyboardType: TextInputType
                                                    .emailAddress,
                                                textInputAction:
                                                TextInputAction.done,
                                                onFieldSubmitted: (_) =>
                                                    _submit(context, form,
                                                        session, l10n),
                                                decoration: InputDecoration(
                                                  hintText: l10n.t('emailHint'),
                                                  prefixIcon: const Icon(
                                                      Icons.email_outlined),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return l10n
                                                        .t('emailRequired');
                                                  }
                                                  if (!value.contains('@')) {
                                                    return l10n
                                                        .t('invalidEmail');
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 24),
                                              _GreenButton(
                                                isLoading: form.isLoading,
                                                label:
                                                l10n.t('resetPassword'),
                                                loadingLabel:
                                                l10n.t('sending'),
                                                onPressed: () => _submit(
                                                    context,
                                                    form,
                                                    session,
                                                    l10n),
                                              ),
                                              const SizedBox(height: 16),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                  Colors.grey.shade600,
                                                ),
                                                child: Text(
                                                  l10n.t('backToLogin'),
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
        },
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

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
                      style:
                      TextStyle(color: Colors.grey.shade600)),
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