import 'package:flutter/material.dart';

class NotificationService with ChangeNotifier {
  List<String> _notifications = [];

  List<String> get notifications => _notifications;

  void addNotification(String message) {
    _notifications.add(message);
    notifyListeners();
  }
}