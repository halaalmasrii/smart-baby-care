import 'package:flutter/material.dart';
import 'dart:math';

class BabySoundScreen extends StatefulWidget {
  const BabySoundScreen({Key? key}) : super(key: key);

  @override
  State<BabySoundScreen> createState() => _BabySoundScreenState();
}

class _BabySoundScreenState extends State<BabySoundScreen> {
  final List<_CryAnalysisResult> _history = [];
  final List<String> _fakeReasons = [
    'Hungry',
    'Colic',
    'Tired',
    'Needs Burping',
    'Discomfort',
    'Wet Diaper',
  ];

  final Map<String, IconData> _reasonIcons = {
    'Hungry': Icons.restaurant,
    'Colic': Icons.sick,
    'Tired': Icons.bedtime,
    'Needs Burping': Icons.air,
    'Discomfort': Icons.sentiment_dissatisfied,
    'Wet Diaper': Icons.baby_changing_station,
  };

  _CryAnalysisResult? _latestResult;

  void _simulateAnalysis() {
    final random = Random();
    final reason = _fakeReasons[random.nextInt(_fakeReasons.length)];
    final time = DateTime.now();

    final result = _CryAnalysisResult(reason, time);
    setState(() {
      _latestResult = result;
      _history.insert(0, result);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Analysis Complete: $reason")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cry Sound Analysis'),
        backgroundColor: primary,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simulateAnalysis,
        icon: const Icon(Icons.mic),
        label: const Text("Record Cry"),
        backgroundColor: primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_latestResult != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _reasonIcons[_latestResult!.reason] ?? Icons.help,
                      size: 40,
                      color: primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Latest Analysis: ${_latestResult!.reason}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text("No analysis history yet."))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final entry = _history[index];
                        return ListTile(
                          leading: Icon(
                            _reasonIcons[entry.reason] ?? Icons.help_outline,
                            color: primary,
                          ),
                          title: Text(entry.reason),
                          subtitle: Text(
                            "${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')} - ${entry.time.day}/${entry.time.month}/${entry.time.year}",
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CryAnalysisResult {
  final String reason;
  final DateTime time;

  _CryAnalysisResult(this.reason, this.time);
}
