import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/appointment.dart';
import '../utils/theme_provider.dart';
import '../widgets/add_edit_appointment.dart';
import '../services/auth_service.dart';
import '../utils/string_extensions.dart';

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
    fetchAppointmentsFromServer(); // جلب المواعيد عند بداية الصفحة
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> fetchAppointmentsFromServer() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final babyId = authService.selectedBabyId;
    if (token == null || babyId == null) return;

    final uri = Uri.parse('http://localhost:3000/api/babies/babies/appointments/$babyId');

    try {
      final response = await http.get(uri, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetched = List<Map<String, dynamic>>.from(data['appointments']);
        setState(() {
          _appointments.clear();
          _appointments.addAll(fetched.map((appt) => Appointment.fromJson(appt)));
        });
      } else {
        print("Error loading appointments: ${response.body}");
      }
    } catch (e) {
      print("Exception while fetching appointments: $e");
    }
  }

  Future<void> _createAppointmentOnServer(Appointment appointment) async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final token = authService.token;
  final babyId = authService.selectedBabyId;

  if (token == null || babyId == null) return;

  final uri = Uri.parse("http://localhost:3000/api/babies/babies/appointments/$babyId");

  try {
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "title": appointment.title,
        "type": appointment.type.name,
        "date": appointment.date?.toIso8601String(),
        "times": appointment.times.map((t) => "${t.hour}:${t.minute}").toList(), // ← هنا يتم التحويل
        "repeat": appointment.recurrence,
        "durationDays": appointment.durationDays,
        "notifyOneDayBefore": appointment.notifyOneDayBefore,
        "notifyAtTime": appointment.notifyAtTime,
      }),
    );

    if (response.statusCode == 201) {
      await fetchAppointmentsFromServer();
    } else {
      print("Failed to save: ${response.body}");
    }
  } catch (e) {
    print("Send error: $e");
  }
}

  Future<void> _deleteAppointmentFromServer(String id) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final uri = Uri.parse("http://localhost:3000/api/babies/appointments/$id");

    try {
      final response = await http.delete(uri, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode != 200) {
        print("Error deleting appointment: ${response.body}");
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }

  Future<void> scheduleNotification(Appointment appointment) async {
  // الموعد من نوع دواء لا يحتاج تاريخ للتنبيه، لكن يجب أن يحتوي أوقات.
  if ((appointment.type != AppointmentType.medicine && appointment.date == null) || appointment.times.isEmpty) {
    print('Skipping notification: Missing required date or times');
    return;
  }

  for (var time in appointment.times) {
    final tzDateTime = tz.TZDateTime.from(
      DateTime(
        appointment.date?.year ?? DateTime.now().year,
        appointment.date?.month ?? DateTime.now().month,
        appointment.date?.day ?? DateTime.now().day,
        time.hour,
        time.minute,
      ),
      tz.local,
    );

    final notificationId = int.parse('${appointment.id.hashCode}${time.hour}${time.minute}');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      getNotificationTitle(appointment.type),
      getNotificationBody(appointment.type),
      tzDateTime,
      getNotificationDetails(appointment.type),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: '${appointment.id}-${time.hour}:${time.minute}',
    );
  }
}


  void _openAppointmentModal({Appointment? appointment}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditAppointmentModal(
        appointment: appointment,
        onSave: (newAppointment) async {
          final String? appointmentId = newAppointment.id;
          if (appointmentId != null && appointmentId.isNotEmpty) {
            // تحديث موعد موجود
            await _updateAppointmentOnServer(newAppointment);
          } else {
            // إضافة موعد جديد
            await _createAppointmentOnServer(newAppointment);
          }
          scheduleNotification(newAppointment);
          fetchAppointmentsFromServer(); // لتحديث القائمة بعد الحفظ
        },
      ),
    );
  }

  Future<void> _updateAppointmentOnServer(Appointment appointment) async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final token = authService.token;
  final String? id = appointment.id;

  //تحقق أن ال id ليس null وطوله 24
  if (token == null || id == null || id.length != 24) {
    print("تم إلغاء التحديث: المعرف غير صالح");
    return;
  }

  final uri = Uri.parse("http://localhost:3000/api/babies/appointments/$id");

  try {
    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "title": appointment.title,
        "type": appointment.type.name,
        "date": appointment.date?.toIso8601String(),
        "times": appointment.times.map((t) => _formatTime(t)).toList(),
        "recurrence": appointment.recurrence,
        "durationDays": appointment.durationDays,
        "notifyOneDayBefore": appointment.notifyOneDayBefore,
        "notifyAtTime": appointment.notifyAtTime,
      }),
    );

    if (response.statusCode == 200) {
      print("Appointment updated successfully");
    } else {
      print("Failed to update appointment: ${response.body}");
    }
  } catch (e) {
    print("Update error: $e");
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
              child: Text('No appointments added yet.', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                final formattedDate = appointment.date != null
                    ? appointment.date!.toLocal().toString().split(" ")[0]
                    : 'No date';

                final timesText = appointment.times.isNotEmpty
                    ? appointment.times.map((t) => '${t.format(context)}').join(', ')
                    : '-';

                return Card(
                  color: cardColor,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: getAppointmentIcon(appointment.type, primaryColor),
                    title: Text(
                      '${appointment.type.name.capitalize()} • ${appointment.title}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: $formattedDate'),
                        if (appointment.times.isNotEmpty)
                          Text('Time(s): $timesText'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _openAppointmentModal(appointment: appointment),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _deleteAppointmentFromServer(appointment.id!);
                            setState(() => _appointments.removeAt(index));
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