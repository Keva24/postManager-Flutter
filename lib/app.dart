import 'package:flutter/material.dart';
import 'models/post.dart';
import 'screens/post_detail_screen.dart';
import 'screens/post_form_screen.dart';
import 'screens/posts_list_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/fade_slide_route.dart';

class PostsManagerApp extends StatelessWidget {
  const PostsManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts Manager',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final Widget page;
        switch (settings.name) {
          case '/':
            page = const PostsListScreen();
          case '/detail':
            page = PostDetailScreen(post: settings.arguments as Post);
          case '/form':
            page = PostFormScreen(post: settings.arguments as Post?);
          default:
            return null;
        }
        return FadeSlideRoute(page: page);
      },
    );
  }
}
