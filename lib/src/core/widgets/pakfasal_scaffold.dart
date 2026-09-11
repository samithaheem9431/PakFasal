import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../routing/app_routes.dart';
import '../theme/app_colors.dart';
import 'auth_required_dialog.dart';
import 'language_toggle_button.dart';

class PakFasalScaffold extends StatelessWidget {
  const PakFasalScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showBack = true,
    this.isOffline = false,
    this.actions,
    this.floatingActionButton,
    this.showBottomNavigation = true,
  });

  final String title;
  final Widget child;
  final bool showBack;
  final bool isOffline;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBottomNavigation;

  int _selectedNavIndex(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    switch (route) {
      case AppRoutes.aiQuery:
        return 1;
      case AppRoutes.sensor:
        return 2;
      case AppRoutes.profile:
        return 3;
      case AppRoutes.home:
      default:
        return 0;
    }
  }

  Future<void> _onNavTap(BuildContext context, int index) async {
    final target = switch (index) {
      1 => AppRoutes.aiQuery,
      2 => AppRoutes.sensor,
      3 => AppRoutes.profile,
      _ => AppRoutes.home,
    };
    final current = ModalRoute.of(context)?.settings.name;
    if (current == target) return;

    // Sensor and Ask AI require a registered Firebase account.
    if (index == 1 || index == 2) {
      final allowed = await ensureRegisteredUser(context);
      if (!allowed || !context.mounted) return;
    }

    Navigator.pushReplacementNamed(context, target);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.darkGreen,
                AppColors.primaryGreen,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: showBack
                ? IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                        return;
                      }
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (_) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.white,
                    ),
                  )
                : null,
            title: Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const LanguageToggleButton(),
              ),
              const SizedBox(width: 12),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNavigation
          ? SafeArea(
              top: false,
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.darkGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomTabItem(
                      icon: Icons.home,
                      label: localizations.t('home'),
                      isActive: _selectedNavIndex(context) == 0,
                      onTap: () => _onNavTap(context, 0),
                    ),
                    _BottomTabItem(
                      icon: Icons.smart_toy_outlined,
                      label: localizations.t('askAi'),
                      isActive: _selectedNavIndex(context) == 1,
                      onTap: () => _onNavTap(context, 1),
                    ),
                    _BottomTabItem(
                      icon: Icons.sensors_outlined,
                      label: localizations.t('sensorData'),
                      isActive: _selectedNavIndex(context) == 2,
                      onTap: () => _onNavTap(context, 2),
                    ),
                    _BottomTabItem(
                      icon: Icons.person_outline,
                      label: localizations.t('profile'),
                      isActive: _selectedNavIndex(context) == 3,
                      onTap: () => _onNavTap(context, 3),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _BottomTabItem extends StatelessWidget {
  const _BottomTabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive 
                    ? AppColors.white 
                    : AppColors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive 
                      ? AppColors.white 
                      : AppColors.white.withValues(alpha: 0.6),
                ),
              ),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

