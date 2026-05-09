import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/offline_badge.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/repositories/youtube_learning_repository.dart';
import '../../domain/entities/learning_video.dart';

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
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final next = _searchController.text;
    if (_searchQuery == next) return;
    final hadSearch = _searchQuery.trim().isNotEmpty;
    final hasSearch = next.trim().isNotEmpty;
    setState(() {
      _searchQuery = next;
      if (hadSearch != hasSearch) {
        _videosFuture = hasSearch
            ? _repository.fetchVideosForAllCategories()
            : _repository.fetchVideosByCategory(_selectedCategory);
      }
    });
  }

  List<LearningVideo> _filterVideos(List<LearningVideo> videos) {
    final q = _searchQuery.trim();
    if (q.isEmpty) return videos;
    final tokens = q
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return videos;
    return videos.where((v) {
      final hay =
      '${v.title} ${v.channelTitle} ${v.description}'.toLowerCase();
      for (final t in tokens) {
        if (!hay.contains(t)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _refreshLearning() async {
    setState(() {
      _videosFuture = _searchQuery.trim().isEmpty
          ? _repository.fetchVideosByCategory(
        _selectedCategory,
        forceRefresh: true,
      )
          : _repository.fetchVideosForAllCategories(forceRefresh: true);
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
            final rawVideos = snapshot.data ?? [];
            final videos = _filterVideos(rawVideos);
            final isSearching = _searchQuery.trim().isNotEmpty;
            final showFeatured = !isSearching &&
                videos.isNotEmpty &&
                snapshot.connectionState == ConnectionState.done;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                _LearningSearchField(
                  controller: _searchController,
                  hint: l10n.t('learningSearchHint'),
                  palette: palette,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.t('learningFilterByCrop'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: palette.onSurfaceMuted,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories
                        .map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CropChip(
                        label: _localizedCropName(l10n, category),
                        isSelected: _selectedCategory == category,
                        palette: palette,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _searchController.clear();
                            _searchQuery = '';
                            _videosFuture = _repository
                                .fetchVideosByCategory(
                              category,
                              forceRefresh: false,
                            );
                          });
                        },
                      ),
                    ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 18),

                if (snapshot.connectionState == ConnectionState.waiting)
                  _LoadingPlaceholder(palette: palette),

                if (snapshot.hasError)
                  ErrorStateCard(onRetry: _refreshLearning),

                if (!snapshot.hasError &&
                    snapshot.connectionState == ConnectionState.done &&
                    rawVideos.isEmpty)
                  _EmptyStateCard(
                    message: l10n.t('learningEmpty'),
                    palette: palette,
                  ),

                if (!snapshot.hasError &&
                    snapshot.connectionState == ConnectionState.done &&
                    rawVideos.isNotEmpty &&
                    videos.isEmpty &&
                    isSearching)
                  _EmptyStateCard(
                    message: l10n.t('learningNoSearchResults'),
                    palette: palette,
                  ),

                if (!snapshot.hasError &&
                    snapshot.connectionState == ConnectionState.done &&
                    videos.isNotEmpty) ...[
                  if (showFeatured) ...[
                    _SectionHeader(
                      title: l10n.t('featuredLearning'),
                      palette: palette,
                    ),
                    const SizedBox(height: 10),
                    _FeaturedLearningCard(
                      video: videos.first,
                      gradientColors: _categoryGradients[_selectedCategory] ??
                          palette.fallbackGradient,
                      palette: palette,
                    ),
                    const SizedBox(height: 14),
                    if (videos.length > 1) ...[
                      _SectionHeader(
                        title: l10n.t('latest'),
                        count: videos.length - 1,
                        palette: palette,
                      ),
                      const SizedBox(height: 10),
                      ...videos.skip(1).map(
                            (video) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LearningVideoCard(
                            video: video,
                            gradientColors:
                            _categoryGradients[_selectedCategory] ??
                                palette.fallbackGradient,
                            palette: palette,
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    _SectionHeader(
                      title: l10n.t('latest'),
                      count: videos.length,
                      palette: palette,
                    ),
                    const SizedBox(height: 10),
                    ...videos.map(
                          (video) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LearningVideoCard(
                          video: video,
                          gradientColors:
                          _categoryGradients[_selectedCategory] ??
                              palette.fallbackGradient,
                          palette: palette,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LearningSearchField extends StatelessWidget {
  const _LearningSearchField({
    required this.controller,
    required this.hint,
    required this.palette,
  });

  final TextEditingController controller;
  final String hint;
  final _LearningPalette palette;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        color: palette.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: palette.onSurfaceFaded),
        prefixIcon: Icon(Icons.search_rounded, color: palette.primary, size: 22),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip:
              MaterialLocalizations.of(context).deleteButtonTooltip,
              onPressed: controller.clear,
              icon: Icon(Icons.close_rounded,
                  color: palette.onSurfaceMuted, size: 20),
            );
          },
        ),
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.outlineSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.outlineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
      ),
    );
  }
}

class _CropChip extends StatelessWidget {
  const _CropChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.palette,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final _LearningPalette palette;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? palette.primaryContainer : palette.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? palette.primary : palette.outlineSoft,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
            isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? palette.onPrimaryContainer
                : palette.onSurfaceMuted,
          ),
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

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder({required this.palette});

  final _LearningPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: i == 0 ? 180 : 80,
          decoration: BoxDecoration(
            color: palette.surfaceMuted.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.message,
    required this.palette,
  });

  final String message;
  final _LearningPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: palette.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: palette.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: palette.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: palette.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedLearningCard extends StatelessWidget {
  const _FeaturedLearningCard({
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
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: palette.primary.withValues(alpha: 0.22), width: 1.2),
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
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      size: 56,
                      color: Colors.white70,
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
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 12,
                child: GestureDetector(
                  onTap: () => _openYoutube(context, video.youtubeUrl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: palette.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            color: palette.onPrimary, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          l10n.t('watchNow'),
                          style: TextStyle(
                            color: palette.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    final date = DateFormat('d MMM y').format(video.publishedAt);

    return GestureDetector(
      onTap: () => _openYoutube(context, video.youtubeUrl),
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.outlineSoft),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 112,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      video.thumbnailUrl.isEmpty
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
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: palette.onSurface,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.tv_outlined,
                            size: 12, color: palette.onSurfaceFaded),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            video.channelTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.onSurfaceMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 11, color: palette.onSurfaceFaded),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 10,
                            color: palette.onSurfaceFaded,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.open_in_new_rounded,
                  color: palette.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
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
