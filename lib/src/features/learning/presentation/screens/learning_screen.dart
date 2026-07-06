import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/offline_badge.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/repositories/youtube_learning_repository.dart';
import '../../domain/entities/learning_video.dart';
import '../widgets/learning_widgets.dart';

/// Theme-aware palette derived per build so the Learning surface flips
/// cleanly between light and dark modes. Uses the active [ColorScheme] so
/// branding stays consistent with the rest of the app.
class _LearningPalette {
  _LearningPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.surface,
    required this.surfaceMuted,
    required this.outline,
    required this.outlineSoft,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.onSurfaceFaded,
    required this.fallbackGradient,
  });

  factory _LearningPalette.of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _LearningPalette(
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      primaryContainer: scheme.primaryContainer,
      onPrimaryContainer: scheme.onPrimaryContainer,
      surface: scheme.surface,
      surfaceMuted: scheme.surfaceContainerHighest,
      outline: scheme.outline,
      outlineSoft: scheme.outlineVariant,
      onSurface: scheme.onSurface,
      onSurfaceMuted: scheme.onSurfaceVariant,
      onSurfaceFaded: scheme.onSurfaceVariant.withValues(alpha: 0.7),
      fallbackGradient: isDark
          ? const [Color(0xFF1B5E20), Color(0xFF66BB6A)]
          : const [Color(0xFF1B5E20), Color(0xFF43A047)],
    );
  }

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color surface;
  final Color surfaceMuted;
  final Color outline;
  final Color outlineSoft;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color onSurfaceFaded;
  final List<Color> fallbackGradient;
}

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final YouTubeLearningRepository _repository = YouTubeLearningRepository();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = const [
    'Wheat',
    'Rice',
    'Cotton',
    'Sugarcane',
    'Maize',
  ];

  /// Curated "popular searches" surfaced as one-tap chips. Each entry pairs a
  /// crop with a common problem area (disease / fertilizer / pest / sowing).
  /// The [query] is kept in English so the YouTube Data API returns the most
  /// relevant Pakistani agriculture content, while the label is localized.
  static const List<_SearchSuggestion> _suggestions = [
    _SearchSuggestion(crop: 'Wheat', topic: _SearchTopic.disease),
    _SearchSuggestion(crop: 'Wheat', topic: _SearchTopic.fertilizer),
    _SearchSuggestion(crop: 'Cotton', topic: _SearchTopic.disease),
    _SearchSuggestion(crop: 'Cotton', topic: _SearchTopic.pest),
    _SearchSuggestion(crop: 'Rice', topic: _SearchTopic.disease),
    _SearchSuggestion(crop: 'Rice', topic: _SearchTopic.fertilizer),
    _SearchSuggestion(crop: 'Cotton', topic: _SearchTopic.fertilizer),
    _SearchSuggestion(crop: 'Wheat', topic: _SearchTopic.sowing),
  ];

  Timer? _debounce;

  late String _selectedCategory;
  late Future<List<LearningVideo>> _videosFuture;
  String _searchQuery = '';

  // ── Icons per category for gradient thumbnails ───────────────────────────
  static const _categoryGradients = <String, List<Color>>{
    'Wheat':     [Color(0xFF1B5E20), Color(0xFF43A047)],
    'Rice':      [Color(0xFF00695C), Color(0xFF26A69A)],
    'Cotton':    [Color(0xFF6D4C41), Color(0xFF8D6E63)],
    'Sugarcane': [Color(0xFFF57F17), Color(0xFFFBC02D)],
    'Maize':     [Color(0xFFE65100), Color(0xFFFF8F00)],
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _videosFuture = _repository.fetchVideosByCategory(_selectedCategory);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Debounced live search. Typing runs a real YouTube search for the query
  /// (biased to Pakistani agriculture) after a short pause, so results reflect
  /// exactly what the farmer typed — e.g. "wheat rust", "cotton fertilizer".
  void _onSearchChanged() {
    final trimmed = _searchController.text.trim();
    _debounce?.cancel();

    if (trimmed.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        setState(() {
          _searchQuery = '';
          _videosFuture = _repository.fetchVideosByCategory(_selectedCategory);
        });
      }
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted || trimmed == _searchQuery) return;
      setState(() {
        _searchQuery = trimmed;
        _videosFuture = _repository.searchVideos(trimmed);
      });
    });
  }

  /// Immediately runs a search for a tapped suggestion / popular-search chip.
  void _runSearch(String query) {
    _debounce?.cancel();
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    FocusScope.of(context).unfocus();
    setState(() {
      _searchQuery = query;
      _videosFuture = _repository.searchVideos(query);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _videosFuture = _repository.fetchVideosByCategory(_selectedCategory);
    });
  }

  Future<void> _refreshLearning() async {
    setState(() {
      _videosFuture = _searchQuery.trim().isEmpty
          ? _repository.fetchVideosByCategory(
              _selectedCategory,
              forceRefresh: true,
            )
          : _repository.searchVideos(_searchQuery, forceRefresh: true);
    });
    await _videosFuture;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = _LearningPalette.of(context);

    return PakFasalScaffold(
      title: l10n.t('learningYoutubeVideos'),
      child: RefreshIndicator(
        color: palette.primary,
        onRefresh: _refreshLearning,
        child: FutureBuilder<List<LearningVideo>>(
          future: _videosFuture,
          builder: (context, snapshot) {
            final videos = snapshot.data ?? [];
            final isSearching = _searchQuery.trim().isNotEmpty;
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final isDone = snapshot.connectionState == ConnectionState.done;
            final gradient = isSearching
                ? palette.fallbackGradient
                : (_categoryGradients[_selectedCategory] ??
                      palette.fallbackGradient);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                LearningIntro(
                  title: l10n.t('learningIntroTitle'),
                  hint: l10n.t('learningIntroHint'),
                ),
                const SizedBox(height: 16),
                LearningSearchField(
                  controller: _searchController,
                  hint: l10n.t('learningSearchHint'),
                ),
                const SizedBox(height: 16),

                // ── Popular searches (browse mode only) ──────────────────
                if (!isSearching) ...[
                  _PopularSearches(
                    suggestions: _suggestions,
                    palette: palette,
                    gradients: _categoryGradients,
                    onTap: _runSearch,
                  ),
                  const SizedBox(height: 16),
                  LearningSectionLabel(l10n.t('learningFilterByCrop')),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories
                          .map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: LearningChip(
                                label: _localizedCropName(l10n, category),
                                isSelected: _selectedCategory == category,
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                    _searchQuery = '';
                                    _searchController.clear();
                                    _videosFuture = _repository
                                        .fetchVideosByCategory(category);
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // ── Search results header (search mode only) ─────────────
                if (isSearching) ...[
                  _SearchResultsHeader(
                    query: _searchQuery,
                    count: isDone ? videos.length : null,
                    isLoading: isLoading,
                    palette: palette,
                    onClear: _clearSearch,
                  ),
                  const SizedBox(height: 14),
                ],

                if (isLoading) const LearningListSkeleton(),

                if (snapshot.hasError) ErrorStateCard(onRetry: _refreshLearning),

                if (!snapshot.hasError && isDone && videos.isEmpty)
                  LearningEmptyCard(
                    message: isSearching
                        ? l10n.t('learningNoSearchResults')
                        : l10n.t('learningEmpty'),
                    icon: isSearching
                        ? Icons.search_off_rounded
                        : Icons.info_outline_rounded,
                  ),

                if (!snapshot.hasError && isDone && videos.isNotEmpty) ...[
                  if (!isSearching) ...[
                    _SectionHeader(
                      title: l10n.t('latest'),
                      count: videos.length,
                      palette: palette,
                    ),
                    const SizedBox(height: 12),
                  ],
                  ...videos.map(
                    (video) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _LearningVideoCard(
                        video: video,
                        gradientColors: gradient,
                        palette: palette,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.palette,
    this.count,
  });

  final String title;
  final int? count;
  final _LearningPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
            letterSpacing: 0.2,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 9, vertical: 2),
            decoration: BoxDecoration(
              color: palette.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: palette.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Large, full-width video card used for every result. A 16:9 thumbnail with
/// a gradient scrim, a date pill and a centered play button on top, followed
/// by the title, channel (verified) and a prominent "Watch Now" action.
class _LearningVideoCard extends StatelessWidget {
  const _LearningVideoCard({
    required this.video,
    required this.gradientColors,
    required this.palette,
  });

  final LearningVideo video;
  final List<Color> gradientColors;
  final _LearningPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat('d MMM y').format(video.publishedAt);

    return GestureDetector(
      onTap: () => _openYoutube(context, video.youtubeUrl),
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: palette.primary.withValues(alpha: 0.20), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: video.thumbnailUrl.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        )
                      : Image.network(
                          video.thumbnailUrl,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                // Centered play button
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.85),
                            width: 2),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                // Date pill
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 11, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: palette.onSurface,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          size: 15, color: palette.primary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.onSurfaceMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const OfflineBadge(isOffline: false, isCompact: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: palette.onPrimary, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              l10n.t('watchNow'),
                              style: TextStyle(
                                color: palette.onPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The kind of farming problem a popular-search chip targets. Each topic
/// carries the English keywords appended to the crop for the YouTube query,
/// the localization key for its display label, and an icon.
enum _SearchTopic {
  disease('disease treatment symptoms', 'learningTopicDisease',
      Icons.coronavirus_outlined),
  fertilizer('fertilizer schedule dose', 'learningTopicFertilizer',
      Icons.compost_rounded),
  pest('pest control spray', 'learningTopicPest', Icons.pest_control_rounded),
  sowing('sowing method time', 'learningTopicSowing', Icons.agriculture_rounded);

  const _SearchTopic(this.keywords, this.labelKey, this.icon);

  final String keywords;
  final String labelKey;
  final IconData icon;
}

/// A single curated popular-search entry (crop + topic).
class _SearchSuggestion {
  const _SearchSuggestion({required this.crop, required this.topic});

  final String crop;
  final _SearchTopic topic;

  /// English query sent to YouTube for best-quality results.
  String get query => '$crop ${topic.keywords}';

  /// Short, localized label shown on the chip, e.g. "Wheat · Diseases".
  String label(AppLocalizations l10n) =>
      '${_localizedCropName(l10n, crop)} · ${l10n.t(topic.labelKey)}';
}

/// Horizontally scrolling row of one-tap "popular searches", each styled with
/// the crop's brand gradient so wheat/cotton/rice topics are instantly
/// recognisable. Guides farmers straight to disease / fertilizer / pest videos.
class _PopularSearches extends StatelessWidget {
  const _PopularSearches({
    required this.suggestions,
    required this.palette,
    required this.gradients,
    required this.onTap,
  });

  final List<_SearchSuggestion> suggestions;
  final _LearningPalette palette;
  final Map<String, List<Color>> gradients;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up_rounded, size: 16, color: palette.primary),
            const SizedBox(width: 6),
            LearningSectionLabel(l10n.t('learningPopularSearches')),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: suggestions.map((s) {
              final colors =
                  gradients[s.crop] ?? palette.fallbackGradient;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _SuggestionChip(
                  label: s.label(l10n),
                  icon: s.topic.icon,
                  colors: colors,
                  onTap: () => onTap(s.query),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.28),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header shown while a live search is active: the query being searched, a
/// result count (or a spinner while loading) and a quick clear action.
class _SearchResultsHeader extends StatelessWidget {
  const _SearchResultsHeader({
    required this.query,
    required this.count,
    required this.isLoading,
    required this.palette,
    required this.onClear,
  });

  final String query;
  final int? count;
  final bool isLoading;
  final _LearningPalette palette;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.manage_search_rounded, size: 20, color: palette.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('learningSearchResultsFor', params: {'query': query}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: palette.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                if (isLoading)
                  Text(
                    l10n.t('learningSearching'),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: palette.onSurfaceMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else if (count != null)
                  Text(
                    l10n.t('learningResultCount', params: {'count': count}),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: palette.onSurfaceMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: palette.primary,
              ),
            )
          else
            TextButton.icon(
              onPressed: onClear,
              style: TextButton.styleFrom(
                foregroundColor: palette.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: Text(
                l10n.t('learningClearSearch'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _localizedCropName(AppLocalizations l10n, String crop) {
  return switch (crop) {
    'Wheat'     => l10n.t('cropWheat'),
    'Rice'      => l10n.t('cropRice'),
    'Cotton'    => l10n.t('cropCotton'),
    'Sugarcane' => l10n.t('cropSugarcane'),
    'Maize'     => l10n.t('cropMaize'),
    _           => crop,
  };
}

Future<void> _openYoutube(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    if (context.mounted) _showCouldNotOpen(context);
    return;
  }

  // Try, in order: external app (YouTube / browser), in-app web view, and
  // finally the platform default. Each individual launch can both return
  // false *and* throw a PlatformException when no handler is installed, so
  // we must guard every attempt.
  const modes = <LaunchMode>[
    LaunchMode.externalApplication,
    LaunchMode.inAppBrowserView,
    LaunchMode.platformDefault,
  ];

  for (final mode in modes) {
    try {
      if (await launchUrl(uri, mode: mode)) return;
    } catch (_) {
      // Try the next mode.
    }
  }

  if (context.mounted) _showCouldNotOpen(context);
}

void _showCouldNotOpen(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context).t('couldNotOpenVideo')),
      backgroundColor: scheme.primary,
    ),
  );
}
