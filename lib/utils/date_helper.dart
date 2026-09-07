/// أدوات مساعدة للتعامل مع التواريخ وأسماء الأشهر بالعربي
class DateHelper {
  static const List<String> arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static const List<String> arabicWeekdays = [
    'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد',
  ];

  /// اسم الشهر بالعربي مع السنة، مثال: "أغسطس 2026"
  static String monthYearLabel(int year, int month) {
    return '${arabicMonths[month - 1]} $year';
  }

  /// اسم اليوم بالعربي المختصر بناءً على DateTime.weekday (1=إثنين ... 7=أحد)
  static String weekdayLabel(DateTime date) {
    return arabicWeekdays[date.weekday - 1];
  }

  /// عدد أيام شهر معين
  static int daysInMonth(int year, int month) {
    final firstDayNextMonth =
        (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    final lastDayThisMonth = firstDayNextMonth.subtract(const Duration(days: 1));
    return lastDayThisMonth.day;
  }

  /// مفتاح فريد لتخزين اليوم في قاعدة البيانات مثل "2026-08-31"
  static String dayKey(int year, int month, int day) {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }

  /// مفتاح الشهر (يُستخدم للفلترة السريعة) مثل "2026-08"
  static String monthPrefix(int year, int month) {
    final m = month.toString().padLeft(2, '0');
    return '$year-$m';
  }
}
