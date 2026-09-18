import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/layout/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/govt_scheme.dart';
import '../providers/govt_schemes_provider.dart';
import '../widgets/scheme_banner_slider.dart';
import '../widgets/scheme_card.dart';
import 'scheme_detail_screen.dart';

class GovtSchemesScreen extends StatelessWidget {
  const GovtSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GovtSchemesProvider(),
      child: const _GovtSchemesView(),
    );
  }
}

class _GovtSchemesView extends StatefulWidget {
  const _GovtSchemesView();

  @override
  State<_GovtSchemesView> createState() => _GovtSchemesViewState();
}

class _GovtSchemesViewState extends State<_GovtSchemesView> {
  bool _animateIn = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animateIn = true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openApply(GovtScheme scheme) async {
    final url = scheme.hasApplyUrl
        ? scheme.applyUrl
        : (scheme.hasWebsite ? scheme.website : '');
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('schemeApplyFailed')),
        ),
      );
    }
  }

  void _openDetail(GovtScheme scheme) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SchemeDetailScreen(scheme: scheme)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang =
        context.watch<LocalizationController>().locale.languageCode;
    final provider = context.watch<GovtSchemesProvider>();
    final schemes = provider.filteredSchemes;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final showBanner = provider.bannerSchemes.isNotEmpty &&
        provider.selectedCategoryEn == null &&
        provider.searchQuery.trim().isEmpty;

    return PakFasalScaffold(
      title: l10n.t('govtSchemes'),
      child: RefreshIndicator(
        onRefresh: () => provider.load(forceRefresh: true),
        color: AppColors.primaryGreen,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: context.pagePadding(bottom: 20).bottom,
          ),
          children: [
            _FadeSlideIn(
              animate: _animateIn,
              delayMs: 20,
              child: _SchemesScenicHeader(
                isDark: isDark,
                child: Padding(
                  padding: context.pagePadding(
                    horizontal: 14,
                    top: 12,
                    bottom: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('govtSchemesSubtitle'),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.85)
                              : const Color(0xFF3D4A3F),
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Material(
                        elevation: 3,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(28),
                        color: isDark
                            ? scheme.surfaceContainerHighest
                            : Colors.white,
                        child: TextField(
                          controller: _searchController,
                          onChanged: provider.setSearchQuery,
                          decoration: InputDecoration(
                            hintText: l10n.t('schemeSearchHint'),
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!provider.isLoading ||
                          provider.allSchemes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 1 + provider.categoryKeys.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final isAll = index == 0;
                              final catKey = isAll
                                  ? null
                                  : provider.categoryKeys[index - 1];
                              final selected =
                                  provider.selectedCategoryEn == catKey;
                              final label = isAll
                                  ? l10n.t('schemeCatAll')
                                  : provider.categoryLabel(catKey!, lang);
                              return FilterChip(
                                label: Text(label),
                                selected: selected,
                                showCheckmark: false,
                                onSelected: (_) =>
                                    provider.setCategoryEn(catKey),
                                selectedColor: AppColors.primaryGreen,
                                backgroundColor: isDark
                                    ? scheme.surfaceContainerHighest
                                        .withValues(alpha: 0.92)
                                    : Colors.white.withValues(alpha: 0.92),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : scheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.primaryGreen
                                      : scheme.outlineVariant
                                          .withValues(alpha: 0.55),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: context.pagePadding(horizontal: 14, top: 4, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBanner) ...[
                    const SizedBox(height: 10),
                    _FadeSlideIn(
                      animate: _animateIn,
                      delayMs: 110,
                      child: SchemeBannerSlider(
                        schemes: provider.bannerSchemes,
                        onTap: _openDetail,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _FadeSlideIn(
                    animate: _animateIn,
                    delayMs: 150,
                    child: Text(
                      l10n.t('schemePopular'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (provider.isLoading && provider.allSchemes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    )
                  else if (provider.hasError && provider.allSchemes.isEmpty)
                    ErrorStateCard(
                      onRetry: () => provider.load(forceRefresh: true),
                    )
                  else if (schemes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text(l10n.t('schemeNoResults'))),
                    )
                  else
                    ...List.generate(schemes.length, (index) {
                      final item = schemes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FadeSlideIn(
                          animate: _animateIn,
                          delayMs: (180 + (index * 35)).clamp(180, 520),
                          child: SchemeCard(
                            scheme: item,
                            languageCode: lang,
                            eligibleLabel: l10n.t('schemeEligible'),
                            viewDetailsLabel: l10n.t('schemeViewDetails'),
                            applyLabel: l10n.t('schemeApply'),
                            openDeadlineLabel: l10n.t('schemeDeadlineOpen'),
                            onViewDetails: () => _openDetail(item),
                            onApply: () => _openApply(item),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchemesScenicHeader extends StatelessWidget {
  const _SchemesScenicHeader({
    required this.child,
    required this.isDark,
  });

  final Widget child;
  final bool isDark;

  static const _asset =
      'assets/images/govt_schemes/schemes_header_bg.png';

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return ClipRRect(
      child: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : Colors.transparent,
                BlendMode.darken,
              ),
              child: Image.asset(
                _asset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scaffoldBg.withValues(alpha: isDark ? 0.35 : 0.18),
                    scaffoldBg.withValues(alpha: isDark ? 0.55 : 0.35),
                    scaffoldBg.withValues(alpha: isDark ? 0.92 : 0.88),
                    scaffoldBg,
                  ],
                  stops: const [0.0, 0.45, 0.82, 1.0],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.child,
    required this.animate,
    required this.delayMs,
  });

  final Widget child;
  final bool animate;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final delayFactor = (delayMs / 700).clamp(0.0, 0.6);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: animate ? 1 : 0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayed =
            ((value - delayFactor) / (1 - delayFactor)).clamp(0.0, 1.0);
        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - delayed)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
