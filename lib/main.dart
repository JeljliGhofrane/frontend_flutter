import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ✅ Import de votre fichier manuel créé dans lib/generated/
import 'generated/l10n.dart'; 

// Providers
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart'; 
import 'providers/notifications_provider.dart';

// Theme et Screens
import 'theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bloquer l'orientation en portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const NetTempGuardApp());
}

class NetTempGuardApp extends StatelessWidget {
  const NetTempGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()..load()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'NetTemp Guard',
            debugShowCheckedModeBanner: false,

            // 🎨 Gestion du Thème (Sombre / Clair)
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            // 🌍 Langue sélectionnée dynamiquement via le Provider
            locale: languageProvider.locale,

            // ✅ Liste des langues supportées (définie dans lib/generated/l10n.dart)
            supportedLocales: AppLocalizations.supportedLocales,

            // ✅ DÉLÉGUÉS DE TRADUCTION (Correction des erreurs précédentes)
            localizationsDelegates: [
              AppLocalizations.delegate,             // Votre délégué manuel
              GlobalMaterialLocalizations.delegate,  // Pour les textes Material Design (Fr/Ar)
              GlobalWidgetsLocalizations.delegate,   // Pour la direction du texte (RTL pour l'Arabe)
              GlobalCupertinoLocalizations.delegate, // Pour les widgets style iOS
            ],

            // 🔥 Force la mise à jour de l'interface lors du changement de langue
            localeResolutionCallback: (locale, supportedLocales) {
              return languageProvider.locale;
            },

            // Écran de démarrage
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}