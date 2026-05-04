import 'dart:convert';
import 'dart:html' as html; // ✅ Flutter Web uniquement
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double>   _fade;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ac, curve: Curves.easeIn),
    );
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ac, curve: Curves.easeOutBack),
    );
    _ac.forward();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    // ══════════════════════════════════════════════════════
    //  CAS 1 — Retour depuis Google OAuth
    //  URL : localhost:8080/auth/callback?token=JWT
    // ══════════════════════════════════════════════════════
    if (kIsWeb) {
      final uri   = Uri.base;
      final token = uri.queryParameters['token'];

      if (token != null && token.isNotEmpty) {
        // ✅ Sauvegarder token + infos user
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Décoder le payload JWT pour récupérer rôle, nom, etc.
        final payload = _decodeJwt(token);
        await prefs.setString('role',   payload['role']   ?? 'autre_service');
        await prefs.setString('nom',    payload['nom']    ?? '');
        await prefs.setString('prenom', payload['prenom'] ?? '');
        await prefs.setString('email',  payload['email']  ?? '');

        // ✅ Nettoyer l'URL — retire ?token= de la barre d'adresse
        // Sans recharger la page (replaceState)
        html.window.history.replaceState(null, '', '/');

        final role = payload['role'] as String? ?? 'autre_service';

        if (!mounted) return;
        _goTo(DashboardScreen(userRole: role));
        return;
      }
    }

    // ══════════════════════════════════════════════════════
    //  CAS 2 — Session email/password existante
    // ══════════════════════════════════════════════════════
    final bool isValid = await AuthService().restoreSession();

    if (!mounted) return;

    if (isValid) {
      _goTo(DashboardScreen(userRole: AuthService().currentUser!.role));
    } else {
      _goTo(const LoginScreen());
    }
  }

  // ── Décode le payload JWT complet ─────────────────────────
  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};

      var payload = parts[1];
      // Padding base64url → base64
      while (payload.length % 4 != 0) payload += '=';

      final decoded = utf8.decode(
        base64Decode(payload.replaceAll('-', '+').replaceAll('_', '/')),
      );
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  void _goTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'NetTemp Guard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'OMMP Bizerte',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white.withValues(alpha: 0.40),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
