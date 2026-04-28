import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/offline_badge.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/repositories/youtube_learning_repository.dart';
import '../../domain/entities/learning_video.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final YouTubeLearningRepository _repository = YouTubeLearningRepository();
  final List<String> _categories = const ['Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Maize'];
  late String _selectedCategory;
  late Future<List<LearningVideo>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _videosFuture = _repository.fetchVideosByCategory(_selectedCategory);
  }

  Future<void> _refreshLearning() async {
    setState(() {
      _videosFuture = _repository.fetchVideosByCategory(
        _selectedCategory,
        forceRefresh: true,
      );
    });
    await _videosFuture;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PakFasalScaffold(
      title: l10n.t('learning'),
      child: RefreshIndicator(
        onRefresh: _refreshLearning,
        child: FutureBuilder<List<LearningVideo>>(
          future: _videosFuture,
          builder: (context, snapshot) {
            final videos = snapshot.data ?? [];

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.t('learningSubtitle'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories
                      .map(
                        (category) => ChoiceChip(
                          label: Text(_localizedCropName(l10n, category)),
                          selected: _selectedCategory == category,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                              _videosFuture = _repository.fetchVideosByCategory(
                                category,
                                forceRefresh: false,
                              );
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const LoadingStateCard(),
                if (snapshot.hasError)
                  ErrorStateCard(onRetry: _refreshLearning),
                if (!snapshot.hasError &&
                    snapshot.connectionState == ConnectionState.done &&
                    videos.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.t('learningEmpty')),
                    ),
                  ),
                if (videos.isNotEmpty) ...[
                  _FeaturedLearningCard(video: videos.first),
                  const SizedBox(height: 10),
                  ...videos
                      .skip(1)
                      .map((video) => _LearningVideoCard(video: video)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

String _localizedCropName(AppLocalizations l10n, String crop) {
  return switch (crop) {
    'Wheat' => l10n.t('cropWheat'),
    'Rice' => l10n.t('cropRice'),
    'Cotton' => l10n.t('cropCotton'),
    'Sugarcane' => l10n.t('cropSugarcane'),
    'Maize' => l10n.t('cropMaize'),
    _ => crop,
  };
}

class _FeaturedLearningCard extends StatelessWidget {
  const _FeaturedLearningCard({required this.video});

  final LearningVideo video;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: video.thumbnailUrl.isEmpty
                  ? Container(
                      color: Colors.green.withValues(alpha: 0.12),
                      child: const Icon(Icons.play_circle, size: 54),
                    )
                  : Image.network(video.thumbnailUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('featuredLearning'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        video.channelTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const OfflineBadge(isOffline: false, isCompact: true),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _openYoutube(context, video.youtubeUrl),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.t('watchNow')),
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
  const _LearningVideoCard({required this.video});

  final LearningVideo video;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat('d MMM y').format(video.publishedAt);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 86,
            height: 64,
            child: video.thumbnailUrl.isEmpty
                ? Container(
                    color: Colors.green.withValues(alpha: 0.1),
                    child: const Icon(Icons.ondemand_video),
                  )
                : Image.network(video.thumbnailUrl, fit: BoxFit.cover),
          ),
        ),
        title: Text(
          video.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              video.channelTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(date, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _openYoutube(context, video.youtubeUrl),
          icon: const Icon(Icons.open_in_new),
          tooltip: l10n.t('watchNow'),
        ),
      ),
    );
  }
}

Future<void> _openYoutube(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).t('couldNotOpenVideo'))),
    );
  }
}
