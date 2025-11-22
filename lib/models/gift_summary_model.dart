class GiftSummary {
  final String name;
  final int total; // Ubah dari String ke int
  final String unit;
  final String description;

  GiftSummary({
    required this.name,
    required this.total, // Sekarang int
    required this.unit,
    required this.description,
  });

  factory GiftSummary.fromJson(Map<String, dynamic> json) {
    return GiftSummary(
      name: json['name']?.toString() ?? '', // Pastikan string
      total: _parseTotal(json['total']), // Handle berbagai tipe data
      unit: json['unit']?.toString() ?? 'Unit', // Pastikan string
      description: json['description']?.toString() ?? '', // Pastikan string
    );
  }

  // Helper method untuk parse total dari berbagai tipe
  static int _parseTotal(dynamic totalValue) {
    if (totalValue is int) {
      return totalValue;
    } else if (totalValue is String) {
      return int.tryParse(totalValue) ?? 0;
    } else if (totalValue is double) {
      return totalValue.toInt();
    } else {
      return 0;
    }
  }
}