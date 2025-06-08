import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatusScreen extends StatelessWidget {
  StatusScreen({Key? key}) : super(key: key);

  List<FlSpot> heightWeightData = const [
    FlSpot(68, 7.5),
    FlSpot(70, 8.1),
    FlSpot(72, 8.9),
    FlSpot(74, 9.4),
  ];

  List<FlSpot> heightAgeData = const [
    FlSpot(8, 68),
    FlSpot(12, 70),
    FlSpot(16, 72),
    FlSpot(20, 74),
  ];

  List<FlSpot> weightAgeData = const [
    FlSpot(8, 7.5),
    FlSpot(12, 8.1),
    FlSpot(16, 8.9),
    FlSpot(20, 9.4),
  ];

  Widget buildChart(String title, List<FlSpot> data, String xLabel, String yLabel) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("X: $xLabel", style: const TextStyle(fontSize: 12)),
                Text("Y: $yLabel", style: const TextStyle(fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Baby Status")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildChart("Height vs Weight", heightWeightData, "Height (cm)", "Weight (kg)"),
            buildChart("Height vs Age", heightAgeData, "Age (weeks)", "Height (cm)"),
            buildChart("Weight vs Age", weightAgeData, "Age (weeks)", "Weight (kg)"),
          ],
        ),
      ),
    );
  }
}
