import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/api_service.dart';

class AdminRfidScreen extends StatefulWidget {
  const AdminRfidScreen({super.key});
  @override State<AdminRfidScreen> createState() => _State();
}
class _State extends State<AdminRfidScreen> {
  static const _accent = Color(0xFF7E57C2);
  static const _green  = Color(0xFF4CAF50);
  static const _red    = Color(0xFFEF5350);
  List<dynamic> _list = []; bool _loading = true; String _search = '';

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getRfids();
    if (!mounted) return;
    setState(() { _list = (r is List) ? r : []; _loading = false; });
  }

  List<dynamic> get _filtered => _list.where((r) => _search.isEmpty ||
    '${r['nom']} ${r['prenom']} ${r['uid']}'.toLowerCase().contains(_search.toLowerCase())).toList();

  Future<void> _toggle(String id, bool cur) async { await ApiService().updateRfid(id, {'actif': !cur}); _load(); }

  Future<void> _delete(String id, String nom) async {
    final ok = await showCupertinoDialog<bool>(context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Supprimer ce badge ?'),
        content: Text('Badge de "$nom" sera supprimé.'),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          CupertinoDialogAction(isDestructiveAction: true, onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ]));
    if (ok == true) { await ApiService().deleteRfid(id); _snack('Badge supprimé ✅'); _load(); }
  }

  void _showAdd() {
    final uid = TextEditingController(); final nom = TextEditingController();
    final pre = TextEditingController(); final pos = TextEditingController();
    showDialog(context: context, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 38, height: 38,
              decoration: BoxDecoration(color: _accent.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
              child: const Icon(CupertinoIcons.creditcard_fill, color: _accent, size: 18)),
            const SizedBox(width: 10),
            const Text('Nouveau Badge RFID', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 18),
          _F('UID du badge (ex: A4F2BC30)', uid),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _F('Prénom', pre)), const SizedBox(width: 10), Expanded(child: _F('Nom', nom))]),
          const SizedBox(height: 10),
          _F('Poste (optionnel)', pos),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                if (uid.text.isEmpty || nom.text.isEmpty || pre.text.isEmpty) return;
                Navigator.pop(context);
                await ApiService().addRfid({'uid': uid.text.trim(), 'nom': nom.text.trim(), 'prenom': pre.text.trim(), 'poste': pos.text.trim()});
                _snack('Badge ajouté ✅'); _load();
              },
              child: const Text('Ajouter', style: TextStyle(color: Colors.white)))),
          ]),
        ]))));
  }

  Widget _F(String h, TextEditingController c) => TextField(controller: c,
    decoration: InputDecoration(hintText: h, filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)));

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
    final actifs  = _list.where((r) => r['actif'] == true).length;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0,
        leading: GestureDetector(onTap: () => Navigator.pop(context),
          child: Container(margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 6, offset: const Offset(0,2))]),
            child: Icon(CupertinoIcons.chevron_left, color: textP, size: 18))),
        title: Text('Gestion RFID', style: TextStyle(color: textP, fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [
          GestureDetector(onTap: _showAdd,
            child: Container(margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(10)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(CupertinoIcons.add, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text('Ajouter', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ]))),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16,8,16,12),
          child: Row(children: [
            _S('Total',    '${_list.length}', _accent),
            const SizedBox(width: 8),
            _S('Actifs',   '$actifs',                  _green),
            const SizedBox(width: 8),
            _S('Inactifs', '${_list.length - actifs}', Colors.grey),
          ])),
        Padding(padding: const EdgeInsets.fromLTRB(16,0,16,12),
          child: Container(height: 44,
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14)),
            child: TextField(onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(hintText: 'Rechercher UID ou nom...', hintStyle: TextStyle(color: textS, fontSize: 13),
                prefixIcon: Icon(CupertinoIcons.search, color: textS, size: 16), border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12))))),
        Expanded(child: _filtered.isEmpty
          ? Center(child: Text('Aucun badge RFID', style: TextStyle(color: textS)))
          : RefreshIndicator(onRefresh: _load, child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final r     = _filtered[i];
                final actif = r['actif'] as bool? ?? true;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 8, offset: const Offset(0,2))],
                    border: Border.all(color: actif ? _green.withOpacity(0.15) : Colors.transparent)),
                  child: Row(children: [
                    Container(width: 44, height: 44,
                      decoration: BoxDecoration(color: _accent.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(CupertinoIcons.creditcard_fill, color: _accent, size: 16),
                        const SizedBox(height: 2),
                        Text('${r['uid'] ?? '??'}'.substring(0, (r['uid'] as String? ?? '??').length > 8 ? 8 : (r['uid'] as String? ?? '??').length),
                          style: const TextStyle(color: _accent, fontSize: 7, fontWeight: FontWeight.w700)),
                      ])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${r['prenom']} ${r['nom']}', style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text(r['poste'] ?? 'Aucun poste', style: TextStyle(color: textS, fontSize: 11)),
                      Text('UID: ${r['uid']}', style: const TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.w600)),
                    ])),
                    Column(children: [
                      CupertinoSwitch(value: actif, onChanged: (_) => _toggle(r['_id'], actif), activeColor: _green, trackColor: Colors.grey.shade300),
                      const SizedBox(height: 6),
                      GestureDetector(onTap: () => _delete(r['_id'], '${r['prenom']} ${r['nom']}'),
                        child: const Icon(CupertinoIcons.trash, color: _red, size: 16)),
                    ]),
                  ]),
                );
              }))),
      ]),
    );
  }
}

class _S extends StatelessWidget {
  final String l, v; final Color c;
  const _S(this.l, this.v, this.c);
  @override Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 6, offset: const Offset(0,2))]),
      child: Column(children: [
        Text(v, style: TextStyle(color: c, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(l, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
      ])));
  }
}