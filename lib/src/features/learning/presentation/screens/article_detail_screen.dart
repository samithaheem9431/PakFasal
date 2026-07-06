import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/learning_article_models.dart';
import '../widgets/learning_widgets.dart';

/// Full reader view for one learning article. [article] carries both
/// languages; display text is resolved live from the current locale so
/// switching language updates this screen instantly, even while it's open.
class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  final LearningArticleEntry article;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final languageCode =
        context.watch<LocalizationController>().locale.languageCode;

    return PakFasalScaffold(
      title: article.category(languageCode),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          LearningDetailHeader(
            icon: article.icon,
            title: article.title(languageCode),
            subtitle: Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  l10n.t(
                    'articleReadTimeMinutes',
                    params: {'minutes': article.readTimeMinutes},
                  ),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              article.summary(languageCode),
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 22),
          ...article.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        margin: const EdgeInsets.only(top: 3, right: 10),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          section.heading(languageCode),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.body(languageCode),
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
