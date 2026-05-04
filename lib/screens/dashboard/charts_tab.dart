import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';

// ════════════════════════════════════════════════════════════
//  Palette claire & épurée
// ════════════════════════════════════════════════════════════
class _C {
  static const bg       = Color(0xFFF7F8FA);
  static const card     = Color(0xFFFFFFFF);
  static const border   = Color(0xFFEAECF0);

  static const textP    = Color(0xFF111827);
  static const textS    = Color(0xFF6B7280);
  static const textT    = Color(0xFF9CA3AF);

  static const temp     = Color(0xFFEF4444);
  static const tempFill = Color(0x18EF4444);
  static const hum      = Color(0xFF3B82F6);
  static const humFill  = Color(0x183B82F6);

  static const ok       = Color(0xFF10B981);
  static const warn     = Color(0xFFF59E0B);
  static const danger   = Color(0xFFEF4444);

  static const okBg     = Color(0xFFECFDF5);
  static const warnBg   = Color(0xFFFFFBEB);
  static const dangerBg = Color(0xFFFEF2F2);
}

// ════════════════════════════════════════════════════════════
//  Widget principal
// ════════════════════════════════════════════════════════════
class ChartsTab extends StatefulWidget {
  const ChartsTab({super.key});
  @override
  State<ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  static const _maxPoints = 30;

  final List<double> _tempHistory = [];
  final List<double> _humHistory  = [];
  final List<bool>   _gazHistory  = [];
  final List<bool>   _eauHistory  = [];

  Map<String, dynamic>? _donnees;
  Map<String, dynamic>? _prediction;
  bool    _loading = true;
  String? _error;
  Timer?  _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final d = await ApiService().getDonnees();
      final p = await ApiService().getPrediction();
      if (!mounted) return;

      final temp  = (d?['temperature']?['temperature'] as num?)?.toDouble();
      final humid = (d?['humidite']?['humidite']       as num?)?.toDouble();
      final gaz   = d?['gaz']?['detecte'] as bool? ?? false;
      final eau   = d?['eau']?['detecte'] as bool? ?? false;

      void push<T>(List<T> list, T val) {
        list.add(val);
        if (list.length > _maxPoints) list.removeAt(0);
      }

      if (temp  != null) push(_tempHistory, temp);
      if (humid != null) push(_humHistory,  humid);
      push(_gazHistory, gaz);
      push(_eauHistory, eau);

