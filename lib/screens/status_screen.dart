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
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        isLoading = false;
      });
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
                    // رسم خطوط SD (-3 إلى +3)
                    LineChartBarData(
                      spots: getZScoreCurve(growthData!['gender'], x),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),

                    // نقطة الطفل
                    LineChartBarData(
                      spots: [FlSpot(x, y)],
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
                Text("X: $xLabel", style: TextStyle(fontSize: 12)),
                Text("Y: $yLabel", style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text("status: $status", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // وظيفة رسم خطوط Z-Score بناءً على الجنس والطول أو العمر
  List<FlSpot> getZScoreCurve(String gender, double xValue) {
    // هنا يمكنك استخدام بياناتك من Excel لرسم المنحنى
    // مثال: إن كان x هو العمر بالشهور، استخدم ملفات LHFA/WFA
    // وإن كان x هو الطول، استخدم ملفات WFL

    if (xValue <= 24) {
      // مثال: WFL (وزن حسب الطول)
      if (gender == 'male') {
        return [
          FlSpot(80, 10),
          FlSpot(85, 11.5),
          FlSpot(90, 13),
          FlSpot(95, 14.5),
          FlSpot(100, 16),
        ];
      } else {
        return [
          FlSpot(80, 9.8),
          FlSpot(85, 11.2),
          FlSpot(90, 12.8),
          FlSpot(95, 14.3),
          FlSpot(100, 15.8),
        ];
      }
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Growth Report")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : growthData == null
              ? const Center(child: Text("There is no data"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      buildChart(
                        "Height for age (LHFA)",
                        (growthData!['ageInMonths'] as num).toDouble(),
                        (growthData!['height'] as num).toDouble(),
                        "Age (Month)",
                        "Heghit (CM)",
                        growthData!['lhfa']['status'],
                      ),
                      buildChart(
                        "weight for age (WFA)",
                        (growthData!['ageInMonths'] as num).toDouble(),
                        (growthData!['weight'] as num).toDouble(),
                        "Age (Month)",
                        "Weight (Kg)",
                        growthData!['wfa']['status'],
                      ),
                      buildChart(
                        "Weight to height (WFL)",
                        (growthData!['height'] as num).toDouble(),
                        (growthData!['weight'] as num).toDouble(),
                        "Height (Cm)",
                        "Weight (Kg)",
                        growthData!['wfl']['status'],
                      ),
                    ],
                  ),
                ),
    );
  }
}