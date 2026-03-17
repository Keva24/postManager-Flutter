import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/post_card.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/search_bar_widget.dart';

class PostsListScreen extends StatefulWidget {
  const PostsListScreen({super.key});

  @override
  State<PostsListScreen> createState() => _PostsListScreenState();
}

class _PostsListScreenState extends State<PostsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().loadPosts();
    });
  }

  Future<void> _handleDelete(BuildContext context, Post post) async {
    final provider = context.read<PostsProvider>();
    try {
      await provider.deletePost(post.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: provider.undoDelete,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete. Post restored.'),
        ),
      );
    }
  }

  Widget _buildSwipeBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 20),
          SizedBox(width: 6),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, PostsProvider provider) {
    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: provider.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: provider.posts.length,
        separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final post = provider.posts[index];
          return Dismissible(
            key: ValueKey(post.id),
            direction: DismissDirection.endToStart,
            background: _buildSwipeBackground(),
            confirmDismiss: (_) async {
              // Only allow swipe-to-delete for real (non-optimistic) posts
              return !post.isOptimistic;
            },
            onDismissed: (_) => _handleDelete(context, post),
            child: PostCard(
              post: post,
              onTap: () => Navigator.pushNamed(
                context,
                '/detail',
                arguments: post,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyView(PostsProvider provider) {
    final hasQuery = provider.searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off : Icons.inbox_outlined,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery
                  ? 'No posts match "${provider.searchQuery}"'
                  : 'No posts yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasQuery) ...[
              const SizedBox(height: 8),
              const Text(
                'Try a different search term.',
                style: TextStyle(fontSize: 13, color: AppColors.textHint),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, PostsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: provider.loadPosts,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PostsProvider provider) {
    if (provider.isLoading && provider.posts.isEmpty) {
      return const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 8),
          child: SkeletonList(),
        ),
      );
    }
    if (provider.error != null && provider.posts.isEmpty) {
      return _buildErrorView(context, provider);
    }
    if (provider.posts.isEmpty) {
      return _buildEmptyView(provider);
    }
    return _buildPostsList(context, provider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New post',
            onPressed: () => Navigator.pushNamed(context, '/form'),
          ),
        ],
      ),
      body: Consumer<PostsProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              const SearchBarWidget(),
              Expanded(child: _buildContent(context, provider)),
            ],
          );
        },
      ),
    );
  }
}
