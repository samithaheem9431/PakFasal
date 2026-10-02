import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_localizations.dart';
import '../routing/app_routes.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_session_controller.dart';
import '../../features/auth/presentation/providers/biometric_lock_controller.dart';

/// Full-screen biometric unlock overlay when [BiometricLockController.isLocked].
class AppLockGate extends StatelessWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthSessionController, BiometricLockController>(
      builder: (context, auth, lock, _) {
        final registered = auth.currentUser != null && !auth.isGuestUser;
        // Sync outside the build paint cycle.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          lock.onSessionChanged(
            hasRegisteredUser: registered,
            userId: auth.userId,
          );
        });

        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (lock.isLocked) _LockOverlay(auth: auth, lock: lock),
          ],
        );
      },
    );
  }
}

class _LockOverlay extends StatelessWidget {
  const _LockOverlay({required this.auth, required this.lock});

  final AuthSessionController auth;
  final BiometricLockController lock;

  Future<void> _unlock(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await lock.unlock(reason: l10n.t('biometricUnlockReason'));
    if (!ok && context.mounted && lock.lastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t(lock.lastError!))),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await auth.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Positioned.fill(
      child: Material(
        color: const Color(0xFF0F2A14),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.lightGreen.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    size: 48,
                    color: AppColors.lightGreen,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.t('appLockedTitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.t('appLockedSubtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 14.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: lock.isBusy ? null : () => _unlock(context),
                    icon: lock.isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock_open_rounded),
                    label: Text(l10n.t('unlockWithBiometric')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: lock.isBusy ? null : () => _signOut(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                  child: Text(l10n.t('authSignOut')),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
