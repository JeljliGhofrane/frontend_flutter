import 'package:flutter/material.dart';

class AppColors {
  // ---------- Thème clair ----------
  static const Color lightPrimary = Color(0xFF1055CC);
  static const Color lightBackground = Color(0xFFF4F7FF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0D2557);
  static const Color lightTextSecondary = Color(0xFF96A4BE);
  static const Color lightBorder = Color(0xFFE8EDF8);

  // ---------- Thème sombre ----------
  static const Color darkPrimary = Color(0xFF5A8CFF);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF2C2C2C);

  // Couleurs communes
  static const Color navyDark    = Color(0xFF0D2557);
  static const Color navyMid     = Color(0xFF1055CC);
  static const Color navyLight   = Color(0xFFEEF3FF);
  static const Color bgPage      = Color(0xFFF4F7FF);
  static const Color bgCard      = Color(0xFFFFFFFF);
  static const Color bgField     = Color(0xFFFAFBFF);
  static const Color textPrimary   = Color(0xFF0D2557);
  static const Color textSecondary = Color(0xFF96A4BE);
  static const Color textHint      = Color(0xFFC5CDE0);
  static const Color border        = Color(0xFFE8EDF8);

  // Statuts
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFB347);
  static const Color error   = Color(0xFFFF4D6A);
  static const Color cyan    = Color(0xFF00B4D8);

  // Dégradé
  static const LinearGradient btnGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1055CC), Color(0xFF0A3FA0)],
  );
}