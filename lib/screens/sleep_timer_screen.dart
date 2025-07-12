import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    final authService = Provider.of<AuthService>(context, listen: false);
    print("Selected baby ID: ${authService.selectedBabyId}");
    print("Token: ${authService.token}");
    _loadSleepStartTime();
    fetchTodaySleepSessions();
  }

  Future<void> _loadSleepStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTime = prefs.getString('sleep_start_time');

    if (storedTime != null) {
      _startTime = DateTime.tryParse(storedTime);
      if (_startTime != null) {
        _startTimer();
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
        });
      }
    }
  }

  Future<void> _saveSleepStartTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sleep_start_time', time.toIso8601String());
  }

  Future<void> _clearSleepStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sleep_start_time');
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });
  }

  Future<void> fetchTodaySleepSessions() async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final token = authService.token;
  final babyId = authService.selectedBabyId;

  if (babyId == null || token == null) {
    setState(() => isLoading = false);
    print("babyId or token is null");
    return;
  }

  final uri = Uri.parse("http://localhost:3000/api/babies/sleep/baby/$babyId");

  try {
    final response = await http.get(uri, headers: {"Authorization": "Bearer $token"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final allSessions = List<Map<String, dynamic>>.from(data['sleepSessions']);
      final today = DateTime.now();

      setState(() {
        _todaySessions = allSessions.where((session) {
          final start = DateTime.parse(session['startTime']);
          return start.day == today.day &&
              start.month == today.month &&
              start.year == today.year;
        }).toList();
        isLoading = false;
      });
    } else {
      print("Fetch failed: ${response.body}");
      setState(() => isLoading = false);
    }
  } catch (e) {
    print("Fetch sleep error: $e");
    setState(() => isLoading = false);
  }
}

  
  Future<void> _saveSleepId(String id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('current_sleep_id', id);
}

  Future<String?> _loadSleepId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_sleep_id');
  }

  Future<void> _clearSleepId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_sleep_id');
  }


  Future<void> _toggleSleep() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final babyId = authService.selectedBabyId;

    if (token == null || babyId == null) {
      print("Token or babyId missing");
      return;
    }

    if (_startTime == null) {
      //  Start sleep session
      final now = DateTime.now();
      print(now);
      final uri = Uri.parse("http://localhost:3000/api/babies/sleep/$babyId");

      try {
        final response = await http.post(
          uri,
          headers: {
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final start = DateTime.tryParse(data['sleep']['startTime']);
          final sleepId = data['sleep']['_id'];

          if (start != null) {
            _startTime = start;
            await _saveSleepStartTime(start);
            await _saveSleepId(sleepId); //  حفظ الـ ID لإنهاء الجلسة لاحقًا
            _startTimer();
            setState(() => _elapsed = DateTime.now().difference(_startTime!));
          }
        } else {
          print("Failed to start sleep: ${response.body}");
        }
      } catch (e) {
        print("Start sleep error: $e");
      }
    } else {
      // End sleep session
      final sleepId = await _loadSleepId();
      if (sleepId == null) {
        print("Missing sleep ID");
        return;
      }
      final uri = Uri.parse("http://localhost:3000/api/babies/sleep/end/$sleepId");

      try {
        final response = await http.patch(
          uri,
          headers: {
            "Authorization": "Bearer $token",
          },
        );
        if (response.statusCode == 200) {
          await _clearSleepStartTime();
          await _clearSleepId();
          _timer?.cancel();
          setState(() {
            _startTime = null;
            _elapsed = Duration.zero;
          });
          fetchTodaySleepSessions();
        } else {
          print("Failed to end sleep: ${response.body}");
        }
      } catch (e) {
        print("End sleep error: $e");
      }
    }
  }


  String _formatTime(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                  if (isSleeping)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Elapsed: ${_formatElapsed(_elapsed)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 30),
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
