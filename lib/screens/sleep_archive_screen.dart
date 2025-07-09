import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SleepArchiveScreen extends StatefulWidget {
  const SleepArchiveScreen({Key? key}) : super(key: key);

  @override
  State<SleepArchiveScreen> createState() => _SleepArchiveScreenState();
}

class _SleepArchiveScreenState extends State<SleepArchiveScreen> {
  List<Map<String, dynamic>> archivedSessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArchivedSleepSessions();
  }

  Future<void> fetchArchivedSleepSessions() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final babyId = authService.selectedBabyId;

    final uri = Uri.parse('http://localhost:3000/api/users/sleep');

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allSessions = List<Map<String, dynamic>>.from(data['sleepSessions']);

        // استبعاد جلسات اليوم الحالي
        final today = DateTime.now();
        today.subtract(Duration(
          hours: today.hour,
          minutes: today.minute,
          seconds: today.second,
          milliseconds: today.millisecond,
        ));

        setState(() {
          archivedSessions = allSessions.where((session) {
            final start = DateTime.parse(session['startTime']);
            return start.day != today.day ||
                start.month != today.month ||
                start.year != today.year;
          }).toList();
          isLoading = false;
        });
      } else {
        print("Error loading sleep archive");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Archive Error: $e");
      setState(() => isLoading = false);
    }
  }

  String _formatTime(String timestamp) {
    final time = DateTime.parse(timestamp);
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Archive")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : archivedSessions.isEmpty
              ? const Center(child: Text("No archived sessions found."))
              : ListView.builder(
                  itemCount: archivedSessions.length,
                  itemBuilder: (context, index) {
                    final session = archivedSessions[index];
                    return ListTile(
                      leading: const Icon(Icons.nightlight_round),
                      title: Text(
                        '${_formatTime(session['startTime'])} - ${_formatTime(session['endTime'])}',
                      ),
                      subtitle: Text(
                          'Duration: ${((session['duration'] ?? 0) / 60).toStringAsFixed(1)} hrs'),
                    );
                  },
                ),
    );
  }
}
