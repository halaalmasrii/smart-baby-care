import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({Key? key}) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Map<String, dynamic>? growthData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGrowthData();
  }

  Future<void> fetchGrowthData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final babyId = authService.selectedBabyId;

    if (token == null || babyId == null) return;

    final uri = Uri.parse('http://localhost:3000/api/babies/growth-report/$babyId');

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          growthData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Error fetching growth report: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Widget buildChart(String title, double x, double y, String xLabel, String yLabel, String status) {
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
                      spots: [FlSpot(x, y)],
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
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
            ),
            const SizedBox(height: 8),
            Text("الحالة: $status", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Growth Report")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : growthData == null
              ? const Center(child: Text("لا يوجد بيانات"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      buildChart(
                        "الطول بالنسبة للعمر (LHFA)",
                        (growthData!['ageInMonths'] as num).toDouble(),
                        (growthData!['height'] as num).toDouble(),
                        "العمر (أشهر)",
                        "الطول (سم)",
                        growthData!['lhfa']['status'],
                      ),
                      buildChart(
                        "الوزن بالنسبة للعمر (WFA)",
                        (growthData!['ageInMonths'] as num).toDouble(),
                        (growthData!['weight'] as num).toDouble(),
                        "العمر (أشهر)",
                        "الوزن (كغ)",
                        growthData!['wfa']['status'],
                      ),
                      buildChart(
                        "الوزن بالنسبة للطول (WFL)",
                        (growthData!['height'] as num).toDouble(),
                        (growthData!['weight'] as num).toDouble(),
                        "الطول (سم)",
                        "الوزن (كغ)",
                        growthData!['wfl']['status'],
                      ),
                    ],
                  ),
                ),
    );
  }
}
