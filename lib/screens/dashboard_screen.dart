import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/stats_card.dart';
import '../widgets/notification_card.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/theme_provider.dart';
import '../utils/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? lastUpdate;

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isFemale = themeProvider.isFemaleTheme;

    final now = DateTime.now();
    final daysSinceUpdate = lastUpdate == null ? 999 : now.difference(lastUpdate!).inDays;

    return Scaffold(
      appBar: CustomAppBar(title: 'Dashboard'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const StatsCard(),
          const SizedBox(height: 20),
          const NotificationCard(),
          const SizedBox(height: 20),

          // ✅ زر الوصول إلى Feeding Schedule
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.feeding);
            },
            icon: const Icon(Icons.local_drink),
            label: const Text("Feeding Schedule"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ✅ إشعار لتحديث الطول والوزن إذا مر أكثر من أسبوع
          if (daysSinceUpdate >= 7)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  Expanded(child: Text("Don't forget to update your baby's height & weight.")),
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
        ],
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
