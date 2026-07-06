import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/repositories/learning_articles_repository.dart';
import '../../domain/entities/learning_article_models.dart';
import '../widgets/learning_widgets.dart';
import 'article_detail_screen.dart';

/// List of learning articles with category filter chips and search.
/// Content is fetched live from Firestore (managed by the admin website).
/// Both languages are fetched once; switching the app's language re-renders
/// instantly without a re-fetch.
class LearningArticlesScreen extends StatefulWidget {
  const LearningArticlesScreen({super.key});

  @override
  State<LearningArticlesScreen> createState() =>
      _LearningArticlesScreenState();
}

class _LearningArticlesScreenState extends State<LearningArticlesScreen> {
  final LearningArticlesRepository _repository = LearningArticlesRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  late Future<List<LearningArticleEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchArticles();
    _searchController.addListener(() {
      final next = _searchController.text;
      if (_searchQuery == next) return;
      setState(() => _searchQuery = next);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = _repository.fetchArticles(forceRefresh: true);
    });
    await _future;
  }

  List<LearningArticleEntry> _filtered(
    List<LearningArticleEntry> articles,
    String languageCode,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    return articles.where((a) {
      if (_selectedCategory != null &&
          a.category(languageCode) != _selectedCategory) {
        return false;
      }
      if (query.isEmpty) return true;
      final haystack =
          '${a.title(languageCode)} ${a.summary(languageCode)} ${a.category(languageCode)}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode =
        context.watch<LocalizationController>().locale.languageCode;

    return PakFasalScaffold(
      title: l10n.t('learningOptionArticles'),
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<LearningArticleEntry>>(
          future: _future,
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final allArticles =
                snapshot.data ?? const <LearningArticleEntry>[];
            final articles = _filtered(allArticles, languageCode);
            final categories = <String>{
              for (final a in allArticles) a.category(languageCode),
            }.toList();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                LearningIntro(
                  title: l10n.t('articlesIntroTitle'),
                  hint: l10n.t('articlesIntroHint'),
                ),
                const SizedBox(height: 16),
                LearningSearchField(
                  controller: _searchController,
                  hint: l10n.t('articlesSearchHint'),
                ),
                const SizedBox(height: 14),
                LearningSectionLabel(l10n.t('articlesPickCategory')),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: LearningChip(
                          label: l10n.t('articlesAllCategory'),
                          isSelected: _selectedCategory == null,
                          onTap: () =>
                              setState(() => _selectedCategory = null),
                        ),
                      ),
                      ...categories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: LearningChip(
                            label: category,
                            isSelected: _selectedCategory == category,
                            onTap: () =>
                                setState(() => _selectedCategory = category),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (isLoading)
                  const LearningListSkeleton(featured: false)
                else if (snapshot.hasError)
                  ErrorStateCard(onRetry: _onRefresh)
                else if (articles.isEmpty)
                  LearningEmptyCard(message: l10n.t('articlesEmpty'))
                else
                  ...articles.map(
                    (article) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ArticleCard(
                        article: article,
                        languageCode: languageCode,
                        l10n: l10n,
                        onTap: () {
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ArticleDetailScreen(article: article),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.languageCode,
    required this.l10n,
    required this.onTap,
  });

  final LearningArticleEntry article;
  final String languageCode;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(article.icon, color: scheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.category(languageCode).toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      article.title(languageCode),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.summary(languageCode),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 12, color: scheme.onSurfaceVariant),
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
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
