import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
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
  bool _requireBiometricForAutofill = true;

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
      defaultValue: true,
    ) as bool;
    final legacyEmail =
        preferences.get(_legacyRememberedEmailKey, defaultValue: '') as String;
    // Safety cleanup for older versions that stored plain-text credentials in Hive.
    await preferences.delete(_legacyRememberedEmailKey);
    await preferences.delete(_legacyRememberedPasswordKey);

    if (legacyEmail.isNotEmpty) {
      await _secureStorage.write(key: _secureEmailKey, value: legacyEmail);
    }

    final email = await _secureStorage.read(key: _secureEmailKey) ?? '';
    final savedPassword = await _secureStorage.read(key: _securePasswordKey) ?? '';

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
          // Allow PIN/pattern fallback if biometrics are not enrolled.
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
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          backgroundColor: Colors.redAccent,
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
                                          autocorrect: false,
                                          enableSuggestions: false,
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
                                          autocorrect: false,
                                          enableSuggestions: false,
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

                                        const SizedBox(height: 8),
                                        CheckboxListTile(
                                          value: _rememberMe,
                                          onChanged: form.isLoading
                                              ? null
                                              : (value) {
                                                  setState(() {
                                                    _rememberMe = value ?? false;
                                                    if (!_rememberMe) {
                                                      _requireBiometricForAutofill =
                                                          false;
                                                    }
                                                  });
                                                  if (!(value ?? false)) {
                                                    _persistRememberedCredentials();
                                                  }
                                                },
                                          dense: true,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: AppTheme.primaryGreen,
                                          title: Text(
                                            l10n.t('rememberMe'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SwitchListTile(
                                          value: _requireBiometricForAutofill,
                                          onChanged: form.isLoading || !_rememberMe
                                              ? null
                                              : (value) {
                                                  setState(() {
                                                    _requireBiometricForAutofill =
                                                        value;
                                                  });
                                                },
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: AppTheme.primaryGreen,
                                          title: Text(
                                            l10n.t('requireBiometricAutofill'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            l10n.t('rememberMeHint'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                          ),
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
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: form.isLoading
                                              ? null
                                              : () => _continueAsGuest(
                                                    context,
                                                    session,
                                                  ),
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppTheme.primaryGreen,
                                          ),
                                          child: Text(
                                            l10n.t('continueAsGuest'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
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