      setState(() {
        _donnees = d; _prediction = p;
        _loading = false; _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = "Impossible de joindre l'API"; });
    }
  }

  double? get _temp  => (_donnees?['temperature']?['temperature'] as num?)?.toDouble();
  double? get _humid => (_donnees?['humidite']?['humidite']       as num?)?.toDouble();
  bool    get _gaz   =>  _donnees?['gaz']?['detecte'] as bool? ?? false;
  bool    get _eau   =>  _donnees?['eau']?['detecte'] as bool? ?? false;

  static _Status _tempStatus(double? t) {
    if (t == null) return _Status.na;
    if (t >= 27)   return _Status.danger;
    if (t >= 25)   return _Status.warn;
    return _Status.ok;
  }

  static _Status _humStatus(double? h) {
    if (h == null)         return _Status.na;
    if (h > 60 || h < 40) return _Status.warn;
    return _Status.ok;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _C.temp, strokeWidth: 2))
            : RefreshIndicator(
                onRefresh: _load,
                color: _C.temp,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  children: [
                    _Header(error: _error),
                    const SizedBox(height: 20),

                    _SummaryRow(temp: _temp, humid: _humid, gaz: _gaz, eau: _eau),
                    const SizedBox(height: 20),

                    _LineCard(
                      label: 'Température',
                      sensor: 'DS18B20',
                      value: _temp != null ? '${_temp!.toStringAsFixed(1)}°C' : '—',
                      history: _tempHistory,
                      lineColor: _C.temp,
                      fillColor: _C.tempFill,
                      minY: 15, maxY: 40,
                      threshMin: 20, threshMax: 27,
                      unit: '°C',
                      status: _tempStatus(_temp),
                    ),
                    const SizedBox(height: 14),

                    _LineCard(
                      label: 'Humidité',
                      sensor: 'DHT22',
                      value: _humid != null ? '${_humid!.toStringAsFixed(1)}%' : '—',
                      history: _humHistory,
                      lineColor: _C.hum,
                      fillColor: _C.humFill,
                      minY: 20, maxY: 85,
                      threshMin: 40, threshMax: 60,
                      unit: '%',
                      status: _humStatus(_humid),
                    ),
                    const SizedBox(height: 22),

                    const _SectionLabel('Capteurs discrets'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _BinaryCard(
                        label: 'Gaz / Fumée', sensor: 'MQ-2',
                        icon: Icons.air_rounded,
                        detected: _gaz,
                        alertColor: _C.warn, alertBg: _C.warnBg,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _BinaryCard(
                        label: "Fuite d'eau", sensor: 'Water Sensor',
                        icon: Icons.water_rounded,
                        detected: _eau,
                        alertColor: _C.danger, alertBg: _C.dangerBg,
                      )),
                    ]),
                    const SizedBox(height: 22),

                    const _SectionLabel('Historique détections'),
                    const SizedBox(height: 12),
                    _TimelineCard(label: 'Gaz', history: _gazHistory, color: _C.warn),
                    const SizedBox(height: 10),
                    _TimelineCard(label: 'Eau', history: _eauHistory, color: _C.hum),
                    const SizedBox(height: 22),

                    if (_prediction?['message'] != null) ...[
                      const _SectionLabel('Prédiction IA'),
                      const SizedBox(height: 12),
                      _PredCard(pred: _prediction!),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Enum statut
// ════════════════════════════════════════════════════════════
enum _Status { ok, warn, danger, na }

extension _StatusX on _Status {
  Color get color => switch (this) {
    _Status.ok     => _C.ok,
    _Status.warn   => _C.warn,
    _Status.danger => _C.danger,
    _Status.na     => _C.textT,
  };

  Color get bg => switch (this) {
    _Status.ok     => _C.okBg,
    _Status.warn   => _C.warnBg,
    _Status.danger => _C.dangerBg,
    _Status.na     => const Color(0xFFF3F4F6),
  };

  String get label => switch (this) {
    _Status.ok     => 'Normal',
    _Status.warn   => 'Attention',
    _Status.danger => 'Danger',
    _Status.na     => 'N/A',
  };
}

// ════════════════════════════════════════════════════════════
//  En-tête
// ════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final String? error;
  const _Header({this.error});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Capteurs',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                color: _C.textP, letterSpacing: -0.5)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: error != null ? _C.dangerBg : _C.okBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 6, height: 6,
                decoration: BoxDecoration(
                  color: error != null ? _C.danger : _C.ok,
                  shape: BoxShape.circle,
                )),
            const SizedBox(width: 6),
            Text(error != null ? 'Erreur' : 'En direct',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: error != null ? _C.danger : _C.ok,
                )),
          ]),
        ),
      ]),
      const SizedBox(height: 4),
      const Text('Mise à jour toutes les 3 secondes',
          style: TextStyle(fontSize: 13, color: _C.textS)),
      if (error != null) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _C.dangerBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.danger.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.wifi_off_rounded, color: _C.danger, size: 15),
            const SizedBox(width: 8),
            Text(error!, style: const TextStyle(color: _C.danger, fontSize: 12)),
          ]),
        ),
      ],
    ]);
  }
}

// ════════════════════════════════════════════════════════════
//  4 tuiles résumé
// ════════════════════════════════════════════════════════════
class _SummaryRow extends StatelessWidget {
  final double? temp, humid;
  final bool gaz, eau;
  const _SummaryRow({
    required this.temp, required this.humid,
    required this.gaz,  required this.eau,
  });

