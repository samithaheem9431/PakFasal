import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';

/// Section keys passed via [RouteSettings.arguments].
class AboutPakFasalArgs {
  static const help = 'help';
  static const rate = 'rate';
}

class AboutPakFasalScreen extends StatefulWidget {
  const AboutPakFasalScreen({super.key});

  @override
  State<AboutPakFasalScreen> createState() => _AboutPakFasalScreenState();
}

class _AboutPakFasalScreenState extends State<AboutPakFasalScreen>
    with TickerProviderStateMixin {
  static const _appVersion = '1.0.0';
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.example.pakfasal_app';

  final _scrollController = ScrollController();
  final _actionsKey = GlobalKey();

  late final AnimationController _heroCtrl;
  late final AnimationController _bodyCtrl;
  late final AnimationController _footerCtrl;
  bool _handledArgs = false;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    _bodyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _footerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _bodyCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) _footerCtrl.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRouteArgs());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroCtrl.dispose();
    _bodyCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  bool get _isHelpMode =>
      ModalRoute.of(context)?.settings.arguments == AboutPakFasalArgs.help;

  void _handleRouteArgs() {
    if (_handledArgs || !mounted) return;
    _handledArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == AboutPakFasalArgs.rate) {
      _scrollToKey(_actionsKey);
      _rateApp();
    }
  }

  Future<void> _scrollToKey(GlobalKey key) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final targetContext = key.currentContext;
    if (targetContext == null || !targetContext.mounted) return;
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  Future<void> _rateApp() async {
    final messenger = ScaffoldMessenger.of(context);
    final unavailable = AppLocalizations.of(context).t('aboutRateUnavailable');
    final uri = Uri.parse(_playStoreUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      messenger.showSnackBar(SnackBar(content: Text(unavailable)));
    }
  }

  Future<void> _shareApp(AppLocalizations l10n) async {
    final message = l10n.t('aboutShareMessage');
    final messenger = ScaffoldMessenger.of(context);
    try {
      await SharePlus.instance.share(ShareParams(text: message));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: message));
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.t('aboutShareCopied'))),
      );
    }
  }

  Future<void> _openEmail(AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final email = l10n.t('aboutContactEmail');
    final failMsg = l10n.t('aboutCouldNotOpenEmail');
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'PakFasal Support'},
    );
    final opened = await launchUrl(uri);
    if (!opened && mounted) {
      messenger.showSnackBar(SnackBar(content: Text(failMsg)));
    }
  }

  Future<void> _openWhatsapp(AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final failMsg = l10n.t('couldNotOpenWhatsapp');
    final phone =
        l10n.t('aboutContactWhatsapp').replaceAll(RegExp(r'[^\d+]'), '');
    final clean = phone.replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$clean');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      messenger.showSnackBar(SnackBar(content: Text(failMsg)));
    }
  }

  void _showFeatureDetail(_FeatureItem item) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final sheetColor = isDark
        ? Color.alphaBlend(
            AppColors.white.withValues(alpha: 0.04),
            scheme.surface,
          )
        : AppColors.white;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: sheetColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: AppColors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.white
                              : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  item.detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.55,
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.9)
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(l10n.t('aboutGotIt')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final cardBg = isDark
        ? scheme.surfaceContainerHighest
        : const Color(0xFFF1F8F5);

    return PakFasalScaffold(
      title: l10n.t(_isHelpMode ? 'aboutHelpSupport' : 'aboutPakFasal'),
      child: ListView(
        controller: _scrollController,
        padding: PakFasalFloatingBottomBar.scrollPadding(
          context,
          left: 16,
          top: 12,
          right: 16,
          bottom: 28,
        ),
        children: _isHelpMode
            ? _buildHelpChildren(
                l10n: l10n,
                scheme: scheme,
                textTheme: textTheme,
                cardBg: cardBg,
              )
            : _buildAboutChildren(
                l10n: l10n,
                scheme: scheme,
                textTheme: textTheme,
                isDark: isDark,
                cardBg: cardBg,
              ),
      ),
    );
  }

  List<Widget> _buildAboutChildren({
    required AppLocalizations l10n,
    required ColorScheme scheme,
    required TextTheme textTheme,
    required bool isDark,
    required Color cardBg,
  }) {
    final features = <_FeatureItem>[
      _FeatureItem(
        icon: Icons.cloud,
        title: l10n.t('weather'),
        desc: l10n.t('aboutFeatureWeatherDesc'),
        detail: l10n.t('aboutFeatureWeatherDetail'),
      ),
      _FeatureItem(
        icon: Icons.sensors,
        title: l10n.t('sensorData'),
        desc: l10n.t('aboutFeatureSensorDesc'),
        detail: l10n.t('aboutFeatureSensorDetail'),
      ),
      _FeatureItem(
        icon: Icons.smart_toy,
        title: l10n.t('askAi'),
        desc: l10n.t('aboutFeatureAiDesc'),
        detail: l10n.t('aboutFeatureAiDetail'),
      ),
      _FeatureItem(
        icon: Icons.menu_book,
        title: l10n.t('learning'),
        desc: l10n.t('aboutFeatureLearningDesc'),
        detail: l10n.t('aboutFeatureLearningDetail'),
      ),
      _FeatureItem(
        icon: Icons.calendar_month,
        title: l10n.t('cropCalendar'),
        desc: l10n.t('aboutFeatureCalendarDesc'),
        detail: l10n.t('aboutFeatureCalendarDetail'),
      ),
      _FeatureItem(
        icon: Icons.store,
        title: l10n.t('marketplace'),
        desc: l10n.t('aboutFeatureMarketDesc'),
        detail: l10n.t('aboutFeatureMarketDetail'),
      ),
    ];

    return [
      _FadeSlide(
        controller: _heroCtrl,
        child: _HeroCard(l10n: l10n),
      ),
      const SizedBox(height: 14),
      _FadeSlide(
        controller: _bodyCtrl,
        child: _SectionCard(
          background: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('aboutMissionTitle'),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? scheme.onSurface : AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('aboutMissionBody'),
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      _FadeSlide(
        controller: _bodyCtrl,
        child: Text(
          l10n.t('aboutFeaturesTitle'),
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
      ),
      const SizedBox(height: 10),
      ...features.map(
        (f) => _FadeSlide(
          controller: _bodyCtrl,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _FeatureRow(
              item: f,
              background: cardBg,
              onTap: () => _showFeatureDetail(f),
            ),
          ),
        ),
      ),
      const SizedBox(height: 6),
      KeyedSubtree(
        key: _actionsKey,
        child: _FadeSlide(
          controller: _footerCtrl,
          child: _SectionCard(
            background: cardBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.t('aboutAppInfoTitle'),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.t(
                    'aboutVersionLabel',
                    params: {'version': _appVersion},
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('aboutPrivacyNote'),
                  style: textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _rateApp,
                        icon: const Icon(Icons.star_outline, size: 18),
                        label: Text(l10n.t('aboutRateUs')),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareApp(l10n),
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: Text(l10n.t('aboutShareApp')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isDark ? AppColors.white : AppColors.primaryGreen,
                          side: BorderSide(
                            color: (isDark
                                    ? AppColors.white
                                    : AppColors.primaryGreen)
                                .withValues(alpha: 0.45),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
    ];
  }

  List<Widget> _buildHelpChildren({
    required AppLocalizations l10n,
    required ColorScheme scheme,
    required TextTheme textTheme,
    required Color cardBg,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? AppColors.white : AppColors.primaryGreen;
    final faqs = <_FaqItem>[
      _FaqItem(l10n.t('aboutFaqWeatherQ'), l10n.t('aboutFaqWeatherA')),
      _FaqItem(l10n.t('aboutFaqSensorQ'), l10n.t('aboutFaqSensorA')),
      _FaqItem(l10n.t('aboutFaqLanguageQ'), l10n.t('aboutFaqLanguageA')),
      _FaqItem(l10n.t('aboutFaqOfflineQ'), l10n.t('aboutFaqOfflineA')),
      _FaqItem(l10n.t('aboutFaqLoginQ'), l10n.t('aboutFaqLoginA')),
    ];

    return [
      _FadeSlide(
        controller: _heroCtrl,
        child: _SectionCard(
          background: cardBg,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: AppColors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('aboutHelpSupport'),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: headingColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.t('aboutFaqTitle'),
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.85)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _FadeSlide(
        controller: _bodyCtrl,
        child: Text(
          l10n.t('aboutFaqTitle'),
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.white : scheme.onSurface,
          ),
        ),
      ),
      const SizedBox(height: 10),
      _FadeSlide(
        controller: _bodyCtrl,
        child: _SectionCard(
          background: cardBg,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < faqs.length; i++) ...[
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 0,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.paleGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        size: 18,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    title: Text(
                      faqs[i].question,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? AppColors.white : null,
                      ),
                    ),
                    children: [
                      Text(
                        faqs[i].answer,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: isDark
                              ? AppColors.white.withValues(alpha: 0.85)
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < faqs.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  ),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      _FadeSlide(
        controller: _footerCtrl,
        child: _SectionCard(
          background: cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('aboutContactTitle'),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.white : null,
                ),
              ),
              const SizedBox(height: 10),
              _ContactRow(
                icon: Icons.email_outlined,
                label: l10n.t('aboutContactEmail'),
                onTap: () => _openEmail(l10n),
              ),
              const SizedBox(height: 8),
              _ContactRow(
                icon: Icons.chat_outlined,
                label: l10n.t('aboutContactWhatsapp'),
                onTap: () => _openWhatsapp(l10n),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String desc;
  final String detail;
}

class _FaqItem {
  const _FaqItem(this.question, this.answer);

  final String question;
  final String answer;
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.controller, required this.child});

  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/PakFASAL.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.eco,
                  color: AppColors.primaryGreen,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.t('appName'),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.t('appTagline'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.92),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    required this.background,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color background;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.item,
    required this.background,
    required this.onTap,
  });

  final _FeatureItem item;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: AppColors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.info_outline,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.white : AppColors.primaryGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ),
            Icon(Icons.open_in_new, size: 16, color: accent),
          ],
        ),
      ),
    );
  }
}
