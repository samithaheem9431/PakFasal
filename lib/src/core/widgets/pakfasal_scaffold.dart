import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../layout/responsive.dart';
import '../localization/app_localizations.dart';
import '../routing/app_routes.dart';
import '../theme/app_colors.dart';
import 'auth_required_dialog.dart';
import 'language_toggle_button.dart';

SystemUiOverlayStyle pakFasalSystemOverlay(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
  );
}

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
    this.backgroundColor,
    this.transparentChrome = false,
    this.extendBodyBehindAppBar = false,
    this.extendBehindBottomBar = false,
  });

  final String title;
  final Widget child;
  final bool showBack;
  final bool isOffline;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBottomNavigation;
  /// When set, overrides the theme scaffold background (e.g. weather sky).
  final Color? backgroundColor;
  /// Transparent app bar (white icons) for immersive screens like weather.
  final bool transparentChrome;
  /// Lets [child] draw under the app bar (pair with [transparentChrome]).
  final bool extendBodyBehindAppBar;
  /// Lets [child] paint under the floating bottom bar (no bottom clearance pad).
  final bool extendBehindBottomBar;

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
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.scaffoldBackgroundColor;

    final appBar = AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: pakFasalSystemOverlay(context),
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
        style: TextStyle(
          color: AppColors.white,
          fontWeight: transparentChrome ? FontWeight.w600 : FontWeight.w700,
          fontSize: transparentChrome ? 16 : 18,
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const LanguageToggleButton(),
        ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: pakFasalSystemOverlay(context),
      child: Scaffold(
        backgroundColor: bg,
        extendBodyBehindAppBar: extendBodyBehindAppBar || transparentChrome,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: transparentChrome
              ? appBar
              : Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
                  child: appBar,
                ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Builder(
                builder: (bodyContext) {
                  final immersive = transparentChrome || extendBodyBehindAppBar;
                  // Weather paints sky under the floating bar without a dark strip.
                  final bottomPad =
                      (!extendBehindBottomBar &&
                              !immersive &&
                              showBottomNavigation)
                          ? PakFasalFloatingBottomBar.contentClearance(
                              bodyContext,
                            )
                          : 0.0;
                  return SafeArea(
                    top: !immersive,
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPad),
                      child: ResponsiveContent(child: child),
                    ),
                  );
                },
              ),
            ),
            if (showBottomNavigation)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PakFasalFloatingBottomBar(
                  selectedIndex: _selectedNavIndex(context),
                  onTap: (index) => _onNavTap(context, index),
                ),
              ),
          ],
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

class PakFasalFloatingBottomBar extends StatelessWidget {
  const PakFasalFloatingBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  /// Space content needs above the screen bottom so it clears the floating bar.
  static double contentClearance(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 360;
    final barHeight = narrow ? 62.0 : 68.0;
    const padBelowBar = 12.0;
    const gapAboveBar = 6.0;
    return barHeight +
        padBelowBar +
        gapAboveBar +
        MediaQuery.paddingOf(context).bottom;
  }

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final narrow = context.screenWidth < 360;
    final sidePad = context.isExpanded ? 24.0 : (narrow ? 10.0 : 16.0);

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 12),
              child: Container(
                height: narrow ? 62 : 68,
                padding: EdgeInsets.symmetric(
                  horizontal: narrow ? 4 : 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryGreen : AppColors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.18 : 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BottomTabItem(
                      icon: Icons.home,
                      label: localizations.t('home'),
                      isActive: selectedIndex == 0,
                      onTap: () => onTap(0),
                      compact: narrow,
                    ),
                    _BottomTabItem(
                      icon: Icons.smart_toy_outlined,
                      label: localizations.t('askAi'),
                      isActive: selectedIndex == 1,
                      onTap: () => onTap(1),
                      compact: narrow,
                    ),
                    _BottomTabItem(
                      icon: Icons.sensors_outlined,
                      label: localizations.t('sensorData'),
                      isActive: selectedIndex == 2,
                      onTap: () => onTap(2),
                      compact: narrow,
                    ),
                    _BottomTabItem(
                      icon: Icons.person_outline,
                      label: localizations.t('profile'),
                      isActive: selectedIndex == 3,
                      onTap: () => onTap(3),
                      compact: narrow,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomTabItem extends StatelessWidget {
  const _BottomTabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = AppColors.white;
    final Color inactiveColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : const Color(0xFF4A5568);

    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 4 : 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isDark && isActive
                  ? AppColors.white.withValues(alpha: 0.18)
                  : null,
              gradient: !isDark && isActive
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF108D4C),
                        Color(0xFF0A5E32),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: compact ? 20 : 22,
                  color: isActive ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 9 : 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
