import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
//  SENSORS SCREEN — Design amélioré
// ══════════════════════════════════════════════════════════════
class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulse;

  double _temp   = 23.5;
  double _humid  = 58.0;
  double _gas    = 12.0;
  bool   _water  = false;

  final List<double> _tempHistory  = [22, 24, 21, 26, 25, 23, 27, 24];
  final List<double> _humidHistory = [55, 58, 60, 57, 62, 59, 58, 61];
  final List<double> _gasHistory   = [10, 12, 11, 14, 12, 10, 13, 11];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final rng = Random();
      setState(() {
        _temp  = 21 + rng.nextDouble() * 6;
        _humid = 50 + rng.nextDouble() * 20;
        _gas   = 8  + rng.nextDouble() * 10;
        _tempHistory
          ..removeAt(0)
          ..add(double.parse(_temp.toStringAsFixed(1)));
        _humidHistory
          ..removeAt(0)
          ..add(double.parse(_humid.toStringAsFixed(1)));
        _gasHistory
          ..removeAt(0)
          ..add(double.parse(_gas.toStringAsFixed(1)));
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: pageBg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar élégant ──────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppColors.navyDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.navyDark,
                      (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          .withOpacity(0.85),
                    ],
                  ),
                ),
                child: Stack(children: [
                  // Cercles décoratifs
                  Positioned(right: -30, top: -30,
                    child: Container(width: 140, height: 140,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.07), width: 1))),
                  ),
                  Positioned(right: 20, top: 10,
                    child: Container(width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05), width: 1))),
                  ),
                  // Titre
                  Positioned(left: 20, bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('ESP32 Monitor',
                          style: TextStyle(color: Colors.white70,
                            fontSize: 11, letterSpacing: 2,
                            fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('Capteurs en direct',
                          style: TextStyle(color: Colors.white,
                            fontSize: 22, fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            actions: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1 + _pulse.value * 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    Container(width: 6, height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          AppColors.success.withOpacity(0.5),
                          AppColors.success,
                          _pulse.value,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('LIVE',
                      style: TextStyle(color: Colors.white,
                        fontSize: 11, fontWeight: FontWeight.w800,
                        letterSpacing: 1)),
                  ]),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Status bar résumé ─────────────────────
                const _SectionHeader(
                  title: 'Aperçu',
                  subtitle: 'Statut rapide des capteurs',
                  icon: Icons.dashboard_rounded,
                ),
                _StatusSummary(
                  temp: _temp, humid: _humid,
                  gas: _gas, water: _water,
                ),
                const SizedBox(height: 20),

                // ── Carte Température ─────────────────────
                const _SectionHeader(
                  title: 'Capteurs',
                  subtitle: 'Mesures en temps réel',
                  icon: Icons.sensors_rounded,
                ),
                _SensorCard(
                  label: 'Température',
                  sub: 'DHT22 — ESP32',
                  value: '${_temp.toStringAsFixed(1)}°C',
                  icon: Icons.thermostat_rounded,
                  color: _temp > 27
                    ? AppColors.error
                    : _temp > 25
                      ? AppColors.warning
                      : AppColors.success,
                  status: _temp > 27 ? 'CRITIQUE'
                    : _temp > 25 ? 'AVERTISSEMENT' : 'NORMAL',
                  history: _tempHistory,
                  min: 15, max: 35,
                  pulse: _pulse,
                ),
                const SizedBox(height: 14),

                // ── Carte Humidité ────────────────────────
                _SensorCard(
                  label: 'Humidité',
                  sub: 'DHT22 — ESP32',
                  value: '${_humid.toStringAsFixed(0)}%',
                  icon: Icons.water_drop_rounded,
                  color: _humid > 70
                    ? AppColors.warning
                    : AppColors.cyan,
                  status: _humid > 70 ? 'ÉLEVÉE' : 'NORMALE',
                  history: _humidHistory,
                  min: 30, max: 90,
                  pulse: _pulse,
                ),
                const SizedBox(height: 14),

                // ── Carte Gaz ─────────────────────────────
                _SensorCard(
                  label: 'Gaz / Fumée',
                  sub: 'MQ-2 — ESP32',
                  value: '${_gas.toStringAsFixed(0)} ppm',
                  icon: Icons.cloud_outlined,
                  color: _gas > 30
                    ? AppColors.error
                    : AppColors.success,
                  status: _gas > 30 ? 'DANGER' : 'NORMAL',
                  history: _gasHistory,
                  min: 0, max: 50,
                  pulse: _pulse,
                ),
                const SizedBox(height: 14),

                // ── Carte Fuite d'eau ─────────────────────
                const _SectionHeader(
                  title: 'Sécurité',
                  subtitle: 'Détections & alertes',
                  icon: Icons.security_rounded,
                ),
                _WaterLeakCard(detected: _water, pulse: _pulse),
                const SizedBox(height: 14),

                // ── Caméra ESP32 ──────────────────────────
                const _CameraCard(),
                const SizedBox(height: 14),

                // ── Journal RFID ──────────────────────────
                const _SectionHeader(
                  title: 'Accès',
                  subtitle: 'Derniers passages RFID',
                  icon: Icons.nfc_rounded,
                ),
                const _RfidCard(),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── En-tête section ────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary =
        isDark ? AppColors.darkTextSecondary.withOpacity(0.75) : AppColors.lightTextSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.18),
              ),
            ),
            child: Icon(icon, size: 20, color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Barre résumé statut ───────────────────────────────────────
class _StatusSummary extends StatelessWidget {
  final double temp, humid, gas;
  final bool water;
  const _StatusSummary({
    required this.temp, required this.humid,
    required this.gas,  required this.water,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary =
        isDark ? AppColors.darkTextSecondary.withOpacity(0.75) : AppColors.lightTextSecondary;

    final items = <({IconData icon, String label, String value, bool alert, Color color})>[
      (
        icon: Icons.thermostat_rounded,
        label: 'Temp',
        value: '${temp.toStringAsFixed(1)}°C',
        alert: temp > 27,
        color: temp > 27 ? AppColors.error : (temp > 25 ? AppColors.warning : AppColors.success),
      ),
      (
        icon: Icons.water_drop_rounded,
        label: 'Hum',
        value: '${humid.toStringAsFixed(0)}%',
        alert: humid > 70,
        color: humid > 70 ? AppColors.warning : AppColors.cyan,
      ),
      (
        icon: Icons.cloud_outlined,
        label: 'Gaz',
        value: '${gas.toStringAsFixed(0)} ppm',
        alert: gas > 30,
        color: gas > 30 ? AppColors.error : AppColors.success,
      ),
      (
        icon: water ? Icons.water_damage_rounded : Icons.verified_rounded,
        label: 'Eau',
        value: water ? 'Fuite' : 'OK',
        alert: water,
        color: water ? AppColors.error : AppColors.success,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border.withOpacity(isDark ? 0.70 : 1),
        ),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
          blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: item.color.withOpacity(0.18)),
                  ),
                  child: Icon(item.icon, size: 18, color: item.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i != items.length - 1)
                  Container(
                    width: 1,
                    height: 34,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: border.withOpacity(isDark ? 0.35 : 0.9),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Carte capteur principale ──────────────────────────────────
class _SensorCard extends StatelessWidget {
  final String label, sub, value, status;
  final IconData icon;
  final Color color;
  final List<double> history;
  final double min, max;
  final AnimationController pulse;

  const _SensorCard({
    required this.label, required this.sub,
    required this.value, required this.status,
    required this.icon,  required this.color,
    required this.history, required this.min,
    required this.max, required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final title = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary.withOpacity(0.75) : AppColors.lightTextSecondary;
    final maxVal = history.reduce((a, b) => a > b ? a : b);
    final delta = history.last - history[history.length - 2];
    final trendUp = delta >= 0;
    final trendColor = trendUp ? AppColors.success : AppColors.warning;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border.withOpacity(isDark ? 0.70 : 1),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20, offset: const Offset(0, 6)),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: [
        // ── Header ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            // Icône avec glow
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15,
                  color: title,
                  letterSpacing: -0.3,
                )),
                Text(sub, style: TextStyle(
                  color: textSec, fontSize: 11,
                  fontWeight: FontWeight.w500)),
              ],
            )),
            // Badge statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Text(status, style: TextStyle(
                color: color, fontSize: 10,
                fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ]),
        ),

        // ── Valeur principale ─────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedBuilder(
                animation: pulse,
                builder: (_, __) => Text(value,
                  style: TextStyle(
                    fontSize: 38, fontWeight: FontWeight.w900,
                    color: Color.lerp(color, color.withOpacity(0.8), pulse.value * 0.2),
                    letterSpacing: -1,
                  ),
                ),
              ),
              const Spacer(),
              // Mini trend arrow
              Icon(
                history.last > history[history.length - 2]
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
                color: trendColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${trendUp ? '+' : ''}${delta.abs().toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: trendColor,
                ),
              ),
            ],
          ),
        ),

        // ── Graphique barres ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(history.length, (i) {
                final pct = maxVal > 0 ? history[i] / maxVal : 0.0;
                final isLast = i == history.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          height: pct * 52 + 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                color.withOpacity(isLast ? 0.9 : 0.45),
                                color.withOpacity(isLast ? 0.6 : 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: isLast
                              ? Border.all(color: color.withOpacity(0.5), width: 1)
                              : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // ── Footer ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Row(children: [
            Text('Dernières 8 mesures',
              style: TextStyle(color: textSec, fontSize: 10)),
            const Spacer(),
            Text('Min ${history.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}  '
              'Max ${history.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}',
              style: TextStyle(color: textSec, fontSize: 10,
                fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

// ── Carte fuite d'eau ─────────────────────────────────────────
class _WaterLeakCard extends StatelessWidget {
  final bool detected;
  final AnimationController pulse;
  const _WaterLeakCard({required this.detected, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final title = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary =
        isDark ? AppColors.darkTextSecondary.withOpacity(0.75) : AppColors.lightTextSecondary;
    final color = detected
      ? AppColors.error
      : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: detected
            ? AppColors.error.withOpacity(0.35)
            : border.withOpacity(isDark ? 0.70 : 1)),
        boxShadow: [
          if (detected)
            BoxShadow(color: AppColors.error.withOpacity(0.15),
              blurRadius: 20, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        AnimatedBuilder(
          animation: pulse,
          builder: (_, __) => Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1 + pulse.value * 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3 + pulse.value * 0.2)),
            ),
            child: Icon(
              detected ? Icons.water_damage_rounded : Icons.water_drop_outlined,
              color: color, size: 26,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Détection fuite d\'eau',
              style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15,
                color: title,
                letterSpacing: -0.3,
              )),
            const SizedBox(height: 3),
            Text('Capteur eau — ESP32',
              style: TextStyle(
                color: secondary,
                fontSize: 11)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(children: [
            Text(
              detected ? 'ALERTE' : 'OK',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Caméra ESP32-CAM ──────────────────────────────────────────
class _CameraCard extends StatelessWidget {
  const _CameraCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradA = AppColors.navyDark;
    final gradB = (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.9);
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradA, gradB],
        ),
        boxShadow: [BoxShadow(
          color: gradA.withOpacity(0.35),
          blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(children: [
        // Grille décorative
        ...List.generate(5, (i) => Positioned(
          left: 0, right: 0,
          top: i * 38.0,
          child: Divider(
            color: Colors.white.withOpacity(0.04), height: 1),
        )),
        ...List.generate(5, (i) => Positioned(
          top: 0, bottom: 0,
          left: i * 70.0,
          child: VerticalDivider(
            color: Colors.white.withOpacity(0.04), width: 1),
        )),

        Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15)),
              ),
              child: const Icon(Icons.videocam_rounded,
                color: Colors.white54, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('Flux ESP32-CAM',
              style: TextStyle(color: Colors.white70,
                fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Connecter le flux RTSP',
              style: TextStyle(color: Colors.white.withOpacity(0.35),
                fontSize: 11)),
          ],
        )),

        // Badge LIVE
        Positioned(top: 14, left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('LIVE',
                style: TextStyle(color: Colors.white, fontSize: 10,
                  fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            ]),
          ),
        ),

        // Résolution badge
        Positioned(top: 14, right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Text('720p',
              style: TextStyle(color: Colors.white70, fontSize: 10,
                fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

// ── Journal RFID ──────────────────────────────────────────────
class _RfidCard extends StatelessWidget {
  const _RfidCard();

  static const _logs = [
    (name: 'Mohamed Ali',  time: '08:14', ok: true,  uid: 'A3F2E1'),
    (name: 'Sonia Ben',    time: '08:32', ok: true,  uid: 'B7C3D4'),
    (name: 'Inconnu',      time: '09:15', ok: false, uid: 'XXXXXX'),
    (name: 'Admin OMMP',   time: '10:00', ok: true,  uid: 'F1E2A3'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final title = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary.withOpacity(0.75) : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border.withOpacity(isDark ? 0.70 : 1),
        ),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.nfc_rounded,
              color: AppColors.cyan, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Journal RFID',
                style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15,
                  color: title,
                  letterSpacing: -0.3,
                )),
              Text('${_logs.length} accès récents',
                style: TextStyle(color: textSec, fontSize: 11)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Actif',
              style: TextStyle(color: AppColors.success,
                fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ]),

        const SizedBox(height: 14),
        Divider(color: border.withOpacity(isDark ? 0.35 : 0.9)),
        const SizedBox(height: 8),

        // Logs
        ..._logs.map((l) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            // Avatar
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: (l.ok
                  ? AppColors.success
                  : AppColors.error).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (l.ok
                    ? AppColors.success
                    : AppColors.error).withOpacity(0.2)),
              ),
              child: Icon(
                l.ok ? Icons.check_rounded : Icons.close_rounded,
                color: l.ok
                  ? AppColors.success
                  : AppColors.error,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13,
                    color: title,
                  )),
                Text('UID: ${l.uid}',
                  style: TextStyle(color: textSec, fontSize: 10)),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(l.time,
                style: TextStyle(color: textSec, fontSize: 12,
                  fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (l.ok
                    ? AppColors.success
                    : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l.ok ? 'Autorisé' : 'Refusé',
                  style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: l.ok
                      ? AppColors.success
                      : AppColors.error,
                  ),
                ),
              ),
            ]),
          ]),
        )),
      ]),
    );
  }
}