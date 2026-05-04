import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════
//  MODELS
// ═══════════════════════════════════════════════════════════
enum AlertLevel { danger, warning, info }

class PredictionData {
  final String title;
  final String prediction;
  final double confidence;
  final String recommendation;
  final IconData icon;
  final AlertLevel level;

  const PredictionData({
    required this.title,
    required this.prediction,
    required this.confidence,
    required this.recommendation,
    required this.icon,
    required this.level,
  });

  Color get color {
    switch (level) {
      case AlertLevel.danger:  return const Color(0xFFFF6B6B);
      case AlertLevel.warning: return const Color(0xFFFFB74D);
      case AlertLevel.info:    return const Color(0xFF4C9FD5);
    }
  }

  String get levelLabel {
    switch (level) {
      case AlertLevel.danger:  return 'CRITIQUE';
      case AlertLevel.warning: return 'ÉLEVÉ';
      case AlertLevel.info:    return 'INFO';
    }
  }
}

enum MsgType { text, card }

class ChatMessage {
  final String? text;
  final bool isUser;
  final MsgType type;
  final String? cardTitle;
  final List<String>? cardItems;
  final DateTime time;

  ChatMessage.text({required this.text, required this.isUser})
      : type = MsgType.text,
        cardTitle = null,
        cardItems = null,
        time = DateTime.now();

  ChatMessage.card({required this.cardTitle, required this.cardItems})
      : type = MsgType.card,
        text = null,
        isUser = false,
        time = DateTime.now();
}

// ═══════════════════════════════════════════════════════════
//  SERVICE GEMINI
// ═══════════════════════════════════════════════════════════
class GeminiService {
  static String get _base =>
      kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  /// Envoie un message à Gemini via le backend Node.js
  /// [message] : texte de l'utilisateur
  /// [history] : historique des messages précédents
  /// [sensorData] : données capteurs en temps réel (optionnel)
  static Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
    Map<String, dynamic>? sensorData,
  }) async {
    try {
      // Convertir l'historique Flutter → format API
      final historyJson = history
          .where((m) => m.text != null && m.text!.isNotEmpty)
          .map((m) => {'text': m.text, 'isUser': m.isUser})
          .toList();

      final res = await http.post(
        Uri.parse('$_base/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message'   : message,
          'history'   : historyJson,
          'sensorData': sensorData,
        }),
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['reply'] as String? ?? "Pas de réponse reçue.";
      }

      return "Erreur serveur (${res.statusCode}). Réessayez.";
    } catch (e) {
      return "Impossible de contacter Navigator. Vérifiez votre connexion.";
    }
  }

  /// Récupère les données capteurs depuis le backend
  static Future<Map<String, dynamic>?> fetchSensorData() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/donnees'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}

// ═══════════════════════════════════════════════════════════
//  ROOT WIDGET
// ═══════════════════════════════════════════════════════════
class AiAssistantTab extends StatelessWidget {
  const AiAssistantTab({super.key});

  static const _predictions = [
    PredictionData(
      title: 'Risque de surchauffe',
      prediction: 'Risque élevé dans les 2 prochaines heures selon les tendances capteurs.',
      confidence: 0.85,
      recommendation: 'Activer le refroidissement supplémentaire immédiatement',
      icon: Icons.thermostat_rounded,
      level: AlertLevel.warning,
    ),
    PredictionData(
      title: 'Comportement anormal',
      prediction: 'Variation de température inhabituelle — écart ±4 °C sur 30 min.',
      confidence: 0.72,
      recommendation: 'Vérifier les unités de climatisation du secteur B',
      icon: Icons.analytics_rounded,
      level: AlertLevel.warning,
    ),
    PredictionData(
      title: 'Maintenance préventive',
      prediction: 'Le capteur RFID du module 3 présente des signes de dégradation.',
      confidence: 0.68,
      recommendation: "Planifier une vérification du module RFID d'ici 72 h",
      icon: Icons.build_rounded,
      level: AlertLevel.info,
    ),
    PredictionData(
      title: 'Sécurité renforcée',
      prediction: "3 tentatives d'accès non autorisé détectées en 10 minutes.",
      confidence: 0.93,
      recommendation: 'Activer la double authentification en urgence',
      icon: Icons.security_rounded,
      level: AlertLevel.danger,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _ThemedBg(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 720) {
                return _WideLayout(predictions: _predictions);
              }
              return _NarrowLayout(predictions: _predictions);
            },
          ),
        ),
      ),
    );
  }
}

