import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/api_service.dart';

class AdminHistoriqueScreen extends StatefulWidget {
  const AdminHistoriqueScreen({super.key});
  @override State<AdminHistoriqueScreen> createState() => _State();
}
class _State extends State<AdminHistoriqueScreen> {
  static const _accent = Color(0xFF66BB6A);
  List<dynamic> _list = []; Map<String, dynamic>? _stats;
  bool _loading = true; String _filter = 'tous';

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getHistorique(limite: 200);
    final s = await ApiService().getHistoriqueStats();
    if (!mounted) return;
    setState(() { _list = r?['mesures'] as List? ?? []; _stats = s is Map ? s as Map<String,dynamic> : null; _loading = false; });
  }

  List<dynamic> get _filtered => _filter == 'tous' ? _list
      : _list.where((m) => '${m['statut']}'.toUpperCase() == _filter).toList();

  Color _sc(String? s) => s?.toUpperCase() == 'DANGER' ? const Color(0xFFEF5350) : s?.toUpperCase() == 'AVERTISSEMENT' ? const Color(0xFFFF9800) : const Color(0xFF4CAF50);

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
        title: Text('Historique Mesures', style: TextStyle(color: textP, fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: _accent))],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        // Stats
        if (_stats != null) Padding(padding: const EdgeInsets.fromLTRB(16,8,16,12),
          child: Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 8, offset: const Offset(0,2))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _MS('Total',   '${_stats!['total'] ?? 0}',                                               _accent),
              _MS('Min °C',  '${((_stats!['temperature']?['min']    ?? 0) as num).toStringAsFixed(1)}', const Color(0xFF4A6CF7)),
              _MS('Max °C',  '${((_stats!['temperature']?['max']    ?? 0) as num).toStringAsFixed(1)}', const Color(0xFFEF5350)),
              _MS('Moy °C',  '${((_stats!['temperature']?['moyenne']?? 0) as num).toStringAsFixed(1)}', const Color(0xFFFF9800)),
            ]))),
        // Filtres
        SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          children: ['tous','NORMAL','AVERTISSEMENT','DANGER'].map((s) {
            final sel = _filter == s;
            final c   = _sc(s == 'tous' ? null : s);
            return GestureDetector(onTap: () => setState(() => _filter = s),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: sel ? c : surface, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: sel ? c.withOpacity(0.25) : Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0,2))]),
                child: Text(s == 'tous' ? 'Tous' : s,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : textS))));
          }).toList())),
        const SizedBox(height: 8),
        // Liste
        Expanded(child: _filtered.isEmpty
          ? Center(child: Text('Aucune mesure', style: TextStyle(color: textS)))
          : RefreshIndicator(onRefresh: _load, child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final m      = _filtered[i];
                final temp   = '${m['temperature'] ?? '-'}°C';
                final statut = m['statut'] as String? ?? 'NORMAL';
                final ts     = m['timestamp'] as String? ?? '';
                final c      = _sc(statut);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 6, offset: const Offset(0,2))]),
                  child: Row(children: [
                    Container(width: 36, height: 36,
                      decoration: BoxDecoration(color: c.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.thermostat_rounded, color: c, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(temp, style: TextStyle(color: textP, fontSize: 15, fontWeight: FontWeight.w800)),
                      Text(ts,   style: TextStyle(color: textS, fontSize: 10)),
                    ])),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: c.withOpacity(0.10), borderRadius: BorderRadius.circular(6)),
                      child: Text(statut, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700))),
                  ]),
                );
              }))),
      ]),
    );
  }
}

class _MS extends StatelessWidget {
  final String l, v; final Color c;
  const _MS(this.l, this.v, this.c);
  @override Widget build(BuildContext context) => Column(children: [
    Text(v, style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.w800)),
    Text(l, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
  ]);
}