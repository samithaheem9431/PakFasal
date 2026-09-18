import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/layout/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_required_dialog.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';

/// View All modules — scenic hero + pastel module cards matching design mock.
class ViewAllModulesScreen extends StatelessWidget {
  const ViewAllModulesScreen({super.key});

  static const _headerAsset =
      'assets/images/dashboard/view_all_header_bg.png';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = context.isCompact ? 14.0 : 18.0;
    final bottomClearance =
        PakFasalFloatingBottomBar.contentClearance(context);

    final modules = <_ModuleItem>[
      _ModuleItem(
        image: 'assets/images/dashboard/tile_learning.png',
        title: l10n.t('learning'),
        description: l10n.t('moduleLearningDesc'),
        route: AppRoutes.learning,
        pastel: const Color(0xFFE7F6EA),
        accent: const Color(0xFF1B5E20),
        titleColor: const Color(0xFF1B5E20),
        requiresAuth: false,
      ),
      _ModuleItem(
        image: 'assets/images/dashboard/tile_weather.png',
        title: l10n.t('weather'),
        description: l10n.t('moduleWeatherDesc'),
        route: AppRoutes.weather,
        pastel: const Color(0xFFE3F2FD),
        accent: const Color(0xFF1565C0),
        titleColor: const Color(0xFF0D47A1),
        requiresAuth: false,
      ),
      _ModuleItem(
        image: 'assets/images/dashboard/tile_ask_ai.png',
        title: l10n.t('askAi'),
        description: l10n.t('moduleAskAiDesc'),
        route: AppRoutes.aiQuery,
        pastel: const Color(0xFFFFF0E0),
        accent: const Color(0xFFA1887F),
        titleColor: const Color(0xFF5D4037),
        requiresAuth: true,
      ),
      _ModuleItem(
        image: 'assets/images/dashboard/tile_sensor.png',
        title: l10n.t('sensorData'),
        description: l10n.t('moduleSensorDesc'),
        route: AppRoutes.sensor,
        pastel: const Color(0xFFE8F5E9),
        accent: const Color(0xFF2E7D32),
        titleColor: const Color(0xFF1B5E20),
        requiresAuth: true,
      ),
      _ModuleItem(
        image: 'assets/images/dashboard/tile_marketplace.png',
        title: l10n.t('marketplace'),
        description: l10n.t('moduleMarketplaceDesc'),
        route: AppRoutes.marketplace,
        pastel: const Color(0xFFF3E5F5),
        accent: const Color(0xFF8E24AA),
        titleColor: const Color(0xFF6A1B9A),
        requiresAuth: false,
      ),
      _ModuleItem(
        image: 'assets/images/dashboard/tile_crop_calendar.png',
        title: l10n.t('cropCalendar'),
        description: l10n.t('moduleCropCalendarDesc'),
        route: AppRoutes.cropCalendar,
        pastel: const Color(0xFFFFF8E1),
        accent: const Color(0xFF8D6E63),
        titleColor: const Color(0xFF5D4037),
        requiresAuth: false,
      ),
      _ModuleItem(
        image: 'assets/images/dashboard/tile_govt_schemes.png',
        title: l10n.t('govtSchemes'),
        description: l10n.t('moduleGovtSchemesDesc'),
        route: AppRoutes.govtSchemes,
        pastel: const Color(0xFFE0F7FA),
        accent: const Color(0xFF00838F),
        titleColor: const Color(0xFF006064),
        requiresAuth: false,
      ),
      _ModuleItem(
        image: 'assets/images/dashboard/tile_profit_calculator.png',
        title: l10n.t('profitCalculator'),
        description: l10n.t('moduleProfitCalculatorDesc'),
        route: AppRoutes.profitCalculator,
        pastel: const Color(0xFFF3E5F5),
        accent: const Color(0xFF7B1FA2),
        titleColor: const Color(0xFF4A148C),
        requiresAuth: false,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark ? scheme.surface : Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _ViewAllHeroHeader(
                      asset: _headerAsset,
                      title: l10n.t('viewAll'),
                      subtitle: l10n.t('viewAllSubtitle'),
                      isDark: isDark,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      4,
                      hPad,
                      bottomClearance + 8,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        // Taller cards so 2-line descriptions aren't clipped.
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final module = modules[index];
                          return _ViewAllModuleCard(
                            module: module,
                            onTap: () => _openModule(context, module),
                          );
                        },
                        childCount: modules.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PakFasalFloatingBottomBar(
                selectedIndex: 0,
                onTap: (index) => _onBottomNavTap(context, index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openModule(BuildContext context, _ModuleItem module) async {
    if (module.requiresAuth) {
      final allowed = await ensureRegisteredUser(context);
      if (!allowed || !context.mounted) return;
    }
    if (!context.mounted) return;
    Navigator.pushNamed(context, module.route);
  }

  Future<void> _onBottomNavTap(BuildContext context, int index) async {
    final target = switch (index) {
      1 => AppRoutes.aiQuery,
      2 => AppRoutes.sensor,
      3 => AppRoutes.profile,
      _ => AppRoutes.home,
    };
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }
    if (index == 1 || index == 2) {
      final allowed = await ensureRegisteredUser(context);
      if (!allowed || !context.mounted) return;
    }
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, target);
  }
}

class _ModuleItem {
  const _ModuleItem({
    required this.image,
    required this.title,
    required this.description,
    required this.route,
    required this.pastel,
    required this.accent,
    required this.titleColor,
    required this.requiresAuth,
  });

  final String image;
  final String title;
  final String description;
  final String route;
  final Color pastel;
  final Color accent;
  final Color titleColor;
  final bool requiresAuth;
}

class _ViewAllHeroHeader extends StatelessWidget {
  const _ViewAllHeroHeader({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final String asset;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final titleStyle = GoogleFonts.lora(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: isDark ? AppColors.white : const Color(0xFF1B4D2E),
    );

    return ClipPath(
      clipper: const _HeroBottomCurveClipper(),
      child: SizedBox(
        height: 250 + topInset,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isDark
                    ? Colors.black.withValues(alpha: 0.40)
                    : Colors.transparent,
                BlendMode.darken,
              ),
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.15),
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFB8E0C8),
                        Color(0xFFE8F5E9),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Soft readability veil behind title
            Positioned(
              left: 36,
              right: 36,
              top: topInset + 70,
              child: IgnorePointer(
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.12 : 0.42),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: topInset + 10,
              child: Row(
                children: [
                  _HeroCircleButton(
                    onTap: () {
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
                  ),
                  const Spacer(),
                  const _HeroLanguagePill(),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: topInset + 78,
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.white.withValues(alpha: 0.88)
                          : const Color(0xFF4A5568),
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

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF1B5E20),
          ),
        ),
      ),
    );
  }
}

class _HeroLanguagePill extends StatelessWidget {
  const _HeroLanguagePill();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocalizationController>();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: controller.toggleLanguage,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language,
                size: 16,
                color: Color(0xFF1B5E20),
              ),
              const SizedBox(width: 6),
              Text(
                controller.isUrdu ? 'اردو' : 'EN',
                style: const TextStyle(
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Color(0xFF1B5E20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewAllModuleCard extends StatefulWidget {
  const _ViewAllModuleCard({
    required this.module,
    required this.onTap,
  });

  final _ModuleItem module;
  final VoidCallback onTap;

  @override
  State<_ViewAllModuleCard> createState() => _ViewAllModuleCardState();
}

class _ViewAllModuleCardState extends State<_ViewAllModuleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pastel = isDark
        ? Color.lerp(module.pastel, Colors.black, 0.45)!
        : module.pastel;
    final titleColor = isDark ? AppColors.white : module.titleColor;
    final descColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : const Color(0xFF6B7280);
    final whiteSection = isDark ? AppColors.darkSurfaceMid : Colors.white;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              color: whiteSection,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: pastel,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                    child: Image.asset(
                      module.image,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: module.accent,
                      ),
                    ),
                  ),
                ),
                // Fixed footer height so description always has room for 2 lines.
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              module.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                height: 1.15,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              module.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                                color: descColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: module.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: module.accent.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
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

/// Soft upward white cutout under the scenic hero (matches mock).
class _HeroBottomCurveClipper extends CustomClipper<Path> {
  const _HeroBottomCurveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    // White content rises into the header at the center.
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(
      size.width * 0.72,
      size.height - 34,
      size.width * 0.5,
      size.height - 36,
    );
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height - 34,
      0,
      size.height,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
