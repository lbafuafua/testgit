class Notification {
  int? id;
  int userId;
  String content;
  String createdAt;
  String status;

  Notification({
    this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.status = 'unread',
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json['id'],
        userId: json['user_id'],
        content: json['content'],
        createdAt: json['created_at'],
        status: json['status'] ?? 'unread',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'content': content,
        'created_at': createdAt,
        'status': status,
      };
}
