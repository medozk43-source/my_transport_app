import 'package:hive_flutter/hive_flutter.dart';
import '../models/day_record.dart';
import '../utils/date_helper.dart';

/// خدمة التخزين المحلي باستخدام Hive.
/// كل يوم يُخزَّن بمفتاح فريد (yyyy-MM-dd) داخل صندوق واحد،
/// وهذا يجعل دعم أرشيف الشهور السابقة تلقائياً بدون أي عمل إضافي:
/// كل الشهور موجودة في نفس الصندوق ونقوم بفلترتها حسب الحاجة.
class StorageService {
  static const String boxName = 'day_records';

  static Box get _box => Hive.box(boxName);

  /// يجب استدعاؤها مرة واحدة عند بدء التطبيق قبل تشغيل runApp
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  /// حفظ بيانات يوم معين
  static Future<void> saveDay(DateTime date, DayRecord record) async {
    final key = DateHelper.dayKey(date.year, date.month, date.day);
    if (record.isEmpty) {
      // لا داعي لتخزين سجل فارغ بالكامل
      await _box.delete(key);
    } else {
      await _box.put(key, record.toMap());
    }
  }

  /// جلب بيانات يوم معين (أو سجل فارغ إن لم يوجد)
  static DayRecord getDay(DateTime date) {
    final key = DateHelper.dayKey(date.year, date.month, date.day);
    final raw = _box.get(key);
    if (raw == null) return DayRecord(location: '', transportCost: 0.0);
    return DayRecord.fromMap(Map.from(raw));
  }

  /// هل يوجد بيانات محفوظة ليوم معين (تُستخدم لوضع مؤشر بصري في شريط الأيام)
  static bool hasData(DateTime date) {
    final key = DateHelper.dayKey(date.year, date.month, date.day);
    return _box.containsKey(key);
  }

  /// إجمالي قيمة المواصلات لشهر وسنة معينين (يشمل الشهور الحالية والسابقة = الأرشيف)
  static double monthTotal(int year, int month) {
    final prefix = DateHelper.monthPrefix(year, month);
    double total = 0.0;
    for (final key in _box.keys) {
      if (key is String && key.startsWith(prefix)) {
        final raw = _box.get(key);
        if (raw != null) {
          total += DayRecord.fromMap(Map.from(raw)).transportCost;
        }
      }
    }
    return total;
  }

  /// أول شهر/سنة يحتوي على بيانات محفوظة (لتحديد أقدم نقطة في الأرشيف)
  /// يُرجع null إذا لم توجد أي بيانات بعد
  static DateTime? earliestRecordedMonth() {
    DateTime? earliest;
    for (final key in _box.keys) {
      if (key is String && key.length == 10) {
        final parts = key.split('-');
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (y != null && m != null) {
          final candidate = DateTime(y, m);
          if (earliest == null || candidate.isBefore(earliest)) {
            earliest = candidate;
          }
        }
      }
    }
    return earliest;
  }
}
