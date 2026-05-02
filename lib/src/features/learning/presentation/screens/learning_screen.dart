import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/offline_badge.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/repositories/youtube_learning_repository.dart';
import '../../domain/entities/learning_video.dart';

// ── Green palette ─────────────────────────────────────────────────────────────
// All values kept as local constants so the file is self-contained.
// They mirror AppColors to avoid import changes elsewhere.
class _G {
  static const forest     = Color(0xFF2E7D32);
  static const emerald    = Color(0xFF43A047);
  static const dark       = Color(0xFF1B5E20);
  static const tint       = Color(0xFFE8F5E9);
  static const border     = Color(0xFFC8E6C9);
  static const surface    = Color(0xFFF5F5F5);
  static const white      = Color(0xFFFFFFFF);
  static const textDark   = Color(0xFF212121);
  static const textGrey   = Color(0xFF757575);
  static const textLight  = Color(0xFF9E9E9E);
  static const yellow     = Color(0xFFFBC02D);
  static const brown      = Color(0xFF6D4C41);
  static const blue       = Color(0xFF29B6F6);
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

  // --- UNCHANGED LOGIC ---
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
  // -----------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PakFasalScaffold(
      title: l10n.t('learningYoutubeVideos'),
      child: RefreshIndicator(
        color: _G.forest,
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
                // ── Search field ──────────────────────────────────────
                _LearningSearchField(
                  controller: _searchController,
                  hint: l10n.t('learningSearchHint'),
                ),
                const SizedBox(height: 14),

                // ── Filter label ──────────────────────────────────────
                Text(
                  l10n.t('learningFilterByCrop'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _G.textGrey,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Category chips ────────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories
                        .map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CropChip(
                        label: _localizedCropName(l10n, category),
                        isSelected: _selectedCategory == category,
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

                // ── Loading ───────────────────────────────────────────
                if (snapshot.connectionState == ConnectionState.waiting)
                  const _GreenLoadingCard(),

                // ── Error ─────────────────────────────────────────────
                if (snapshot.hasError)
                  ErrorStateCard(onRetry: _refreshLearning),

                // ── Empty (no videos) ─────────────────────────────────
                if (!snapshot.hasError &&
                    snapshot.connectionState == ConnectionState.done &&
                    rawVideos.isEmpty)
                  _EmptyStateCard(message: l10n.t('learningEmpty')),

                // ── Empty (search no results) ─────────────────────────
                if (!snapshot.hasError &&
                    snapshot.connectionState == ConnectionState.done &&
                    rawVideos.isNotEmpty &&
                    videos.isEmpty &&
                    isSearching)
                  _EmptyStateCard(
                      message: l10n.t('learningNoSearchResults')),

                // ── Content ───────────────────────────────────────────
                if (!snapshot.hasError &&
                    snapshot.connectionState == ConnectionState.done &&
                    videos.isNotEmpty) ...[
                  if (showFeatured) ...[
                    _SectionHeader(
                      title: l10n.t('featuredLearning'),
                    ),
                    const SizedBox(height: 10),
                    _FeaturedLearningCard(
                      video: videos.first,
                      gradientColors: _categoryGradients[_selectedCategory] ??
                          const [_G.dark, _G.emerald],
                    ),
                    const SizedBox(height: 14),
                    if (videos.length > 1) ...[
                      _SectionHeader(
                        title: l10n.t('latest'),
                        count: videos.length - 1,
                      ),
                      const SizedBox(height: 10),
                      ...videos.skip(1).map(
                            (video) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LearningVideoCard(
                            video: video,
                            gradientColors:
                            _categoryGradients[_selectedCategory] ??
                                const [_G.dark, _G.emerald],
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    _SectionHeader(
                      title: l10n.t('latest'),
                      count: videos.length,
                    ),
                    const SizedBox(height: 10),
                    ...videos.map(
                          (video) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LearningVideoCard(
                          video: video,
                          gradientColors:
                          _categoryGradients[_selectedCategory] ??
                              const [_G.dark, _G.emerald],
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

// ── Search field ──────────────────────────────────────────────────────────────
class _LearningSearchField extends StatelessWidget {
  const _LearningSearchField({
    required this.controller,
    required this.hint,
  });

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: _G.textDark,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _G.textLight.withValues(alpha: 0.8)),
        prefixIcon: const Icon(Icons.search_rounded, color: _G.forest, size: 22),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip:
              MaterialLocalizations.of(context).deleteButtonTooltip,
              onPressed: controller.clear,
              icon: const Icon(Icons.close_rounded,
                  color: _G.textLight, size: 20),
            );
          },
        ),
        filled: true,
        fillColor: _G.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _G.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _G.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _G.forest, width: 2),
        ),
      ),
    );
  }
}

// ── Crop chip ──────────────────────────────────────────────────────────────────
class _CropChip extends StatelessWidget {
  const _CropChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _G.tint : _G.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? _G.forest : _G.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _G.forest.withValues(alpha: 0.12),
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
            color: isSelected ? _G.forest : _G.textGrey,
          ),
        ),
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _G.textDark,
            letterSpacing: 0.2,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 9, vertical: 2),
            decoration: BoxDecoration(
              color: _G.tint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _G.forest,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Green shimmer loading card ─────────────────────────────────────────────────
class _GreenLoadingCard extends StatelessWidget {
  const _GreenLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: i == 0 ? 180 : 80,
          decoration: BoxDecoration(
            color: _G.tint.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }),
    );
  }
}

// ── Empty state card ───────────────────────────────────────────────────────────
class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: _G.tint.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _G.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: _G.tint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: _G.forest,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: _G.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured card ──────────────────────────────────────────────────────────────
class _FeaturedLearningCard extends StatelessWidget {
  const _FeaturedLearningCard({
    required this.video,
    required this.gradientColors,
  });

  final LearningVideo video;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: _G.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: _G.forest.withValues(alpha: 0.22), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _G.forest.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail ──────────────────────────────────────────────
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
              // Gradient overlay
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
              // Watch Now button
              Positioned(
                bottom: 10,
                left: 12,
                child: GestureDetector(
                  onTap: () => _openYoutube(context, video.youtubeUrl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _G.forest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded,
                            color: _G.white, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          l10n.t('watchNow'),
                          style: const TextStyle(
                            color: _G.white,
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

          // ── Info section ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _G.textDark,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.verified_rounded,
                        size: 15, color: _G.forest),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        video.channelTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _G.textGrey,
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

// ── Video list card ────────────────────────────────────────────────────────────
class _LearningVideoCard extends StatelessWidget {
  const _LearningVideoCard({
    required this.video,
    required this.gradientColors,
  });

  final LearningVideo video;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat('d MMM y').format(video.publishedAt);

    return GestureDetector(
      onTap: () => _openYoutube(context, video.youtubeUrl),
      child: Container(
        decoration: BoxDecoration(
          color: _G.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _G.border),
          boxShadow: [
            BoxShadow(
              color: _G.forest.withValues(alpha: 0.05),
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
              // ── Thumbnail ─────────────────────────────────────────
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
                            color: _G.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Text info ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _G.textDark,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.tv_outlined,
                            size: 12, color: _G.textLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            video.channelTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _G.textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 11, color: _G.textLight),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 10,
                            color: _G.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Open icon ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.open_in_new_rounded,
                  color: _G.forest,
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

// ── Helpers ───────────────────────────────────────────────────────────────────
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
  final uri = Uri.parse(url);
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).t('couldNotOpenVideo')),
        backgroundColor: _G.forest,
      ),
    );
  }
}