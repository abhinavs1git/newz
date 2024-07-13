// lib/models/news_article.dart
class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String author;
  final String content;
  final String urlToImage;
  final String source;

  NewsArticle({
    required this.title,
   
    required this.author,
    required this.description,
    required this.url,
    required this.content,
    required this.urlToImage,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      author: json['author'],
      title: json['title'],
      description: json['description'],
      content :json['content'],
      url: json['url'],
      urlToImage: json['urlToImage'] ??'',
      source: json['source']['name']
    );
  }
}
