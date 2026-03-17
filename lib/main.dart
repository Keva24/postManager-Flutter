import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/posts_provider.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PostsProvider(apiService: ApiService()),
      child: const PostsManagerApp(),
    ),
  );
}