// ─── Background adaptatif ────────────────────────────────
class _ThemedBg extends StatelessWidget {
  final Widget child;
  const _ThemedBg({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0F1117), Color(0xFF141828), Color(0xFF0F1117)]
              : const [Color(0xFFCFDEEE), Color(0xFFD9E6F2), Color(0xFFEAF0F8)],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class _WideLayout extends StatelessWidget {
  final List<PredictionData> predictions;
  const _WideLayout({required this.predictions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _AlertsPanel(predictions: predictions)),
        Container(width: 0.5, color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(width: 380, child: _ChatPanel()),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final List<PredictionData> predictions;
  const _NarrowLayout({required this.predictions});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _NavTabBar(),
          Expanded(
            child: TabBarView(
              children: [
                _AlertsPanel(predictions: predictions),
                const _ChatPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final textSec = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      height: 44,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: outline),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFF4C5FD5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(
              color: const Color(0xFF4C5FD5).withValues(alpha: 0.30),
              blurRadius: 8)],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: textSec,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: 'Alertes IA'), Tab(text: 'Assistant')],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ALERTS PANEL — inchangé
// ═══════════════════════════════════════════════════════════
class _AlertsPanel extends StatelessWidget {
  final List<PredictionData> predictions;
  const _AlertsPanel({required this.predictions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AlertsHeader(count: predictions.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            itemCount: predictions.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PredictionCard(data: predictions[i], index: i),
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertsHeader extends StatelessWidget {
  final int count;
  const _AlertsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSec     = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF4C5FD5),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [BoxShadow(
                  color: const Color(0xFF4C5FD5).withValues(alpha: 0.30),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.notifications_active_rounded,
                color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Alertes IA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      color: textPrimary, letterSpacing: -0.2)),
              Text('$count alertes actives',
                  style: TextStyle(fontSize: 11, color: textSec)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count actives',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatefulWidget {
  final PredictionData data;
  final int index;
  const _PredictionCard({required this.data, required this.index});

  @override
  State<_PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<_PredictionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bar, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 800));
    _bar  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: 80 + widget.index * 90), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d           = widget.data;
    final surface     = Theme.of(context).colorScheme.surface;
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSec     = Theme.of(context).colorScheme.onSurfaceVariant;
    final tipBg = isDark ? const Color(0xFF1E2547) : const Color(0xFFEEF3FA);
    final barBg = isDark ? const Color(0xFF2A2F45) : const Color(0xFFE0EAF5);

    return AnimatedBuilder(
      animation: _fade,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
            offset: Offset(0, 14 * (1 - _fade.value)), child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(color: d.color.withValues(alpha: 0.07),
                blurRadius: 18, offset: const Offset(0, 7)),
            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(width: 4, color: d.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                            color: d.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(d.icon, color: d.color, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(d.title,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                              color: textPrimary, letterSpacing: -0.1))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: d.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(d.levelLabel,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                                color: d.color, letterSpacing: 0.4)),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(d.prediction,
                        style: TextStyle(fontSize: 12.5, color: textSec, height: 1.5)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                          color: tipBg, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.lightbulb_rounded,
                            size: 13, color: Color(0xFFFFB74D)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(d.recommendation,
                            style: TextStyle(fontSize: 11.5,
                                color: textSec, height: 1.4))),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _bar,
                      builder: (_, __) => Column(children: [
                        Row(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: d.confidence * _bar.value,
                                backgroundColor: barBg,
                                valueColor: AlwaysStoppedAnimation<Color>(d.color),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${(d.confidence * 100).toInt()}%',
                              style: TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w700, color: d.color)),
                        ]),
                        const SizedBox(height: 3),
                        Align(alignment: Alignment.centerLeft,
                          child: Text('Indice de confiance',
                              style: TextStyle(fontSize: 10, color: textSec))),
                      ]),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CHAT PANEL — connecté à Gemini ✅
// ═══════════════════════════════════════════════════════════
class _ChatPanel extends StatefulWidget {
  const _ChatPanel();

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final TextEditingController _ctrl   = TextEditingController();
  final ScrollController      _scroll = ScrollController();
  bool _isTyping = false;

  // Données capteurs — récupérées au démarrage et mises à jour
  Map<String, dynamic>? _sensorData;

  final List<ChatMessage> _msgs = [
    ChatMessage.text(text: 'Hey there! Je suis Navigator 👋', isUser: false),
    ChatMessage.text(
        text: "Je surveille vos systèmes en temps réel. Posez-moi n'importe quelle question sur vos capteurs.",
        isUser: false),
  ];

  static const _quickActions = [
    'Résumé alertes',
    'Surchauffe ?',
    'Statut capteurs',
    'Rapport complet',
  ];

  @override
  void initState() {
    super.initState();
    _loadSensorData();
    // Rafraîchir les données capteurs toutes les 30 secondes
    Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadSensorData();
    });
  }

  Future<void> _loadSensorData() async {
    final data = await GeminiService.fetchSensorData();
    if (mounted) setState(() => _sensorData = data);
  }

  // ── Envoyer message à Gemini ────────────────────────────
  Future<void> _send([String? quick]) async {
    final text = quick ?? _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();

    setState(() {
      _msgs.add(ChatMessage.text(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollDown();

    // Appel réel à Gemini via le backend
    final reply = await GeminiService.sendMessage(
      message   : text,
      history   : _msgs.where((m) => m.text != null).toList(),
      sensorData: _sensorData,
    );

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _msgs.add(ChatMessage.text(text: reply, isUser: false));
    });
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChatHeader(sensorData: _sensorData),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            itemCount: _msgs.length + (_isTyping ? 1 : 0),
            itemBuilder: (_, i) {
              if (_isTyping && i == _msgs.length) return const _TypingBubble();
              return _MessageBubble(msg: _msgs[i]);
            },
          ),
        ),
        _QuickChips(actions: _quickActions, onTap: _send),
        const SizedBox(height: 6),
        _InputBar(controller: _ctrl, onSend: _send),
        const SizedBox(height: 14),
      ],
    );
  }
}

