import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../auth/presentation/providers/auth_session_controller.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../widgets/dashboard_tile.dart';
import '../widgets/home_weather_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedBottomIndex = 0;
  bool _animateContentIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _animateContentIn = true);
      context.read<WeatherProvider>().ensureLoaded();
    });
    // Auth-state guarding is handled by AuthGate at the route level.
    // Weather state and its auto-refresh timer live in WeatherProvider.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<WeatherProvider>().refreshAll();
    }
  }

  Future<void> _refreshDashboard() async {
    await context.read<WeatherProvider>().refreshAll();
  }

  void _openNotificationsPanel(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final sheetColor = isDark
        ? Color.alphaBlend(AppColors.white.withValues(alpha: 0.04), scheme.surface)
        : AppColors.white;
    final tileColor = isDark
        ? Color.alphaBlend(
            AppColors.primaryGreen.withValues(alpha: 0.28),
            scheme.surfaceContainerHighest,
          )
        : scheme.surfaceContainerLow;
    final iconBgColor = isDark
        ? AppColors.primaryGreen.withValues(alpha: 0.40)
        : AppColors.paleGreen;
    final titleColor = isDark ? scheme.onSurface : AppColors.primaryGreen;
    final textColor = isDark ? scheme.onSurface : scheme.onSurfaceVariant;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: sheetColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final items = <String>[
          l10n.t('notificationIrrigationReminder'),
          l10n.t('notificationWeatherAlert'),
          l10n.t('notificationMarketplaceOffer'),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('notifications'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(
                          alpha: isDark ? 0.50 : 0.18,
                        ),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: isDark ? AppColors.white : AppColors.primaryGreen,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        item,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedBottomIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.aiQuery);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.sensor);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  Widget _buildLeftDrawer({
    required AuthSessionController auth,
    required ThemeController themeController,
    required AppLocalizations l10n,
  }) {
    final displayName = _displayNameFor(auth);
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      width: 295,
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── User header ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primaryContainer,
                      scheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: scheme.primary,
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'F',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'PakFasal Farmer',
                            style: TextStyle(
                              color: scheme.primary.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Divider(color: scheme.outlineVariant),
              // ── Dark mode toggle ───────────────────────────────────────
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: themeController.isDarkMode,
                activeColor: AppColors.primaryGreen,
                title: Text(
                  themeController.isDarkMode
                      ? l10n.t('darkMode')
                      : l10n.t('lightMode'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    themeController.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: AppColors.primaryGreen,
                    size: 18,
                  ),
                ),
                onChanged: (_) => themeController.toggleTheme(),
              ),
              // ── Language toggle ────────────────────────────────────────
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.language,
                    color: AppColors.primaryGreen,
                    size: 18,
                  ),
                ),
                title: Text(
                  l10n.t('language'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    context.watch<LocalizationController>().isUrdu
                        ? 'اردو'
                        : 'EN',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                onTap: () =>
                    context.read<LocalizationController>().toggleLanguage(),
              ),
              const Spacer(),
              // ── Sign out ───────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
                  title: Text(
                    l10n.t('authSignOut'),
                    style: TextStyle(
                      color: scheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await auth.signOut();
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (_) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthSessionController>();
    final themeController = context.watch<ThemeController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scheme.surface,
      drawer: _buildLeftDrawer(
        auth: auth,
        themeController: themeController,
        l10n: l10n,
      ),
      // ── Bottom navigation bar ──────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.10),
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
                  label: l10n.t('home'),
                  isActive: _selectedBottomIndex == 0,
                  onTap: () => _onBottomNavTap(0),
                ),
                _BottomTabItem(
                  icon: Icons.smart_toy_outlined,
                  label: l10n.t('askAi'),
                  isActive: _selectedBottomIndex == 1,
                  onTap: () => _onBottomNavTap(1),
                ),
                _BottomTabItem(
                  icon: Icons.sensors_outlined,
                  label: l10n.t('sensorData'),
                  isActive: _selectedBottomIndex == 2,
                  onTap: () => _onBottomNavTap(2),
                ),
                _BottomTabItem(
                  icon: Icons.person_outline,
                  label: l10n.t('profile'),
                  isActive: _selectedBottomIndex == 3,
                  onTap: () => _onBottomNavTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  bottom: BorderSide(color: scheme.outlineVariant, width: 1),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: Icon(Icons.menu, size: 24, color: scheme.primary),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.eco,
                            color: scheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PakFasal',
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              l10n.t('appTagline'),
                              style: TextStyle(
                                color: scheme.primary.withValues(alpha: 0.7),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () => _openNotificationsPanel(l10n),
                        icon: Icon(
                          Icons.notifications_none,
                          color: scheme.primary,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 8,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshDashboard,
                color: AppColors.primaryGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Consumer<WeatherProvider>(
                        builder: (context, weather, _) {
                          if (weather.current == null &&
                              weather.isLoadingCurrent) {
                            return const _FadeSlideIn(
                              delayMs: 40,
                              child: LoadingStateCard(),
                            );
                          }
                          if (weather.current == null) {
                            return _FadeSlideIn(
                              delayMs: 40,
                              child: ErrorStateCard(
                                onRetry: () => weather.loadCurrent(
                                  forceRefresh: true,
                                ),
                              ),
                            );
                          }
                          final data = weather.current!;
                          final lastSyncAt = weather.lastSyncAt;
                          return _FadeSlideIn(
                            delayMs: 40,
                            animate: _animateContentIn,
                            child: HomeWeatherCard(
                              weather: data,
                              temperatureLabel: l10n.t('temperature'),
                              humidityLabel: l10n.t('humidity'),
                              rainChanceLabel: l10n.t('rainChance'),
                              lastSyncedLabel: lastSyncAt == null
                                  ? null
                                  : '${l10n.t('lastUpdated')}: ${TimeOfDay.fromDateTime(lastSyncAt).format(context)}',
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _FadeSlideIn(
                        delayMs: 120,
                        animate: _animateContentIn,
                        child: Text(
                          l10n.t('quickAccess'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: scheme.primary,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.9,
                        children: [
                          _FadeSlideIn(
                            delayMs: 160,
                            animate: _animateContentIn,
                            child: DashboardTile(
                              icon: Icons.menu_book,
                              title: l10n.t('learning'),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.learning,
                              ),
                            ),
                          ),
                          _FadeSlideIn(
                            delayMs: 210,
                            animate: _animateContentIn,
                            child: DashboardTile(
                              icon: Icons.cloud,
                              title: l10n.t('weather'),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.weather,
                              ),
                            ),
                          ),
                          _FadeSlideIn(
                            delayMs: 260,
                            animate: _animateContentIn,
                            child: DashboardTile(
                              icon: Icons.smart_toy,
                              title: l10n.t('askAi'),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.aiQuery,
                              ),
                            ),
                          ),
                          _FadeSlideIn(
                            delayMs: 310,
                            animate: _animateContentIn,
                            child: DashboardTile(
                              icon: Icons.sensors,
                              title: l10n.t('sensorData'),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.sensor,
                              ),
                            ),
                          ),
                          _FadeSlideIn(
                            delayMs: 360,
                            animate: _animateContentIn,
                            child: DashboardTile(
                              icon: Icons.store,
                              title: l10n.t('marketplace'),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.marketplace,
                              ),
                            ),
                          ),
                          _FadeSlideIn(
                            delayMs: 410,
                            animate: _animateContentIn,
                            child: DashboardTile(
                              icon: Icons.calendar_month,
                              title: l10n.t('cropCalendar'),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.cropCalendar,
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
          ],
        ),
      ),
    );
  }

  String _displayNameFor(AuthSessionController auth) {
    final userName = auth.userName?.trim();
    if (userName != null && userName.isNotEmpty) return userName;
    final email = auth.userEmail?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return 'Farmer';
  }
}

// ── Bottom tab item ────────────────────────────────────────────────────────
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.paleGreen : AppColors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  scale: isActive ? 1.08 : 1.0,
                  child: Icon(
                    icon,
                    size: 19,
                    color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Fade-slide-in animation wrapper — unchanged ────────────────────────────
class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.child,
    this.animate = true,
    this.delayMs = 0,
  });

  final Widget child;
  final bool animate;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final delayFactor = (delayMs / 700).clamp(0.0, 0.55);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: animate ? 1 : 0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayed = ((value - delayFactor) / (1 - delayFactor)).clamp(
          0.0,
          1.0,
        );
        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - delayed)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
