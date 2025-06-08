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
  final int ageInWeeks = 64;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

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
        ],
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }

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
