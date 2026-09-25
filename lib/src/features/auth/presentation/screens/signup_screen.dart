import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_form_provider.dart';
import '../providers/auth_session_controller.dart';
import '../widgets/auth_shared_widgets.dart';

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

    return Scaffold(
      backgroundColor: AuthBackground.fillColor,
      resizeToAvoidBottomInset: false,
      body: AuthBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: AuthFitViewport(
              builder: (context, m) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    m.pagePadH,
                    m.gapSm,
                    m.pagePadH,
                    m.gapMd,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeTransition(
                        opacity: _fadeHeader,
                        child: AuthTopBar(
                          title: l10n.t('signup'),
                          metrics: m,
                          showBack: true,
                          centerTitle: true,
                        ),
                      ),
                      SizedBox(height: m.gapSm),
                      FadeTransition(
                        opacity: _fadeHeader,
                        child: AuthHeroHeader(
                          heroAsset: 'assets/images/auth/signup_hero.png',
                          title: l10n.t('welcome'),
                          subtitle: l10n.t('createAccountSubtitle'),
                          metrics: m,
                        ),
                      ),
                      SizedBox(height: m.gapMd),
                      SlideTransition(
                        position: _slideCard,
                        child: FadeTransition(
                          opacity: _fadeCard,
                          child: AuthFormCard(
                            metrics: m,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AuthFieldLabel(
                                    l10n.t('username'),
                                    metrics: m,
                                  ),
                                  SizedBox(height: m.gapXs + 1),
                                  TextFormField(
                                    controller: _usernameController,
                                    textInputAction: TextInputAction.next,
                                    style: TextStyle(
                                      fontSize: m.fieldFontSize,
                                    ),
                                    scrollPadding:
                                        const EdgeInsets.only(bottom: 72),
                                    decoration: authInputDecoration(
                                      hintText: l10n.t('usernameHint'),
                                      prefixIcon:
                                          Icons.person_outline_rounded,
                                      metrics: m,
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
                                  SizedBox(height: m.gapSm + 2),
                                  AuthFieldLabel(l10n.t('email'), metrics: m),
                                  SizedBox(height: m.gapXs + 1),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    style: TextStyle(
                                      fontSize: m.fieldFontSize,
                                    ),
                                    scrollPadding:
                                        const EdgeInsets.only(bottom: 72),
                                    decoration: authInputDecoration(
                                      hintText: l10n.t('emailHint'),
                                      prefixIcon: Icons.email_outlined,
                                      metrics: m,
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
                                  SizedBox(height: m.gapSm + 2),
                                  AuthFieldLabel(
                                    l10n.t('password'),
                                    metrics: m,
                                  ),
                                  SizedBox(height: m.gapXs + 1),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: form.obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    style: TextStyle(
                                      fontSize: m.fieldFontSize,
                                    ),
                                    scrollPadding:
                                        const EdgeInsets.only(bottom: 72),
                                    decoration: authInputDecoration(
                                      hintText: l10n.t('passwordHint'),
                                      prefixIcon: Icons.lock_outline_rounded,
                                      metrics: m,
                                      suffixIcon: IconButton(
                                        onPressed:
                                            form.togglePasswordVisibility,
                                        icon: Icon(
                                          form.obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AuthDesign.mutedLabel,
                                          size: m.iconSize,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length < 6) {
                                        return l10n.t('weakPasswordForm');
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: m.gapSm + 2),
                                  AuthFieldLabel(
                                    l10n.t('confirmPassword'),
                                    metrics: m,
                                  ),
                                  SizedBox(height: m.gapXs + 1),
                                  TextFormField(
                                    controller: _confirmController,
                                    obscureText: form.obscureConfirmPassword,
                                    textInputAction: TextInputAction.next,
                                    style: TextStyle(
                                      fontSize: m.fieldFontSize,
                                    ),
                                    scrollPadding:
                                        const EdgeInsets.only(bottom: 72),
                                    decoration: authInputDecoration(
                                      hintText: l10n.t('passwordHint'),
                                      prefixIcon:
                                          Icons.verified_user_outlined,
                                      metrics: m,
                                      suffixIcon: IconButton(
                                        onPressed: form
                                            .toggleConfirmPasswordVisibility,
                                        icon: Icon(
                                          form.obscureConfirmPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AuthDesign.mutedLabel,
                                          size: m.iconSize,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.t(
                                          'confirmPasswordRequired',
                                        );
                                      }
                                      if (value != _passwordController.text) {
                                        return l10n.t('passwordsMismatch');
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: m.gapSm + 2),
                                  AuthFieldLabel(l10n.t('phone'), metrics: m),
                                  SizedBox(height: m.gapXs + 1),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    style: TextStyle(
                                      fontSize: m.fieldFontSize,
                                    ),
                                    scrollPadding:
                                        const EdgeInsets.only(bottom: 72),
                                    decoration: authInputDecoration(
                                      hintText: l10n.t('phoneHint'),
                                      prefixIcon: Icons.smartphone_rounded,
                                      metrics: m,
                                    ),
                                    validator: (value) {
                                      final phone = value?.trim() ?? '';
                                      if (phone.isEmpty) return null;
                                      final digitsOnly = phone.replaceAll(
                                        RegExp(r'\D'),
                                        '',
                                      );
                                      if (digitsOnly.length < 10 ||
                                          digitsOnly.length > 15) {
                                        return l10n.t('invalidPhone');
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: m.gapLg),
                                  AuthGradientButton(
                                    metrics: m,
                                    isLoading: form.isLoading,
                                    label: l10n.t('signup'),
                                    loadingLabel:
                                        l10n.t('authCreatingAccount'),
                                    onPressed: () => _submit(
                                      context,
                                      form,
                                      session,
                                      l10n,
                                    ),
                                  ),
                                  SizedBox(height: m.gapMd),
                                  AuthOrDivider(l10n.t('or'), metrics: m),
                                  SizedBox(height: m.gapSm + 2),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        l10n.t('alreadyHaveAccount'),
                                        style: TextStyle(
                                          color: AuthDesign.mutedLabel,
                                          fontSize:
                                              m.s(13).clamp(11.0, 13.0),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              AuthDesign.deepGreen,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: m.gapSm,
                                            vertical: m.gapXs,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                        ),
                                        child: Text(
                                          l10n.t('login'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize:
                                                m.s(13).clamp(11.0, 13.0),
                                            letterSpacing: 0.2,
                                          ),
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
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
