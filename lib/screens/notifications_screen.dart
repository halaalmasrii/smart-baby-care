import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/appointment.dart';
import '../utils/routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<Appointment> upcomingAppointments = [];
  final DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeTimeZones();
    setupNotificationChannels();
    loadUpcomingAppointments();
    scheduleNotifications();
  }

  Future<void> initializeTimeZones() async {
    tz.initializeTimeZones();
    final location = tz.getLocation('Europe/Istanbul');
    tz.setLocalLocation(location);
  }

  Future<void> setupNotificationChannels() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const AndroidNotificationChannel feedingChannel = AndroidNotificationChannel(
      'feeding_channel',
      'Feeding Alerts',
      description: 'Alerts after 3 hours from last feeding',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(android: initializationSettingsAndroid),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && details.payload!.contains('feeding')) {
          Navigator.pushNamed(context, AppRoutes.schedule); // ✅ التنقل إلى شاشة الرضاعة
        }
      },
    );

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(feedingChannel);
    }
  }

  Future<void> loadUpcomingAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAppointments = prefs.getStringList('appointments') ?? [];

    setState(() {
      upcomingAppointments = savedAppointments
          .map((json) => Appointment.fromJson(jsonDecode(json)))
          .toList();
    });
  }

  Future<void> scheduleNotifications() async {
    for (final appointment in upcomingAppointments) {
      if (appointment.isNotificationDone) continue;

      final scheduledDate = appointment.date ?? DateTime.now();
      final scheduledTime = appointment.time ?? TimeOfDay.now();

      final tzDateTime = tz.TZDateTime.from(
        DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day,
            scheduledTime.hour, scheduledTime.minute),
        tz.local,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(appointment.id),
        getNotificationTitle(appointment.type),
        getNotificationBody(appointment.type),
        tzDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            appointment.type == AppointmentType.feeding
                ? 'feeding_channel'
                : 'general_channel',
            appointment.type == AppointmentType.feeding
                ? 'Feeding Alerts'
                : 'General Notifications',
            channelDescription: appointment.type == AppointmentType.feeding
                ? 'Alerts after 3 hours from last feeding'
                : 'General appointment alerts',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: appointment.type == AppointmentType.feeding
                ? RawResourceAndroidNotificationSound('notification_sound')
                : null,
            autoCancel: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: appointment.id,
      );
    }
  }

  String getNotificationTitle(AppointmentType type) {
    switch (type) {
      case AppointmentType.feeding:
        return 'Feeding Reminder';
      case AppointmentType.vaccine:
        return 'Vaccine Reminder';
      case AppointmentType.doctor:
        return 'Doctor Appointment';
      case AppointmentType.medicine:
        return 'Medicine Intake';
      default:
        return 'Appointment Reminder';
    }
  }

  String getNotificationBody(AppointmentType type) {
    switch (type) {
      case AppointmentType.feeding:
        return 'It\'s been 3 hours since the last feeding.';
      case AppointmentType.vaccine:
        return 'Don\'t forget your baby\'s vaccine appointment!';
      case AppointmentType.doctor:
        return 'Your medical consultation is coming up.';
      case AppointmentType.medicine:
        return 'It\'s time to give your baby their medicine.';
      default:
        return 'An appointment is scheduled soon.';
    }
  }

  Icon getAppointmentIcon(AppointmentType type, Color primaryColor) {
    switch (type) {
      case AppointmentType.vaccine:
        return Icon(Icons.vaccines, color: primaryColor);
      case AppointmentType.doctor:
        return Icon(Icons.person_pin_circle, color: primaryColor.withBlue(160));
      case AppointmentType.medicine:
        return Icon(Icons.medication, color: Colors.orangeAccent);
      case AppointmentType.feeding:
        return Icon(Icons.baby_changing_station, color: Colors.blueAccent);
      default:
        return const Icon(Icons.event, color: Colors.grey);
    }
  }

  Future<void> markAsDone(String id) async {
    await flutterLocalNotificationsPlugin.cancel(int.parse(id));

    final index = upcomingAppointments.indexWhere((appt) => appt.id == id);
    if (index != -1) {
      final appointment = upcomingAppointments[index];

      setState(() {
        upcomingAppointments[index] = appointment.copyWith(isNotificationDone: true);
      });

      // ✅ جدولة إشعار جديد بعد 3 ساعات في حالة Feeding
      if (appointment.type == AppointmentType.feeding) {
        final newReminderTime = appointment.lastFeeding?.add(const Duration(hours: 3)) ??
            DateTime.now().add(const Duration(hours: 3));

        final newAppointment = Appointment(
          id: 'feeding_${newReminderTime.millisecondsSinceEpoch}',
          type: AppointmentType.feeding,
          title: 'Feeding Reminder',
          date: newReminderTime,
          time: TimeOfDay.fromDateTime(newReminderTime),
          recurrence: 'every_3_hours',
          notifyAtTime: true,
          lastFeeding: newReminderTime,
        );

        setState(() {
          upcomingAppointments.add(newAppointment);
        });
      }

      final prefs = await SharedPreferences.getInstance();
      final updatedJsonList =
          upcomingAppointments.map((appt) => jsonEncode(appt.toJson())).toList();
      await prefs.setStringList('appointments', updatedJsonList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: upcomingAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = upcomingAppointments[index];
                  final timeUntil = appointment.date!
                      .difference(now)
                      .inHours
                      .abs()
                      .toString()
                      .padLeft(2, '0');

                  return Card(
                    color: appointment.isNotificationDone
                        ? Colors.grey[300]
                        : theme.cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      leading: getAppointmentIcon(appointment.type, color),
                      title: Text(
                        '${appointment.title} - ${getNotificationTitle(appointment.type)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              appointment.isNotificationDone ? Colors.grey : color,
                          decoration: appointment.isNotificationDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        'In $timeUntil hours • ${appointment.date!.toLocal().toString()}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => markAsDone(appointment.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appointment.isNotificationDone
                              ? Colors.grey
                              : theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 36),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'All upcoming reminders will appear here',
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}
