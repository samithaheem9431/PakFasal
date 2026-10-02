import '../../../../core/localization/app_localizations.dart';

/// Shared email / password validators for auth forms.
class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  static final RegExp _hasUpper = RegExp(r'[A-Z]');
  static final RegExp _hasLower = RegExp(r'[a-z]');
  static final RegExp _hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/]');

  static String? email(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.t('emailRequired');
    if (!_emailRegex.hasMatch(email)) return l10n.t('invalidEmail');
    return null;
  }

  /// Login: password must be present (existing accounts may predate strength rules).
  static String? loginPassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.t('passwordRequired');
    return null;
  }

  /// Signup: min 8 chars + upper + lower + special character.
  static String? signupPassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.t('passwordRequired');
    if (value.length < 8) return l10n.t('passwordMin');
    if (!_hasUpper.hasMatch(value)) return l10n.t('passwordNeedsUpper');
    if (!_hasLower.hasMatch(value)) return l10n.t('passwordNeedsLower');
    if (!_hasSpecial.hasMatch(value)) return l10n.t('passwordNeedsSpecial');
    return null;
  }

  static String? confirmPassword(
    String? value,
    String password,
    AppLocalizations l10n,
  ) {
    if (value == null || value.isEmpty) {
      return l10n.t('confirmPasswordRequired');
    }
    if (value != password) return l10n.t('passwordsMismatch');
    return null;
  }
}
