import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/local_database.dart';
import '../models/person.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final LocalDatabase _db = LocalDatabase();
  List<Map<String, dynamic>> _upcomingHolidays = [];

  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  void _loadHolidays() {
    final persons = _db.getAllPersons();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<Map<String, dynamic>> temp = [];

    for (var person in persons) {
      for (var holiday in person.holidays) {
        if (holiday.date != null) {
          // Приводим праздник к текущему году
          DateTime holidayDate = DateTime(today.year, holiday.date!.month, holiday.date!.day);
          
          // Если дата в этом году уже прошла, праздник будет в следующем
          if (holidayDate.isBefore(today)) {
            holidayDate = DateTime(today.year + 1, holiday.date!.month, holiday.date!.day);
          }

          temp.add({
            'person': person,
            'holiday': holiday,
            'nextDate': holidayDate,
            'daysLeft': holidayDate.difference(today).inDays,
          });
        }
      }
    }

    // Сортируем: ближайшие праздники сверху
    temp.sort((a, b) => (a['nextDate'] as DateTime).compareTo(b['nextDate'] as DateTime));

    setState(() {
      _upcomingHolidays = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ближайшие события', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _upcomingHolidays.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Пока нет дат', style: TextStyle(color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _upcomingHolidays.length,
              itemBuilder: (context, index) {
                final item = _upcomingHolidays[index];
                final Person person = item['person'];
                final HolidayItem holiday = item['holiday'];
                final DateTime nextDate = item['nextDate'];
                final int daysLeft = item['daysLeft'];

                final bool isUrgent = daysLeft <= 7; // Подсвечиваем, если осталась неделя

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    border: isUrgent ? Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5) : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: person.avatarColor.withOpacity(0.2),
                      child: Icon(Icons.cake, color: person.avatarColor),
                    ),
                    title: Text(
                      '${person.name} — ${holiday.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(DateFormat('dd.MM.yyyy').format(nextDate), style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        if (holiday.giftIdea != null && holiday.giftIdea!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Идея: ${holiday.giftIdea}', style: const TextStyle(color: Colors.indigo)),
                        ],
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isUrgent ? Colors.redAccent.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        daysLeft == 0 ? 'Сегодня!' : 'Через $daysLeft дн.',
                        style: TextStyle(
                          color: isUrgent ? Colors.redAccent : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}