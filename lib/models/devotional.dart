class Devotional {
  final int id;
  final String title;
  final String content;
  final DateTime readAt;

  Devotional({
    required this.id,
    required this.title,
    required this.content,
    required this.readAt,
  });

  factory Devotional.fromJson(Map<String, dynamic> json) {
    return Devotional(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      readAt: DateTime.parse(json['read_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'read_at': readAt.toIso8601String(),
    };
  }
}
