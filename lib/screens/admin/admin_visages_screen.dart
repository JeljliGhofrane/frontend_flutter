import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/api_service.dart';

class AdminVisagesScreen extends StatefulWidget {
  const AdminVisagesScreen({super.key});
  @override State<AdminVisagesScreen> createState() => _State();
}
class _State extends State<AdminVisagesScreen> {
  static const _accent = Color(0xFF26C6DA);
  static const _green  = Color(0xFF4CAF50);
  static const _red    = Color(0xFFEF5350);
  List<dynamic> _list = []; bool _loading = true;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getVisages();
    if (!mounted) return;
    setState(() { _list = r?['visages'] as List? ?? []; _loading = false; });
  }

  Future<void> _delete(String nom) async {
    final ok = await showCupertinoDialog<bool>(context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Supprimer ce visage ?'),
        content: Text('"$nom" sera supprimé de la base.'),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          CupertinoDialogAction(isDestructiveAction: true, onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ]));
    if (ok == true) { await ApiService().deleteVisage(nom); _snack('Visage "$nom" supprimé ✅'); _load(); }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(m), backgroundColor: _green, behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

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
        title: Text('Gestion des Visages', style: TextStyle(color: textP, fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: _accent))],
      ),
      body: Column(children: [
        // Banner info
        Padding(padding: const EdgeInsets.fromLTRB(16,8,16,12),
          child: Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _accent.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accent.withOpacity(0.20))),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: _accent, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ajout via Backend', style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w700)),
                Text('Pour ajouter un visage : POST /api/visages depuis ESP32-CAM ou Postman.',
                  style: TextStyle(color: textS, fontSize: 11, height: 1.4)),
              ])),
            ])),
        ),
        // Stats
        Padding(padding: const EdgeInsets.fromLTRB(16,0,16,16),
          child: Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 8, offset: const Offset(0,2))]),
            child: Row(children: [
              const Icon(Icons.face_rounded, color: _accent, size: 26),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_list.length} visage(s) autorisé(s)', style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w700)),
                Text('Base de reconnaissance faciale', style: TextStyle(color: textS, fontSize: 11)),
              ]),
            ])),
        ),
        // Liste
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.face_outlined, size: 64, color: textS.withOpacity(0.3)),
                const SizedBox(height: 12),
                Text('Aucun visage enregistré', style: TextStyle(color: textS, fontSize: 14)),
              ]))
            : RefreshIndicator(onRefresh: _load, child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final v   = _list[i];
                  final nom = v['nom'] as String? ?? 'Inconnu';
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 8, offset: const Offset(0,2))]),
                    child: Row(children: [
                      Container(width: 48, height: 48,
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [_accent, Color(0xFF0097A7)]), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.face_rounded, color: Colors.white, size: 26)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(nom.replaceAll('_', ' '), style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('Fichier: ${v['fichier'] ?? ''}', style: TextStyle(color: textS, fontSize: 11)),
                        const SizedBox(height: 3),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: _green.withOpacity(0.10), borderRadius: BorderRadius.circular(6)),
                          child: const Text('✅ Autorisé', style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w600))),
                      ])),
                      GestureDetector(onTap: () => _delete(nom),
                        child: Container(width: 34, height: 34,
                          decoration: BoxDecoration(color: _red.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(CupertinoIcons.trash_fill, color: _red, size: 16))),
                    ]),
                  );
                }))),
      ]),
    );
  }
}