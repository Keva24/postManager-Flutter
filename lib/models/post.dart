class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  Post copyWith({int? id, int? userId, String? title, String? body}) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  /// Creates a temporary optimistic post with a guaranteed-negative id
  /// so it can be distinguished from real API posts.
  factory Post.optimistic({
    required int userId,
    required String title,
    required String body,
  }) {
    return Post(
      id: -DateTime.now().millisecondsSinceEpoch,
      userId: userId,
      title: title,
      body: body,
    );
  }

  bool get isOptimistic => id < 0;

  @override
  bool operator ==(Object other) => other is Post && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
