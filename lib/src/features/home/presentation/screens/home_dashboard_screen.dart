import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/auth_required_dialog.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../auth/presentation/providers/auth_session_controller.dart';
import '../../../about/presentation/screens/about_pakfasal_screen.dart';
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

  Future<void> _handleBackPress() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
      return;
    }

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        final buttonShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        );
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.t('exitAppTitle'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isDark ? scheme.onSurface : AppColors.primaryGreen,
            ),
          ),
          content: Text(
            l10n.t('exitAppMessage'),
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isDark ? scheme.onSurface : AppColors.darkText,
                      side: BorderSide(
                        color: isDark
                            ? scheme.outline
                            : AppColors.lightGrey,
                        width: 1.6,
                      ),
                      minimumSize: const Size(0, 48),
                      shape: buttonShape,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(l10n.t('no')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(true),
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
                    child: Text(l10n.t('yes')),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldExit == true && mounted) {
      SystemNavigator.pop();
    }
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

  Future<void> _onBottomNavTap(int index) async {
    // Sensor (2) and Ask AI (1) require a registered Firebase account.
    if (index == 1 || index == 2) {
      final allowed = await ensureRegisteredUser(context);
      if (!allowed || !mounted) return;
    }

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

  Future<void> _openProtectedRoute(String routeName) async {
    final allowed = await ensureRegisteredUser(context);
    if (!allowed || !mounted) return;
    Navigator.pushNamed(context, routeName);
  }

  Widget _buildLeftDrawer({
    required AuthSessionController auth,
    required ThemeController themeController,
    required AppLocalizations l10n,
  }) {
    final displayName = _displayNameFor(auth);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      width: 300,
      backgroundColor: isDark ? scheme.surface : AppColors.white,
      child: Column(
        children: [
          // ── Green gradient header with user info ─────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
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
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'F',
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // User name
                Text(
                  displayName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                // User role
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: AppColors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PakFasal Farmer',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // ── Menu items ───────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Dark mode toggle
                _DrawerMenuItem(
                  icon: themeController.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  title: themeController.isDarkMode
                      ? l10n.t('darkMode')
                      : l10n.t('lightMode'),
                  trailing: Switch(
                    value: themeController.isDarkMode,
                    onChanged: (_) => themeController.toggleTheme(),
                    activeColor: AppColors.primaryGreen,
                  ),
                  onTap: () => themeController.toggleTheme(),
                ),
                
                // Language selector
                _DrawerMenuItem(
                  icon: Icons.language,
                  title: l10n.t('language'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      ),
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
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                
                // App info section
                _DrawerMenuItem(
                  icon: Icons.info_outline,
                  title: l10n.t('aboutPakFasal'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.about);
                  },
                ),
                
                _DrawerMenuItem(
                  icon: Icons.help_outline,
                  title: l10n.t('aboutHelpSupport'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.about,
                      arguments: AboutPakFasalArgs.help,
                    );
                  },
                ),
                
                _DrawerMenuItem(
                  icon: Icons.star_outline,
                  title: l10n.t('aboutRateUs'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.about,
                      arguments: AboutPakFasalArgs.rate,
                    );
                  },
                ),
              ],
            ),
          ),
          
          // ── Sign out button ──────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error.withValues(alpha: 0.1),
                  AppColors.error.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.t('authSignOut'),
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthSessionController>();
    final themeController = context.watch<ThemeController>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: scheme.surface,
      drawer: _buildLeftDrawer(
        auth: auth,
        themeController: themeController,
        l10n: l10n,
      ),
      // ── Bottom navigation bar with deep green background ──────────
      bottomNavigationBar: SafeArea(
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
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar with gradient green background ─────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu, size: 24, color: AppColors.white),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: AppColors.primaryGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PakFasal',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              l10n.t('appTagline'),
                              style: const TextStyle(
                                color: AppColors.white,
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
                        icon: const Icon(
                          Icons.notifications_none,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 9,
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
                          // Only show offline when data is stale (old), not just cached
                          final isOfflineMode = weather.isStale;
                          return _FadeSlideIn(
                            delayMs: 40,
                            animate: _animateContentIn,
                            child: HomeWeatherCard(
                              weather: data,
                              temperatureLabel: l10n.t('temperature'),
                              humidityLabel: l10n.t('humidity'),
                              rainChanceLabel: l10n.t('rainChance'),
                              isOffline: isOfflineMode,
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
                                color: isDark ? Colors.white : Colors.black,
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
                              onTap: () => _openProtectedRoute(AppRoutes.aiQuery),
                            ),
                          ),
                          _FadeSlideIn(
                            delayMs: 310,
                            animate: _animateContentIn,
                            child: DashboardTile(
                              icon: Icons.sensors,
                              title: l10n.t('sensorData'),
                              onTap: () => _openProtectedRoute(AppRoutes.sensor),
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

// ── Bottom tab item with white icons ──────────────────────────────────────
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
                color: isActive ? AppColors.white : AppColors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.white : AppColors.white.withValues(alpha: 0.6),
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

// ── Drawer menu item widget ────────────────────────────────────────────────
class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
