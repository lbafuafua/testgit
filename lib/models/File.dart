class File {
  int? id;
  int uploadedBy;
  int chatRoomId;
  String fileUrl;
  String uploadedAt;
  String fileType;

  File({
    this.id,
    required this.uploadedBy,
    required this.chatRoomId,
    required this.fileUrl,
    required this.uploadedAt,
    required this.fileType,
  });

  factory File.fromJson(Map<String, dynamic> json) => File(
        id: json['id'],
        uploadedBy: json['uploaded_by'],
        chatRoomId: json['chat_room_id'],
        fileUrl: json['file_url'],
        uploadedAt: json['uploaded_at'],
        fileType: json['file_type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'uploaded_by': uploadedBy,
        'chat_room_id': chatRoomId,
        'file_url': fileUrl,
        'uploaded_at': uploadedAt,
        'file_type': fileType,
      };
}
