import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AddEditAppointmentModal extends StatefulWidget {
  final Appointment? appointment;
  final void Function(Appointment) onSave;

  const AddEditAppointmentModal({super.key, this.appointment, required this.onSave});

  @override
  State<AddEditAppointmentModal> createState() => _AddEditAppointmentModalState();
}

class _AddEditAppointmentModalState extends State<AddEditAppointmentModal> {
  late AppointmentType _type;
  late TextEditingController _titleController;
  DateTime? _date;
  TimeOfDay? _time;
  TimeOfDay? _morningTime;
  TimeOfDay? _eveningTime;
  String? _recurrence;
  int? _durationDays;
  bool _notifyOneDayBefore = false;
  bool _notifyAtTime = false;

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      final appt = widget.appointment!;
      _type = appt.type;
      _titleController = TextEditingController(text: appt.title);
      _date = appt.date;
      _time = appt.time;
      _recurrence = appt.recurrence;
      _durationDays = appt.durationDays;
      _notifyOneDayBefore = appt.notifyOneDayBefore;
      _notifyAtTime = appt.notifyAtTime;
    } else {
      _type = AppointmentType.vaccine;
      _titleController = TextEditingController();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(Function(TimeOfDay) onSelected) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) onSelected(picked);
  }

  Widget _buildExtraFields() {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    if (_type == AppointmentType.vaccine) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(_date == null ? 'Select Date' : _date!.toLocal().toString().split(' ')[0]),
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
          ),
          CheckboxListTile(
            value: _notifyOneDayBefore,
            onChanged: (val) => setState(() => _notifyOneDayBefore = val!),
            title: const Text('Notify 1 day before'),
          ),
        ],
      );
    } else if (_type == AppointmentType.doctor) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(_date == null ? 'Select Date' : _date!.toLocal().toString().split(' ')[0]),
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
          ),
          ElevatedButton.icon(
            onPressed: () => _pickTime((t) => setState(() => _time = t)),
            icon: const Icon(Icons.access_time),
            label: Text(_time == null ? 'Select Time' : _time!.format(context)),
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
          ),
          CheckboxListTile(
            value: _notifyOneDayBefore,
            onChanged: (val) => setState(() => _notifyOneDayBefore = val!),
            title: const Text('Notify 1 day before'),
          ),
          CheckboxListTile(
            value: _notifyAtTime,
            onChanged: (val) => setState(() => _notifyAtTime = val!),
            title: const Text('Notify at time'),
          ),
        ],
      );
    } else if (_type == AppointmentType.medicine) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _showRecurrenceOptions(),
                child: Text(_recurrence ?? 'Select Frequency'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _showDurationDialog(),
                child: Text('${_durationDays ?? '0'} Days'),
              ),
            ],
          ),
          if (_recurrence == 'Once Daily')
            ElevatedButton.icon(
              onPressed: () => _pickTime((t) => setState(() => _time = t)),
              icon: const Icon(Icons.access_time),
              label: Text(_time == null ? 'Select Time' : _time!.format(context)),
            ),
          if (_recurrence == 'Morning & Evening') ...[
            ElevatedButton.icon(
              onPressed: () => _pickTime((t) => setState(() => _morningTime = t)),
              icon: const Icon(Icons.wb_sunny),
              label: Text(_morningTime == null ? 'Select Morning Time' : _morningTime!.format(context)),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickTime((t) => setState(() => _eveningTime = t)),
              icon: const Icon(Icons.nights_stay),
              label: Text(_eveningTime == null ? 'Select Evening Time' : _eveningTime!.format(context)),
            ),
          ],
        ],
      );
    }
    return const SizedBox();
  }

  void _showRecurrenceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text("Once Daily"), onTap: () {
            setState(() {
              _recurrence = 'Once Daily';
              _morningTime = null;
              _eveningTime = null;
            });
            Navigator.pop(context);
          }),
          ListTile(title: const Text("Morning & Evening"), onTap: () {
            setState(() {
              _recurrence = 'Morning & Evening';
              _time = null;
            });
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  void _showDurationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Number of Days"),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (v) => _durationDays = int.tryParse(v),
          decoration: const InputDecoration(labelText: "Days"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  void _handleSave() {
    final appt = Appointment(
      id: widget.appointment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      title: _titleController.text,
      date: _date,
      time: _time ?? _morningTime,
      recurrence: _recurrence,
      durationDays: _durationDays,
      notifyAtTime: _notifyAtTime,
      notifyOneDayBefore: _notifyOneDayBefore,
    );
    widget.onSave(appt);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 16, right: 16, top: 16),
      child: Column(
        children: [
          Text(widget.appointment == null ? 'Add Appointment' : 'Edit Appointment',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<AppointmentType>(
            value: _type == AppointmentType.feeding ? AppointmentType.vaccine : _type,
            decoration: const InputDecoration(labelText: 'Appointment Type', border: OutlineInputBorder()),
            items: AppointmentType.values
                .where((e) => e != AppointmentType.feeding) // حذف خيار Feeding
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) => setState(() => _type = val!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          _buildExtraFields(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Save Appointment"),
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
