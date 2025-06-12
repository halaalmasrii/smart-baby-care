import 'package:flutter/material.dart'; 

enum AppointmentType { vaccine, doctor, medicine }

class Appointment {
  final String id;
  final AppointmentType type;
  final String title;
  final DateTime? date;
  final TimeOfDay? time;
  final String? recurrence;
  final int? durationDays;
  final bool notifyOneDayBefore;
  final bool notifyAtTime;

  Appointment({
    required this.id,
    required this.type,
    required this.title,
    this.date,
    this.time,
    this.recurrence,
    this.durationDays,
    this.notifyOneDayBefore = false,
    this.notifyAtTime = false,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      type: _parseType(json['type']), // ✅ التحويل من JSON إلى AppointmentType
      title: json['title'],
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      time: json['time'] != null 
          ? TimeOfDay.fromDateTime(DateTime.parse("2023-01-01 ${json['time']}")) 
          : null,
      recurrence: json['recurrence'],
      durationDays: json['durationDays'] is String 
          ? int.tryParse(json['durationDays']) 
          : json['durationDays'],
      notifyOneDayBefore: json['notifyOneDayBefore'] ?? false,
      notifyAtTime: json['notifyAtTime'] ?? false,
    );
  }

  static AppointmentType _parseType(String? typeString) {
    switch (typeString) {
      case 'vaccine':
        return AppointmentType.vaccine;
      case 'doctor':
        return AppointmentType.doctor;
      case 'medicine':
        return AppointmentType.medicine;
      default:
        throw Exception('Invalid AppointmentType: $typeString');
    }
  }
}