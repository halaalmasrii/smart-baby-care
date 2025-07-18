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

    if (babyId == null || token == null) {
      setState(() => isLoading = false);
      print("babyId or token is null");
      return;
    }

    final uri = Uri.parse('http://localhost:3000/api/babies/sleep/baby/$babyId');

    try {
      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allSessions = List<Map<String, dynamic>>.from(data['sleepSessions']);

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        setState(() {
          archivedSessions = allSessions.where((session) {
            final start = DateTime.parse(session['startTime']);
            final sessionDate = DateTime(start.year, start.month, start.day);
            return sessionDate.isBefore(today); // فقط الجلسات القديمة
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

  String _formatDate(String timestamp) {
    final time = DateTime.parse(timestamp);
    return '${time.day}/${time.month}/${time.year}';
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
                    final start = session['startTime'];
                    final end = session['endTime'];
                    final duration = session['duration'];
                    final notes = session['notes'];

                    return ListTile(
                      leading: const Icon(Icons.nightlight_round),
                      title: Text(
                        '${_formatTime(start)} - ${_formatTime(end)} (${_formatDate(start)})',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Duration: ${(duration / 60).toStringAsFixed(1)} hrs'),
                          if (notes != null && notes.toString().isNotEmpty)
                            Text('Notes: $notes'),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
