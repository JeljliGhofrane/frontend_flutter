import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_notification.dart';
import '../providers/notifications_provider.dart';
import 'auth_service.dart';

class NotificationsService {
  static final NotificationsService _i = NotificationsService._();
  factory NotificationsService() => _i;
  NotificationsService._();

  static String get _base {
    // Backend route: /api/notifications
    if (kIsWeb) return 'http://localhost:3000/api/notifications';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/notifications';
    }
    return 'http://127.0.0.1:3000/api/notifications';
  }

  // For now: only backend calls (FCM integration can be added once Firebase config is present).
  Future<String?> registerFcmToken(String token) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/register-token'),
            headers: AuthService().authHeaders,
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return null;
      return data['message'] as String? ?? 'Erreur';
    } catch (_) {
      return 'Impossible de joindre le serveur.';
    }
  }

  Future<String?> sendDangerTemperatureNotification() async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/danger-temperature'),
            headers: AuthService().authHeaders,
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return null;
      return data['message'] as String? ?? 'Erreur';
    } catch (_) {
      return 'Impossible de joindre le serveur.';
    }
  }

  // Helper for UI demo (until FCM wired)
  Future<void> addLocalDemoNotification(NotificationsProvider provider) async {
    final n = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Alerte température',
      body: 'Température dangereuse dans la salle réseau',
      createdAt: DateTime.now(),
      type: 'TEMP_DANGER',
      read: false,
    );
    await provider.add(n);
  }
}

