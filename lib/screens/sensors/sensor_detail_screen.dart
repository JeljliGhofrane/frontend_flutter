import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
//  SENSOR DETAIL SCREEN — Design amélioré
// ══════════════════════════════════════════════════════════════

enum SensorType { temperature, humidity, gas, waterLeak, rfid, camera, environment }

class SensorDetailScreen extends StatefulWidget {
  final SensorType sensorType;
  final double currentValue;
  final String unit;

  const SensorDetailScreen({
    super.key,
    required this.sensorType,
    required this.currentValue,
    required this.unit,
  });

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulse;
  late AnimationController _enter;
  late Animation<double> _enterAnim;

  double _currentValue = 0;
  bool _isOn = true;
  final List<double> _history = [];

  @override
  void initState() {
    super.initState();
    _currentValue = widget.currentValue;
    _history.addAll(List.generate(20, (_) => widget.currentValue));

    // Animation d'entrée
    _enter = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _enterAnim = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    _enter.forward();

    // Pulsation valeur
    _pulse = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    // Simulation live
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      final rng = Random();
      setState(() {
        switch (widget.sensorType) {
          case SensorType.temperature:
            _currentValue = 20 + rng.nextDouble() * 10;
          case SensorType.humidity:
            _currentValue = 45 + rng.nextDouble() * 30;
          case SensorType.gas:
            _currentValue = rng.nextDouble() * 50;
          case SensorType.waterLeak:
            _currentValue = rng.nextInt(10) > 8 ? 1.0 : 0.0;
          default:
            _currentValue = _currentValue == 0 ? 1 : 0;
        }
        _history.removeAt(0);
        _history.add(_currentValue);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulse.dispose();
    _enter.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────
  String get _name {
    switch (widget.sensorType) {
      case SensorType.temperature: return 'Température';
      case SensorType.humidity:    return 'Humidité';
      case SensorType.gas:         return 'Gaz / Fumée';
      case SensorType.waterLeak:   return 'Fuite d\'eau';
      case SensorType.rfid:        return 'Contrôle RFID';
      case SensorType.camera:      return 'Caméra Live';
      case SensorType.environment: return 'Environnement';
    }
  }

  String get _subLabel {
    switch (widget.sensorType) {
      case SensorType.temperature:
      case SensorType.humidity:    return 'DHT22 — ESP32';
      case SensorType.gas:         return 'MQ-2 — ESP32';
      case SensorType.waterLeak:   return 'Capteur eau — ESP32';
      case SensorType.camera:      return 'ESP32-CAM';
      default:                     return 'Module ESP32';
    }
  }

  IconData get _icon {
    switch (widget.sensorType) {
      case SensorType.temperature: return Icons.thermostat_rounded;
      case SensorType.humidity:    return Icons.water_drop_rounded;
      case SensorType.gas:         return Icons.cloud_outlined;
      case SensorType.waterLeak:   return Icons.water_damage_rounded;
      case SensorType.rfid:        return Icons.nfc_rounded;
      case SensorType.camera:      return Icons.videocam_rounded;
      case SensorType.environment: return Icons.eco_rounded;
    }
  }

  Color get _color {
    switch (widget.sensorType) {
      case SensorType.temperature:
        if (_currentValue < 20) return const Color(0xFF4C9FD5);
        if (_currentValue < 28) return const Color(0xFF22C55E);
        if (_currentValue < 34) return const Color(0xFFFFB74D);
        return const Color(0xFFFF6B6B);
      case SensorType.humidity:
        return _currentValue < 70
          ? const Color(0xFF4C9FD5)
          : const Color(0xFFFFB74D);
      case SensorType.gas:
        return _currentValue < 30
          ? const Color(0xFF22C55E)
          : const Color(0xFFFF6B6B);
      case SensorType.waterLeak:
        return _currentValue > 0.5
          ? const Color(0xFFFF6B6B)
          : const Color(0xFF22C55E);
      default:
        return const Color(0xFF4C9FD5);
    }
  }

  String get _status {
    switch (widget.sensorType) {
      case SensorType.temperature:
        if (_currentValue < 20) return 'FROID';
        if (_currentValue < 28) return 'NORMAL';
        if (_currentValue < 34) return 'AVERTISSEMENT';
        return 'CRITIQUE';
      case SensorType.humidity:
        return _currentValue < 70 ? 'NORMALE' : 'ÉLEVÉE';
      case SensorType.gas:
        return _currentValue < 30 ? 'NORMAL' : 'DANGER';
      case SensorType.waterLeak:
        return _currentValue > 0.5 ? 'FUITE DÉTECTÉE' : 'AUCUNE FUITE';
      case SensorType.rfid:
        return _isOn ? 'ACTIF' : 'INACTIF';
      default:
        return 'EN LIGNE';
    }
  }

  String get _formattedValue {
    if (widget.sensorType == SensorType.waterLeak) {
      return _currentValue > 0.5 ? 'FUITE' : 'OK';
    }
    return '${_currentValue.toStringAsFixed(1)}${widget.unit}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = _color;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
          // ── AppBar flottant ──────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF1A2744),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(_name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _enterAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(_enterAnim),
                child: Column(children: [

                  // ── Hero Card valeur ────────────────────
                  _HeroCard(
                    color: color, name: _name,
                    subLabel: _subLabel, icon: _icon,
                    formattedValue: _formattedValue,
                    status: _status, pulse: _pulse,
                    isDark: isDark,
                  ),

                  // ── Statistiques ────────────────────────
                  if (widget.sensorType != SensorType.waterLeak)
                    _StatsRow(history: _history, color: color, isDark: isDark),

                  // ── Graphique ───────────────────────────
                  if (widget.sensorType != SensorType.waterLeak &&
                      widget.sensorType != SensorType.camera)
                    _ChartCard(history: _history, color: color, isDark: isDark),

                  // ── Seuils ──────────────────────────────
                  _ThresholdsCard(
                    sensorType: widget.sensorType,
                    currentValue: _currentValue,
                    color: color, isDark: isDark,
                  ),

                  // ── Contrôle toggle ─────────────────────
                  if (widget.sensorType == SensorType.rfid ||
                      widget.sensorType == SensorType.camera)
                    _ToggleCard(
                      isOn: _isOn, isDark: isDark,
                      onChanged: (v) => setState(() => _isOn = v),
                    ),

                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte hero avec valeur principale ────────────────────────
class _HeroCard extends StatelessWidget {
  final Color color;
  final String name, subLabel, formattedValue, status;
  final IconData icon;
  final AnimationController pulse;
  final bool isDark;

  const _HeroCard({
    required this.color, required this.name,
    required this.subLabel, required this.icon,
    required this.formattedValue, required this.status,
    required this.pulse, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF1A2035) : Colors.white,
            isDark
              ? Color.lerp(const Color(0xFF1A2035), color, 0.05)!
              : Color.lerp(Colors.white, color, 0.03)!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.12),
            blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: [
        // Icône + label
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              letterSpacing: -0.3)),
            Text(subLabel, style: TextStyle(
              color: isDark
                ? Colors.white.withOpacity(0.4)
                : const Color(0xFF718096),
              fontSize: 11)),
          ]),
          const Spacer(),
          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Text(status, style: TextStyle(
              color: color, fontSize: 10,
              fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ),
        ]),

        const SizedBox(height: 24),

        // Valeur principale avec cercle
        AnimatedBuilder(
          animation: pulse,
          builder: (_, __) => Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.05 + pulse.value * 0.03),
              border: Border.all(
                color: color.withOpacity(0.15 + pulse.value * 0.1),
                width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15 + pulse.value * 0.1),
                  blurRadius: 20 + pulse.value * 10,
                  spreadRadius: pulse.value * 4,
                ),
              ],
            ),
            child: Center(child: Text(formattedValue,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: formattedValue.length > 5 ? 22 : 34,
                fontWeight: FontWeight.w900,
                color: color, letterSpacing: -1,
              ),
            )),
          ),
        ),

        const SizedBox(height: 16),

        // Heure de mise à jour
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.access_time_rounded,
            size: 12, color: isDark
              ? Colors.white.withOpacity(0.3)
              : const Color(0xFF718096)),
          const SizedBox(width: 4),
          Text(
            'Mis à jour : ${DateTime.now().toString().substring(11, 19)}',
            style: TextStyle(fontSize: 11,
              color: isDark
                ? Colors.white.withOpacity(0.3)
                : const Color(0xFF718096)),
          ),
        ]),
      ]),
    );
  }
}