  @override
  Widget build(BuildContext context) {
    final tSt = _ChartsTabState._tempStatus(temp);
    final hSt = _ChartsTabState._humStatus(humid);

    return Row(children: [
      Expanded(child: _Tile(
        'Temp.', temp != null ? '${temp!.toStringAsFixed(1)}°' : '—',
        Icons.thermostat_rounded, tSt.color, tSt.bg,
      )),
      const SizedBox(width: 10),
      Expanded(child: _Tile(
        'Humidité', humid != null ? '${humid!.toStringAsFixed(0)}%' : '—',
        Icons.water_drop_rounded, hSt.color, hSt.bg,
      )),
      const SizedBox(width: 10),
      Expanded(child: _Tile(
        'Gaz', gaz ? 'Alerte' : 'OK',
        Icons.air_rounded,
        gaz ? _C.warn : _C.ok,
        gaz ? _C.warnBg : _C.okBg,
      )),
      const SizedBox(width: 10),
      Expanded(child: _Tile(
        'Eau', eau ? 'Fuite' : 'OK',
        Icons.water_rounded,
        eau ? _C.danger : _C.ok,
        eau ? _C.dangerBg : _C.okBg,
      )),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _Tile(this.label, this.value, this.icon, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 10, color: _C.textS, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Label de section
// ════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: _C.textS, letterSpacing: 0.2));
}

// ════════════════════════════════════════════════════════════
//  Badge statut
// ════════════════════════════════════════════════════════════
class _Badge extends StatelessWidget {
  final String text;
  final Color color, bg;
  const _Badge(this.text, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Carte graphique linéaire — épurée
// ════════════════════════════════════════════════════════════
class _LineCard extends StatelessWidget {
  final String label, sensor, value, unit;
  final List<double> history;
  final Color lineColor, fillColor;
  final double minY, maxY, threshMin, threshMax;
  final _Status status;

  const _LineCard({
    required this.label,     required this.sensor,
    required this.value,     required this.history,
    required this.lineColor, required this.fillColor,
    required this.minY,      required this.maxY,
    required this.threshMin, required this.threshMax,
    required this.unit,      required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // En-tête
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: _C.textP)),
            const SizedBox(height: 2),
            Text(sensor,
                style: const TextStyle(fontSize: 12, color: _C.textT)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: lineColor)),
            const SizedBox(height: 4),
            _Badge(status.label, status.color, status.bg),
          ]),
        ]),

        const SizedBox(height: 16),

        // Graphique
        if (history.length >= 2)
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minX: 0, maxX: (history.length - 1).toDouble(),
                minY: minY, maxY: maxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 4,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Color(0x0F000000), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: (maxY - minY) / 4,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10, color: _C.textT),
                      ),
                    ),
                  ),
                  rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  // Courbe principale
                  LineChartBarData(
                    spots: List.generate(
                        history.length, (i) => FlSpot(i.toDouble(), history[i])),
                    isCurved: true, curveSmoothness: 0.35,
                    color: lineColor, barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: fillColor),
                  ),
                  // Seuil max (pointillé rouge)
                  LineChartBarData(
                    spots: List.generate(
                        history.length, (i) => FlSpot(i.toDouble(), threshMax)),
                    isCurved: false,
                    color: _C.danger.withOpacity(0.30),
                    barWidth: 1,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          )
        else
          const SizedBox(
            height: 60,
            child: Center(
              child: Text('En attente de données…',
                  style: TextStyle(fontSize: 12, color: _C.textT)),
            ),
          ),

        const SizedBox(height: 10),

        // Légende
        Row(children: [
          Container(width: 16, height: 3,
              decoration: BoxDecoration(color: lineColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: _C.textS)),
          const SizedBox(width: 16),
          Container(width: 16, height: 2,
              decoration: BoxDecoration(
                  color: _C.danger.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(1))),
          const SizedBox(width: 6),
          Text('Seuil max $threshMax$unit',
              style: const TextStyle(fontSize: 11, color: _C.textS)),
          const Spacer(),
          Text('${history.length} pts',
              style: const TextStyle(fontSize: 10, color: _C.textT)),
        ]),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Capteur binaire
