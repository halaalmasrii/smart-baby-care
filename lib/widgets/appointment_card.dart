import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AppointmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Vaccination', style: TextStyle(fontSize: 18, color: AppColors.text)),
            SizedBox(height: 10),
            Text('Date: 2023-10-15', style: TextStyle(color: AppColors.text)),
            Text('Time: 10:00 AM', style: TextStyle(color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}