/// Modelo de video educativo del API de Ocupa2.
class VideoModel {
  final String id;
  final String title;
  final String? description;
  final String url;
  final String? thumbnailUrl;

  const VideoModel({
    required this.id,
    required this.title,
    this.description,
    required this.url,
    this.thumbnailUrl,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      url: json['url'] as String? ?? '',
      thumbnailUrl:
          json['thumbnailUrl'] as String? ?? json['thumbnail'] as String?,
    );
  }

  /// Intenta extraer el ID de YouTube del URL para construir thumbnail.
  String? get youtubeThumbnailUrl {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return thumbnailUrl;
    }
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regExp.firstMatch(url);
    if (match != null) {
      final videoId = match.group(1);
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return null;
  }
}
