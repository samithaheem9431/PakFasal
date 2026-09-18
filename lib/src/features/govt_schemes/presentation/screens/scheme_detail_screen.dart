import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/layout/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/govt_scheme.dart';
import '../widgets/scheme_card.dart';

class SchemeDetailScreen extends StatelessWidget {
  const SchemeDetailScreen({super.key, required this.scheme});

  final GovtScheme scheme;

  Future<void> _openUrl(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('schemeApplyFailed'))),
      );
    }
  }

  Future<void> _apply(BuildContext context) async {
    final url = scheme.hasApplyUrl
        ? scheme.applyUrl
        : (scheme.hasWebsite ? scheme.website : '');
    if (url.isEmpty) return;
    await _openUrl(context, url);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang =
        context.watch<LocalizationController>().locale.languageCode;
    final colorScheme = Theme.of(context).colorScheme;
    final benefits = scheme.benefits(lang);
    final eligibility = scheme.eligibility(lang);
    final deadlineText = scheme.deadline.trim().isEmpty
        ? l10n.t('schemeDeadlineOpen')
        : scheme.deadline;

    return PakFasalScaffold(
      title: l10n.t('schemeDetailTitle'),
      child: ListView(
        padding: context.pagePadding(horizontal: 16, top: 12, bottom: 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: scheme.hasImage
                  ? CachedNetworkImage(
                      imageUrl: scheme.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.paleGreen),
                      errorWidget: (_, __, ___) => _ImageFallback(scheme: scheme),
                    )
                  : _ImageFallback(scheme: scheme),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            scheme.title(lang),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (scheme.category(lang).trim().isNotEmpty)
                _Chip(label: scheme.category(lang)),
              if (scheme.province.trim().isNotEmpty)
                _Chip(
                  label: scheme.province,
                  icon: Icons.location_on_outlined,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            scheme.description(lang),
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (scheme.department(lang).trim().isNotEmpty)
            _InfoTile(
              icon: Icons.account_balance_outlined,
              label: l10n.t('schemeDepartment'),
              value: scheme.department(lang),
            ),
          if (scheme.department(lang).trim().isNotEmpty)
            const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.calendar_today_outlined,
            label: l10n.t('schemeDeadline'),
            value: deadlineText,
          ),
          if (eligibility.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              l10n.t('schemeEligibilityTitle'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...eligibility.map((e) => _Bullet(text: e)),
          ],
          if (benefits.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              l10n.t('schemeBenefits'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...benefits.map((b) => _Bullet(text: b)),
          ],
          const SizedBox(height: 20),
          if (scheme.hasApplyUrl || scheme.hasWebsite)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _apply(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.t('schemeApplyNow'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          if (scheme.hasWebsite &&
              scheme.hasApplyUrl &&
              scheme.website != scheme.applyUrl) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openUrl(context, scheme.website),
                icon: const Icon(Icons.language, size: 18),
                label: Text(l10n.t('schemeVisitWebsite')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.scheme});

  final GovtScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.paleGreen,
      child: Icon(
        schemeIconData(scheme.iconKey),
        size: 48,
        color: AppColors.primaryGreen,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.primaryGreen),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 18,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHighest : AppColors.softSurfaceGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
