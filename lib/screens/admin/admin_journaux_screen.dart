import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/api_service.dart';

class AdminJournauxScreen extends StatefulWidget {
  const AdminJournauxScreen({super.key});
  @override State<AdminJournauxScreen> createState() => _State();
}
class _State extends State<AdminJournauxScreen> {
  static const _accent = Color(0xFFFF9800);
  List<dynamic> _list = []; Map<String, dynamic>? _stats;
  bool _loading = true; String _filter = 'tous';

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    final statut = _filter == 'tous' ? null : _filter;
    final r = await ApiService().getJournaux(statut: statut, limite: 100);
    final s = await ApiService().getJournauxStats();
    if (!mounted) return;
    setState(() {
      _list  = r?['journaux'] as List? ?? [];
      _stats = s is Map ? s as Map<String,dynamic> : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg      = Theme.of(context).scaffoldBackgroundColor;
    final surface = Theme.of(context).colorScheme.surface;
    final textP   = Theme.of(context).colorScheme.onSurface;
    final textS   = Theme.of(context).colorScheme.onSurfaceVariant;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0,
        leading: GestureDetector(onTap: () => Navigator.pop(context),
          child: Container(margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 6, offset: const Offset(0,2))]),
            child: Icon(CupertinoIcons.chevron_left, color: textP, size: 18))),
        title: Text('Journaux d\'accès', style: TextStyle(color: textP, fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: _accent))],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        // Stats
        if (_stats != null) Padding(padding: const EdgeInsets.fromLTRB(16,8,16,12),
          child: Row(children: [
            _SB('Total',      '${_stats!['total']        ?? 0}', const Color(0xFF4A6CF7)),
            const SizedBox(width: 8),
            _SB('Autorisés',  '${_stats!['autorise']     ?? 0}', const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            _SB('Refusés',    '${_stats!['refuse']       ?? 0}', const Color(0xFFEF5350)),
            const SizedBox(width: 8),
            _SB('Auj.',       '${_stats!['dernieres24h'] ?? 0}', _accent),
          ])),
        // Filtres
        SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            {'k':'tous',      'l':'Tous'},
            {'k':'autorise',  'l':'✅ Autorisés'},
            {'k':'refuse',    'l':'❌ Refusés'},
          ].map((f) {
            final sel = _filter == f['k'];
            final c   = f['k'] == 'autorise' ? const Color(0xFF4CAF50) : f['k'] == 'refuse' ? const Color(0xFFEF5350) : _accent;
            return GestureDetector(onTap: () { setState(() => _filter = f['k']!); _load(); },
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: sel ? c : surface, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: sel ? c.withOpacity(0.25) : Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0,2))]),
                child: Text(f['l']!,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : textS))));
          }).toList())),
        const SizedBox(height: 8),
        // Liste
        Expanded(child: _list.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.door_back_door_rounded, size: 64, color: textS.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('Aucun journal d\'accès', style: TextStyle(color: textS, fontSize: 14)),
            ]))
          : RefreshIndicator(onRefresh: _load, child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _list.length,
              itemBuilder: (ctx, i) {
                final j    = _list[i];
                final ok   = j['statut'] == 'autorise';
                final c    = ok ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
                final type = j['typeAcces'] as String? ?? 'rfid';
                final typeIcon = type == 'facial' ? Icons.face_rounded : type == 'rfid+facial' ? Icons.security_rounded : Icons.credit_card_rounded;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 6, offset: const Offset(0,2))],
                    border: Border.all(color: ok ? Colors.transparent : const Color(0xFFEF5350).withOpacity(0.20))),
                  child: Row(children: [
                    Container(width: 44, height: 44,
                      decoration: BoxDecoration(color: c.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
                      child: Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded, color: c, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${j['prenom'] ?? ''} ${j['nom'] ?? 'Inconnu'}'.trim(),
                        style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(typeIcon, size: 11, color: textS),
                        const SizedBox(width: 3),
                        Text('$type • UID: ${j['uid'] ?? '-'}', style: TextStyle(color: textS, fontSize: 10)),
                      ]),
                      if (j['motifRefus'] != null && j['motifRefus'] != '') ...[
                        const SizedBox(height: 2),
                        Text('⚠️ ${j['motifRefus']}', style: const TextStyle(color: Color(0xFFFF9800), fontSize: 10)),
                      ],
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: c.withOpacity(0.10), borderRadius: BorderRadius.circular(6)),
                        child: Text(ok ? 'Autorisé' : 'Refusé', style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700))),
                      const SizedBox(height: 4),
                      if (j['horodatage'] != null)
                        Text(_formatDate(j['horodatage']), style: TextStyle(color: textS, fontSize: 9)),
                    ]),
                  ]),
                );
              }))),
      ]),
    );
  }

  String _formatDate(dynamic d) {
    try {
      final dt = DateTime.parse(d.toString()).toLocal();
      return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) { return ''; }
  }
}

class _SB extends StatelessWidget {
  final String l, v; final Color c;
  const _SB(this.l, this.v, this.c);
  @override Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 6, offset: const Offset(0,2))]),
      child: Column(children: [
        Text(v, style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(l, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9)),
      ])));
  }
}