// ─── Chat Header avec statut capteurs ─────────────────────
class _ChatHeader extends StatelessWidget {
  final Map<String, dynamic>? sensorData;
  const _ChatHeader({this.sensorData});

  @override
  Widget build(BuildContext context) {
    final surface     = Theme.of(context).colorScheme.surface;
    final outline     = Theme.of(context).colorScheme.outlineVariant;
    final textSec     = Theme.of(context).colorScheme.onSurfaceVariant;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    // Nombre d'alertes actives
    int alertCount = 0;
    if (sensorData != null) {
      final temp  = sensorData!['temperature'];
      final humid = sensorData!['humidite'];
      final gaz   = sensorData!['gaz'];
      final eau   = sensorData!['eau'];
      if (temp  != null && temp['statut']  != 'NORMAL') alertCount++;
      if (humid != null && humid['statut'] != 'NORMAL') alertCount++;
      if (gaz   != null && gaz['statut']   == 'ALERTE') alertCount++;
      if (eau   != null && eau['statut']   == 'FUITE')  alertCount++;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          const _BotOrb(size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Navigator',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: textPrimary, letterSpacing: -0.2)),
              Row(children: [
                const _PulsingDot(),
                const SizedBox(width: 4),
                Text(
                  alertCount > 0
                      ? 'En ligne · $alertCount alerte${alertCount > 1 ? "s" : ""}'
                      : 'En ligne · Surveillance active',
                  style: TextStyle(
                    fontSize: 11,
                    color: alertCount > 0
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF2ECC88),
                  ),
                ),
              ]),
            ]),
          ),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: surface, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: outline),
            ),
            child: Icon(Icons.more_horiz_rounded, size: 18, color: textSec),
          ),
        ],
      ),
    );
  }
}

// ─── Bot Orb ───────────────────────────────────────────────
class _BotOrb extends StatefulWidget {
  final double size;
  const _BotOrb({required this.size});

  @override
  State<_BotOrb> createState() => _BotOrbState();
}

