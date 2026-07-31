import 'package:flutter/foundation.dart';

/// Modelo de noticia del API de Ocupa2.
class NewsModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime? createdAt;
  final String? url;
  final String? source;

  const NewsModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.createdAt,
    this.url,
    this.source,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? (json['title']?.hashCode ?? json['url']?.hashCode ?? UniqueKey().hashCode).toString(),
      title: json['title'] as String? ?? '',
      body: json['summary'] as String? ?? json['body'] as String? ?? json['content'] as String? ?? '',
      imageUrl: json['image'] as String? ?? json['imageUrl'] as String?,
      createdAt: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null),
      url: json['url'] as String?,
      source: json['source'] as String?,
    );
  }
}
