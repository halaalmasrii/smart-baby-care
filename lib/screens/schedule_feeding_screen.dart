import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../utils/notification_utils.dart';
import '../services/auth_service.dart';

class FeedingScheduleScreen extends StatefulWidget {
  const FeedingScheduleScreen({Key? key}) : super(key: key);

  @override
  State<FeedingScheduleScreen> createState() => _FeedingScheduleScreenState();
}

class _FeedingScheduleScreenState extends State<FeedingScheduleScreen> {
  final List<DateTime> feedings = [];

  @override
  void initState() {
    super.initState();
    fetchFeedingsFromServer();
  }

  Future<void> fetchFeedingsFromServer() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final babyId = authService.selectedBabyId;

    if (token == null || babyId == null) {
      print(" Token or Baby ID is missing");
      return;
    }

    final uri = Uri.parse("http://localhost:3000/api/babies/feedings/$babyId");

    try {
      final response = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> feedingsJson = data['feedings'] ?? [];

        setState(() {
          feedings.clear();
          feedings.addAll(feedingsJson.map((f) => DateTime.parse(f['time'])));
        });
      } else {
        print("Failed to fetch feedings: ${response.body}");
      }
    } catch (e) {
      print("Error fetching feedings: $e");
    }
  }

  Future<void> _addFeedingNow() async {
    final now = DateTime.now();
    final nextReminder = now.add(const Duration(hours: 3));

    final success = await sendFeedingToServer(now);

    if (success) {
      setState(() {
        feedings.insert(0, now);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feeding time added')),
      );

      await scheduleFeedingReminder(nextReminder, now);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save feeding')),
      );
    }
  }

  Future<bool> sendFeedingToServer(DateTime now) async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final token = authService.token;
  final babyId = authService.selectedBabyId;
  final userId = authService.userId;

  if (token == null || babyId == null || userId == null) {
    print("Missing auth data");
    return false;
  }

  final uri = Uri.parse("http://localhost:3000/api/babies/feedings/$babyId");

  final body = {
    "user": userId,
    "title": "Feeding Reminder",
    "time": now.toIso8601String(),
    "recurrence": "every_3_hours",
    "notifyAtTime": true,
    "lastFeeding": now.toIso8601String(),
  };

  try {
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      print("Feeding saved successfully");
      return true;
    } else {
      print("Failed to save feeding: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Exception: $e");
    return false;
  }
}

  Future<void> scheduleFeedingReminder(DateTime reminderTime, DateTime feedingTime) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('appointments') ?? [];
    final appointments = saved
        .map((json) => Appointment.fromJson(jsonDecode(json)))
        .toList();

    final reminder = Appointment(
      type: AppointmentType.feeding,
      title: 'Feeding Reminder',
      date: reminderTime,
      times: [TimeOfDay.fromDateTime(reminderTime)],
      recurrence: 'every_3_hours',
      notifyAtTime: true,
      lastFeeding: feedingTime,
    );

    final updated = [
      ...appointments.where((a) => a.type != AppointmentType.feeding),
      reminder,
    ];

    final updatedJson = updated.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('appointments', updatedJson);
    await NotificationUtils.scheduleNotification(reminder);
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
                    subtitle: Text('${time.day}/${time.month}/${time.year}'),
                  ),
                );
              },
            ),
    );
  }
}
