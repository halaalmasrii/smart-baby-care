import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class DataEntryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Data Entry'),
      body: Center(
        child: Text('Data Entry Form Here'),
      ),
    );
  }
}