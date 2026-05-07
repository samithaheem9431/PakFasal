import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../domain/entities/learning_video.dart';

class YouTubeLearningRepository {
  String get _apiKey => AppConfig.youtubeApiKey;
  String get _channelId => AppConfig.youtubeChannelId;

  bool get isConfigured => AppConfig.hasYoutubeApiKey;

  /// Loads videos for every crop category in parallel, deduped by [LearningVideo.videoId].
  Future<List<LearningVideo>> fetchVideosForAllCategories({
    bool forceRefresh = false,
  }) async {
    const categories = [
      'Wheat',
      'Rice',
      'Cotton',
      'Sugarcane',
      'Maize',
    ];
    final lists = await Future.wait(
      categories.map(
        (c) => fetchVideosByCategory(c, forceRefresh: forceRefresh),
      ),
    );
    final byId = <String, LearningVideo>{};
    for (final list in lists) {
      for (final v in list) {
        byId.putIfAbsent(v.videoId, () => v);
      }
    }
    final merged = byId.values.toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return merged;
  }

  Future<List<LearningVideo>> fetchVideosByCategory(
    String category, {
    bool forceRefresh = false,
  }) async {
    final box = Hive.box('learning_cache');
    final cacheKey = 'videos_$category';
    final cached = box.get(cacheKey) as String?;
    final cachedPayload = cached != null ? _decodePayload(cached) : null;
    final cachedVideos = cachedPayload?.videos ?? const <LearningVideo>[];
    final cachedSource = cachedPayload?.source ?? 'live';

    if (!forceRefresh && cached != null && cached.isNotEmpty) {
      // If API key exists but cached content is demo, try live fetch again.
      final shouldUseCachedImmediately =
          _apiKey.isEmpty || cachedSource == 'live';
      if (shouldUseCachedImmediately && cachedVideos.isNotEmpty) {
        return cachedVideos;
      }
    }

    if (_apiKey.isEmpty) {
      final demo = _demoVideos(category);
      box.put(cacheKey, _toJson(demo, source: 'demo'));
      return demo;
    }

    try {
      final query = 'Pakistan farming $category';
      final uri = Uri.parse(
        '${AppConfig.youtubeApiBaseUrl}/search'
        '?part=snippet'
        '&type=video'
        '&maxResults=12'
        '&order=relevance'
        '&q=${Uri.encodeQueryComponent(query)}'
        '${_channelId.isNotEmpty ? '&channelId=$_channelId' : ''}'
        '&key=$_apiKey',
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        if (cachedVideos.isNotEmpty) return cachedVideos;
        final demo = _demoVideos(category);
        box.put(cacheKey, _toJson(demo, source: 'demo'));
        return demo;
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['items'] as List<dynamic>? ?? []);

      final parsed = items
          .map((item) {
            final map = item as Map<String, dynamic>;
            final id = map['id'] as Map<String, dynamic>? ?? {};
            final snippet = map['snippet'] as Map<String, dynamic>? ?? {};
            final thumbnails =
                snippet['thumbnails'] as Map<String, dynamic>? ?? {};
            final high = thumbnails['high'] as Map<String, dynamic>? ?? {};
            final medium = thumbnails['medium'] as Map<String, dynamic>? ?? {};

            final videoId = (id['videoId'] as String?) ?? '';
            if (videoId.isEmpty) return null;

            return LearningVideo(
              videoId: videoId,
              title: (snippet['title'] as String?) ?? 'Untitled',
              channelTitle: (snippet['channelTitle'] as String?) ?? 'Unknown',
              publishedAt:
                  DateTime.tryParse(
                    (snippet['publishedAt'] as String?) ?? '',
                  ) ??
                  DateTime.now(),
              thumbnailUrl:
                  (high['url'] as String?) ?? (medium['url'] as String?) ?? '',
              description: (snippet['description'] as String?) ?? '',
            );
          })
          .whereType<LearningVideo>()
          .toList();

      final result = parsed.isEmpty ? _demoVideos(category) : parsed;
      box.put(
        cacheKey,
        _toJson(result, source: parsed.isEmpty ? 'demo' : 'live'),
      );
      return result;
    } catch (_) {
      if (cachedVideos.isNotEmpty) return cachedVideos;
      final demo = _demoVideos(category);
      box.put(cacheKey, _toJson(demo, source: 'demo'));
      return demo;
    }
  }

  List<LearningVideo> _demoVideos(String category) {
    final now = DateTime.now();
    return [
      LearningVideo(
        videoId: 'dQw4w9WgXcQ',
        title: '$category Farming Basics for Pakistan',
        channelTitle: 'PakFasal Learning (Demo)',
        publishedAt: now.subtract(const Duration(days: 15)),
        thumbnailUrl: '',
        description: 'Demo content shown because YouTube API key is not set.',
      ),
      LearningVideo(
        videoId: 'J---aiyznGQ',
        title: '$category Water Management Tips',
        channelTitle: 'PakFasal Learning (Demo)',
        publishedAt: now.subtract(const Duration(days: 32)),
        thumbnailUrl: '',
        description: 'Configure YOUTUBE_API_KEY to load live videos.',
      ),
      LearningVideo(
        videoId: '9bZkp7q19f0',
        title: '$category Pest Control Guide',
        channelTitle: 'PakFasal Learning (Demo)',
        publishedAt: now.subtract(const Duration(days: 56)),
        thumbnailUrl: '',
        description: 'This is fallback local demo data.',
      ),
    ];
  }

  String _toJson(List<LearningVideo> videos, {required String source}) {
    return jsonEncode({
      'source': source,
      'videos': videos
          .map(
            (e) => {
              'videoId': e.videoId,
              'title': e.title,
              'channelTitle': e.channelTitle,
              'publishedAt': e.publishedAt.toIso8601String(),
              'thumbnailUrl': e.thumbnailUrl,
              'description': e.description,
            },
          )
          .toList(),
    });
  }

  _LearningCachePayload _decodePayload(String source) {
    final decoded = jsonDecode(source);

    // Backward compatibility for older cache format (just a list).
    if (decoded is List<dynamic>) {
      return _LearningCachePayload(source: 'demo', videos: _fromList(decoded));
    }

    if (decoded is Map<String, dynamic>) {
      final sourceLabel = (decoded['source'] as String?) ?? 'live';
      final list = (decoded['videos'] as List<dynamic>? ?? []);
      return _LearningCachePayload(
        source: sourceLabel,
        videos: _fromList(list),
      );
    }

    return const _LearningCachePayload(source: 'demo', videos: []);
  }

  List<LearningVideo> _fromList(List<dynamic> list) {
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return LearningVideo(
        videoId: (map['videoId'] as String?) ?? '',
        title: (map['title'] as String?) ?? '',
        channelTitle: (map['channelTitle'] as String?) ?? '',
        publishedAt:
            DateTime.tryParse((map['publishedAt'] as String?) ?? '') ??
            DateTime.now(),
        thumbnailUrl: (map['thumbnailUrl'] as String?) ?? '',
        description: (map['description'] as String?) ?? '',
      );
    }).toList();
  }
}

class _LearningCachePayload {
  const _LearningCachePayload({required this.source, required this.videos});

  final String source;
  final List<LearningVideo> videos;
}
