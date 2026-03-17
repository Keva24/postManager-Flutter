import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/character_count_field.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;

  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;

  bool get _isEditMode => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.post?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.post?.body ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PostsProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    try {
      if (_isEditMode) {
        final updated = widget.post!.copyWith(title: title, body: body);
        await provider.updatePost(updated);
      } else {
        await provider.createPost(title: title, body: body);
      }
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Post' : 'New Post'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section label
              const Text(
                'POST DETAILS',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              // Title field
              CharacterCountField(
                controller: _titleCtrl,
                label: 'Title',
                maxLength: 100,
                maxLines: 2,
                hintText: 'Enter a concise post title',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Body field
              CharacterCountField(
                controller: _bodyCtrl,
                label: 'Body',
                maxLength: 500,
                maxLines: 9,
                hintText: 'Write your post content here...',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Body is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit button
              Consumer<PostsProvider>(
                builder: (ctx, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isSubmitting ? null : _submit,
                    child: provider.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditMode ? 'Save Changes' : 'Create Post'),
                  );
                },
              ),

              if (_isEditMode) ...[
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Changes are applied immediately via the API.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
