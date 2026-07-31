/// Modelo de noticia del API de Ocupa2.
class NewsModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime? createdAt;

  const NewsModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.createdAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
