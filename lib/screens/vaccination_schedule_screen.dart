import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/appointment.dart';
import '../utils/theme_provider.dart';
import '../widgets/add_edit_appointment.dart';

class VaccinationScheduleScreen extends StatefulWidget {
  const VaccinationScheduleScreen({Key? key}) : super(key: key);

  @override
  State<VaccinationScheduleScreen> createState() => _VaccinationScheduleScreenState();
}

class _VaccinationScheduleScreenState extends State<VaccinationScheduleScreen> {
  final List<Appointment> _appointments = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeTimeZones();
    setupNotificationChannels();
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

  Future<void> scheduleNotification(Appointment appointment) async {
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
      getNotificationDetails(appointment.type),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: appointment.id,
    );
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

  NotificationDetails getNotificationDetails(AppointmentType type) {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'general_channel',
        'General Reminders',
        channelDescription: 'Appointment alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        autoCancel: true,
      ),
    );
  }

  Icon getAppointmentIcon(AppointmentType type, Color primaryColor) {
    switch (type) {
      case AppointmentType.vaccine:
        return Icon(Icons.vaccines, color: primaryColor);
      case AppointmentType.doctor:
        return Icon(Icons.person_pin_circle, color: primaryColor.withBlue(180));
      case AppointmentType.medicine:
        return Icon(Icons.medication, color: Colors.orangeAccent);
      default:
        return const Icon(Icons.event, color: Colors.grey);
    }
  }

  void _openAppointmentModal({Appointment? appointment, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditAppointmentModal(
        appointment: appointment,
        onSave: (newAppointment) {
          setState(() {
            if (index != null) {
              _appointments[index] = newAppointment;
            } else {
              _appointments.add(newAppointment);
            }
          });
          scheduleNotification(newAppointment);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final cardColor = theme.cardColor;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            tooltip: "Toggle Theme",
            onPressed: () {
              themeProvider.toggleTheme();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAppointmentModal(),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Appointment'),
      ),
      body: _appointments.isEmpty
          ? const Center(
              child: Text(
                'No appointments added yet.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                return Card(
                  color: cardColor,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: getAppointmentIcon(appointment.type, primaryColor),
                    title: Text(
                      appointment.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    subtitle: Text(
                      appointment.type == AppointmentType.vaccine
                          ? 'Date: ${appointment.date?.toLocal()}'
                          : appointment.type == AppointmentType.doctor
                              ? 'Date: ${appointment.date?.toLocal()} • Time: ${appointment.time?.format(context)}'
                              : 'Recurrence: ${appointment.recurrence} • Duration: ${appointment.durationDays} days',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _openAppointmentModal(appointment: appointment, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _appointments.removeAt(index);
                            });
                          },
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
