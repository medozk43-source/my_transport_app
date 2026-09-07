/// يمثل بيانات يوم واحد: مكان الدوام وقيمة المواصلات.
/// نستخدم Map بسيط للتخزين في Hive بدون الحاجة لتوليد أكواد إضافية (build_runner).
class DayRecord {
  final String location;
  final double transportCost;

  DayRecord({
    required this.location,
    required this.transportCost,
  });

  /// تحويل الكائن إلى Map لتخزينه في Hive
  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'cost': transportCost,
    };
  }

  /// إنشاء الكائن من Map مسترجعة من Hive
  factory DayRecord.fromMap(Map map) {
    return DayRecord(
      location: (map['location'] ?? '').toString(),
      transportCost: (map['cost'] is num) ? (map['cost'] as num).toDouble() : 0.0,
    );
  }

  bool get isEmpty => location.isEmpty && transportCost == 0.0;
}
