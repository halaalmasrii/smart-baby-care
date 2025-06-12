import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/appointment.dart';

import 'dart:convert';

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

    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(android: initializationSettingsAndroid),
      onDidReceiveNotificationResponse: (details) {
        print('Notification tapped: ${details.payload}');
      },
    );
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
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'general_channel',
            'General Notifications',
            channelDescription: 'General alerts',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
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
      default:
        return const Icon(Icons.event, color: Colors.grey);
    }
  }

  void markAsDone(String id) {
    setState(() {
      upcomingAppointments.removeWhere((appt) => appt.id == id);
    });
    flutterLocalNotificationsPlugin.cancel(int.parse(id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Appointments'),
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
                    color: theme.cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: getAppointmentIcon(appointment.type, color),
                      title: Text(
                        '${appointment.title} - ${getNotificationTitle(appointment.type)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      subtitle: Text(
                        'In $timeUntil hours • ${appointment.date!.toLocal().toString()}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => markAsDone(appointment.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
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
