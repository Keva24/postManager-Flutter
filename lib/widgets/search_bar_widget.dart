import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../theme/app_colors.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _ctrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) context.read<PostsProvider>().setSearchQuery(val);
    });
    // Force rebuild to show/hide clear button
    setState(() {});
  }

  void _clear() {
    _ctrl.clear();
    _debounce?.cancel();
    context.read<PostsProvider>().setSearchQuery('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostsProvider>();
    final hasQuery = _ctrl.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.search,
                    color: AppColors.textHint,
                    size: 18,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onChanged: _onChanged,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search posts...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      filled: false,
                    ),
                  ),
                ),
                if (hasQuery)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    color: AppColors.textHint,
                    onPressed: _clear,
                    splashRadius: 16,
                  ),
              ],
            ),
          ),
        ),
        if (provider.searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 16, 0),
            child: Text(
              '${provider.posts.length} result${provider.posts.length == 1 ? '' : 's'} '
              'for "${provider.searchQuery}"',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
