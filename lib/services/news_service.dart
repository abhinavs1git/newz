
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String apiKey = '2164a41ccbb442088be114f985884431';
  final String apiUrl =
      'https://newsapi.org/v2';

  Future<List<dynamic>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/everything?q=farmers%20india&sortBy=publishedAt&apiKey=$apiKey'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['articles'];
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Failed to load news');
    }
  }
  Future<List<dynamic>> searchNews(String query) async {
    final response = await http.get(Uri.parse('$apiUrl/everything?q=farmers%20india%20$query&sortBy=publishedAt&apiKey=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['articles'];
    } else {
      throw Exception('Failed to search news');
    }
  }
}
