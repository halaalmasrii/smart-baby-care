import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/stats_card.dart';
import '../widgets/notification_card.dart';
import '../widgets/custom_nav_bar.dart';
import '../utils/theme_provider.dart';
import '../utils/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? lastUpdate;
  final int ageInWeeks = 64; // ← يمكن تعديله لاحقاً حسب البيانات الفعلية

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
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final now = DateTime.now();
    final daysSinceUpdate = lastUpdate == null ? 999 : now.difference(lastUpdate!).inDays;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/baby.jpg'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Baby Layan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('$ageInWeeks weeks old',
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const StatsCard(),
          const SizedBox(height: 20),
          const NotificationCard(),
          const SizedBox(height: 20),

          // ✅ Today Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Today Baby Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Height: 68 cm"),
                Text("Weight: 7.5 kg"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ✅ المربعات الثلاثة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _featureBox(context, Icons.bedtime, "Sleep", () {
                Navigator.pushNamed(context, AppRoutes.sleepTimer);
              }),
              _featureBox(context, Icons.local_drink, "Feeding", () {
                Navigator.pushNamed(context, AppRoutes.feeding);
              }),
              _featureBox(context, Icons.vaccines, "Schedule", () {
                Navigator.pushNamed(context, AppRoutes.vaccines);
              }),
            ],
          ),

          const SizedBox(height: 20),

          // ✅ زر Status
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.status);
            },
            icon: const Icon(Icons.analytics),
            label: const Text("Status"),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 16),

          // ✅ إشعار تحديث الطول والوزن
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
                  const Expanded(
                    child: Text("Don't forget to update your baby's height & weight."),
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
        ],
      ),

      // ✅ تم استرجاع الشريط السفلي
      bottomNavigationBar: const CustomNavBar(),
    );
  }

  // 🔷 تصميم مربعات Sleep - Feeding - Schedule
  Widget _featureBox(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 90,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
