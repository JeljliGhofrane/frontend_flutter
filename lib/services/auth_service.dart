import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _i = AuthService._();
  factory AuthService() => _i;
  AuthService._();

  static String get _base {
    if (kIsWeb) return 'http://localhost:3000/api/auth';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000/api/auth';
    return 'http://127.0.0.1:3000/api/auth';
  }

  UserModel? _currentUser;
  String?    _token;
  int        _attempts    = 0;
  DateTime?  _lockedUntil;

  UserModel? get currentUser => _currentUser;
  String?    get token       => _token;
  bool       get isLoggedIn  => _token != null && _currentUser != null;
  bool get isLocked  => _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);
  int  get remaining => (5 - _attempts).clamp(0, 5);

  Map<String, String> get authHeaders => {
    'Content-Type' : 'application/json',
    'Authorization': 'Bearer $_token',
  };

  // ══════════════════════════════════════════════════════
  //  LOGIN — Admin hardcoded ou Technicien/Employé DB
  // ══════════════════════════════════════════════════════
  Future<String?> login(String email, String password) async {
    if (isLocked) {
      final m = _lockedUntil!.difference(DateTime.now()).inMinutes + 1;
      return 'Compte bloqué. Réessayez dans $m min.';
    }
    try {
      final res = await http.post(
        Uri.parse('$_base/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim().toLowerCase(), 'password': password}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        _attempts = 0; _lockedUntil = null;
        _token       = data['token'] as String;
        _currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        await _saveSession(_token!, _currentUser!);
        return null; // ✅ Succès
      }

      // Compte en attente d'approbation — message spécial
      if (res.statusCode == 403) {
        return data['message'] as String? ?? 'Compte en attente d\'approbation.';
      }

      _attempts++;
      if (_attempts >= 5) {
        _lockedUntil = DateTime.now().add(const Duration(minutes: 5));
        await _saveAttempts();
        return 'Trop de tentatives. Compte bloqué 5 min.';
      }
      final msg = data['message'] as String? ?? 'Identifiants incorrects';
      return '$msg ($remaining essai${remaining > 1 ? "s" : ""} restant)';
    } catch (e) {
      return 'Serveur inaccessible. Vérifiez que Node.js est démarré.';
    }
  }

  // ══════════════════════════════════════════════════════
  //  REGISTER — Seulement technicien/employe
  //  ❌ Admin ne peut pas s'inscrire via l'app
  // ══════════════════════════════════════════════════════
  Future<String?> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String role,
  }) async {
    // ✅ Validation côté Flutter
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email))
      return 'Email invalide';
    if (password.length < 8)
      return 'Mot de passe trop court (min. 8 car.)';

    // ✅ Bloquer inscription admin côté Flutter aussi
    if (role == 'admin')
      return 'L\'inscription en tant qu\'administrateur est interdite.';

    if (!['technicien', 'employe'].includes(role))
      return 'Rôle invalide.';

    try {
      final res = await http.post(
        Uri.parse('$_base/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom'     : nom.trim(),
          'prenom'  : prenom.trim(),
          'email'   : email.trim().toLowerCase(),
          'password': password,
          'role'    : role,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) return null; // ✅ Succès
      return data['message'] as String? ?? 'Erreur lors de l\'inscription';
    } catch (e) {
      return 'Impossible de joindre le serveur.';
    }
  }

  // ══════════════════════════════════════════════════════
  //  FORGOT PASSWORD
  // ══════════════════════════════════════════════════════
  Future<String?> sendPasswordReset(String email) async {
    if (!email.contains('@')) return 'Email invalide';
    try {
      final res = await http.post(
        Uri.parse('$_base/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim().toLowerCase()}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return null;
      return data['message'] as String? ?? 'Erreur';
    } catch (e) { return 'Impossible de joindre le serveur.'; }
  }

  Future<({String? error, String? resetToken})> verifyCode(String email, String code) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim().toLowerCase(), 'code': code.trim()}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return (error: null, resetToken: data['token'] as String?);
      return (error: data['message'] as String? ?? 'Code invalide', resetToken: null);
    } catch (e) { return (error: 'Serveur inaccessible.', resetToken: null); }
  }

  Future<String?> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    if (newPassword.length < 8) return 'Mot de passe trop court (min. 8 car.)';
    try {
      final res = await http.post(
        Uri.parse('$_base/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim().toLowerCase(), 'token': token, 'password': newPassword}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return null;
      return data['message'] as String? ?? 'Erreur';
    } catch (e) { return 'Impossible de joindre le serveur.'; }
  }

  Future<String?> changePassword({String? currentPassword, required String newPassword}) async {
    if (_token == null) return 'Session expirée.';
    if (newPassword.trim().isEmpty || newPassword.length < 8) return 'Mot de passe trop court (min. 8 car.)';
    try {
      final body = <String, dynamic>{'newPassword': newPassword};
      if (currentPassword != null && currentPassword.trim().isNotEmpty)
        body['currentPassword'] = currentPassword;
      final res = await http.put(
        Uri.parse('$_base/change-password'),
        headers: authHeaders,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return null;
      return data['message'] as String? ?? 'Erreur';
    } catch (e) { return 'Impossible de joindre le serveur.'; }
  }

  // ══════════════════════════════════════════════════════
  //  SESSION
  // ══════════════════════════════════════════════════════
  Future<void> logout() async {
    _currentUser = null; _token = null;
    _attempts = 0; _lockedUntil = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;
    _token = token;
    _currentUser = UserModel(
      id    : prefs.getString('id')     ?? '',
      email : prefs.getString('email')  ?? '',
      role  : prefs.getString('role')   ?? 'technicien',
      nom   : prefs.getString('nom')    ?? '',
      prenom: prefs.getString('prenom') ?? '',
    );
    _attempts = prefs.getInt('attempts') ?? 0;
    final lockedTs = prefs.getInt('lockedUntil');
    if (lockedTs != null) _lockedUntil = DateTime.fromMillisecondsSinceEpoch(lockedTs);
    return true;
  }

  Future<void> _saveSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token',  token);
    await prefs.setString('id',     user.id);
    await prefs.setString('email',  user.email);
    await prefs.setString('role',   user.role);
    await prefs.setString('nom',    user.nom);
    await prefs.setString('prenom', user.prenom);
  }

  Future<void> _saveAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('attempts', _attempts);
    if (_lockedUntil != null)
      await prefs.setInt('lockedUntil', _lockedUntil!.millisecondsSinceEpoch);
  }
}

// Extension utilitaire
extension _ListExtension on List<String> {
  bool includes(String s) => contains(s);
}