import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../utils/notification_utils.dart';

class FeedingScheduleScreen extends StatefulWidget {
  const FeedingScheduleScreen({Key? key}) : super(key: key);

  @override
  State<FeedingScheduleScreen> createState() => _FeedingScheduleScreenState();
}

class _FeedingScheduleScreenState extends State<FeedingScheduleScreen> {
  final List<DateTime> feedings = [];

  Future<void> _addFeedingNow() async {
    final now = DateTime.now();
    final nextReminder = now.add(const Duration(hours: 3));

    setState(() {
      feedings.insert(0, now);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Feeding time added')),
    );

    await scheduleFeedingReminder(nextReminder, now);
  }

  Future<void> scheduleFeedingReminder(DateTime reminderTime, DateTime feedingTime) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('appointments') ?? [];
    final appointments = saved
        .map((json) => Appointment.fromJson(jsonDecode(json)))
        .toList();

    //  إنشاء تذكير رضاعة جديد
    final feedingReminder = Appointment(
      id: 'feeding_${feedingTime.millisecondsSinceEpoch}',
      type: AppointmentType.feeding,
      title: 'Feeding Reminder',
      date: reminderTime,
      time: TimeOfDay.fromDateTime(reminderTime),
      recurrence: 'every_3_hours',
      notifyAtTime: true,
      lastFeeding: feedingTime,
    );

    //  تحديث قائمة التذكيرات
    final updatedAppointments = [
      ...appointments.where((a) => a.type != AppointmentType.feeding),
      feedingReminder,
    ];

    //  حفظها
    final updatedJsonList =
        updatedAppointments.map((a) => jsonEncode(a.toJson())).toList();

    await prefs.setStringList('appointments', updatedJsonList);

    //  جدولة الإشعار فعلياً
    await NotificationUtils.scheduleNotification(feedingReminder);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Schedule'),
        backgroundColor: primary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFeedingNow,
        backgroundColor: primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Feeding'),
      ),
      body: feedings.isEmpty
          ? const Center(
              child: Text(
                'No feedings added yet.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedings.length,
              itemBuilder: (context, index) {
                final time = feedings[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.baby_changing_station),
                    title: Text(
                      'Feeding at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    ),
                    subtitle:
                        Text('${time.day}/${time.month}/${time.year}'),
                  ),
                );
              },
            ),
    );
  }
}
