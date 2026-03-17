import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static const String _base = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Request failed with status ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  Future<List<Post>> fetchPosts() async {
    final response = await _client.get(Uri.parse('$_base/posts'));
    _checkStatus(response);
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Post> fetchPost(int id) async {
    final response = await _client.get(Uri.parse('$_base/posts/$id'));
    _checkStatus(response);
    return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Post> createPost({
    required int userId,
    required String title,
    required String body,
  }) async {
    final response = await _client.post(
      Uri.parse('$_base/posts'),
      headers: _jsonHeaders,
      body: jsonEncode({'userId': userId, 'title': title, 'body': body}),
    );
    _checkStatus(response);
    return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Post> updatePost(Post post) async {
    final response = await _client.put(
      Uri.parse('$_base/posts/${post.id}'),
      headers: _jsonHeaders,
      body: jsonEncode(post.toJson()),
    );
    _checkStatus(response);
    return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deletePost(int id) async {
    final response =
        await _client.delete(Uri.parse('$_base/posts/$id'));
    _checkStatus(response);
  }

  void dispose() => _client.close();
}
