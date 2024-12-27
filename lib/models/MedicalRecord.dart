class MedicalRecord {
  int? id;
  int userId;
  String recordType;
  Map<String, dynamic>? data;
  String? createdAt;
  String? updatedAt;

  MedicalRecord({
    this.id,
    required this.userId,
    required this.recordType,
    this.data,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) => MedicalRecord(
        id: json['id'],
        userId: json['user_id'],
        recordType: json['record_type'],
        data: json['data'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'record_type': recordType,
        'data': data,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
