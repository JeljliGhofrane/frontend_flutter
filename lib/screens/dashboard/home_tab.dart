import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

// ════════════════════════════════════════════════════════════
//  Palette — light & dark
// ════════════════════════════════════════════════════════════
class _P {
  // ── Light ──
  static const bgLight         = Color(0xFFEFF1F8);
  static const cardLight       = Color(0xFFFFFFFF);
  static const textPLight      = Color(0xFF1A1C24);
  static const textSLight      = Color(0xFF8C91A9);
  static const sensorBgLight   = Color(0xFFE8EAF2);

  // ── Dark ──
  static const bgDark          = Color(0xFF0F1117);
  static const cardDark        = Color(0xFF1C1F2E);
  static const textPDark       = Color(0xFFE8EAF2);
  static const textSDark       = Color(0xFF6B6F85);
  static const sensorBgDark    = Color(0xFF1E2130);

  // ── Shared ──
  static const accent          = Color(0xFF4A6CF7);
  static const alertStart      = Color(0xFFFF5F6D);
  static const alertEnd        = Color(0xFFFFC371);

  // ── Helpers ──
  static Color bg(BuildContext ctx)       => _isDark(ctx) ? bgDark       : bgLight;
  static Color card(BuildContext ctx)     => _isDark(ctx) ? cardDark     : cardLight;
  static Color textP(BuildContext ctx)    => _isDark(ctx) ? textPDark    : textPLight;
  static Color textS(BuildContext ctx)    => _isDark(ctx) ? textSDark    : textSLight;
  static Color sensorBg(BuildContext ctx) => _isDark(ctx) ? sensorBgDark : sensorBgLight;

  static bool _isDark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;
}

