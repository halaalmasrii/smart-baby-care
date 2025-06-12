import 'package:flutter/material.dart';

enum AppointmentType { vaccine, doctor, medicine, feeding }

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
  final bool isNotificationDone;
  final DateTime? lastFeeding; // لتخزين آخر وقت للرضاعة

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
    this.isNotificationDone = false,
    this.lastFeeding,
  });

  Appointment copyWith({
    bool? isNotificationDone,
    DateTime? lastFeeding,
  }) {
    return Appointment(
      id: id,
      type: type,
      title: title,
      date: date,
      time: time,
      recurrence: recurrence,
      durationDays: durationDays,
      notifyOneDayBefore: notifyOneDayBefore,
      notifyAtTime: notifyAtTime,
      isNotificationDone: isNotificationDone ?? this.isNotificationDone,
      lastFeeding: lastFeeding ?? this.lastFeeding,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final timeString = json['time'] as String?;
    TimeOfDay? time;

    if (timeString != null && timeString.contains(':')) {
      final parts = timeString.split(':');
      time = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }

    return Appointment(
      id: json['id'],
      type: _parseType(json['type']),
      title: json['title'],
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      time: time,
      recurrence: json['recurrence'],
      durationDays: json['durationDays'] is String
          ? int.tryParse(json['durationDays'])
          : json['durationDays'],
      notifyOneDayBefore: json['notifyOneDayBefore'] ?? false,
      notifyAtTime: json['notifyAtTime'] ?? false,
      isNotificationDone: json['isNotificationDone'] ?? false,
      lastFeeding: json['lastFeeding'] != null
          ? DateTime.tryParse(json['lastFeeding'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'date': date?.toIso8601String(),
      'time': time != null
          ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
          : null,
      'recurrence': recurrence,
      'durationDays': durationDays,
      'notifyOneDayBefore': notifyOneDayBefore,
      'notifyAtTime': notifyAtTime,
      'isNotificationDone': isNotificationDone,
      'lastFeeding': lastFeeding?.toIso8601String(),
    };
  }

  //  تحويل النص إلى AppointmentType
  static AppointmentType _parseType(String? typeString) {
    switch (typeString) {
      case 'vaccine':
        return AppointmentType.vaccine;
      case 'doctor':
        return AppointmentType.doctor;
      case 'medicine':
        return AppointmentType.medicine;
      case 'feeding':
        return AppointmentType.feeding;
      default:
        throw Exception('Invalid AppointmentType: $typeString');
    }
  }
}
