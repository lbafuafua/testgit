class ChatRoom {
  int? id;
  String name;
  String? createdAt;
  String type;

  ChatRoom({
    this.id,
    required this.name,
    this.createdAt,
    required this.type,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
        id: json['id'],
        name: json['name'],
        createdAt: json['created_at'],
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt,
        'type': type,
      };
}