// ════════════════════════════════════════════════════════════
//  HomeTab
// ════════════════════════════════════════════════════════════
class HomeTab extends StatefulWidget {
  final String userRole;
  const HomeTab({super.key, required this.userRole});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Map<String, dynamic>? _donnees;
  Map<String, dynamic>? _prediction;
  Map<String, dynamic>? _aStats;
  Map<String, dynamic>? _jStats;
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final d = await ApiService().getDonnees();
    final p = await ApiService().getPrediction();
    final a = widget.userRole == 'admin' ? await ApiService().getAlertesStats()  : null;
    final j = widget.userRole == 'admin' ? await ApiService().getJournauxStats() : null;
    if (!mounted) return;
    setState(() {
      _donnees    = d;  _prediction = p;
      _aStats     = a;  _jStats     = j;
      _loading    = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user  = AuthService().currentUser;
    final temp  = (_donnees?['temperature']?['temperature'] as num?)?.toDouble();
    final humid = (_donnees?['humidite']?['humidite']       as num?)?.toDouble();
    final gaz   = _donnees?['gaz']?['detecte'] as bool? ?? false;
    final eau   = _donnees?['eau']?['detecte'] as bool? ?? false;

    return Scaffold(
      backgroundColor: _P.bg(context),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _P.accent, strokeWidth: 2))
            : RefreshIndicator(
                onRefresh: _load,
                color: _P.accent,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  children: [

                    // ── Header ───────────────────────────────
                    _Header(user: user),
                    const SizedBox(height: 16),

                    // ── Badge rôle ────────────────────────────
                    _RoleBadge(role: widget.userRole),
                    const SizedBox(height: 28),

                    // ── Titre section ─────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mes Capteurs',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: _P.textP(context), letterSpacing: -0.4)),
                        Text(_donnees != null ? 'En direct' : '--',
                            style: const TextStyle(
                                fontSize: 12, color: _P.accent,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Grille 2×2 capteurs ───────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.88,
                      children: [
                        _SensorGridCard(
                          title: 'Température',
                          subtitle: 'smart température sensor',
                          value: temp != null ? '${temp.toStringAsFixed(1)}°C' : '--',
                          imagePath: 'assets/images/temp.png',
                          isAlert: temp != null && temp >= 27,
                          accentColor: const Color(0xFF4A6CF7),
                        ),
                        _SensorGridCard(
                          title: 'Humidité',
                          subtitle: 'smart humidité sensor',
                          value: humid != null ? '${humid.toStringAsFixed(0)}%' : '--',
                          imagePath: 'assets/images/hum.png',
                          isAlert: humid != null && (humid > 70 || humid < 30),
                          accentColor: const Color(0xFF00B4D8),
                        ),
                        _SensorGridCard(
                          title: 'Gaz',
                          subtitle: 'smart gaz sensor',
                          value: gaz ? 'Détecté' : 'Normal',
                          imagePath: 'assets/images/gaz.png',
                          isAlert: gaz,
                          accentColor: const Color(0xFFFF9800),
                        ),
                        _SensorGridCard(
                          title: 'Eau',
                          subtitle: 'Climatisation',
                          value: eau ? 'Fuite !' : 'Normal',
                          imagePath: 'assets/images/clim.png',
                          isAlert: eau,
                          accentColor: const Color(0xFF00C9A7),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Prédiction IA ─────────────────────────
                    if (_prediction != null) ...[
                      _IAPredCard(pred: _prediction!),
                      const SizedBox(height: 28),
                    ],

                    // ── Stats admin ───────────────────────────
                    if (widget.userRole == 'admin') ...[
                      Text('Statistiques Système',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                              color: _P.textP(context))),
                      const SizedBox(height: 14),
                      _AdminStats(aStats: _aStats, jStats: _jStats),
                      const SizedBox(height: 28),
                    ],

                    // ── Journaux récents ──────────────────────
                    if (widget.userRole == 'admin')
                      const _RecentJournaux(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  En-tête
// ════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final dynamic user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bonjour,',
              style: TextStyle(color: _P.textS(context), fontSize: 15, fontWeight: FontWeight.w500)),
          Text(
            user?.prenom ?? 'Utilisateur',
            style: TextStyle(
                color: _P.textP(context), fontSize: 26,
                fontWeight: FontWeight.w900, letterSpacing: -0.8),
          ),
        ]),
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                colors: [_P.alertStart, _P.alertEnd]),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: _P.card(context),
            child: Icon(Icons.person_rounded, color: _P.textP(context), size: 28),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Badge rôle
// ════════════════════════════════════════════════════════════
class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (role) {
      'admin'      => (const Color(0xFF4A6CF7), 'Administrateur', Icons.admin_panel_settings_rounded),
      'technicien' => (const Color(0xFF00B4D8), 'Technicien',     Icons.engineering_rounded),
      _            => (const Color(0xFF66BB6A), 'Employé',        Icons.badge_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.22), width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Carte capteur — style grille avec image en fond
// ════════════════════════════════════════════════════════════
class _SensorGridCard extends StatelessWidget {
  final String title, subtitle, value, imagePath;
  final bool isAlert;
  final Color accentColor;

  const _SensorGridCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.imagePath,
    required this.isAlert,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = _P.sensorBg(context);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: isAlert
            ? Border.all(color: _P.alertStart.withOpacity(0.55), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: (isAlert ? _P.alertStart : Colors.black).withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── Image capteur ──
            Positioned(
              top: 0, left: 0, right: 0,
              height: 155,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: bg,
                  child: Icon(Icons.sensors_rounded,
                      color: accentColor.withOpacity(0.4), size: 48),
                ),
              ),
            ),

            // ── Alerte dot ──
            if (isAlert)
              Positioned(
                top: 12, right: 12,
                child: Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(
                    color: _P.alertStart,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // ── Icône sparkle ──
            Positioned(
              bottom: 68, right: 12,
              child: Icon(Icons.auto_awesome_rounded,
                  color: Colors.white.withOpacity(0.70), size: 18),
            ),

            // ── Bandeau infos ──
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                color: bg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: _P.textP(context), letterSpacing: -0.2)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isAlert ? _P.alertStart : _P.textS(context))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Prédiction IA
// ════════════════════════════════════════════════════════════
class _IAPredCard extends StatelessWidget {
  final Map<String, dynamic> pred;
  const _IAPredCard({required this.pred});

  @override
  Widget build(BuildContext context) {
    final alerte   = pred['alerte'] as String? ?? 'NORMAL';
    final isDanger = alerte == 'DANGER';

    return Container(
      width: double.infinity,
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: const AssetImage('assets/images/ai.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            (isDanger ? Colors.red : Colors.black).withOpacity(0.55),
            BlendMode.darken,
          ),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text('Prédiction IA',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w800, fontSize: 17)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(alerte,
                    style: const TextStyle(color: Colors.white,
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ]),
            const Spacer(),
            Text(pred['message'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w500)),
            if (pred['temperaturePredite'] != null) ...[
              const SizedBox(height: 6),
              Text('Prédiction : ${pred['temperaturePredite']}°C',
                  style: const TextStyle(color: Colors.white,
                      fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Stats admin
// ════════════════════════════════════════════════════════════
class _AdminStats extends StatelessWidget {
  final Map<String, dynamic>? aStats, jStats;
  const _AdminStats({required this.aStats, required this.jStats});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _MiniStat('Alertes',  '${aStats?['nonResolues'] ?? 0}', _P.alertStart),
      const SizedBox(width: 12),
      _MiniStat('Accès',    '${jStats?['dernieres24h'] ?? 0}', _P.accent),
      const SizedBox(width: 12),
      _MiniStat('Refusés',  '${jStats?['refuse'] ?? 0}',      Colors.orange),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _P.card(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03),
                blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: _P.textS(context), fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Journaux récents (admin)
// ════════════════════════════════════════════════════════════
class _RecentJournaux extends StatefulWidget {
  const _RecentJournaux();

  @override
  State<_RecentJournaux> createState() => _RecentJournauxState();
}

class _RecentJournauxState extends State<_RecentJournaux> {
  List<dynamic> _list    = [];
  bool          _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService().getJournaux(limite: 5);
    if (!mounted) return;
    setState(() {
      _list    = (res?['journaux'] as List? ?? []).take(5).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activité Récente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: _P.textP(context))),
        const SizedBox(height: 14),
        ..._list.map((j) {
          final ok = j['statut'] == 'autorise';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _P.card(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02),
                    blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(children: [
              Container(
                width: 45, height: 45,
                decoration: BoxDecoration(
                  color: (ok ? Colors.green : Colors.red).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/rfid.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      ok ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                      color: ok ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${j['prenom'] ?? ''} ${j['nom'] ?? 'Inconnu'}',
                      style: TextStyle(
                          color: _P.textP(context), fontWeight: FontWeight.w700)),
                  Text(j['typeAcces'] ?? 'RFID',
                      style: TextStyle(color: _P.textS(context), fontSize: 12)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (ok ? Colors.green : Colors.red).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ok ? 'Succès' : 'Refusé',
                  style: TextStyle(
                      color: ok ? Colors.green : Colors.red,
                      fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ]),
          );
        }),
      ],
    );
  }
}