import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Reports'),
      body: Center(
        child: Text('Reports and Statistics Here'),
      ),
    );
  }
}