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

  /// Runs a live YouTube search for an arbitrary query typed by the user
  /// (e.g. "wheat rust disease", "cotton fertilizer schedule"). The query is
  /// scoped to Pakistan farming so results stay on-topic, and each unique
  /// query is cached so repeated / offline searches resolve instantly.
  Future<List<LearningVideo>> searchVideos(
    String query, {
    bool forceRefresh = false,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <LearningVideo>[];

    final box = Hive.box('learning_cache');
    final normalized = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final cacheKey = 'search_v2_$normalized';
    final cached = box.get(cacheKey) as String?;
    final cachedPayload = cached != null ? _decodePayload(cached) : null;
    final cachedVideos = cachedPayload?.videos ?? const <LearningVideo>[];
    final cachedSource = cachedPayload?.source ?? 'live';

    // Without an API key, always serve the curated offline catalog so farmers
    // still get real agriculture videos (and stale meme demos are never kept).
    if (_apiKey.isEmpty) {
      final demo = _demoSearchVideos(trimmed);
      box.put(cacheKey, _toJson(demo, source: 'demo'));
      return demo;
    }

    if (!forceRefresh &&
        cached != null &&
        cached.isNotEmpty &&
        cachedSource == 'live' &&
        cachedVideos.isNotEmpty) {
      return cachedVideos;
    }

    try {
      // Bias the query towards Pakistani agriculture content so a search like
      // "disease" resolves to crop diseases rather than unrelated videos.
      final searchQuery = 'Pakistan farming agriculture $trimmed';
      final uri = Uri.parse(
        '${AppConfig.youtubeApiBaseUrl}/search'
        '?part=snippet'
        '&type=video'
        '&maxResults=20'
        '&order=relevance'
        '&q=${Uri.encodeQueryComponent(searchQuery)}'
        '${_channelId.isNotEmpty ? '&channelId=$_channelId' : ''}'
        '&key=$_apiKey',
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        if (cachedVideos.isNotEmpty) return cachedVideos;
        final demo = _demoSearchVideos(trimmed);
        box.put(cacheKey, _toJson(demo, source: 'demo'));
        return demo;
      }

      final parsed = _parseSearchResponse(response.body);
      final result = parsed.isEmpty ? _demoSearchVideos(trimmed) : parsed;
      box.put(
        cacheKey,
        _toJson(result, source: parsed.isEmpty ? 'demo' : 'live'),
      );
      return result;
    } catch (_) {
      if (cachedVideos.isNotEmpty) return cachedVideos;
      final demo = _demoSearchVideos(trimmed);
      box.put(cacheKey, _toJson(demo, source: 'demo'));
      return demo;
    }
  }

  Future<List<LearningVideo>> fetchVideosByCategory(
    String category, {
    bool forceRefresh = false,
  }) async {
    final box = Hive.box('learning_cache');
    final cacheKey = 'videos_v2_$category';
    final cached = box.get(cacheKey) as String?;
    final cachedPayload = cached != null ? _decodePayload(cached) : null;
    final cachedVideos = cachedPayload?.videos ?? const <LearningVideo>[];
    final cachedSource = cachedPayload?.source ?? 'live';

    // Offline curated catalog — skip Hive so updated video IDs ship immediately.
    if (_apiKey.isEmpty) {
      final demo = _demoVideos(category);
      box.put(cacheKey, _toJson(demo, source: 'demo'));
      return demo;
    }

    if (!forceRefresh &&
        cached != null &&
        cached.isNotEmpty &&
        cachedSource == 'live' &&
        cachedVideos.isNotEmpty) {
      return cachedVideos;
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

      final parsed = _parseSearchResponse(response.body);

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

  /// Parses a YouTube Data API `search` response body into videos, skipping
  /// any entries without a usable video id.
  List<LearningVideo> _parseSearchResponse(String body) {
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    final items = (json['items'] as List<dynamic>? ?? []);

    return items
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
                DateTime.tryParse((snippet['publishedAt'] as String?) ?? '') ??
                DateTime.now(),
            thumbnailUrl:
                (high['url'] as String?) ?? (medium['url'] as String?) ?? '',
            description: (snippet['description'] as String?) ?? '',
          );
        })
        .whereType<LearningVideo>()
        .toList();
  }

  /// Curated Pakistan-agriculture videos used when [YOUTUBE_API_KEY] is missing.
  /// Thumbnails use YouTube's public image CDN (no API key required).
  static String _thumb(String videoId) =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  List<LearningVideo> _demoSearchVideos(String query) {
    final q = query.toLowerCase();
    final all = <LearningVideo>[
      ..._demoVideos('Wheat'),
      ..._demoVideos('Rice'),
      ..._demoVideos('Cotton'),
      ..._demoVideos('Sugarcane'),
      ..._demoVideos('Maize'),
    ];

    final matched = all.where((v) {
      final hay = '${v.title} ${v.description} ${v.channelTitle}'.toLowerCase();
      return q.split(RegExp(r'\s+')).where((t) => t.length > 2).any(hay.contains);
    }).toList();

    if (matched.isNotEmpty) return matched;
    // Fall back to wheat catalog so search never looks empty offline.
    return _demoVideos('Wheat');
  }

  List<LearningVideo> _demoVideos(String category) {
    final now = DateTime.now();
    switch (category) {
      case 'Rice':
        return [
          LearningVideo(
            videoId: 'MGH5IEf830Q',
            title: 'Direct Seeded Rice Farming — Dryland Paddy Technique',
            channelTitle: 'Agriculture Learning',
            publishedAt: now.subtract(const Duration(days: 40)),
            thumbnailUrl: _thumb('MGH5IEf830Q'),
            description: 'Rice / dhan cultivation method for higher yield.',
          ),
          LearningVideo(
            videoId: 'jt5Yr9jZcOQ',
            title: 'Pakistan Agriculture Reforms — Farmer Perspective',
            channelTitle: 'PIDE Official',
            publishedAt: now.subtract(const Duration(days: 90)),
            thumbnailUrl: _thumb('jt5Yr9jZcOQ'),
            description: 'Crop planning context for Pakistani farmers.',
          ),
        ];
      case 'Cotton':
        return [
          LearningVideo(
            videoId: '3fKkQREo_mQ',
            title: 'Cotton Crop — How We Can Improve Cotton Yield',
            channelTitle: 'Agri Intel',
            publishedAt: now.subtract(const Duration(days: 55)),
            thumbnailUrl: _thumb('3fKkQREo_mQ'),
            description: 'Cotton / kapas management tips for Pakistan.',
          ),
          LearningVideo(
            videoId: 'jt5Yr9jZcOQ',
            title: 'Pakistan Agriculture Reforms — Cotton & Water',
            channelTitle: 'PIDE Official',
            publishedAt: now.subtract(const Duration(days: 90)),
            thumbnailUrl: _thumb('jt5Yr9jZcOQ'),
            description: 'Water and crop choice discussion for farmers.',
          ),
        ];
      case 'Sugarcane':
        return [
          LearningVideo(
            videoId: 'P3huKJqy6Xs',
            title: 'How to Grow Sugarcane in Pakistan — Management Guide',
            channelTitle: 'Agriculture Learning',
            publishedAt: now.subtract(const Duration(days: 70)),
            thumbnailUrl: _thumb('P3huKJqy6Xs'),
            description: 'Ganna / sugarcane cultivation steps.',
          ),
          LearningVideo(
            videoId: 'WhyDitkbmjA',
            title: 'Ganne Ki Kheti — Sugarcane Farming in Village Pakistan',
            channelTitle: 'Agriculture Learning',
            publishedAt: now.subtract(const Duration(days: 120)),
            thumbnailUrl: _thumb('WhyDitkbmjA'),
            description: 'Field-level sugarcane farming walkthrough.',
          ),
        ];
      case 'Maize':
        return [
          LearningVideo(
            videoId: 'O0KSZn5QuX0',
            title: 'Maize Growing Methods — Corn Cultivation Guide',
            channelTitle: 'Nature N Agriculture',
            publishedAt: now.subtract(const Duration(days: 60)),
            thumbnailUrl: _thumb('O0KSZn5QuX0'),
            description: 'Makai / maize cultivation techniques (Urdu/Hindi).',
          ),
          LearningVideo(
            videoId: 'jt5Yr9jZcOQ',
            title: 'Pakistan Agriculture Reforms — Crop Choices',
            channelTitle: 'PIDE Official',
            publishedAt: now.subtract(const Duration(days: 90)),
            thumbnailUrl: _thumb('jt5Yr9jZcOQ'),
            description: 'Broader farming economics for Pakistani growers.',
          ),
        ];
      case 'Wheat':
      default:
        return [
          LearningVideo(
            videoId: 'DAUHaMb2IW4',
            title: 'Effective Use of Potash in Wheat Crop',
            channelTitle: 'Crop Reformer',
            publishedAt: now.subtract(const Duration(days: 25)),
            thumbnailUrl: _thumb('DAUHaMb2IW4'),
            description: 'Wheat fertilizer guidance for Pakistani farmers.',
          ),
          LearningVideo(
            videoId: 'FOw9pfTMvcE',
            title: 'Wheat Production Plan — Complete Guide',
            channelTitle: 'Agriculture Learning',
            publishedAt: now.subtract(const Duration(days: 45)),
            thumbnailUrl: _thumb('FOw9pfTMvcE'),
            description: 'End-to-end wheat / gandum production planning.',
          ),
          LearningVideo(
            videoId: 'jZckwIwvQjU',
            title: 'How to Grow Wheat — Cultivation Basics',
            channelTitle: 'Agriculture Learning',
            publishedAt: now.subtract(const Duration(days: 80)),
            thumbnailUrl: _thumb('jZckwIwvQjU'),
            description: 'Sowing and crop care fundamentals for wheat.',
          ),
        ];
    }
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
