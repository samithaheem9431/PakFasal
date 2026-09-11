import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_session_controller.dart';
import '../localization/app_localizations.dart';
import '../routing/app_routes.dart';
import '../theme/app_colors.dart';

/// Returns `true` when the user has a real Firebase account.
///
/// Guests (`AuthSessionController.isGuestUser`) and fully signed-out users
/// return `false` after the registration-required dialog is shown.
Future<bool> ensureRegisteredUser(BuildContext context) async {
  final auth = context.read<AuthSessionController>();
  if (auth.currentUser != null) return true;
  await showAuthenticationRequiredDialog(context);
  return false;
}

/// Modern auth-required dialog matching PakFasal dialog styling.
///
/// Login → [AppRoutes.login], Register → [AppRoutes.signup], Cancel → dismiss.
Future<void> showAuthenticationRequiredDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final buttonShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      );
      final maxWidth = MediaQuery.sizeOf(dialogContext).width;
      final dialogWidth = maxWidth < 360 ? maxWidth * 0.92 : 340.0;

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryGreen.withValues(alpha: 0.25)
                    : AppColors.paleGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: isDark ? AppColors.lightGreen : AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.t('registrationRequiredTitle'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: isDark ? scheme.onSurface : AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: dialogWidth,
          child: Text(
            l10n.t('registrationRequiredMessage'),
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.primaryGreen,
                    side: const BorderSide(
                      color: AppColors.darkGreen,
                      width: 1.6,
                    ),
                    minimumSize: const Size(0, 48),
                    shape: buttonShape,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l10n.t('login')),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.pushNamed(context, AppRoutes.signup);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isDark ? scheme.onSurface : AppColors.primaryGreen,
                    side: BorderSide(
                      color: isDark ? scheme.outline : AppColors.primaryGreen,
                      width: 1.6,
                    ),
                    minimumSize: const Size(0, 48),
                    shape: buttonShape,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l10n.t('register')),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isDark ? scheme.onSurfaceVariant : AppColors.mutedText,
                    minimumSize: const Size(0, 44),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(l10n.t('cancel')),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
