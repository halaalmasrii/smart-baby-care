import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Notifications'),
      body: Center(
        child: Text('Notifications List Here'),
      ),
    );
  }
}