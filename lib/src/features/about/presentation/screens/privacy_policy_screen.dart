import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/privacy_policy_content.dart';

/// In-app Privacy Policy (Play User Data policy: accessible inside the app).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url, String failKey) async {
    final messenger = ScaffoldMessenger.of(context);
    final fail = AppLocalizations.of(context).t(failKey);
    final uri = Uri.tryParse(url);
    if (uri == null) {
      messenger.showSnackBar(SnackBar(content: Text(fail)));
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(fail)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final sections = PrivacyPolicyContent.sectionsFor(l10n.locale.languageCode);

    return PakFasalScaffold(
      title: l10n.t('privacyPolicyTitle'),
      showBottomNavigation: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            l10n.t(
              'privacyPolicyUpdated',
              params: {'date': PrivacyPolicyContent.lastUpdated},
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.t('privacyPolicyIntro'),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 8),
          ...sections.map(
            (s) => Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.white : AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => _openUrl(
              context,
              AppConfig.privacyPolicyUrl,
              'aboutCouldNotOpenLink',
            ),
            icon: const Icon(Icons.open_in_browser_rounded, size: 18),
            label: Text(l10n.t('privacyPolicyOpenOnline')),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openUrl(
              context,
              AppConfig.accountDeletionUrl,
              'aboutCouldNotOpenLink',
            ),
            icon: const Icon(Icons.delete_forever_outlined, size: 18),
            label: Text(l10n.t('accountDeletionWebLink')),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  isDark ? AppColors.white : AppColors.primaryGreen,
              side: BorderSide(
                color: (isDark ? AppColors.white : AppColors.primaryGreen)
                    .withValues(alpha: 0.45),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
