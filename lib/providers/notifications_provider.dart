import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';

class NotificationsProvider extends ChangeNotifier {
  static const _prefsKey = 'app_notifications_v1';

  final List<AppNotification> _items = [];
  bool _loaded = false;

  List<AppNotification> get items => List.unmodifiable(_items);
  bool get loaded => _loaded;
  int get unreadCount => _items.where((n) => !n.read).length;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _items
          ..clear()
          ..addAll(decoded.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        // ignore corrupted cache
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(AppNotification n) async {
    _items.insert(0, n);
    await _persist();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    for (var i = 0; i < _items.length; i++) {
      if (!_items[i].read) _items[i] = _items[i].copyWith(read: true);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    if (_items[idx].read) return;
    _items[idx] = _items[idx].copyWith(read: true);
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }
}

