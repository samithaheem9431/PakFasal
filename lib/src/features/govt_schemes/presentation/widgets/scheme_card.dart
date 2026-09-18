import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/govt_scheme.dart';

IconData schemeIconData(String icon) {
  return switch (icon) {
    'card' => Icons.credit_card,
    'shield' => Icons.health_and_safety_outlined,
    'bank' => Icons.account_balance_outlined,
    'seed' => Icons.eco_outlined,
    'water' => Icons.water_drop_outlined,
    'tractor' => Icons.agriculture_outlined,
    'school' => Icons.school_outlined,
    _ => Icons.spa_outlined,
  };
}

class SchemeCard extends StatefulWidget {
  const SchemeCard({
    super.key,
    required this.scheme,
    required this.languageCode,
    required this.eligibleLabel,
    required this.viewDetailsLabel,
    required this.applyLabel,
    required this.onViewDetails,
    required this.onApply,
    this.deadlineLabel = '',
    this.openDeadlineLabel = 'Open',
  });

  final GovtScheme scheme;
  final String languageCode;
  final String eligibleLabel;
  final String viewDetailsLabel;
  final String applyLabel;
  final VoidCallback onViewDetails;
  final VoidCallback onApply;
  final String deadlineLabel;
  final String openDeadlineLabel;

  @override
  State<SchemeCard> createState() => _SchemeCardState();
}

class _SchemeCardState extends State<SchemeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.scheme;
    final narrow = MediaQuery.sizeOf(context).width < 380;

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: Material(
        color: isDark ? scheme.surfaceContainerHighest : Colors.white,
        elevation: _pressed ? 1 : 2,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onViewDetails,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderRow(
                        item: item,
                        scheme: scheme,
                        languageCode: widget.languageCode,
                      ),
                      const SizedBox(height: 8),
                      _Body(
                        item: item,
                        languageCode: widget.languageCode,
                        eligibleLabel: widget.eligibleLabel,
                        openDeadlineLabel: widget.openDeadlineLabel,
                        muted: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 10),
                      _ActionButtons(
                        viewDetailsLabel: widget.viewDetailsLabel,
                        applyLabel: widget.applyLabel,
                        onViewDetails: widget.onViewDetails,
                        onApply: widget.onApply,
                        canApply: item.hasApplyUrl || item.hasWebsite,
                        stacked: false,
                        onSurface: scheme.onSurface,
                        outline: scheme.outlineVariant,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Thumb(item: item),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Body(
                          item: item,
                          languageCode: widget.languageCode,
                          eligibleLabel: widget.eligibleLabel,
                          openDeadlineLabel: widget.openDeadlineLabel,
                          muted: scheme.onSurfaceVariant,
                          titleStyle: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 96,
                        child: _ActionButtons(
                          viewDetailsLabel: widget.viewDetailsLabel,
                          applyLabel: widget.applyLabel,
                          onViewDetails: widget.onViewDetails,
                          onApply: widget.onApply,
                          canApply: item.hasApplyUrl || item.hasWebsite,
                          stacked: true,
                          onSurface: scheme.onSurface,
                          outline: scheme.outlineVariant,
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

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item});

  final GovtScheme item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 58,
        height: 58,
        child: item.hasImage
            ? CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => _iconFallback(item),
                errorWidget: (_, __, ___) => _iconFallback(item),
              )
            : _iconFallback(item),
      ),
    );
  }

  Widget _iconFallback(GovtScheme item) {
    return ColoredBox(
      color: AppColors.paleGreen,
      child: Icon(
        schemeIconData(item.iconKey),
        color: AppColors.primaryGreen,
        size: 28,
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.item,
    required this.scheme,
    required this.languageCode,
  });

  final GovtScheme item;
  final ColorScheme scheme;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Thumb(item: item),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title(languageCode),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.category(languageCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.item,
    required this.languageCode,
    required this.eligibleLabel,
    required this.openDeadlineLabel,
    required this.muted,
    this.titleStyle,
  });

  final GovtScheme item;
  final String languageCode;
  final String eligibleLabel;
  final String openDeadlineLabel;
  final Color muted;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final eligibility = item.eligibilityPreview(languageCode);
    final deadlineText = item.deadline.trim().isEmpty
        ? openDeadlineLabel
        : item.deadline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleStyle != null)
          Text(
            item.title(languageCode),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        if (titleStyle != null) const SizedBox(height: 4),
        Text(
          item.description(languageCode),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, height: 1.35, color: muted),
        ),
        if (eligibility.isNotEmpty) ...[
          const SizedBox(height: 8),
          _MetaRow(
            icon: Icons.people_outline,
            text: '$eligibleLabel: $eligibility',
            color: muted,
          ),
        ],
        const SizedBox(height: 4),
        _MetaRow(
          icon: Icons.calendar_today_outlined,
          text: deadlineText,
          color: muted,
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.viewDetailsLabel,
    required this.applyLabel,
    required this.onViewDetails,
    required this.onApply,
    required this.canApply,
    required this.stacked,
    required this.onSurface,
    required this.outline,
  });

  final String viewDetailsLabel;
  final String applyLabel;
  final VoidCallback onViewDetails;
  final VoidCallback onApply;
  final bool canApply;
  final bool stacked;
  final Color onSurface;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    final viewBtn = OutlinedButton(
      onPressed: onViewDetails,
      style: OutlinedButton.styleFrom(
        foregroundColor: onSurface,
        side: BorderSide(color: outline),
        padding: EdgeInsets.symmetric(
          vertical: stacked ? 8 : 8,
          horizontal: stacked ? 4 : 8,
        ),
        minimumSize: stacked ? const Size.fromHeight(34) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: TextStyle(
          fontSize: stacked ? 10.5 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(
        viewDetailsLabel,
        textAlign: TextAlign.center,
        maxLines: 2,
      ),
    );

    final applyBtn = FilledButton(
      onPressed: canApply ? onApply : null,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primaryGreen.withValues(alpha: 0.35),
        padding: EdgeInsets.symmetric(
          vertical: stacked ? 8 : 8,
          horizontal: stacked ? 4 : 8,
        ),
        minimumSize: stacked ? const Size.fromHeight(34) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: TextStyle(
          fontSize: stacked ? 11 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(applyLabel, textAlign: TextAlign.center),
    );

    if (stacked) {
      return Column(
        children: [
          viewBtn,
          const SizedBox(height: 8),
          applyBtn,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: viewBtn),
        const SizedBox(width: 8),
        Expanded(child: applyBtn),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: color, height: 1.3),
          ),
        ),
      ],
    );
  }
}
