import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../widgets/custom_app_bar.dart';
import '../utils/routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  DateTime? lastUpdate;
  bool showFeedingReminder = true;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // ✅ تهيئة التايمزون
    _loadLastUpdate();
    _initializeNotifications();
    _scheduleFeedingNotification(); // ✅ جدولة الإشعار
  }

  Future<void> _loadLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_height_weight_update');
    if (timestamp != null) {
      setState(() {
        lastUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      });
    }
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload == 'feeding') {
          Navigator.pushNamed(context, AppRoutes.feeding);
        }
      },
    );
  }

  Future<void> _scheduleFeedingNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Feeding Reminder',
      'It’s been 3 hours since the last feeding.',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 3)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'feeding_channel',
          'Feeding Alerts',
          channelDescription: 'Alerts after 3 hours from last feeding',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'feeding',
    );
  }

  void _handleFeedingReminderTap() {
    Navigator.pushNamed(context, AppRoutes.feeding).then((_) {
      setState(() {
        showFeedingReminder = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysSinceUpdate = lastUpdate == null
        ? 999
        : DateTime.now().difference(lastUpdate!).inDays;

    return Scaffold(
      appBar: CustomAppBar(title: 'Notifications'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (showFeedingReminder) _buildNotificationCard(
            icon: Icons.local_drink,
            title: "It’s been 3 hours since the last feeding.",
            subtitle: "Recommended to feed your baby now.",
            buttonLabel: "Dismiss",
            onPressed: () => setState(() => showFeedingReminder = false),
            onTap: _handleFeedingReminderTap,
          ),

          const SizedBox(height: 16),

          if (daysSinceUpdate >= 7) _buildNotificationCard(
            icon: Icons.height,
            title: "Height & Weight Update Needed",
            subtitle: "Please update your baby's height and weight.",
            buttonLabel: "Update",
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),

          const SizedBox(height: 20),
          const Center(child: Text('Other Notifications Coming Soon...')),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: TextButton(onPressed: onPressed, child: Text(buttonLabel)),
        onTap: onTap,
      ),
    );
  }
}
