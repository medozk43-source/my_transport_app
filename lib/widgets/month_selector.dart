import 'package:flutter/material.dart';
import '../utils/date_helper.dart';

/// شريط أفقي لاختيار الشهر والسنة، يسمح بالتنقل بين الشهر الحالي
/// والشهور السابقة (الأرشيف) عبر أسهم يمين/يسار.
class MonthSelector extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final DateTime earliestAllowedMonth; // أقدم شهر مسموح بالرجوع إليه
  final ValueChanged<DateTime> onMonthChanged;

  const MonthSelector({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.earliestAllowedMonth,
    required this.onMonthChanged,
  });

  bool get _canGoBack {
    final current = DateTime(selectedYear, selectedMonth);
    final earliest = DateTime(earliestAllowedMonth.year, earliestAllowedMonth.month);
    return current.isAfter(earliest);
  }

  bool get _canGoForward {
    final now = DateTime.now();
    final current = DateTime(selectedYear, selectedMonth);
    final currentMonthOnly = DateTime(now.year, now.month);
    return current.isBefore(currentMonthOnly);
  }

  void _shift(int delta) {
    int year = selectedYear;
    int month = selectedMonth + delta;
    if (month > 12) {
      month = 1;
      year += 1;
    } else if (month < 1) {
      month = 12;
      year -= 1;
    }
    onMonthChanged(DateTime(year, month));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'الشهر السابق',
            onPressed: _canGoBack ? () => _shift(-1) : null,
          ),
          Column(
            children: [
              const Text('الشهر المحدد', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                DateHelper.monthYearLabel(selectedYear, selectedMonth),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'الشهر التالي',
            onPressed: _canGoForward ? () => _shift(1) : null,
          ),
        ],
      ),
    );
  }
}
