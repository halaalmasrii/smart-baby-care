import 'package:flutter/material.dart';

class SleepTimerScreen extends StatefulWidget {
  const SleepTimerScreen({Key? key}) : super(key: key);

  @override
  State<SleepTimerScreen> createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends State<SleepTimerScreen> {
  DateTime? _startTime;
  List<String> _sleepSessions = [];

  void _toggleSleep() {
    if (_startTime == null) {
      setState(() {
        _startTime = DateTime.now();
      });
    } else {
      final endTime = DateTime.now();
      final duration = endTime.difference(_startTime!);
      final formatted = '${_formatTime(_startTime!)} - ${_formatTime(endTime)} | ${_formatDuration(duration)}';
      setState(() {
        _sleepSessions.insert(0, formatted);
        _startTime = null;
      });
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final isSleeping = _startTime != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Tracker')),
      body: Padding(
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
            const Text('Sleep Sessions:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _sleepSessions.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.nightlight_round),
                  title: Text(_sleepSessions[index]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
