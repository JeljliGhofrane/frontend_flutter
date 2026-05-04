import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String type;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    required this.read,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        createdAt: createdAt,
        type: type,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'type': type,
        'read': read,
      };

  static AppNotification fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        type: (json['type'] as String?) ?? 'GENERAL',
        read: (json['read'] as bool?) ?? false,
      );

  // UI helpers
  IconData get icon => switch (type) {
        'TEMP_DANGER' => Icons.thermostat_rounded,
        'FACE_UNKNOWN' => Icons.face_retouching_natural_rounded,
        'RFID' => Icons.nfc_rounded,
        'SYSTEM' => Icons.shield_rounded,
        _ => Icons.notifications_active_rounded,
      };

  Color color(ColorScheme scheme) => switch (type) {
        'TEMP_DANGER' => const Color(0xFFEF5350),
        'FACE_UNKNOWN' => const Color(0xFFEF5350),
        'RFID' => const Color(0xFF4CAF50),
        'SYSTEM' => const Color(0xFF4A6CF7),
        _ => scheme.primary,
      };
}

