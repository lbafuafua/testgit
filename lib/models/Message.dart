class Message {
  int? id;
  int chatRoomId;
  int senderId;
  String messageContent;
  String? sentAt;
  String messageType;
  String status;

  Message({
    this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.messageContent,
    this.sentAt,
    this.messageType = 'text',
    this.status = 'sent',
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        chatRoomId: json['chat_room_id'],
        senderId: json['sender_id'],
        messageContent: json['message_content'],
        sentAt: json['sent_at'],
        messageType: json['message_type'] ?? 'text',
        status: json['status'] ?? 'sent',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'chat_room_id': chatRoomId,
        'sender_id': senderId,
        'message_content': messageContent,
        'sent_at': sentAt,
        'message_type': messageType,
        'status': status,
      };
}