// ════════════════════════════════════════════════════════════
class _BinaryCard extends StatelessWidget {
  final String label, sensor;
  final IconData icon;
  final bool detected;
  final Color alertColor, alertBg;

  const _BinaryCard({
    required this.label,       required this.sensor,
    required this.icon,        required this.detected,
    required this.alertColor,  required this.alertBg,
  });

  @override
  Widget build(BuildContext context) {
    final c  = detected ? alertColor : _C.ok;
    final bg = detected ? alertBg    : _C.okBg;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: detected
            ? Border.all(color: alertColor.withOpacity(0.25))
            : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: c, size: 20),
          const Spacer(),
          Container(width: 8, height: 8,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        ]),
        const SizedBox(height: 12),
        Text(
          detected ? (label.contains('Gaz') ? 'Détecté' : 'Fuite') : 'Normal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c),
        ),
        const SizedBox(height: 2),
        Text(label,  style: const TextStyle(fontSize: 12, color: _C.textP, fontWeight: FontWeight.w500)),
        Text(sensor, style: const TextStyle(fontSize: 11, color: _C.textS)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Historique binaire (timeline en barres)
// ════════════════════════════════════════════════════════════
class _TimelineCard extends StatelessWidget {
  final String label;
  final List<bool> history;
  final Color color;

  const _TimelineCard({
    required this.label,
    required this.history,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final alerts = history.where((v) => v).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: _C.textP)),
          const Spacer(),
          Text(
            '$alerts alerte${alerts > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500,
              color: alerts > 0 ? color : _C.ok,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        if (history.isEmpty)
          const Text('En attente…',
              style: TextStyle(fontSize: 12, color: _C.textT))
        else
          Row(
            children: history.asMap().entries.map((e) => Expanded(
              child: Container(
                height: 22,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: e.value
                      ? color.withOpacity(0.75)
                      : _C.ok.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )).toList(),
          ),
        const SizedBox(height: 6),
        Text('${history.length} dernières mesures',
            style: const TextStyle(fontSize: 10, color: _C.textT)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Prédiction IA
// ════════════════════════════════════════════════════════════
class _PredCard extends StatelessWidget {
  final Map<String, dynamic> pred;
  const _PredCard({required this.pred});

  @override
  Widget build(BuildContext context) {
    final alerte  = pred['alerte']  as String? ?? 'NORMAL';
    final message = pred['message'] as String? ?? '';
    final predT   = pred['temperaturePredite'];
    final trend   = pred['trend']   as String? ?? '';

    final st = alerte == 'DANGER'        ? _Status.danger
             : alerte == 'AVERTISSEMENT' ? _Status.warn
             : _Status.ok;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: st.color.withOpacity(0.20)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: st.bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.psychology_rounded, color: st.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Prédiction IA',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.textP)),
            const Text('Régression linéaire · 20 min',
                style: TextStyle(fontSize: 11, color: _C.textS)),
          ])),
          _Badge(st.label, st.color, st.bg),
        ]),
        const SizedBox(height: 12),
        Text(message,
            style: const TextStyle(fontSize: 13, color: _C.textP, height: 1.5)),
        if (predT != null) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Text('Dans 20 min : ',
                style: TextStyle(fontSize: 12, color: _C.textS)),
            Text('$predT°C',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: st.color)),
          ]),
        ],
        if (trend.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            Icon(
              trend == 'MONTANTE'
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: trend == 'MONTANTE' ? _C.danger : _C.ok,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text('Tendance : $trend',
                style: const TextStyle(fontSize: 12, color: _C.textS)),
          ]),
        ],
      ]),
    );
  }
}