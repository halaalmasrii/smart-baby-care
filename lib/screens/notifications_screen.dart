import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLastUpdate();
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
          // 🍼 تذكير الرضاعة
          if (showFeedingReminder)
            Card(
              color: Colors.orange[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.local_drink, color: Colors.deepOrange),
                title: const Text("It’s been 3 hours since the last feeding."),
                subtitle: const Text("Recommended to feed your baby now."),
                trailing: TextButton(
                  onPressed: () {
                    setState(() {
                      showFeedingReminder = false;
                    });
                  },
                  child: const Text("Dismiss"),
                ),
                onTap: _handleFeedingReminderTap,
              ),
            ),

          const SizedBox(height: 20),

          // 📏 تذكير الطول والوزن
          if (daysSinceUpdate >= 7)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text("Please update your baby's height & weight."),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Update"),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),
          const Center(child: Text('Other Notifications Coming Soon...')),
        ],
      ),
    );
  }
}
