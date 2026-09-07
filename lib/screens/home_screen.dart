import 'package:flutter/material.dart';
import '../models/day_record.dart';
import '../services/storage_service.dart';
import '../utils/date_helper.dart';
import '../widgets/day_selector.dart';
import '../widgets/month_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  // أقدم شهر يمكن الرجوع إليه في الأرشيف (نعطي هامش سنتين للخلف كحد افتراضي،
  // أو أقدم شهر يحتوي فعلياً على بيانات إن وُجد أقدم من ذلك)
  DateTime _earliestAllowedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDay = now.day;
    _computeEarliestAllowedMonth();
    _loadSelectedDay();
  }

  void _computeEarliestAllowedMonth() {
    final now = DateTime.now();
    final defaultEarliest = DateTime(now.year - 2, now.month); // هامش سنتين افتراضياً
    final recorded = StorageService.earliestRecordedMonth();
    if (recorded != null && recorded.isBefore(defaultEarliest)) {
      _earliestAllowedMonth = recorded;
    } else {
      _earliestAllowedMonth = defaultEarliest;
    }
  }

  void _loadSelectedDay() {
    final date = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final record = StorageService.getDay(date);
    _locationController.text = record.location;
    _costController.text = record.transportCost == 0.0 ? '' : record.transportCost.toString();
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _selectedYear = newMonth.year;
      _selectedMonth = newMonth.month;
      final maxDay = DateHelper.daysInMonth(_selectedYear, _selectedMonth);
      if (_selectedDay > maxDay) _selectedDay = maxDay;
      _loadSelectedDay();
    });
  }

  void _onDaySelected(int day) {
    setState(() {
      _selectedDay = day;
      _loadSelectedDay();
    });
  }

  void _saveCurrentDay() {
    final date = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final cost = double.tryParse(_costController.text.trim()) ?? 0.0;
    final record = DayRecord(
      location: _locationController.text.trim(),
      transportCost: cost,
    );

    StorageService.saveDay(date, record).then((_) {
      _computeEarliestAllowedMonth();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ بيانات اليوم بنجاح'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = StorageService.monthTotal(_selectedYear, _selectedMonth);
    final selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الدوام والمواصلات'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // شريط اختيار الشهر (يدعم الأرشيف)
            MonthSelector(
              selectedYear: _selectedYear,
              selectedMonth: _selectedMonth,
              earliestAllowedMonth: _earliestAllowedMonth,
              onMonthChanged: _onMonthChanged,
            ),
            const SizedBox(height: 16),

            // شريط أيام الشهر
            DaySelector(
              year: _selectedYear,
              month: _selectedMonth,
              selectedDay: _selectedDay,
              onDaySelected: _onDaySelected,
            ),
            const SizedBox(height: 20),

            // بطاقة إدخال بيانات اليوم المحدد
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'بيانات يوم ${selectedDate.day} ${DateHelper.arabicMonths[selectedDate.month - 1]}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _locationController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'موقع الدوام',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _costController,
                      textAlign: TextAlign.right,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'قيمة المواصلات',
                        prefixIcon: Icon(Icons.directions_car_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _saveCurrentDay,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('حفظ بيانات اليوم'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // بطاقة الإجمالي الشهري
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'إجمالي قيمة المواصلات لشهر ${DateHelper.monthYearLabel(_selectedYear, _selectedMonth)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      total.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _costController.dispose();
    super.dispose();
  }
}
