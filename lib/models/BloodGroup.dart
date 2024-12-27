class BloodGroup {
  String type; // Groupe ABO : A, B, AB, O
  bool isPositive; // Rhésus : vrai pour Rh+, faux pour Rh-

  BloodGroup({
    required this.type,
    required this.isPositive,
  });

  String get fullGroup => "$type${isPositive ? '+' : '-'}";

  bool isCompatibleWith(BloodGroup other) {
    if (type == 'O' && !isPositive) return true;
    if (type == 'AB' && isPositive) return true;
    bool isABOCompatible =
        (type == other.type) || (type == 'O') || (other.type == 'AB');
    bool isRhCompatible = !isPositive || other.isPositive;
    return isABOCompatible && isRhCompatible;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'is_positive': isPositive,
    };
  }

  factory BloodGroup.fromJson(Map<String, dynamic> json) {
    return BloodGroup(
      type: json['type'],
      isPositive: json['is_positive'],
    );
  }
}
