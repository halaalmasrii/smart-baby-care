import 'package:flutter/material.dart';

class FeedingScheduleScreen extends StatefulWidget {
  const FeedingScheduleScreen({Key? key}) : super(key: key);

  @override
  State<FeedingScheduleScreen> createState() => _FeedingScheduleScreenState();
}

class _FeedingScheduleScreenState extends State<FeedingScheduleScreen> {
  final List<DateTime> feedings = [];

  void _addFeedingNow() {
    setState(() {
      feedings.insert(0, DateTime.now());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Feeding time added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Schedule'),
        centerTitle: true,
        backgroundColor: primary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFeedingNow,
        backgroundColor: primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Feeding'),
      ),
      body: feedings.isEmpty
          ? const Center(
              child: Text(
                'No feedings added yet.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedings.length,
              itemBuilder: (context, index) {
                final time = feedings[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.baby_changing_station),
                    title: Text('Feeding at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
                    subtitle: Text('${time.day}/${time.month}/${time.year}'),
                  ),
                );
              },
            ),
    );
  }
}
