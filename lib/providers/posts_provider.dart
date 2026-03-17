import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostsProvider extends ChangeNotifier {
  final ApiService _apiService;

  PostsProvider({required ApiService apiService}) : _apiService = apiService;

  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String _searchQuery = '';

  // Undo state for optimistic delete
  Post? _lastDeleted;
  int? _lastDeletedIndex;
  Timer? _undoTimer;

  // --- Public getters ---

  List<Post> get posts => List.unmodifiable(_filteredPosts);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasUndo => _lastDeleted != null;

  // --- Filter ---

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredPosts = List.of(_posts);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredPosts = _posts.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.body.toLowerCase().contains(q);
      }).toList();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  // --- Load ---

  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _posts = await _apiService.fetchPosts();
      _applyFilter();
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _error = null;
    notifyListeners();
    try {
      _posts = await _apiService.fetchPosts();
      _applyFilter();
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      notifyListeners();
    }
  }

  // --- Delete (optimistic) ---

  Future<void> deletePost(int id) async {
    final idx = _posts.indexWhere((p) => p.id == id);
    if (idx == -1) return;

    _lastDeleted = _posts[idx];
    _lastDeletedIndex = idx;
    _posts.removeAt(idx);
    _applyFilter();
    notifyListeners();

    // Auto-clear undo state after 4.5 s if user does not act
    _undoTimer?.cancel();
    _undoTimer = Timer(const Duration(milliseconds: 4500), clearUndo);

    try {
      await _apiService.deletePost(id);
    } catch (e) {
      // Rollback
      _undoTimer?.cancel();
      _posts.insert(_lastDeletedIndex!, _lastDeleted!);
      _lastDeleted = null;
      _lastDeletedIndex = null;
      _applyFilter();
      notifyListeners();
      rethrow;
    }
  }

  void undoDelete() {
    _undoTimer?.cancel();
    if (_lastDeleted == null || _lastDeletedIndex == null) return;
    final insertIdx = _lastDeletedIndex!.clamp(0, _posts.length);
    _posts.insert(insertIdx, _lastDeleted!);
    _lastDeleted = null;
    _lastDeletedIndex = null;
    _applyFilter();
    notifyListeners();
  }

  void clearUndo() {
    _lastDeleted = null;
    _lastDeletedIndex = null;
  }

  // --- Create (optimistic) ---

  Future<Post> createPost({
    required String title,
    required String body,
  }) async {
    final optimistic =
        Post.optimistic(userId: 1, title: title, body: body);
    _posts.insert(0, optimistic);
    _applyFilter();
    _isSubmitting = true;
    notifyListeners();
    try {
      final real = await _apiService.createPost(
        userId: 1,
        title: title,
        body: body,
      );
      final oi = _posts.indexWhere((p) => p.id == optimistic.id);
      if (oi != -1) _posts[oi] = real;
      _applyFilter();
      return real;
    } catch (e) {
      // Remove optimistic on error
      _posts.removeWhere((p) => p.id == optimistic.id);
      _applyFilter();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // --- Update (optimistic) ---

  Future<void> updatePost(Post updated) async {
    final idx = _posts.indexWhere((p) => p.id == updated.id);
    final original = idx != -1 ? _posts[idx] : null;

    if (idx != -1) _posts[idx] = updated;
    _applyFilter();
    _isSubmitting = true;
    notifyListeners();
    try {
      final real = await _apiService.updatePost(updated);
      final ri = _posts.indexWhere((p) => p.id == real.id);
      if (ri != -1) _posts[ri] = real;
      _applyFilter();
    } catch (e) {
      // Rollback
      if (idx != -1 && original != null) _posts[idx] = original;
      _applyFilter();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // --- Helpers ---

  String _friendlyError(Object e) {
    if (e is ApiException) {
      if (e.statusCode != null) {
        return 'Server error (${e.statusCode}). Please try again.';
      }
      return e.message;
    }
    return 'Connection failed. Check your network and try again.';
  }

  @override
  void dispose() {
    _undoTimer?.cancel();
    _apiService.dispose();
    super.dispose();
  }
}
