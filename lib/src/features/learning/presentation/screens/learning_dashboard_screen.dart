import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import 'learning_screen.dart';

/// Entry hub for all learning content. Opens dedicated flows per topic.
class LearningDashboardScreen extends StatefulWidget {
  const LearningDashboardScreen({super.key});

  @override
  State<LearningDashboardScreen> createState() =>
      _LearningDashboardScreenState();
}

class _LearningDashboardScreenState extends State<LearningDashboardScreen>
    with TickerProviderStateMixin {
  // ── Staggered entrance animations ────────────────────────────────────────
  late final AnimationController _headerCtrl;
  late final List<AnimationController> _cardCtrls;

  static const _cardCount = 4;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    _cardCtrls = List.generate(
      _cardCount,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      ),
    );

    for (var i = 0; i < _cardCount; i++) {
      Future.delayed(Duration(milliseconds: 200 + i * 75), () {
        if (mounted) _cardCtrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // --- UNCHANGED LOGIC ---
  void _showComingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('comingSoon'))),
    );
  }
  // -----------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final items = <_LearningOption>[
      _LearningOption(
        icon: Icons.play_circle_outline_rounded,
        titleKey: 'learningOptionYoutube',
        descKey: 'learningOptionYoutubeDesc',
        accentBg: scheme.primaryContainer,
        accentFg: scheme.primary,
        isActive: true,
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const LearningScreen(),
            ),
          );
        },
      ),
      _LearningOption(
        icon: Icons.article_outlined,
        titleKey: 'learningOptionArticles',
        descKey: 'learningOptionArticlesDesc',
        accentBg: const Color(0xFFE1F5FE),
        accentFg: AppColors.weatherBlue,
        onTap: () => _showComingSoon(context),
      ),
      _LearningOption(
        icon: Icons.bug_report_outlined,
        titleKey: 'learningOptionPests',
        descKey: 'learningOptionPestsDesc',
        accentBg: const Color(0xFFFFF8E1),
        accentFg: const Color(0xFFF9A825),
        onTap: () => _showComingSoon(context),
      ),
      _LearningOption(
        icon: Icons.eco_outlined,
        titleKey: 'learningOptionCropStages',
        descKey: 'learningOptionCropStagesDesc',
        accentBg: scheme.primaryContainer,
        accentFg: AppColors.darkGreen,
        onTap: () => _showComingSoon(context),
      ),
    ];

    return PakFasalScaffold(
      title: l10n.t('learning'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: ConstrainedBox(
              constraints:
              BoxConstraints(minHeight: constraints.maxHeight - 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header block ────────────────────────────────────
                  _AnimEntry(
                    controller: _headerCtrl,
                    slideBegin: const Offset(0, -0.10),
                    child: _HeaderBlock(
                      eyebrow: l10n.t('learningHubEyebrow'),
                      headline: l10n.t('learningHeadlineQuestion'),
                      hint: l10n.t('learningDashboardHint'),
                      textTheme: textTheme,
                      scheme: scheme,
                    ),
                  ),

                  // ── Divider ─────────────────────────────────────────
                  _AnimEntry(
                    controller: _headerCtrl,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1),
                    ),
                  ),

                  // ── Section label ───────────────────────────────────
                  _AnimEntry(
                    controller: _headerCtrl,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.t('learningTopicsLabel'),
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

                  // ── Cards grid ──────────────────────────────────────
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      // Slightly taller than 0.90 so card Column (text + badge) does not
                      // overflow on tight font metrics or accessibility text scale.
                      childAspectRatio: 0.88,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _AnimEntry(
                        controller: _cardCtrls[index],
                        slideBegin: const Offset(0, 0.15),
                        child: _LearningOptionCard(
                          option: items[index],
                          l10n: l10n,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Tip banner ──────────────────────────────────────
                  _AnimEntry(
                    controller: _cardCtrls.last,
                    child: _TipBanner(
                      l10n: l10n,
                      scheme: scheme,
                      textTheme: textTheme,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Fade + slide entry wrapper ────────────────────────────────────────────────
class _AnimEntry extends StatelessWidget {
  const _AnimEntry({
    required this.controller,
    required this.child,
    this.slideBegin = const Offset(0, 0.12),
  });

  final AnimationController controller;
  final Widget child;
  final Offset slideBegin;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );
    final slide = Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ── Header block ──────────────────────────────────────────────────────────────
class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({
    required this.eyebrow,
    required this.headline,
    required this.hint,
    required this.textTheme,
    required this.scheme,
  });

  final String eyebrow;
  final String headline;
  final String hint;
  final TextTheme textTheme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: scheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          headline,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hint,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Tip banner ─────────────────────────────────────────────────────────────────
class _TipBanner extends StatelessWidget {
  const _TipBanner({
    required this.l10n,
    required this.scheme,
    required this.textTheme,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.55,
                ),
                children: [
                  TextSpan(
                    text: l10n.t('learningTipBoldPrefix'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  TextSpan(text: l10n.t('learningTipRest')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model — unchanged ─────────────────────────────────────────────────────
class _LearningOption {
  const _LearningOption({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.accentBg,
    required this.accentFg,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String titleKey;
  final String descKey;
  final Color accentBg;
  final Color accentFg;
  final VoidCallback onTap;
  final bool isActive;
}

// ── Card widget ────────────────────────────────────────────────────────────────
class _LearningOptionCard extends StatefulWidget {
  const _LearningOptionCard({
    required this.option,
    required this.l10n,
  });

  final _LearningOption option;
  final AppLocalizations l10n;

  @override
  State<_LearningOptionCard> createState() => _LearningOptionCardState();
}

class _LearningOptionCardState extends State<_LearningOptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0,
      upperBound: 0.035,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) {
    setState(() => _pressed = true);
    _pressCtrl.forward();
  }

  void _up(TapUpDetails _) {
    setState(() => _pressed = false);
    _pressCtrl.reverse();
    widget.option.onTap();
  }

  void _cancel() {
    setState(() => _pressed = false);
    _pressCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final opt = widget.option;
    final scale = 1.0 - _pressCtrl.value;

    return Transform.scale(
      scale: scale,
      child: GestureDetector(
        onTapDown: _down,
        onTapUp: _up,
        onTapCancel: _cancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _pressed
                ? scheme.surfaceContainerHighest
                : scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: opt.isActive
                ? Border.all(color: scheme.primary, width: 1.5)
                : Border.all(
              color: _pressed
                  ? scheme.outlineVariant
                  : scheme.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: opt.accentFg.withValues(
                  alpha: _pressed ? 0.04 : 0.08,
                ),
                blurRadius: _pressed ? 4 : 14,
                offset: Offset(0, _pressed ? 2 : 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: icon + chevron ─────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: opt.accentBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        opt.icon,
                        size: 22,
                        color: opt.accentFg,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: opt.isActive
                          ? scheme.primary.withValues(alpha: 0.5)
                          : scheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                  ],
                ),

                const Spacer(),

                // ── Title + desc ────────────────────────────────────
                Text(
                  l10n.t(opt.titleKey),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.t(opt.descKey),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // ── Status badge ────────────────────────────────────
                if (opt.isActive)
                  _StatusPill(
                    label: l10n.t('learningStatusAvailable'),
                    isLive: true,
                    fg: scheme.primary,
                    bg: scheme.primaryContainer,
                  )
                else
                  _StatusPill(
                    label: l10n.t('comingSoon'),
                    fg: scheme.onSurfaceVariant,
                    bg: scheme.surfaceContainerHighest,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status pill ────────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.fg,
    required this.bg,
    this.isLive = false,
  });

  final String label;
  final Color fg;
  final Color bg;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fg,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}