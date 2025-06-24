import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String sleep;
  final String feeding;
  final String height;
  final String weight;
  final String babyName;

  const StatsCard({
    Key? key,
    required this.sleep,
    required this.feeding,
    required this.height,
    required this.weight,
    required this.babyName,
  }) : super(key: key);

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Today's ${babyName.endsWith('s') ? "$babyName'" : "$babyName's"} stats",
             style:  TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ), ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.bedtime, 'Sleep', sleep, primary),
                _buildStatItem(Icons.local_dining, 'Feeding', feeding, secondary),
                _buildStatItem(Icons.bar_chart, 'Height/Weight', '$height / $weight', primary),
              ],
            )
          ],
        ),
      ),
    );
  }
}