class _BotOrbState extends State<_BotOrb> with SingleTickerProviderStateMixin {
  late AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100));
    _scheduleBlink();
  }

  Future<void> _scheduleBlink() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 2 + Random().nextInt(4)));
      if (!mounted) return;
      await _blink.forward();
      await _blink.reverse();
    }
  }

  @override
  void dispose() { _blink.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = widget.size;

    return Container(
      width: s, height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: isDark
              ? [const Color(0xFF2A2F4A), const Color(0xFF1A1D30)]
              : [const Color(0xFFF4F7FF), const Color(0xFFD0D8F0)],
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4C5FD5).withValues(alpha: 0.25),
              blurRadius: 14, offset: const Offset(0, 5)),
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Container(
          width: s * 0.65, height: s * 0.38,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1117) : const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(s * 0.18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BotEye(size: s * 0.15, blink: _blink),
              SizedBox(width: s * 0.11),
              _BotEye(size: s * 0.15, blink: _blink),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotEye extends StatelessWidget {
  final double size;
  final AnimationController blink;
  const _BotEye({required this.size, required this.blink});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: blink,
      builder: (_, __) => Transform.scale(
        scaleY: 1.0 - blink.value * 0.9,
        child: Container(
          width: size, height: size * 1.3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.5),
            boxShadow: [BoxShadow(
                color: Colors.white.withValues(alpha: 0.85), blurRadius: 6)],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: 6, height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            const Color(0xFF2ECC88).withValues(alpha: 0.3),
            const Color(0xFF2ECC88),
            _c.value,
          )!,
        ),
      ),
    );
  }
}

// ─── Message Bubble ────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser      = msg.isUser;
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final surface     = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textHint    = Theme.of(context).colorScheme.onSurfaceVariant;

    const bubbleUserColor = Color(0xFF1E2D6E);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[const _BotOrb(size: 28), const SizedBox(width: 7)],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: isUser ? bubbleUserColor : surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 5),
                      bottomRight: Radius.circular(isUser ? 5 : 20),
                    ),
                    boxShadow: [BoxShadow(
                      color: isUser
                          ? bubbleUserColor.withValues(alpha: 0.22)
                          : Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.06),
                      blurRadius: 10, offset: const Offset(0, 4),
                    )],
                  ),
                  child: Text(
                    msg.text ?? '',
                    style: TextStyle(
                      fontSize: 13.5, height: 1.5,
                      color: isUser ? Colors.white : textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(msg.time),
                  style: TextStyle(fontSize: 10, color: textHint),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 7),
            const _UserAvatar(),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF4C5FD5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(
            color: const Color(0xFF4C5FD5).withValues(alpha: 0.30),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 15),
    );
  }
}

// ─── Typing Bubble ─────────────────────────────────────────
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with TickerProviderStateMixin {
  late List<AnimationController> _dots;

  @override
  void initState() {
    super.initState();
    _dots = List.generate(3, (i) {
      final c = AnimationController(vsync: this,
          duration: const Duration(milliseconds: 580));
      Future.delayed(Duration(milliseconds: i * 190), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() { for (final c in _dots) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final textHint = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const _BotOrb(size: 28),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20),
              bottomLeft: Radius.circular(5), bottomRight: Radius.circular(20),
            ),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedBuilder(
                animation: _dots[i],
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, -5 * _dots[i].value),
                  child: Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: textHint.withValues(
                          alpha: 0.4 + 0.6 * _dots[i].value),
                    ),
                  ),
                ),
              ),
            )),
          ),
        ),
      ]),
    );
  }
}

// ─── Quick Chips ───────────────────────────────────────────
class _QuickChips extends StatelessWidget {
  final List<String> actions;
  final void Function(String) onTap;
  const _QuickChips({required this.actions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) =>
            _QuickChip(label: actions[i], onTap: () => onTap(actions[i])),
      ),
    );
  }
}

class _QuickChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  State<_QuickChip> createState() => _QuickChipState();
}

class _QuickChipState extends State<_QuickChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final textSec = Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF4C5FD5) : surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: _pressed ? const Color(0xFF4C5FD5) : outline),
          boxShadow: _pressed
              ? [BoxShadow(
                  color: const Color(0xFF4C5FD5).withValues(alpha: 0.30),
                  blurRadius: 8)]
              : [],
        ),
        child: Text(widget.label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: _pressed ? Colors.white : textSec)),
      ),
    );
  }
}

// ─── Input Bar ─────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final surface     = Theme.of(context).colorScheme.surface;
    final outline     = Theme.of(context).colorScheme.outlineVariant;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textHint    = Theme.of(context).colorScheme.onSurfaceVariant;
    final isDark      = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: outline),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1, maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: TextStyle(fontSize: 13.5, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Écrivez un message...',
                hintStyle: TextStyle(color: textHint, fontSize: 13.5),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF4C5FD5),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                    color: const Color(0xFF4C5FD5).withValues(alpha: 0.30),
                    blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: const Icon(Icons.arrow_upward_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ]),
      ),
    );
  }
}