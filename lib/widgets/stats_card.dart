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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn(context, Icons.bedtime, 'Sleep', sleep),
            _buildStatColumn(context, Icons.baby_changing_station, 'Feeding', feeding),
            _buildStatColumn(context, Icons.height, 'Height', '$height cm'),
            _buildStatColumn(context, Icons.monitor_weight, 'Weight', '$weight kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, IconData icon, String label, String value) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}