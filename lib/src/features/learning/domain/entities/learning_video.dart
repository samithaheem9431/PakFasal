class LearningVideo {
  const LearningVideo({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.publishedAt,
    required this.thumbnailUrl,
    required this.description,
  });

  final String videoId;
  final String title;
  final String channelTitle;
  final DateTime publishedAt;
  final String thumbnailUrl;
  final String description;

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';
}