// ── Statistiques min/moy/max ──────────────────────────────────
class _StatsRow extends StatelessWidget {
  final List<double> history;
  final Color color;
  final bool isDark;
  const _StatsRow({required this.history, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final min = history.reduce((a, b) => a < b ? a : b);
    final max = history.reduce((a, b) => a > b ? a : b);
    final avg = history.reduce((a, b) => a + b) / history.length;
    final bg  = isDark ? const Color(0xFF1A2035) : Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
            ? Colors.white.withOpacity(0.06)
            : const Color(0xFFE8EDF8)),
      ),
      child: Row(children: [
        _StatItem(label: 'Min', value: min.toStringAsFixed(1),
          color: const Color(0xFF4C9FD5), isDark: isDark),
        _Divider(isDark: isDark),
        _StatItem(label: 'Moy', value: avg.toStringAsFixed(1),
          color: color, isDark: isDark),
        _Divider(isDark: isDark),
        _StatItem(label: 'Max', value: max.toStringAsFixed(1),
          color: const Color(0xFFFF6B6B), isDark: isDark),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;
  const _StatItem({required this.label, required this.value,
    required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: isDark ? Colors.white.withOpacity(0.4) : const Color(0xFF718096))),
    ]),
  );
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 36,
    color: isDark
      ? Colors.white.withOpacity(0.06)
      : const Color(0xFFE8EDF8),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

