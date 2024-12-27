class GroupSanguin {
  int? id;
  String name; // e.g., "O+", "A-"

  GroupSanguin({this.id, required this.name});

  factory GroupSanguin.fromJson(Map<String, dynamic> json) {
    return GroupSanguin(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
