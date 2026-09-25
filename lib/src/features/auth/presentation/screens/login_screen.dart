import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_form_provider.dart';
import '../providers/auth_session_controller.dart';
import '../widgets/auth_shared_widgets.dart';

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
  static const String _rememberMeKey = 'auth_remember_me';
  static const String _biometricAutofillKey = 'auth_biometric_autofill';
  static const String _legacyRememberedEmailKey = 'auth_remembered_email';
  static const String _legacyRememberedPasswordKey = 'auth_remembered_password';
  static const String _secureEmailKey = 'secure_auth_remembered_email';
  static const String _securePasswordKey = 'secure_auth_remembered_password';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _rememberMe = false;
  bool _requireBiometricForAutofill = false;

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
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final preferences = Hive.box('app_preferences');
    final rememberMe =
        preferences.get(_rememberMeKey, defaultValue: false) as bool;
    final requireBiometric = preferences.get(
      _biometricAutofillKey,
      defaultValue: false,
    ) as bool;
    final legacyEmail =
        preferences.get(_legacyRememberedEmailKey, defaultValue: '') as String;
    await preferences.delete(_legacyRememberedEmailKey);
    await preferences.delete(_legacyRememberedPasswordKey);

    if (legacyEmail.isNotEmpty) {
      await _secureStorage.write(key: _secureEmailKey, value: legacyEmail);
    }

    final email = await _secureStorage.read(key: _secureEmailKey) ?? '';
    final savedPassword =
        await _secureStorage.read(key: _securePasswordKey) ?? '';

    var shouldAutofillPassword = !requireBiometric;
    if (rememberMe && requireBiometric && savedPassword.isNotEmpty) {
      shouldAutofillPassword = await _authenticateBeforeAutofill();
    }

    if (!mounted) return;
    setState(() {
      _rememberMe = rememberMe;
      _requireBiometricForAutofill = rememberMe ? requireBiometric : false;
      if (_rememberMe) {
        _emailController.text = email;
        if (shouldAutofillPassword) {
          _passwordController.text = savedPassword;
        }
      }
    });

    if (rememberMe &&
        requireBiometric &&
        shouldAutofillPassword &&
        email.isNotEmpty &&
        savedPassword.isNotEmpty &&
        mounted) {
      _autoLoginWithRememberedCredentials();
    }
  }

  Future<void> _persistRememberedCredentials() async {
    final preferences = Hive.box('app_preferences');
    await preferences.put(_rememberMeKey, _rememberMe);
    if (_rememberMe) {
      await preferences.put(
        _biometricAutofillKey,
        _requireBiometricForAutofill,
      );
      await _secureStorage.write(
        key: _secureEmailKey,
        value: _emailController.text.trim(),
      );
      await _secureStorage.write(
        key: _securePasswordKey,
        value: _passwordController.text,
      );
      return;
    }
    await preferences.put(_biometricAutofillKey, false);
    await _secureStorage.delete(key: _secureEmailKey);
    await _secureStorage.delete(key: _securePasswordKey);
  }

  Future<bool> _authenticateBeforeAutofill() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) {
        return true;
      }
      return _localAuth.authenticate(
        localizedReason: 'Authenticate to fill your saved login details',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _autoLoginWithRememberedCredentials() async {
    if (!_formKey.currentState!.validate()) return;
    final form = context.read<AuthFormProvider>();
    final session = context.read<AuthSessionController>();
    final l10n = AppLocalizations.of(context);

    form.setLoading(true);
    final err = await session.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
    form.setLoading(false);
    if (!mounted) return;
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
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    await _persistRememberedCredentials();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  void _continueAsGuest(BuildContext context, AuthSessionController session) {
    session.continueAsGuest();
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
          // Keep landscape bg under the system gesture/nav bar (no white strip).
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
                    m.gapXs,
                    m.pagePadH,
                    m.gapSm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeTransition(
                        opacity: _fadeHeader,
                        child: AuthTopBar(
                          title: l10n.t('login'),
                          metrics: m,
                        ),
                      ),
                      SizedBox(height: m.gapSm),
                      FadeTransition(
                        opacity: _fadeHeader,
                        child: AuthHeroHeader(
                          heroAsset: 'assets/images/auth/login_hero.png',
                          title: l10n.t('welcome'),
                          subtitle: l10n.t('authSubtitle'),
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
                                  AuthFieldLabel(l10n.t('email'), metrics: m),
                                  SizedBox(height: m.gapSm),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    style: TextStyle(
                                      fontSize: m.fieldFontSize,
                                    ),
                                    scrollPadding:
                                        const EdgeInsets.only(bottom: 72),
                                    autocorrect: false,
                                    enableSuggestions: false,
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
                                  SizedBox(height: m.gapMd),
                                  AuthFieldLabel(
                                    l10n.t('password'),
                                    metrics: m,
                                  ),
                                  SizedBox(height: m.gapSm),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: form.obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    style: TextStyle(
                                      fontSize: m.fieldFontSize,
                                    ),
                                    scrollPadding:
                                        const EdgeInsets.only(bottom: 72),
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    onFieldSubmitted: (_) => _submit(
                                      context,
                                      form,
                                      session,
                                      l10n,
                                    ),
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
                                        return l10n.t('passwordMin');
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: m.gapSm + 2),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: m.s(22).clamp(18.0, 24.0),
                                        width: m.s(22).clamp(18.0, 24.0),
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: AuthDesign.deepGreen,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                          visualDensity:
                                              VisualDensity.compact,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          onChanged: form.isLoading
                                              ? null
                                              : (value) {
                                                  setState(() {
                                                    _rememberMe =
                                                        value ?? false;
                                                    if (!_rememberMe) {
                                                      _requireBiometricForAutofill =
                                                          false;
                                                    }
                                                  });
                                                  if (!(value ?? false)) {
                                                    _persistRememberedCredentials();
                                                  }
                                                },
                                        ),
                                      ),
                                      SizedBox(width: m.gapSm),
                                      Expanded(
                                        child: Text(
                                          l10n.t('rememberMe'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: m.s(13).clamp(
                                                  11.0,
                                                  13.0,
                                                ),
                                            color: AuthDesign.labelColor,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.forgotPassword,
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              AuthDesign.deepGreen,
                                          padding: EdgeInsets.symmetric(
                                            vertical: m.gapXs,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                        ),
                                        child: Text(
                                          l10n.t('forgotPassword'),
                                          style: TextStyle(
                                            fontSize: m.s(13).clamp(
                                                  11.0,
                                                  13.0,
                                                ),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: m.gapMd),
                                  AuthBiometricTile(
                                    metrics: m,
                                    enabled: _requireBiometricForAutofill,
                                    title:
                                        l10n.t('requireBiometricAutofill'),
                                    subtitle: l10n.t('rememberMeHint'),
                                    onChanged:
                                        form.isLoading || !_rememberMe
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _requireBiometricForAutofill =
                                                      value;
                                                });
                                              },
                                  ),
                                  SizedBox(height: m.gapLg),
                                  AuthGradientButton(
                                    metrics: m,
                                    isLoading: form.isLoading,
                                    label: l10n.t('login'),
                                    loadingLabel: l10n.t('authLoggingIn'),
                                    onPressed: () => _submit(
                                      context,
                                      form,
                                      session,
                                      l10n,
                                    ),
                                  ),
                                  SizedBox(height: m.gapMd),
                                  AuthOrDivider(l10n.t('or'), metrics: m),
                                  SizedBox(height: m.gapMd),
                                  AuthOutlinedButton(
                                    metrics: m,
                                    label: l10n.t('signup'),
                                    onPressed: form.isLoading
                                        ? null
                                        : () => Navigator.pushNamed(
                                              context,
                                              AppRoutes.signup,
                                            ),
                                  ),
                                  SizedBox(height: m.gapXs),
                                  TextButton(
                                    onPressed: form.isLoading
                                        ? null
                                        : () => _continueAsGuest(
                                              context,
                                              session,
                                            ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AuthDesign.deepGreen,
                                      padding: EdgeInsets.symmetric(
                                        vertical: m.gapXs,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      l10n.t('continueAsGuest'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: m.s(14).clamp(12.0, 14.0),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
