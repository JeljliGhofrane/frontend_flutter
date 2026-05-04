import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AlertsTab extends StatefulWidget {
  /// true  → cache le bouton "Résoudre" (technicien + employé)
  final bool readOnly;
  /// true  → affiche uniquement danger + critique (employé)
  final bool dangerOnly;

  const AlertsTab({
    super.key,
    this.readOnly   = false,
    this.dangerOnly = false,
  });

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  static const _red    = Color(0xFFEF5350);
  static const _orange = Color(0xFFFF9800);
  static const _green  = Color(0xFF4CAF50);
  static const _blue   = Color(0xFF4A6CF7);

  List<dynamic>          _alertes    = [];
  Map<String, dynamic>?  _stats;
  bool                   _loading    = true;
  String                 _filterType = 'tous';
  String                 _filterNiv  = 'tous';
  Timer?                 _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Chargement + filtres ─────────────────────────────────
  Future<void> _load() async {
    final res   = await ApiService().getAlertes(
      type: _filterType == 'tous' ? null : _filterType,
    );
    final stats = await ApiService().getAlertesStats();
    if (!mounted) return;

    List<dynamic> all = res?['alertes'] as List? ?? [];

    // Filtre employé : danger et critique uniquement
    if (widget.dangerOnly) {
      all = all.where((a) {
        final niv = a['niveau'] as String? ?? '';
        return niv == 'danger' || niv == 'critique';
      }).toList();
    }

    setState(() {
      _alertes = all;
      _stats   = stats is Map ? stats as Map<String, dynamic> : null;
      _loading = false;
    });
  }

  // ── Résoudre une alerte (admin seulement) ────────────────
  Future<void> _resoudre(String id) async {
    if (widget.readOnly) return;
    await ApiService().resoudreAlerte(id);
    _snack('Alerte marquée comme résolue ✅', false);
    _load();
  }

  // ── Filtre niveau local ──────────────────────────────────
  List<dynamic> get _filtered {
    if (_filterNiv == 'tous') return _alertes;
    return _alertes.where((a) => a['niveau'] == _filterNiv).toList();
  }

  // ── Helpers couleur / icône ──────────────────────────────
  Color    _nivColor(String? n) =>
      n == 'critique' || n == 'danger' ? _red : n == 'avertissement' ? _orange : _green;

  Color _typeColor(String? t) {
    switch (t) {
      case 'temperature': return _red;
      case 'humidite':    return _blue;
      case 'gaz':         return _orange;
      case 'eau':         return const Color(0xFF26C6DA);
      case 'intrusion':   return const Color(0xFF9C27B0);
      case 'visage':      return const Color(0xFF7E57C2);
      default:            return Colors.grey;
    }
  }

  IconData _typeIcon(String? t) {
    switch (t) {
      case 'temperature': return Icons.thermostat_rounded;
      case 'humidite':    return Icons.water_drop_rounded;
      case 'gaz':         return Icons.cloud_rounded;
      case 'eau':         return Icons.water_damage_rounded;
      case 'intrusion':   return Icons.door_back_door_rounded;
      case 'visage':      return Icons.face_rounded;
      default:            return Icons.notifications_rounded;
    }
  }

  String _typeLabel(String? t) {
    switch (t) {
      case 'temperature': return 'Température';
      case 'humidite':    return 'Humidité';
      case 'gaz':         return 'Gaz / Fumée';
      case 'eau':         return "Fuite d'eau";
      case 'intrusion':   return 'Intrusion';
      case 'visage':      return 'Visage';
      default:            return t ?? '';
    }
  }

  String _formatDate(dynamic d) {
    try {
      final dt = DateTime.parse(d.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}'
          ' ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  void _snack(String m, bool err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(m),
          backgroundColor: err ? _red : _green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  // ── Détail d'une alerte ──────────────────────────────────
  void _showDetail(Map<String, dynamic> a) {
    final c       = _typeColor(a['type'] as String?);
    final resolue = a['resolue'] as bool? ?? false;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2130) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),

            // En-tête type + message
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: c.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12)),
                child:
                    Icon(_typeIcon(a['type'] as String?), color: c, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_typeLabel(a['type'] as String?),
                          style: TextStyle(
                              color: c,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      Text(a['message'] as String? ?? '',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.3)),
                    ]),
              ),
            ]),
            const SizedBox(height: 16),

            if (a['valeur'] != null) _DetailRow('Valeur mesurée', '${a['valeur']}'),
            if (a['seuil']  != null) _DetailRow('Seuil dépassé',  '${a['seuil']}'),
            _DetailRow('Niveau', (a['niveau'] as String? ?? '').toUpperCase()),
            _DetailRow('Statut', resolue ? 'Résolue ✅' : 'Non résolue ⚠️'),
            if (a['horodatage'] != null)
              _DetailRow('Date', _formatDate(a['horodatage'])),

            const SizedBox(height: 20),

            // Bouton résoudre → uniquement si admin (readOnly == false)
            if (!resolue && !widget.readOnly)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white),
                  label: const Text('Marquer comme résolue',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    Navigator.pop(context);
                    _resoudre(a['_id'] as String);
                  },
                ),
              ),

            // Message lecture seule pour technicien / employé
            if (!resolue && widget.readOnly)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.orange.withOpacity(0.30)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text('Contactez un administrateur pour résoudre',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _DetailRow(String l, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text('$l : ',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12)),
          Text(v,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
      );

  // ── Build principal ──────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final textP   = Theme.of(context).colorScheme.onSurface;
    final textS   = Theme.of(context).colorScheme.onSurfaceVariant;
    final surface = Theme.of(context).colorScheme.surface;
    final nonRes  = _stats?['nonResolues'] ?? 0;
    final critiq  = _stats?['critiques']   ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(children: [

          // ── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Text('Alertes',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textP,
                            letterSpacing: -0.3)),
                    if (nonRes > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: _red,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text('$nonRes',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                  Text('${_filtered.length} alerte(s) affichée(s)',
                      style: TextStyle(fontSize: 12, color: textS)),
                ]),
              ),
              // Badge lecture seule pour technicien / employé
              if (widget.readOnly)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.30), width: 0.5),
                  ),
                  child: const Row(children: [
                    Icon(Icons.visibility_outlined,
                        color: Colors.orange, size: 12),
                    SizedBox(width: 4),
                    Text('Lecture seule',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              IconButton(
                  onPressed: _load,
                  icon: Icon(Icons.refresh_rounded, color: _blue)),
            ]),
          ),

          // ── Stats rapides ────────────────────────────────
          if (_stats != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(children: [
                _QuickStat('Non résolues', '$nonRes', _red),
                const SizedBox(width: 8),
                _QuickStat('Critiques', '$critiq', _orange),
                const SizedBox(width: 8),
                _QuickStat('24h', '${_stats!['dernieres24h'] ?? 0}', _blue),
              ]),
            ),

          const SizedBox(height: 12),

          // ── Filtres type ─────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                {'k': 'tous',        'l': 'Tous',     'e': '🔘'},
                {'k': 'temperature', 'l': 'Temp.',    'e': '🌡️'},
                {'k': 'humidite',    'l': 'Humidité', 'e': '💧'},
                {'k': 'gaz',         'l': 'Gaz',      'e': '☁️'},
                {'k': 'eau',         'l': 'Eau',       'e': '🚿'},
                {'k': 'visage',      'l': 'Visage',    'e': '👤'},
              ].map((f) {
                final sel = _filterType == f['k'];
                final c   = f['k'] == 'tous' ? _blue : _typeColor(f['k']);
                return GestureDetector(
                  onTap: () {
                    setState(() => _filterType = f['k']!);
                    _load();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? c : surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: sel
                                ? c.withOpacity(0.25)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(f['e']!, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(f['l']!,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : textS)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),

          // ── Filtres niveau (masqué si dangerOnly) ────────
          if (!widget.dangerOnly)
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  {'k': 'tous',          'l': 'Tous niveaux'},
                  {'k': 'critique',      'l': 'Critique'},
                  {'k': 'danger',        'l': 'Danger'},
                  {'k': 'avertissement', 'l': 'Avertissement'},
                ].map((f) {
                  final sel = _filterNiv == f['k'];
                  final c   = f['k'] == 'critique' || f['k'] == 'danger'
                      ? _red
                      : f['k'] == 'avertissement'
                          ? _orange
                          : _blue;
                  return GestureDetector(
                    onTap: () => setState(() => _filterNiv = f['k']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? c.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: sel
                                ? c.withOpacity(0.40)
                                : Colors.grey.withOpacity(0.20)),
                      ),
                      child: Text(f['l']!,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: sel ? c : textS)),
                    ),
                  );
                }).toList(),
              ),
            ),

          if (!widget.dangerOnly) const SizedBox(height: 10),

          // ── Liste alertes ────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 64,
                                color: _green.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text('Aucune alerte',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textS)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final a       = _filtered[i] as Map<String, dynamic>;
                            final type    = a['type']    as String?;
                            final niveau  = a['niveau']  as String?;
                            final resolue = a['resolue'] as bool? ?? false;
                            final c       = _typeColor(type);
                            final nCol    = _nivColor(niveau);
                            return GestureDetector(
                              onTap: () => _showDetail(a),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: resolue
                                      ? null
                                      : Border.all(
                                          color: nCol.withOpacity(0.30)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: c.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4)),
                                    BoxShadow(
                                        color: Colors.black.withOpacity(
                                            isDark ? 0.2 : 0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                          color: c.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Icon(_typeIcon(type),
                                          color: c, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Expanded(
                                              child: Text(
                                                a['message'] as String? ?? '',
                                                style: TextStyle(
                                                    color: textP,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.3),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (!resolue)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                    color: nCol,
                                                    shape: BoxShape.circle),
                                              ),
                                          ]),
                                          const SizedBox(height: 6),
                                          Row(children: [
                                            _Badge(_typeLabel(type), c),
                                            const SizedBox(width: 6),
                                            _Badge(
                                                (niveau ?? '').toUpperCase(),
                                                nCol),
                                            const SizedBox(width: 6),
                                            _Badge(
                                                resolue
                                                    ? '✅ Résolue'
                                                    : '⚠️ Active',
                                                resolue ? _green : _red),
                                          ]),
                                          const SizedBox(height: 6),
                                          Row(children: [
                                            Icon(Icons.access_time_rounded,
                                                size: 11, color: textS),
                                            const SizedBox(width: 4),
                                            Text(_formatDate(a['horodatage']),
                                                style: TextStyle(
                                                    color: textS,
                                                    fontSize: 10)),
                                            if (a['valeur'] != null) ...[
                                              const SizedBox(width: 10),
                                              Text(
                                                  'Valeur: ${a['valeur']}',
                                                  style: TextStyle(
                                                      color: c,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ],
                                          ]),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded,
                                        color: Colors.grey, size: 18),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ]),
      ),
    );
  }
}

// ── Widgets utilitaires ────────────────────────────────────
class _QuickStat extends StatelessWidget {
  final String l, v;
  final Color c;
  const _QuickStat(this.l, this.v, this.c);

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: [
          Text(v,
              style: TextStyle(
                  color: c, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(l,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 9)),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String l;
  final Color c;
  const _Badge(this.l, this.c);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: c.withOpacity(0.10),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(l,
            style: TextStyle(
                color: c, fontSize: 9, fontWeight: FontWeight.w700)),
      );
}