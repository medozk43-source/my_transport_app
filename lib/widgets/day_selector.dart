import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/date_helper.dart';

/// شريط أفقي قابل للتمرير يعرض كل أيام الشهر المحدد.
/// يظهر نقطة صغيرة تحت أي يوم يحتوي على بيانات محفوظة مسبقاً.
class DaySelector extends StatelessWidget {
  final int year;
  final int month;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const DaySelector({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final totalDays = DateHelper.daysInMonth(year, month);

    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalDays,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(year, month, day);
          final isSelected = day == selectedDay;
          final hasData = StorageService.hasData(date);

          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: Container(
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateHelper.weekdayLabel(date),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (hasData)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
