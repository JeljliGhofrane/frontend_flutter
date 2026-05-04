import 'package:flutter/material.dart';
import 'package:nettemp_guard/generated/l10n.dart';
import '../../theme/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const _cards = [
    ('Reconnaissance Faciale','ESP32-CAM + OpenCV — détection temps réel',
     Icons.face_retouching_natural_rounded, AppColors.navyMid,'Actif'),
    ('Anomalie Température','Seuil adaptatif ML basé sur historique',
     Icons.thermostat_auto_rounded, AppColors.success,'En ligne'),
    ('Prédiction Maintenance','Analyse tendances capteurs — prédiction pannes',
     Icons.build_circle_rounded, AppColors.warning,'Beta'),
  ];

  static const _events = [
    ('Visage inconnu détecté','10:34',AppColors.error,Icons.warning_rounded),
    ('Mohamed Ali — accès autorisé','10:15',AppColors.success,Icons.check_circle_rounded),
    ('Pic température 34°C','09:52',AppColors.warning,Icons.thermostat_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.navyDark,
        title: Text(l10n.aiAnalysisTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        ..._cards.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AICard(c.$1, c.$2, c.$3, c.$4, c.$5),
            )),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
              ]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.recentEvents,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            ..._events.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(children: [
                    Icon(e.$4, color: e.$3, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(e.$1,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
                    Text(e.$2, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ]),
                )),
          ]),
        ),
      ]),
    );
  }
}

class _AICard extends StatelessWidget {
  final String t, d, s; final IconData i; final Color c;
  const _AICard(this.t, this.d, this.i, this.c, this.s);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))]),
    child: Row(children: [
      Container(width: 48, height: 48,
          decoration: BoxDecoration(color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(i, color: c, size: 26)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t, style: const TextStyle(fontWeight: FontWeight.w700,
                fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 3),
            Text(d, style: const TextStyle(color: AppColors.textSecondary,
                fontSize: 11, height: 1.4)),
          ])),
      const SizedBox(width: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(color: c.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Text(s, style: TextStyle(color: c, fontSize: 11,
              fontWeight: FontWeight.w700))),
    ]),
  );
}