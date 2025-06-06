import 'package:flutter/material.dart';

class VaccinationScheduleScreen extends StatefulWidget {
  const VaccinationScheduleScreen({Key? key}) : super(key: key);

  @override
  State<VaccinationScheduleScreen> createState() => _VaccinationScheduleScreenState();
}

class _VaccinationScheduleScreenState extends State<VaccinationScheduleScreen> {
  final List<_VaccineEntry> _vaccines = [];

  void _addOrEditVaccine({_VaccineEntry? existing}) {
    final TextEditingController nameController = TextEditingController(text: existing?.name ?? '');
    DateTime? selectedDate = existing?.date;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Vaccine' : 'Edit Vaccine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Vaccine Name',
                prefixIcon: Icon(Icons.medical_services),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                selectedDate == null
                    ? 'Select Date'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty || selectedDate == null) return;

              setState(() {
                if (existing != null) {
                  existing.name = name;
                  existing.date = selectedDate!;
                } else {
                  _vaccines.add(_VaccineEntry(name, selectedDate!));
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteVaccine(_VaccineEntry entry) {
    setState(() {
      _vaccines.remove(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vaccination Schedule"),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditVaccine(),
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Vaccine'),
      ),
      body: _vaccines.isEmpty
          ? const Center(
              child: Text('No vaccines added yet.', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _vaccines.length,
              itemBuilder: (context, index) {
                final vaccine = _vaccines[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.vaccines),
                    title: Text(vaccine.name),
                    subtitle: Text(
                      'Scheduled on: ${vaccine.date.day}/${vaccine.date.month}/${vaccine.date.year}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _addOrEditVaccine(existing: vaccine),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteVaccine(vaccine),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _VaccineEntry {
  String name;
  DateTime date;

  _VaccineEntry(this.name, this.date);
}
