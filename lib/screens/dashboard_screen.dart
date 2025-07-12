import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/stats_card.dart';
import '../widgets/custom_nav_bar.dart';
import '../utils/routes.dart';
import '../utils/theme_provider.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  List<Map<String, dynamic>> babies = [];
  int selectedBabyIndex = 0;

  String totalSleep = '--'; 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    fetchBabies();
    fetchTodayStats(); // استدعاء جلب الإحصائيات
  }

  Future<void> fetchBabies() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final uri = Uri.parse('http://localhost:3000/api/users/babies');

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final babyList = List<Map<String, dynamic>>.from(data['babies']);
        setState(() {
          babies = babyList;
          selectedBabyIndex = 0;
        });
        if (babyList.isNotEmpty) {
        authService.selectedBabyId = babyList[0]['_id'];
        print(" Baby selected automatically: ${authService.selectedBabyId}");
      }
      } else {
        print("Failed to fetch babies");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // تابع جلب عدد ساعات النوم من الباكند
  Future<void> fetchTodayStats() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    final uri = Uri.parse('http://localhost:3000/api/users/status/today');

    try {
      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sleepMinutes = data['sleep']['totalSleep'];
        final hours = (sleepMinutes / 60).toStringAsFixed(1);

        setState(() {
          totalSleep = '$hours hrs';
        });
      } else {
        print("Failed to fetch stats");
      }
    } catch (e) {
      print("Error fetching stats: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final selectedBaby = babies.isNotEmpty ? babies[selectedBabyIndex] : null;
    final babyName = selectedBaby?['name'] ?? 'No baby';
    final babyImage = (selectedBaby?['imageUrl'] ?? '').toString().isNotEmpty
        ? "http://localhost:3000/${selectedBaby?['imageUrl']}"
        : 'assets/default_baby.png';

    final birthDate = selectedBaby != null ? DateTime.parse(selectedBaby['birthDate']) : null;
    final ageInWeeks = birthDate != null ? DateTime.now().difference(birthDate).inDays ~/ 7 : 0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: color,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: babyImage.startsWith('http')
                    ? NetworkImage(babyImage)
                    : AssetImage(babyImage) as ImageProvider,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    value: babyName,
                    dropdownColor: color,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    iconEnabledColor: Colors.white,
                    underline: const SizedBox(),
                    items: babies.map<DropdownMenuItem<String>>((baby) {
                      final babyName = baby['name']?.toString() ?? 'Unnamed';
                      return DropdownMenuItem<String>(
                        value: babyName,
                        child: Text(
                          babyName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      final index = babies.indexWhere((b) => b['name'] == value);
                      if (index != -1) {
                        setState(() {
                          selectedBabyIndex = index;
                        });
                        //  تحديث selectedBabyId عند اختيار طفل جديد
                        final authService = Provider.of<AuthService>(context, listen: false);
                        authService.selectedBabyId = babies[index]['_id'];
                        print(" Switched to baby: ${authService.selectedBabyId}");
                      }
                    },
                  ),
                  Text(
                    '$ageInWeeks weeks old',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.color_lens, color: Colors.white),
              tooltip: "Toggle Theme",
              onPressed: () {
                themeProvider.toggleTheme();
              },
            )
          ],
        ),
      ),
      body: ScaleTransition(
        scale: _scaleAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StatsCard(
              sleep: totalSleep, // الربط مع القيمة الديناميكية
              feeding: '5 times',
              height: selectedBaby?['height']?.toString() ?? '--',
              weight: selectedBaby?['weight']?.toString() ?? '--',
              babyName: babyName,
            ),
            const SizedBox(height: 20),
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
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }

  Widget _featureBox(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
