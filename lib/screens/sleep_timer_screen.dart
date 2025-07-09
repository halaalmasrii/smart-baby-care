import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class SleepTimerScreen extends StatefulWidget {
  const SleepTimerScreen({Key? key}) : super(key: key);

  @override
  State<SleepTimerScreen> createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends State<SleepTimerScreen> {
  DateTime? _startTime;
  List<Map<String, dynamic>> _todaySessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTodaySleepSessions();
  }

  Future<void> fetchTodaySleepSessions() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final uri = Uri.parse('http://localhost:3000/api/users/sleep');

    try {
      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allSessions = List<Map<String, dynamic>>.from(data['sleepSessions']);

        final today = DateTime.now();
        today.subtract(Duration(
          hours: today.hour,
          minutes: today.minute,
          seconds: today.second,
          milliseconds: today.millisecond,
        ));

        setState(() {
          _todaySessions = allSessions.where((session) {
            final start = DateTime.parse(session['startTime']);
            return start.day == today.day &&
                   start.month == today.month &&
                   start.year == today.year;
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Fetch sleep error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleSleep() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (_startTime == null) {
      setState(() {
        _startTime = DateTime.now();
      });
    } else {
      final endTime = DateTime.now();
      final duration = endTime.difference(_startTime!).inMinutes;

      final uri = Uri.parse("http://localhost:3000/api/sleep/add");
      try {
        final response = await http.post(
          uri,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "startTime": _startTime!.toIso8601String(),
            "endTime": endTime.toIso8601String(),
            "duration": duration,
          }),
        );

        if (response.statusCode == 201) {
          fetchTodaySleepSessions();
        }
      } catch (e) {
        print("Submit sleep error: $e");
      }

      setState(() => _startTime = null);
    }
  }

  String _formatTime(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isSleeping = _startTime != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            tooltip: 'View Archive',
            onPressed: () {
              Navigator.pushNamed(context, '/sleep-archive');
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(isSleeping ? Icons.stop : Icons.play_arrow),
                    label: Text(isSleeping ? 'Stop Sleep' : 'Start Sleep'),
                    onPressed: _toggleSleep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Today\'s Sleep Sessions:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _todaySessions.isEmpty
                        ? const Center(child: Text('No sessions recorded today.'))
                        : ListView.builder(
                            itemCount: _todaySessions.length,
                            itemBuilder: (context, index) {
                              final session = _todaySessions[index];
                              return ListTile(
                                leading: const Icon(Icons.nightlight_round),
                                title: Text(
                                  '${_formatTime(session['startTime'])} - ${_formatTime(session['endTime'])}',
                                ),
                                subtitle: Text(
                                  'Duration: ${((session['duration'] ?? 0) / 60).toStringAsFixed(1)} hrs',
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
    );
  }
}
