class Electrophoresis {
  int? id;
  String type; // e.g., "AA", "AS", "SS"

  Electrophoresis({this.id, required this.type});

  factory Electrophoresis.fromJson(Map<String, dynamic> json) {
    return Electrophoresis(
      id: json['id'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}
