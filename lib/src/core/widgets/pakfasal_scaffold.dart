import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../routing/app_routes.dart';
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

  void _onNavTap(BuildContext context, int index) {
    final target = switch (index) {
      1 => AppRoutes.aiQuery,
      2 => AppRoutes.sensor,
      3 => AppRoutes.profile,
      _ => AppRoutes.home,
    };
    final current = ModalRoute.of(context)?.settings.name;
    if (current == target) return;
    Navigator.pushReplacementNamed(context, target);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              )
            : null,
        title: Text(title),
        actions: [
          const LanguageToggleButton(),
          const SizedBox(width: 8),
          if (actions != null) ...actions!,
        ],
      ),
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNavigation
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
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
    final scheme = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 19,
                color: isActive ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

