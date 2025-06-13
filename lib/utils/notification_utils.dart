import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import '../models/appointment.dart';

class NotificationUtils {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> scheduleNotification(Appointment appointment) async {
    final id = int.tryParse(appointment.id.replaceAll(RegExp(r'\D'), '')) ?? DateTime.now().millisecondsSinceEpoch;

    final scheduledDate = appointment.date ?? DateTime.now();
    final scheduledTime = appointment.time ?? TimeOfDay.now();

    final tzDateTime = tz.TZDateTime.from(
      DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      ),
      tz.local,
    );

    await _plugin.zonedSchedule(
      id,
      _getNotificationTitle(appointment.type),
      _getNotificationBody(appointment.type),
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'feeding_channel',
          'Feeding Alerts',
          channelDescription: 'Alerts after 3 hours from last feeding',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification_sound'), // اسم الصوت لديك
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: appointment.id,
    );
  }

  static String _getNotificationTitle(AppointmentType type) {
    switch (type) {
      case AppointmentType.feeding:
        return 'Feeding Reminder';
      case AppointmentType.vaccine:
        return 'Vaccine Reminder';
      case AppointmentType.doctor:
        return 'Doctor Appointment';
      case AppointmentType.medicine:
        return 'Medicine Reminder';
      default:
        return 'Reminder';
    }
  }

  static String _getNotificationBody(AppointmentType type) {
    switch (type) {
      case AppointmentType.feeding:
        return 'It\'s been 3 hours since the last feeding.';
      case AppointmentType.vaccine:
        return 'Don\'t forget the baby\'s vaccine.';
      case AppointmentType.doctor:
        return 'You have a doctor appointment soon.';
      case AppointmentType.medicine:
        return 'It\'s time for medicine.';
      default:
        return 'An event is coming.';
    }
  }
}
