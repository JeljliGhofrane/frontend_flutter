import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'home_tab.dart';
import 'alerts_tab.dart';
import 'charts_tab.dart';
import 'ai_assistant_tab.dart';
import '../settings/settings_tab.dart';
import '../admin/admin_users_screen.dart';
import '../admin/admin_rfid_screen.dart';
import '../admin/admin_visages_screen.dart';
import '../admin/admin_historique_screen.dart';
import '../admin/admin_journaux_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userRole;
  const DashboardScreen({super.key, required this.userRole});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _idx = 0;
  late PageController _pc;

  // ── Pages selon le rôle ─────────────────────────────────
  List<Widget> get _pages {
    switch (widget.userRole) {
      case 'admin':
        return [
          HomeTab(userRole: widget.userRole),
          const AlertsTab(),
          const ChartsTab(),
          const AiAssistantTab(),
          SettingsTab(userRole: widget.userRole),
        ];
      case 'technicien':
        return [
          HomeTab(userRole: widget.userRole),
          const AlertsTab(readOnly: true),
          const ChartsTab(),
          const AiAssistantTab(),
          SettingsTab(userRole: widget.userRole),
        ];
      default: // employe
        return [
          HomeTab(userRole: widget.userRole),
          const AlertsTab(readOnly: true, dangerOnly: true),
          SettingsTab(userRole: widget.userRole),
        ];
    }
  }

  // ── Tabs navbar selon le rôle ───────────────────────────
  List<_TabDef> get _tabs {
    const blue   = Color(0xFF4A6CF7);
    const red    = Color(0xFFEF5350);
    const cyan   = Color(0xFF26C6DA);
    const purple = Color(0xFF9C27B0);
    const green  = Color(0xFF66BB6A);

    if (widget.userRole == 'employe') {
      return [
        _TabDef(Icons.sensors_outlined,           Icons.sensors_rounded,              'Capteurs',   blue),
        _TabDef(Icons.notifications_none_rounded, Icons.notifications_active_rounded, 'Alertes',    red),
        _TabDef(Icons.settings_outlined,          Icons.settings_rounded,             'Paramètres', green),
      ];
    }
    // admin ET technicien → 5 onglets identiques
    return [
      _TabDef(Icons.dashboard_outlined,          Icons.dashboard_rounded,            'Accueil',    blue),
      _TabDef(Icons.notifications_none_rounded,  Icons.notifications_active_rounded, 'Alertes',    red),
      _TabDef(Icons.show_chart_rounded,          Icons.bar_chart_rounded,            'Graphiques', cyan),
      _TabDef(Icons.assistant_outlined,          Icons.assistant_rounded,            'IA',         purple),
      _TabDef(Icons.settings_outlined,           Icons.settings_rounded,             'Paramètres', green),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pc = PageController();
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (_idx == i) return;
    HapticFeedback.lightImpact();
    setState(() => _idx = i);
    _pc.animateToPage(i,
        duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
    return Scaffold(
      // FAB panel admin uniquement pour l'admin
      floatingActionButton: widget.userRole == 'admin' ? _fab() : null,
      body: PageView(
        controller: _pc,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: _navBar(isDark),
    );
  }

  Widget _fab() => FloatingActionButton(
        backgroundColor: const Color(0xFF4A6CF7),
        elevation: 4,
        onPressed: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => const _AdminSheet(),
        ),
        child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
      );

  Widget _navBar(bool isDark) {
    final bg   = isDark ? const Color(0xFF12141F) : const Color(0xFF1A1D2E);
    final tabs = _tabs;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              tabs.length,
              (i) => _NavItem(
                i, _idx,
                tabs[i].icon, tabs[i].activeIcon,
                tabs[i].label, tabs[i].color, _go,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Modèle d'onglet ────────────────────────────────────────
class _TabDef {
  final IconData icon, activeIcon;
  final String label;
  final Color color;
  const _TabDef(this.icon, this.activeIcon, this.label, this.color);
}

// ── Admin Bottom Sheet — Design Premium ───────────────────
class _AdminSheet extends StatelessWidget {
  const _AdminSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _AItem(
        icon: Icons.people_rounded,
        color: const Color(0xFF4A6CF7),
        bgColor: const Color(0xFF4A6CF7),
        label: 'Utilisateurs',
        subtitle: 'Approuver · Modifier · Supprimer',
        badge: null,
        screen: const AdminUsersScreen(),
      ),
      _AItem(
        icon: Icons.credit_card_rounded,
        color: const Color(0xFF7E57C2),
        bgColor: const Color(0xFF7E57C2),
        label: 'Gestion RFID',
        subtitle: 'Ajouter · Modifier · Supprimer badges',
        badge: null,
        screen: const AdminRfidScreen(),
      ),
      _AItem(
        icon: Icons.face_retouching_natural_rounded,
        color: const Color(0xFF00BCD4),
        bgColor: const Color(0xFF00BCD4),
        label: 'Gestion Visages',
        subtitle: 'Base des visages autorisés',
        badge: null,
        screen: const AdminVisagesScreen(),
      ),
      _AItem(
        icon: Icons.insert_chart_outlined_rounded,
        color: const Color(0xFF43A047),
        bgColor: const Color(0xFF43A047),
        label: 'Historique Mesures',
        subtitle: 'Export CSV · Température complète',
        badge: 'CSV',
        screen: const AdminHistoriqueScreen(),
      ),
      _AItem(
        icon: Icons.door_back_door_rounded,
        color: const Color(0xFFFF7043),
        bgColor: const Color(0xFFFF7043),
        label: "Journaux d'accès",
        subtitle: 'RFID · Reconnaissance faciale',
        badge: null,
        screen: const AdminJournauxScreen(),
      ),
    ];

    final sheetBg = isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F6FA);
    final cardBg  = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final textP   = isDark ? Colors.white : const Color(0xFF0D0F1A);
    final textS   = isDark ? const Color(0xFF8A8FA8) : const Color(0xFF6B7080);
    final divider = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.06);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A6CF7), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A6CF7).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Menu Administrateur',
                          style: TextStyle(
                              color: textP,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text('Accès complet au système',
                          style: TextStyle(color: textS, fontSize: 12)),
                    ]),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6CF7).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF4A6CF7).withOpacity(0.25),
                      width: 0.5),
                ),
                child: const Text('ADMIN',
                    style: TextStyle(
                        color: Color(0xFF4A6CF7),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8)),
              ),
            ]),
          ),

          const SizedBox(height: 16),
          Container(
              height: 0.5,
              color: divider,
              margin: const EdgeInsets.symmetric(horizontal: 20)),
          const SizedBox(height: 12),

          // ── Liste groupée ────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.07)
                      : Colors.black.withOpacity(0.06),
                  width: 0.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.30 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                children: List.generate(items.length, (i) {
                  final item   = items[i];
                  final isLast = i == items.length - 1;
                  return Column(
                    children: [
                      _AdminTile(
                          item: item,
                          isDark: isDark,
                          textP: textP,
                          textS: textS),
                      if (!isLast)
                        Container(
                          height: 0.5,
                          margin: const EdgeInsets.only(left: 68),
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Tile individuel ────────────────────────────────────────
class _AdminTile extends StatelessWidget {
  final _AItem item;
  final bool isDark;
  final Color textP, textS;

  const _AdminTile({
    required this.item,
    required this.isDark,
    required this.textP,
    required this.textS,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => item.screen));
      },
      splashColor: item.color.withOpacity(0.08),
      highlightColor: item.color.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.bgColor.withOpacity(isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: item.bgColor.withOpacity(isDark ? 0.30 : 0.15),
                  width: 0.5),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(item.label,
                        style: TextStyle(
                            color: textP,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    if (item.badge != null) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: item.color.withOpacity(0.30), width: 0.5),
                        ),
                        child: Text(item.badge!,
                            style: TextStyle(
                                color: item.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: TextStyle(color: textS, fontSize: 11)),
                ]),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.chevron_right_rounded,
                color: textS.withOpacity(0.7), size: 17),
          ),
        ]),
      ),
    );
  }
}

// ── Modèle item admin ──────────────────────────────────────
class _AItem {
  final IconData icon;
  final Color color, bgColor;
  final String label, subtitle;
  final String? badge;
  final Widget screen;

  const _AItem({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.label,
    required this.subtitle,
    required this.badge,
    required this.screen,
  });
}

// ── NavItem ────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final int idx, cur;
  final IconData icon, activeIcon;
  final String label;
  final Color accent;
  final Function(int) onTap;

  const _NavItem(this.idx, this.cur, this.icon, this.activeIcon, this.label,
      this.accent, this.onTap);

  bool get sel => idx == cur;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding:
            EdgeInsets.symmetric(horizontal: sel ? 14 : 10, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? accent.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border:
              sel ? Border.all(color: accent.withOpacity(0.30)) : null,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(sel ? activeIcon : icon,
              color:
                  sel ? accent : Colors.white.withOpacity(0.40),
              size: 22),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            child: sel
                ? Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: accent)),
                  )
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}