// ── Graphique barres amélioré ─────────────────────────────────
class _ChartCard extends StatelessWidget {
  final List<double> history;
  final Color color;
  final bool isDark;
  const _ChartCard({required this.history, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1A2035) : Colors.white;
    final textSec = isDark
      ? Colors.white.withOpacity(0.4)
      : const Color(0xFF718096);
    // Dernières 12 valeurs
    final data = history.length > 12 ? history.sublist(history.length - 12) : history;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
            ? Colors.white.withOpacity(0.06)
            : const Color(0xFFE8EDF8)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Historique',
            style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              letterSpacing: -0.3)),
          const Spacer(),
          Text('20 dernières mesures',
            style: TextStyle(color: textSec, fontSize: 10)),
        ]),
        const SizedBox(height: 16),

        // Lignes de grille + barres
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.asMap().entries.map((e) {
              final i   = e.key;
              final val = e.value;
              final pct = maxVal > minVal
                ? (val - minVal) / (maxVal - minVal)
                : 0.5;
              final isLast = i == data.length - 1;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Valeur au-dessus de la dernière barre
                      if (isLast)
                        Text(val.toStringAsFixed(0),
                          style: TextStyle(fontSize: 9,
                            color: color, fontWeight: FontWeight.w800))
                      else
                        const SizedBox(height: 12),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        height: pct * 72 + 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              color.withOpacity(isLast ? 1.0 : 0.5),
                              color.withOpacity(isLast ? 0.7 : 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: isLast
                            ? [BoxShadow(color: color.withOpacity(0.4),
                                blurRadius: 8, offset: const Offset(0, 2))]
                            : [],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 10),
        Row(children: [
          Text('Min ${minVal.toStringAsFixed(1)}',
            style: TextStyle(color: const Color(0xFF4C9FD5),
              fontSize: 11, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('Max ${maxVal.toStringAsFixed(1)}',
            style: TextStyle(color: const Color(0xFFFF6B6B),
              fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

// ── Carte seuils ─────────────────────────────────────────────
class _ThresholdsCard extends StatelessWidget {
  final SensorType sensorType;
  final double currentValue;
  final Color color;
  final bool isDark;

  const _ThresholdsCard({
    required this.sensorType, required this.currentValue,
    required this.color, required this.isDark,
  });

  List<({String label, double value, Color c})> get _thresholds {
    switch (sensorType) {
      case SensorType.temperature:
        return [
          (label: 'Minimum', value: 18, c: const Color(0xFF4C9FD5)),
          (label: 'Optimal', value: 24, c: const Color(0xFF22C55E)),
          (label: 'Avertissement', value: 25, c: const Color(0xFFFFB74D)),
          (label: 'Critique', value: 27, c: const Color(0xFFFF6B6B)),
        ];
      case SensorType.humidity:
        return [
          (label: 'Minimum', value: 40, c: const Color(0xFF4C9FD5)),
          (label: 'Optimal', value: 55, c: const Color(0xFF22C55E)),
          (label: 'Élevée', value: 70, c: const Color(0xFFFFB74D)),
        ];
      case SensorType.gas:
        return [
          (label: 'Normal', value: 10, c: const Color(0xFF22C55E)),
          (label: 'Avertissement', value: 30, c: const Color(0xFFFFB74D)),
          (label: 'Danger', value: 50, c: const Color(0xFFFF6B6B)),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final thresholds = _thresholds;
    if (thresholds.isEmpty) return const SizedBox.shrink();

    final bg = isDark ? const Color(0xFF1A2035) : Colors.white;
    final textSec = isDark
      ? Colors.white.withOpacity(0.4)
      : const Color(0xFF718096);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
            ? Colors.white.withOpacity(0.06)
            : const Color(0xFFE8EDF8)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Seuils & normes TIA-942',
          style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            letterSpacing: -0.3)),
        const SizedBox(height: 14),
        ...thresholds.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(width: 8, height: 8,
              decoration: BoxDecoration(
                color: t.c, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(t.label,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E)))),
            Text('${t.value.toStringAsFixed(0)}${
              sensorType == SensorType.humidity ? '%' :
              sensorType == SensorType.gas ? ' ppm' : '°C'}',
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: textSec)),
            const SizedBox(width: 8),
            if (currentValue >= t.value &&
                (thresholds.last == t ||
                 currentValue < thresholds[thresholds.indexOf(t) + 1 < thresholds.length
                   ? thresholds.indexOf(t) + 1
                   : thresholds.indexOf(t)].value))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: t.c.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Actuel',
                  style: TextStyle(color: t.c, fontSize: 9,
                    fontWeight: FontWeight.w800)),
              )
            else
              const SizedBox(width: 38),
          ]),
        )),
      ]),
    );
  }
}

// ── Toggle contrôle ───────────────────────────────────────────
class _ToggleCard extends StatelessWidget {
  final bool isOn;
  final bool isDark;
  final ValueChanged<bool> onChanged;
  const _ToggleCard({required this.isOn, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A2035) : Colors.white;
    final color = isOn ? const Color(0xFF22C55E) : const Color(0xFF718096);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            isOn ? Icons.power_settings_new_rounded : Icons.power_off_rounded,
            color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Activer / Désactiver',
            style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
          Text(isOn ? 'Module actif' : 'Module inactif',
            style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ])),
        Switch(
          value: isOn,
          onChanged: onChanged,
          activeColor: const Color(0xFF22C55E),
          activeTrackColor: const Color(0xFF22C55E).withOpacity(0.3),
        ),
      ]),
    );
  }
}