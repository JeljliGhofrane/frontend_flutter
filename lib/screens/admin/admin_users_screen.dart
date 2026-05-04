import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> _users = []; 
  Map<String, dynamic>? _stats;
  bool _loading = true; 
  String _search = ''; 
  String _filterRole = 'tous';

  // Couleurs Mode Clair Premium
  static const Color bgLight = Color(0xFFF8F9FD);
  static const Color accentGradientStart = Color(0xFFFF5F6D);
  static const Color accentGradientEnd = Color(0xFFFFC371);
  static const Color textPrimary = Color(0xFF1A1C24);
  static const Color textSecondary = Color(0xFF8C91A9);

  @override 
  void initState() { 
    super.initState(); 
    _load(); 
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final u = await ApiService().getUsers();
    final s = await ApiService().getUserStats();
    if (!mounted) return;
    setState(() { 
      _users = (u is List) ? u : []; 
      _stats = s is Map ? s as Map<String,dynamic> : null; 
      _loading = false; 
    });
  }

  List<dynamic> get _filtered => _users.where((u) {
    final role = _filterRole == 'tous' || u['role'] == _filterRole;
    final search = _search.isEmpty || '${u['nom']} ${u['prenom']} ${u['email']}'.toLowerCase().contains(_search.toLowerCase());
    return role && search;
  }).toList();

  Color _rc(String r) => r == 'admin' ? const Color(0xFFFF9800) : r == 'technicien' ? const Color(0xFF4A6CF7) : const Color(0xFF4CAF50);
  String _rl(String r) => r == 'admin' ? 'Admin' : r == 'technicien' ? 'Technicien' : 'Employé';

  Future<void> _approve(String id) async { 
    await ApiService().approveUser(id); 
    _snack('Compte approuvé avec succès ✅', false); 
    _load(); 
  }

  Future<void> _reject(String id) async { 
    await ApiService().rejectUser(id);  
    _snack('Compte désactivé', true);  
    _load(); 
  }

  Future<void> _delete(String id, String name) async {
    final ok = await showCupertinoDialog<bool>(context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Supprimer l\'utilisateur ?'),
        content: Text('Cette action est irréversible pour $name.'),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          CupertinoDialogAction(isDestructiveAction: true, onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ));
    if (ok == true) { 
      await ApiService().deleteUser(id); 
      _snack('Utilisateur supprimé', true); 
      _load(); 
    }
  }

  void _snack(String m, bool err) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(m, style: const TextStyle(fontWeight: FontWeight.w600)), 
    backgroundColor: err ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
    behavior: SnackBarBehavior.floating, 
    margin: const EdgeInsets.all(20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight, 
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Gestion des Comptes', 
          style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4A6CF7)))
        ],
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A6CF7))) 
        : Column(children: [
            // ── Statistiques ───────────────────────────────
            if (_stats != null) Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(children: [
                _StatCard('Total', '${_stats!['total'] ?? 0}', const Color(0xFF4A6CF7)),
                const SizedBox(width: 12),
                _StatCard('Actifs', '${_stats!['approuves'] ?? 0}', const Color(0xFF4CAF50)),
                const SizedBox(width: 12),
                _StatCard('En attente', '${_stats!['enAttente'] ?? 0}', const Color(0xFFFF9800)),
              ]),
            ),

            // ── Barre de Recherche ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un nom ou email...',
                    hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                    prefixIcon: Icon(CupertinoIcons.search, color: textSecondary, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Filtres de Rôles ───────────────────────────
            SizedBox(
              height: 40, 
              child: ListView(
                scrollDirection: Axis.horizontal, 
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ['tous','admin','technicien','employe'].map((r) {
                  final sel = _filterRole == r;
                  final c = r == 'tous' ? const Color(0xFF4A6CF7) : _rc(r);
                  return GestureDetector(
                    onTap: () => setState(() => _filterRole = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: sel ? LinearGradient(colors: [c, c.withOpacity(0.8)]) : null,
                        color: sel ? null : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: sel ? c.withOpacity(0.3) : Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Text(r == 'tous' ? 'Tous' : _rl(r),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: sel ? Colors.white : textSecondary)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // ── Liste des Utilisateurs ─────────────────────
            Expanded(
              child: _filtered.isEmpty
                ? const Center(child: Text('Aucun utilisateur trouvé', style: TextStyle(color: textSecondary)))
                : RefreshIndicator(
                    onRefresh: _load, 
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                      itemBuilder: (ctx, i) {
                        final u = _filtered[i];
                        final role = u['role'] as String? ?? 'employe';
                        final ok = u['isApproved'] as bool? ?? false;
                        final rCol = _rc(role);
                        
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
                            border: ok ? null : Border.all(color: const Color(0xFFFF9800).withOpacity(0.4), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              Row(children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    color: rCol.withOpacity(0.1), 
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      'assets/images/rfid.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Text('${u['prenom'][0]}${u['nom'][0]}'.toUpperCase(), 
                                          style: TextStyle(color: rCol, fontWeight: FontWeight.w900, fontSize: 18))
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('${u['prenom'] ?? ''} ${u['nom'] ?? ''}', 
                                    style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                                  Text(u['email'] ?? '', style: const TextStyle(color: textSecondary, fontSize: 12)),
                                ])),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: rCol.withOpacity(0.1), 
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: rCol.withOpacity(0.2))
                                  ),
                                  child: Text(_rl(role), style: TextStyle(color: rCol, fontSize: 11, fontWeight: FontWeight.w800)),
                                ),
                              ]),
                              const SizedBox(height: 15),
                              const Divider(height: 1, color: Color(0xFFF1F3F7)),
                              const SizedBox(height: 15),
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: (ok ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)).withOpacity(0.1), 
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Row(children: [
                                    Icon(ok ? Icons.check_circle_rounded : Icons.hourglass_top_rounded, 
                                      color: ok ? const Color(0xFF4CAF50) : const Color(0xFFFF9800), size: 14),
                                    const SizedBox(width: 6),
                                    Text(ok ? 'Compte Actif' : 'En attente',
                                      style: TextStyle(color: ok ? const Color(0xFF4CAF50) : const Color(0xFFFF9800), fontSize: 11, fontWeight: FontWeight.w700)),
                                  ]),
                                ),
                                const Spacer(),
                                if (!ok) _ActionButton(
                                  icon: CupertinoIcons.checkmark_alt, 
                                  color: const Color(0xFF4CAF50), 
                                  label: 'Approuver',
                                  onTap: () => _approve(u['_id'])
                                ),
                                if (ok) _ActionButton(
                                  icon: CupertinoIcons.xmark, 
                                  color: const Color(0xFFFF9800), 
                                  label: 'Bloquer',
                                  onTap: () => _reject(u['_id'])
                                ),
                                const SizedBox(width: 10),
                                _ActionButton(
                                  icon: CupertinoIcons.trash, 
                                  color: const Color(0xFFEF5350), 
                                  label: '',
                                  onTap: () => _delete(u['_id'], '${u['prenom']} ${u['nom']}')
                                ),
                              ]),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            ),
          ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; 
  final Color color;
  const _StatCard(this.label, this.value, this.color);

  @override 
  Widget build(BuildContext context) {
    // Correction : Définition locale de textSecondary
    const Color textSecondary = Color(0xFF8C91A9);
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon; 
  final Color color; 
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.color, required this.label, required this.onTap});

  @override 
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 10 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), 
          borderRadius: BorderRadius.circular(12)
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
          ]
        ]),
      ),
    );
  }
}
