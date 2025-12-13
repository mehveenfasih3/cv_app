class Worker {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String section;
  final DateTime joinDate;

  Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.section,
    required this.joinDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'section': section,
      'joinDate': joinDate.toIso8601String(),
    };
  }

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      section: json['section'],
      joinDate: DateTime.parse(json['joinDate']),
    );
  }
}