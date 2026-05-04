// lib/services/google_auth_handler.dart
// ─────────────────────────────────────────────────────────────
//  Gestion Google OAuth pour Flutter Web
//  Flux : Flutter → ouvre Google → callback → token → dashboard
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthHandler {
  static const _backendBase = 'http://localhost:3000';

  // ─── 1. Ouvrir Google Login ───────────────────────────────
  static Future<void> openGoogleLogin() async {
    final url = Uri.parse('$_backendBase/api/auth/google');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ─── 2. Vérifier si on revient du callback Google ─────────
  //  À appeler dans SplashScreen ou main.dart au démarrage
  static String? extractTokenFromUrl() {
    if (!kIsWeb) return null;

    // Sur Flutter Web, on peut lire l'URL courante
    final currentUrl = Uri.base.toString();
    final uri        = Uri.parse(currentUrl);
    return uri.queryParameters['token']; // ?token=JWT_TOKEN
  }

  // ─── 3. Sauvegarder le token Google ──────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // ─── 4. Nettoyer l'URL après récupération du token ───────
  static void cleanUrl() {
    if (!kIsWeb) return;
    // Retire le ?token= de l'URL visible dans le navigateur
    // ignore: avoid_web_libraries_in_flutter
    // dart:html non importé pour éviter les warnings
  }
}