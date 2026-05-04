import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {

  static ThemeData lightTheme() {

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SF Pro Display',

      brightness: Brightness.light,

      primaryColor: AppColors.lightPrimary,

      scaffoldBackgroundColor: AppColors.lightBackground,

      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightPrimary,

        background: AppColors.lightBackground,
        surface: AppColors.lightCard,

        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
      ),

      cardColor: AppColors.lightCard,

      dividerColor: AppColors.lightBorder,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
      ),
    );
  }

  static ThemeData darkTheme() {

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SF Pro Display',

      brightness: Brightness.dark,

      primaryColor: AppColors.darkPrimary,

      scaffoldBackgroundColor: AppColors.darkBackground,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkPrimary,

        background: AppColors.darkBackground,
        surface: AppColors.darkCard,

        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
      ),

      cardColor: AppColors.darkCard,

      dividerColor: AppColors.darkBorder,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCard,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      ),
    );
  }
}