import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../widgets/custom_app_bar.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final babyId = authService.selectedBabyId;

    if (babyId == null) {
      setState(() => isLoading = false);
      return;
    }

    final uri = Uri.parse("http://localhost:3000/api/babies/babies/appointments/$babyId");

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          appointments = List<Map<String, dynamic>>.from(data['appointments']);
          isLoading = false;
        });
      } else {
        print("Failed to load appointments");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Icon getIconByType(String? type) {
    switch (type) {
      case 'vaccine':
        return const Icon(Icons.vaccines, color: Colors.deepPurple);
      case 'doctor':
        return const Icon(Icons.person_pin_circle, color: Colors.teal);
      case 'medicine':
        return const Icon(Icons.medication, color: Colors.orange);
      default:
        return const Icon(Icons.event_note, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Appointments'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? const Center(child: Text("No appointments found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];

                    // بيانات أساسية
                    final String appointmentType = appointment['type'] ?? '';
                    final String appointmentTitle = appointment['title'] ?? 'Untitled';
                    final String? dateStr = appointment['date'];
                    final List<dynamic>? timesList = appointment['times'];

                    // تحويل التاريخ
                    DateTime? parsedDate = dateStr != null ? DateTime.tryParse(dateStr) : null;

                    String formattedDate = parsedDate != null
                        ? '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}'
                        : 'No Date';

                    // تحويل الأوقات
                    List<TimeOfDay> times = [];
                    if (timesList != null && timesList.isNotEmpty) {
                      times = timesList.map((timeStr) {
                        final parts = timeStr.toString().split(':');
                        if (parts.length == 2) {
                          return TimeOfDay(
                            hour: int.parse(parts[0]),
                            minute: int.parse(parts[1]),
                          );
                        }
                        return null;
                      }).where((t) => t != null).cast<TimeOfDay>().toList();
                    }

                    String formattedTimes = times.isEmpty
                        ? 'No time set'
                        : times.map((t) => "${t.hour}:${t.minute.toString().padLeft(2, '0')}").join(', ');

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: getIconByType(appointmentType),
                        title: Text(appointmentTitle),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$formattedDate"),
                            Text("$formattedTimes"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
