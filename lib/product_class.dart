class Product {
  final String name;
  final int actualCount;
  final int scanningCount;
  final DateTime date;
  final String section;

  Product({
    required this.name,
    required this.actualCount,
    required this.scanningCount,
    required this.date,
    required this.section,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'actualCount': actualCount,
      'scanningCount': scanningCount,
      'date': date.toIso8601String(),
      'section': section,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      actualCount: json['actualCount'],
      scanningCount: json['scanningCount'],
      date: DateTime.parse(json['date']),
      section: json['section'],
    );
  }
}