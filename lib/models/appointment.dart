import 'package:flutter/material.dart';

enum AppointmentType { vaccine, doctor, medicine, feeding }

class Appointment {
  final String? id;
  final String title;
  final DateTime? date;
  final List<TimeOfDay> times;
  final AppointmentType type;
  final String? recurrence;
  final int? durationDays;
  final bool notifyOneDayBefore;
  final bool notifyAtTime;

  // الخصائص الجديدة
  final bool isNotificationDone;
  final DateTime? lastFeeding;

  Appointment({
    this.id,
    required this.title,
    this.date,
    List<TimeOfDay>? times,
    required this.type,
    this.recurrence,
    this.durationDays,
    this.notifyOneDayBefore = false,
    this.notifyAtTime = false,
    this.isNotificationDone = false,
    this.lastFeeding,               
  }) : times = times ?? [];

  Map<String, dynamic> toJson() {
  final map = {
    'title': title,
    'date': date?.toIso8601String(),
    'times': times.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').toList(),
    'type': type.name,
    'repeat': recurrence,
    'durationDays': durationDays,
    'notifyOneDayBefore': notifyOneDayBefore,
    'notifyAtTime': notifyAtTime,
    'isNotificationDone': isNotificationDone,
    'lastFeeding': lastFeeding?.toIso8601String(),
  };

  // فقط إذا كان ObjectId صالح (24 خانة)
  if (id != null && id!.length == 24) {
    map['id'] = id;
  }

  return map;
}


  factory Appointment.fromJson(Map<String, dynamic> json) {
    final timesJson = json['times'] as List?;
    final times = timesJson
        ?.map((timeStr) {
          final parts = timeStr.toString().split(':');
          if (parts.length == 2) {
            return TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
          return null;
        })
        .whereType<TimeOfDay>()
        .toList();

    return Appointment(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      times: times,
      type: AppointmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AppointmentType.vaccine,
      ),
      recurrence: json['repeat'],
      durationDays: json['durationDays'],
      notifyOneDayBefore: json['notifyOneDayBefore'] ?? false,
      notifyAtTime: json['notifyAtTime'] ?? false,

      // المضافات
      isNotificationDone: json['isNotificationDone'] ?? false,
      lastFeeding: json['lastFeeding'] != null
          ? DateTime.tryParse(json['lastFeeding'])
          : null,
    );
  }

  Appointment copyWith({
    String? id,
    String? title,
    DateTime? date,
    List<TimeOfDay>? times,
    AppointmentType? type,
    String? recurrence,
    int? durationDays,
    bool? notifyOneDayBefore,
    bool? notifyAtTime,

    // الخصائص القابلة للنسخ
    bool? isNotificationDone,
    DateTime? lastFeeding,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      times: times ?? this.times,
      type: type ?? this.type,
      recurrence: recurrence ?? this.recurrence,
      durationDays: durationDays ?? this.durationDays,
      notifyOneDayBefore: notifyOneDayBefore ?? this.notifyOneDayBefore,
      notifyAtTime: notifyAtTime ?? this.notifyAtTime,
      isNotificationDone: isNotificationDone ?? this.isNotificationDone,
      lastFeeding: lastFeeding ?? this.lastFeeding,
    );
  }
}
