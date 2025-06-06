import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/appointment_card.dart';

class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Appointments'),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          AppointmentCard(),
          AppointmentCard(),
        ],
      ),
    );
  }
}