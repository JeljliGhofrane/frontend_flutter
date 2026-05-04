import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:nettemp_guard/generated/l10n.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

// ── Palette dark (cohérente avec dashboard) ──────────────────
const _bg     = Color(0xFF0D0F1A);
const _card   = Color(0xFF161928);
const _card2  = Color(0xFF1E2235);
const _accent = Color(0xFF4A6CF7);
const _pink   = Color(0xFFEC4899);
const _error  = Color(0xFFEF5350);
const _wh     = Colors.white;

// ─────────────────────────────────────────────────────────────
//  SettingsTab — design DailyUI + toutes fonctionnalités
// ─────────────────────────────────────────────────────────────
class SettingsTab extends StatefulWidget {
  final String userRole;
  const SettingsTab({super.key, required this.userRole});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab>
    with SingleTickerProviderStateMixin {
  final _nameController  = TextEditingController();
  final _emailController = TextEditingController();
  bool   _notifications  = true;
  String _selectedLang   = 'fr';

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    if (user != null) {
      _nameController.text  = '${user.prenom} ${user.nom}';
      _emailController.text = user.email;
    }
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = context.watch<LanguageProvider>().locale.languageCode;
    if (_selectedLang != code) setState(() => _selectedLang = code);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final text = _nameController.text.trim();
    if (text.isEmpty) return '?';
    final parts = text.split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color get _roleColor {
    switch (widget.userRole) {
      case 'admin':      return const Color(0xFFFF9800);
      case 'technicien': return _accent;
      case 'employe':    return const Color(0xFF4CAF50);
      default:           return const Color(0xFF9E9E9E);
    }
  }

  String get _roleLabel {
    switch (widget.userRole) {
      case 'admin':      return '👑 Administrateur';
      case 'technicien': return '🔧 Technicien';
      case 'employe':    return '🪪 Employé';
      default:           return widget.userRole;
    }
  }

  // ── Couleurs selon thème ──────────────────────────────────
  Color _surface(BuildContext ctx)    => Theme.of(ctx).colorScheme.surface;
  Color _textP(BuildContext ctx)      => Theme.of(ctx).colorScheme.onSurface;
  Color _textS(BuildContext ctx)      => Theme.of(ctx).colorScheme.onSurfaceVariant;
  Color _pageBg(BuildContext ctx)     => Theme.of(ctx).scaffoldBackgroundColor;
  bool  _isDark(BuildContext ctx)     => Theme.of(ctx).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _isDark(context) ? _bg : _pageBg(context),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [

              // ── Profil centré — style DailyUI ─────────────
              _buildProfileHeader(context),

              const SizedBox(height: 28),

              // ── Titre "Settings" ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  lang.settings,
                  style: TextStyle(
                    color: _textP(context),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Groupe Apparence & App ────────────────────
              _SectionLabel(label: lang.appSection.toUpperCase(), context: context),
              const SizedBox(height: 10),
              _buildAppGroup(context, themeProvider, lang),

              const SizedBox(height: 20),

              // ── Groupe Compte ─────────────────────────────
              _SectionLabel(label: lang.accountSection.toUpperCase(), context: context),
              const SizedBox(height: 10),
              _buildAccountGroup(context, lang),

              const SizedBox(height: 32),

              // ── Bouton Déconnexion ────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLogoutButton(context, lang),
              ),

              const SizedBox(height: 16),
              Center(
                child: Text('v1.0',
                    style: TextStyle(
                        color: _textS(context).withOpacity(0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section profil centré avec avatar (sans bouton Pro) ───
  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(_isDark(context) ? 0.12 : 0.08),
            blurRadius: 20, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: [
        // Avatar avec initiales
        Stack(
          children: [
            Container(
              width: 84, height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A6CF7), Color(0xFF9C27B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.40),
                    blurRadius: 24, offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(_initials,
                    style: const TextStyle(
                        color: _wh, fontSize: 26, fontWeight: FontWeight.w800)),
              ),
            ),
            // Dot vert "en ligne"
            Positioned(
              bottom: 4, right: 4,
              child: Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: _surface(context), width: 2.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Nom
        Text(
          _nameController.text.isEmpty ? 'Utilisateur' : _nameController.text,
          style: TextStyle(
              color: _textP(context),
              fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
        ),
        const SizedBox(height: 4),

        // Email
        Text(_emailController.text,
            style: TextStyle(color: _textS(context), fontSize: 12)),
        const SizedBox(height: 12),

        // Badge rôle pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _roleColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _roleColor.withOpacity(0.30), width: 0.5),
          ),
          child: Text(_roleLabel,
              style: TextStyle(
                  color: _roleColor, fontSize: 11,
                  fontWeight: FontWeight.w800, letterSpacing: 0.3)),
        ),
      ]),
    );
  }

  // ── Groupe App : Mode sombre (FONCTIONNEL) + Notifications + Langue ──
  Widget _buildAppGroup(BuildContext context, ThemeProvider themeProvider, AppLocalizations lang) {
    return _SettingsCard(
      context: context,
      children: [
        // Mode sombre — CupertinoSwitch FONCTIONNEL via ThemeProvider
        _SwitchRow(
          icon: CupertinoIcons.moon_fill,
          iconBg: const Color(0xFF374151),
          label: 'Mode sombre',
          value: themeProvider.isDarkMode,
          onChanged: (val) => themeProvider.toggleTheme(val),
          context: context,
        ),
        _Divider(),

        // Notifications — switch fonctionnel local
        _SwitchRow(
          icon: CupertinoIcons.bell_fill,
          iconBg: const Color(0xFFEC4899),
          label: lang.notifications,
          value: _notifications,
          onChanged: (val) => setState(() => _notifications = val),
          context: context,
        ),
        _Divider(),

        // Langue — dropdown fonctionnel via LanguageProvider
        _DropdownRow(
          icon: CupertinoIcons.globe,
          iconBg: const Color(0xFF00BCD4),
          label: lang.language,
          value: _selectedLang,
          items: const ['fr', 'en', 'ar'],
          itemLabel: (code) => switch (code) {
            'fr' => 'Français',
            'en' => 'English',
            'ar' => 'العربية',
            _ => code,
          },
          onChanged: (val) {
            final code = val ?? _selectedLang;
            setState(() => _selectedLang = code);
            context.read<LanguageProvider>().changeLanguage(code);
          },
          context: context,
        ),
      ],
    );
  }

  // ── Groupe Compte : Profil + Mot de passe (FONCTIONNEL) + ESP32 ──
  Widget _buildAccountGroup(BuildContext context, AppLocalizations lang) {
    return _SettingsCard(
      context: context,
      children: [
        _ButtonRow(
          icon: Icons.person_rounded,
          iconBg: const Color(0xFF4CAF50),
          label: lang.profile,
          context: context,
          onTap: () {},
        ),
        _Divider(),

        // Mot de passe — ouvre le dialog FONCTIONNEL
        _ButtonRow(
          icon: Icons.lock_rounded,
          iconBg: const Color(0xFFEF5350),
          label: lang.password,
          context: context,
          onTap: () => _showPasswordDialog(context),
        ),
        _Divider(),

        _ButtonRow(
          icon: Icons.wifi_rounded,
          iconBg: const Color(0xFF26C6DA),
          label: 'Serveur ESP32',
          trailingText: '192.168.1.x',
          context: context,
          onTap: () {},
        ),
      ],
    );
  }

  // ── Bouton déconnexion ────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context, AppLocalizations lang) {
    return GestureDetector(
      onTap: () {
        AuthService().logout();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (r) => false);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: _error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _error.withOpacity(0.25), width: 0.5),
          boxShadow: [
            BoxShadow(
                color: _error.withOpacity(0.08),
                blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(CupertinoIcons.power, color: _error, size: 18),
          const SizedBox(width: 10),
          Text(lang.logout,
              style: const TextStyle(
                  color: _error, fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  // ── Dialog mot de passe FONCTIONNEL ──────────────────────
  void _showPasswordDialog(BuildContext context) {
    final lang          = AppLocalizations.of(context)!;
    final currentCtrl   = TextEditingController();
    final newCtrl       = TextEditingController();
    final confirmCtrl   = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) {
          bool saving = false;

          Future<void> submit() async {
            if (saving) return;
            final next    = newCtrl.text;
            final confirm = confirmCtrl.text;
            if (next.trim().isEmpty) {
              _snack(ctx, 'Nouveau mot de passe requis', err: true); return;
            }
            if (next.length < 8) {
              _snack(ctx, 'Mot de passe trop court (min. 8 car.)', err: true); return;
            }
            if (next != confirm) {
              _snack(ctx, lang.passwordsDontMatch, err: true); return;
            }
            setLocal(() => saving = true);
            final err = await AuthService().changePassword(
              currentPassword: currentCtrl.text,
              newPassword: next,
            );
            if (!ctx.mounted) return;
            setLocal(() => saving = false);
            if (err != null) { _snack(ctx, err, err: true); return; }
            Navigator.pop(ctx);
            if (context.mounted) _snack(context, 'Mot de passe modifié ✓', err: false);
          }

          final surface = _surface(ctx);
          final textP   = _textP(ctx);
          final textS   = _textS(ctx);

          return Dialog(
            backgroundColor: surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // En-tête
                Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(CupertinoIcons.lock_fill, color: _accent, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(lang.password,
                      style: TextStyle(
                          color: textP, fontSize: 16, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 8),
                Text(
                  'Connecté via Google ? Laissez le champ actuel vide.',
                  style: TextStyle(color: textS, fontSize: 11, height: 1.4),
                ),
                const SizedBox(height: 18),
                _DlgField(hint: 'Mot de passe actuel',  ctrl: currentCtrl,  ctx: ctx),
                const SizedBox(height: 10),
                _DlgField(hint: 'Nouveau mot de passe', ctrl: newCtrl,       ctx: ctx),
                const SizedBox(height: 10),
                _DlgField(hint: lang.confirmPassword,   ctrl: confirmCtrl,   ctx: ctx),
                const SizedBox(height: 22),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                            color: Theme.of(ctx).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text('Annuler',
                            style: TextStyle(color: textS, fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: saving ? null : submit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF4A6CF7), Color(0xFF6B8CFF)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(
                              color: _accent.withOpacity(0.30),
                              blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Center(
                          child: saving
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(_wh)))
                              : const Text('Modifier',
                                  style: TextStyle(
                                      color: _wh, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }

  void _snack(BuildContext context, String msg, {required bool err}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: err ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
}

// ─────────────────────────────────────────────────────────────
//  Composants UI réutilisables
// ─────────────────────────────────────────────────────────────

// Label de section avec ligne horizontale
class _SectionLabel extends StatelessWidget {
  final String label;
  final BuildContext context;
  const _SectionLabel({required this.label, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final textS = Theme.of(ctx).colorScheme.onSurfaceVariant;
    final div   = Theme.of(ctx).colorScheme.outlineVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Text(label,
            style: TextStyle(
                color: textS, fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 0.5, color: div)),
      ]),
    );
  }
}

// Card groupée avec dividers
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final BuildContext context;
  const _SettingsCard({required this.children, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final surface = Theme.of(ctx).colorScheme.surface;
    final isDark  = Theme.of(ctx).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.06 : 0.0), width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.30 : 0.06),
              blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(children: children),
      ),
    );
  }
}

// Divider interne
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 66),
      color: Theme.of(context).colorScheme.outlineVariant);
}

// Ligne avec switch (mode sombre, notifications)
class _SwitchRow extends StatelessWidget {
  final dynamic icon;
  final Color iconBg;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final BuildContext context;
  const _SwitchRow({
    required this.icon, required this.iconBg, required this.label,
    required this.value, required this.onChanged, required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final textP = Theme.of(ctx).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label,
            style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w600))),
        CupertinoSwitch(value: value, onChanged: onChanged, activeColor: _accent),
      ]),
    );
  }
}

// Ligne avec dropdown
class _DropdownRow extends StatelessWidget {
  final dynamic icon;
  final Color iconBg;
  final String label, value;
  final List<String> items;
  final String Function(String) itemLabel;
  final ValueChanged<String?> onChanged;
  final BuildContext context;
  const _DropdownRow({
    required this.icon, required this.iconBg, required this.label,
    required this.value, required this.items, required this.itemLabel,
    required this.onChanged, required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final textP = Theme.of(ctx).colorScheme.onSurface;
    final textS = Theme.of(ctx).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label,
            style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w600))),
        DropdownButton<String>(
          value: value,
          dropdownColor: Theme.of(ctx).colorScheme.surface,
          style: TextStyle(color: textS, fontSize: 13),
          icon: Icon(CupertinoIcons.chevron_down, color: textS, size: 13),
          underline: const SizedBox(),
          items: items.map((e) => DropdownMenuItem(
              value: e,
              child: Text(itemLabel(e), style: TextStyle(color: textP)))).toList(),
          onChanged: onChanged,
        ),
      ]),
    );
  }
}

// Ligne bouton avec chevron
class _ButtonRow extends StatelessWidget {
  final dynamic icon;
  final Color iconBg;
  final String label;
  final String? trailingText;
  final String? badge;
  final VoidCallback onTap;
  final BuildContext context;
  const _ButtonRow({
    required this.icon, required this.iconBg, required this.label,
    required this.onTap, required this.context,
    this.trailingText, this.badge,
  });

  @override
  Widget build(BuildContext ctx) {
    final textP = Theme.of(ctx).colorScheme.onSurface;
    final textS = Theme.of(ctx).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label,
              style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w600))),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.35)),
              ),
              child: Text(badge!,
                  style: const TextStyle(
                      color: Color(0xFFFF9800), fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 6),
          ],
          if (trailingText != null) ...[
            Text(trailingText!,
                style: TextStyle(color: textS, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
          ],
          Icon(CupertinoIcons.chevron_right, color: textS, size: 15),
        ]),
      ),
    );
  }
}

// Champ texte dans dialog
class _DlgField extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  final BuildContext ctx;
  const _DlgField({required this.hint, required this.ctrl, required this.ctx});

  @override
  Widget build(BuildContext context) {
    final bg    = Theme.of(ctx).scaffoldBackgroundColor;
    final textP = Theme.of(ctx).colorScheme.onSurface;
    final textS = Theme.of(ctx).colorScheme.onSurfaceVariant;
    return TextField(
      controller: ctrl,
      obscureText: true,
      style: TextStyle(color: textP, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textS, fontSize: 14),
        filled: true, fillColor: bg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  RfidManagementScreen — inchangé, conservé intégralement
// ─────────────────────────────────────────────────────────────
class RfidManagementScreen extends StatefulWidget {
  const RfidManagementScreen({super.key});
  @override
  State<RfidManagementScreen> createState() => _RfidManagementScreenState();
}

class _RfidManagementScreenState extends State<RfidManagementScreen> {
  static const _rfidAccent = Color(0xFF7E57C2);
  static const _green  = Color(0xFF4CAF50);
  static const _red    = Color(0xFFEF5350);

  int    _selectedTab = 0;
  String _search      = '';
  final  _searchCtrl  = TextEditingController();

  final List<_RfidBadge> _badges = [
    _RfidBadge(id: '#A4F2', name: 'Ahmed Ben Ali',  role: 'Admin',      zone: 'Salle Serveurs', active: true,  lastSeen: 'Auj. 09:14'),
    _RfidBadge(id: '#B7D1', name: 'Sara Mansouri',  role: 'Service IT', zone: 'Bureaux',         active: true,  lastSeen: 'Auj. 08:30'),
    _RfidBadge(id: '#C3E8', name: 'Mohamed Triki',  role: 'Agent',      zone: 'Couloir',         active: true,  lastSeen: 'Hier 16:00'),
    _RfidBadge(id: '#D9F1', name: 'Leila Chaabane', role: 'Service IT', zone: 'Bureaux',         active: false, lastSeen: 'Il y a 3j'),
    _RfidBadge(id: '#E2A4', name: 'Karim Jlassi',   role: 'Agent',      zone: 'Couloir',         active: true,  lastSeen: 'Auj. 07:50'),
    _RfidBadge(id: '#F5B0', name: 'Amira Belhaj',   role: 'Admin',      zone: 'Salle Serveurs',  active: false, lastSeen: 'Il y a 7j'),
  ];

  final List<_AccessEvent> _history = [
    _AccessEvent(badge: '#A4F2', name: 'Ahmed Ben Ali', zone: 'Salle Serveurs', time: 'Auj. 09:14', granted: true),
    _AccessEvent(badge: '#B7D1', name: 'Sara Mansouri', zone: 'Bureaux',         time: 'Auj. 08:30', granted: true),
    _AccessEvent(badge: '#ZZ99', name: 'Inconnu',        zone: 'Salle Serveurs', time: 'Hier 17:10', granted: false),
    _AccessEvent(badge: '#C3E8', name: 'Mohamed Triki', zone: 'Couloir',         time: 'Hier 16:00', granted: true),
    _AccessEvent(badge: '#E2A4', name: 'Karim Jlassi',  zone: 'Couloir',         time: 'Auj. 07:50', granted: true),
    _AccessEvent(badge: '#XX01', name: 'Inconnu',        zone: 'Bureaux',         time: 'Hier 11:22', granted: false),
  ];

  final List<_Zone> _zones = [
    _Zone(name: 'Salle Serveurs', icon: CupertinoIcons.desktopcomputer,        color: Color(0xFF4A6CF7), badgeCount: 2, locked: false),
    _Zone(name: 'Bureaux',        icon: CupertinoIcons.building_2_fill,         color: Color(0xFF2196F3), badgeCount: 2, locked: false),
    _Zone(name: 'Couloir',        icon: CupertinoIcons.arrow_right_circle_fill, color: Color(0xFF4CAF50), badgeCount: 2, locked: true),
    _Zone(name: 'Salle Réunion',  icon: CupertinoIcons.person_3_fill,           color: Color(0xFFFF9800), badgeCount: 0, locked: true),
  ];

  List<_RfidBadge> get _filteredBadges => _badges.where((b) =>
      _search.isEmpty ||
      b.name.toLowerCase().contains(_search.toLowerCase()) ||
      b.id.toLowerCase().contains(_search.toLowerCase())).toList();

  Color _surface(BuildContext ctx) => Theme.of(ctx).colorScheme.surface;
  Color _bg(BuildContext ctx)      => Theme.of(ctx).scaffoldBackgroundColor;
  Color _textP(BuildContext ctx)   => Theme.of(ctx).colorScheme.onSurface;
  Color _textS(BuildContext ctx)   => Theme.of(ctx).colorScheme.onSurfaceVariant;
  bool  _isDark(BuildContext ctx)  => Theme.of(ctx).brightness == Brightness.dark;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg(context),
      appBar: AppBar(
        backgroundColor: _bg(context), elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _surface(context), borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(_isDark(context) ? 0.3 : 0.06), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Icon(CupertinoIcons.chevron_left, color: _textP(context), size: 18),
          ),
        ),
        title: Text('Gestion RFID',
            style: TextStyle(color: _textP(context), fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        actions: [
          GestureDetector(
            onTap: _showAddBadgeDialog,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: _rfidAccent, borderRadius: BorderRadius.circular(10)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(CupertinoIcons.add, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text('Ajouter', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
      body: Column(children: [
        _buildStatsRow(context),
        _buildTabs(context),
        const SizedBox(height: 12),
        Expanded(child: _buildContent(context)),
      ]),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final active   = _badges.where((b) => b.active).length;
    final inactive = _badges.where((b) => !b.active).length;
    final refused  = _history.where((h) => !h.granted).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(children: [
        _StatChip(label: 'Actifs',   value: '$active',   color: _green),
        const SizedBox(width: 10),
        _StatChip(label: 'Inactifs', value: '$inactive', color: _textS(context)),
        const SizedBox(width: 10),
        _StatChip(label: 'Refusés',  value: '$refused',  color: _red),
      ]),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final tabs = ['Badges', 'Zones', 'Historique'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: _surface(context), borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(_isDark(context) ? 0.25 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: List.generate(tabs.length, (i) {
          final sel = _selectedTab == i;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: sel ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(tabs[i],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : _textS(context)))),
            ),
          ));
        })),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_selectedTab) {
      case 0:  return _buildBadgeList(context);
      case 1:  return _buildZoneList(context);
      case 2:  return _buildHistory(context);
      default: return const SizedBox();
    }
  }

  Widget _buildBadgeList(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
              color: _surface(context), borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(_isDark(context) ? 0.25 : 0.05), blurRadius: 6, offset: const Offset(0, 2))]),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v),
            style: TextStyle(color: _textP(context), fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Rechercher un badge ou un nom...',
              hintStyle: TextStyle(color: _textS(context), fontSize: 13),
              prefixIcon: Icon(CupertinoIcons.search, color: _textS(context), size: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredBadges.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _BadgeTile(
          badge: _filteredBadges[i],
          onToggle: (val) => setState(() => _filteredBadges[i].active = val),
          onDelete: () => setState(() => _badges.remove(_filteredBadges[i])),
        ),
      )),
    ]);
  }

  Widget _buildZoneList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _zones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final z = _zones[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface(context), borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(_isDark(context) ? 0.25 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(width: 44, height: 44,
                decoration: BoxDecoration(color: z.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(z.icon, color: z.color, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(z.name, style: TextStyle(color: _textP(context), fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${z.badgeCount} badge(s) autorisé(s)', style: TextStyle(color: _textS(context), fontSize: 11)),
            ])),
            GestureDetector(
              onTap: () => setState(() => _zones[i] = _Zone(name: z.name, icon: z.icon, color: z.color, badgeCount: z.badgeCount, locked: !z.locked)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: z.locked ? _red.withOpacity(0.10) : _green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: z.locked ? _red.withOpacity(0.30) : _green.withOpacity(0.30)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(z.locked ? CupertinoIcons.lock_fill : CupertinoIcons.lock_open_fill,
                      color: z.locked ? _red : _green, size: 14),
                  const SizedBox(width: 5),
                  Text(z.locked ? 'Verrouillé' : 'Ouvert',
                      style: TextStyle(color: z.locked ? _red : _green, fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildHistory(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final h = _history[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _surface(context), borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(_isDark(context) ? 0.25 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(width: 38, height: 38,
                decoration: BoxDecoration(color: (h.granted ? _green : _red).withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
                child: Icon(h.granted ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
                    color: h.granted ? _green : _red, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.name, style: TextStyle(color: _textP(context), fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${h.badge}  •  ${h.zone}', style: TextStyle(color: _textS(context), fontSize: 11)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(h.time, style: TextStyle(color: _textS(context), fontSize: 10)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: (h.granted ? _green : _red).withOpacity(0.10), borderRadius: BorderRadius.circular(6)),
                child: Text(h.granted ? 'Accordé' : 'Refusé',
                    style: TextStyle(color: h.granted ? _green : _red, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        );
      },
    );
  }

  void _showAddBadgeDialog() {
    final nameCtrl = TextEditingController();
    final idCtrl   = TextEditingController();
    String role = 'Agent';
    String zone = 'Couloir';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) {
        final surface = Theme.of(ctx).colorScheme.surface;
        final bg      = Theme.of(ctx).scaffoldBackgroundColor;
        final textP   = Theme.of(ctx).colorScheme.onSurface;
        final textS   = Theme.of(ctx).colorScheme.onSurfaceVariant;
        return Dialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: _rfidAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(CupertinoIcons.wifi, color: _rfidAccent, size: 18)),
                const SizedBox(width: 12),
                Text('Nouveau badge', style: TextStyle(color: textP, fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 20),
              _dlgField(ctx, 'ID du badge (ex: #A4F2)', idCtrl),
              const SizedBox(height: 10),
              _dlgField(ctx, 'Nom complet', nameCtrl),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<String>(
                  value: role, isExpanded: true, underline: const SizedBox(),
                  dropdownColor: surface, style: TextStyle(color: textP, fontSize: 14),
                  items: ['Admin', 'Service IT', 'Agent'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setLocal(() => role = v ?? role),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<String>(
                  value: zone, isExpanded: true, underline: const SizedBox(),
                  dropdownColor: surface, style: TextStyle(color: textP, fontSize: 14),
                  items: ['Salle Serveurs', 'Bureaux', 'Couloir', 'Salle Réunion'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setLocal(() => zone = v ?? zone),
                ),
              ),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('Annuler', style: TextStyle(color: textS, fontWeight: FontWeight.w600))),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: GestureDetector(
                  onTap: () {
                    if (idCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                      setState(() => _badges.add(_RfidBadge(id: idCtrl.text, name: nameCtrl.text, role: role, zone: zone, active: true, lastSeen: 'Jamais')));
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(color: _rfidAccent, borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: _rfidAccent.withOpacity(0.30), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: const Center(child: Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                  ),
                )),
              ]),
            ]),
          ),
        );
      }),
    );
  }

  Widget _dlgField(BuildContext ctx, String hint, TextEditingController ctrl) {
    final bg    = Theme.of(ctx).scaffoldBackgroundColor;
    final textP = Theme.of(ctx).colorScheme.onSurface;
    final textS = Theme.of(ctx).colorScheme.onSurfaceVariant;
    return TextField(
      controller: ctrl,
      style: TextStyle(color: textP, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: textS, fontSize: 14),
        filled: true, fillColor: bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ActivityLogScreen — conservé intégralement
// ─────────────────────────────────────────────────────────────
class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});
  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  static const _logAccent = Color(0xFF4A6CF7);
  final _filters = ['Tout', 'Connexion', 'Capteurs', 'RFID', 'Alertes'];
  int    _selectedFilter = 0;
  String _search         = '';
  final  _searchCtrl     = TextEditingController();

  final List<_LogEntry> _logs = [
    _LogEntry(icon: CupertinoIcons.person_fill,                 color: Color(0xFF4A6CF7), title: 'Connexion réussie',       subtitle: 'Admin — iPhone 14 Pro',         time: "Aujourd'hui 09:14", type: 'Connexion'),
    _LogEntry(icon: CupertinoIcons.thermometer,                 color: Color(0xFFFF9800), title: 'Alerte température',       subtitle: 'Capteur temp. → 36.2°C',        time: "Aujourd'hui 08:52", type: 'Alertes'),
    _LogEntry(icon: CupertinoIcons.wifi,                        color: Color(0xFF7E57C2), title: 'Badge RFID scanné',        subtitle: 'Carte #A4F2 — Salle serveurs',   time: "Aujourd'hui 08:30", type: 'RFID'),
    _LogEntry(icon: CupertinoIcons.drop_fill,                   color: Color(0xFF2196F3), title: 'Capteur humidité',         subtitle: 'Humidité : 72% (seuil dépassé)', time: 'Hier 23:41',        type: 'Capteurs'),
    _LogEntry(icon: CupertinoIcons.person_fill,                 color: Color(0xFF4A6CF7), title: 'Connexion réussie',        subtitle: 'Service IT — Android',           time: 'Hier 22:05',        type: 'Connexion'),
    _LogEntry(icon: CupertinoIcons.exclamationmark_shield_fill, color: Color(0xFFEF5350), title: 'Alerte gaz détectée',      subtitle: 'Capteur gaz → 48 ppm',          time: 'Hier 18:33',        type: 'Alertes'),
    _LogEntry(icon: CupertinoIcons.wifi,                        color: Color(0xFF7E57C2), title: 'Badge RFID refusé',        subtitle: 'Carte inconnue #ZZ99',           time: 'Hier 17:10',        type: 'RFID'),
    _LogEntry(icon: CupertinoIcons.lock_fill,                   color: Color(0xFF4CAF50), title: 'Déconnexion',              subtitle: 'Admin — session fermée',         time: 'Hier 16:00',        type: 'Connexion'),
    _LogEntry(icon: CupertinoIcons.thermometer,                 color: Color(0xFF4CAF50), title: 'Température normale',      subtitle: 'Capteur temp. → 22.1°C',         time: 'Hier 14:20',        type: 'Capteurs'),
    _LogEntry(icon: CupertinoIcons.wifi,                        color: Color(0xFF7E57C2), title: 'Badge RFID scanné',        subtitle: 'Carte #B7D1 — Couloir',          time: 'Hier 11:05',        type: 'RFID'),
    _LogEntry(icon: CupertinoIcons.exclamationmark_shield_fill, color: Color(0xFFEF5350), title: 'Tentative accès refusée',  subtitle: 'IP: 192.168.1.44',              time: '12/06 09:30',       type: 'Alertes'),
    _LogEntry(icon: CupertinoIcons.person_fill,                 color: Color(0xFF4A6CF7), title: 'Connexion réussie',        subtitle: 'Agent — Web',                    time: '12/06 08:00',       type: 'Connexion'),
  ];

  List<_LogEntry> get _filtered => _logs.where((e) {
    final f = _filters[_selectedFilter];
    return (f == 'Tout' || e.type == f) &&
        (_search.isEmpty ||
            e.title.toLowerCase().contains(_search.toLowerCase()) ||
            e.subtitle.toLowerCase().contains(_search.toLowerCase()));
  }).toList();

  Color _surface(BuildContext ctx) => Theme.of(ctx).colorScheme.surface;
  Color _bg(BuildContext ctx)      => Theme.of(ctx).scaffoldBackgroundColor;
  Color _textP(BuildContext ctx)   => Theme.of(ctx).colorScheme.onSurface;
  Color _textS(BuildContext ctx)   => Theme.of(ctx).colorScheme.onSurfaceVariant;
  bool  _isDark(BuildContext ctx)  => Theme.of(ctx).brightness == Brightness.dark;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg(context),
      appBar: AppBar(
        backgroundColor: _bg(context), elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _surface(context), borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(_isDark(context) ? 0.3 : 0.06), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Icon(CupertinoIcons.chevron_left, color: _textP(context), size: 18),
          ),
        ),
        title: Text("Journal d'activité",
            style: TextStyle(color: _textP(context), fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _logAccent.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
            child: Text('${_filtered.length} entrées',
                style: const TextStyle(color: _logAccent, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: _surface(context), borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(_isDark(context) ? 0.25 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: TextStyle(color: _textP(context), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: TextStyle(color: _textS(context), fontSize: 14),
                prefixIcon: Icon(CupertinoIcons.search, color: _textS(context), size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: _filters.length,
            itemBuilder: (context, i) {
              final sel = _selectedFilter == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _logAccent : _surface(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                        color: sel ? _logAccent.withOpacity(0.25) : Colors.black.withOpacity(_isDark(context) ? 0.25 : 0.05),
                        blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Text(_filters[i],
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : _textS(context))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(CupertinoIcons.doc_text, size: 48, color: _textS(context).withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text('Aucun résultat', style: TextStyle(color: _textS(context), fontSize: 14)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _LogTile(entry: _filtered[i]),
                ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Modèles de données
// ─────────────────────────────────────────────────────────────
class _RfidBadge {
  final String id, name, role, zone, lastSeen;
  bool active;
  _RfidBadge({required this.id, required this.name, required this.role,
      required this.zone, required this.active, required this.lastSeen});
}

class _AccessEvent {
  final String badge, name, zone, time;
  final bool granted;
  const _AccessEvent({required this.badge, required this.name,
      required this.zone, required this.time, required this.granted});
}

class _Zone {
  final String name; final IconData icon; final Color color;
  final int badgeCount; final bool locked;
  const _Zone({required this.name, required this.icon, required this.color,
      required this.badgeCount, required this.locked});
}

class _LogEntry {
  final IconData icon; final Color color;
  final String title, subtitle, time, type;
  const _LogEntry({required this.icon, required this.color, required this.title,
      required this.subtitle, required this.time, required this.type});
}

// ─────────────────────────────────────────────────────────────
//  Widgets partagés
// ─────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: surface, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
        ]),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final _RfidBadge badge;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  static const _rfidC = Color(0xFF7E57C2);
  static const _green = Color(0xFF4CAF50);
  static const _red   = Color(0xFFEF5350);
  const _BadgeTile({required this.badge, required this.onToggle, required this.onDelete});
  Color get _roleColor => badge.role == 'Admin' ? const Color(0xFFFF9800) : badge.role == 'Service IT' ? const Color(0xFF2196F3) : _green;
  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final textP   = Theme.of(context).colorScheme.onSurface;
    final textS   = Theme.of(context).colorScheme.onSurfaceVariant;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: badge.active ? _green.withOpacity(0.15) : Colors.transparent),
      ),
      child: Row(children: [
        Container(width: 44, height: 44,
            decoration: BoxDecoration(color: _rfidC.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(CupertinoIcons.creditcard_fill, color: _rfidC, size: 16),
              Text(badge.id, style: const TextStyle(color: _rfidC, fontSize: 7, fontWeight: FontWeight.w700)),
            ])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(badge.name, style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _roleColor.withOpacity(0.10), borderRadius: BorderRadius.circular(5)),
                child: Text(badge.role, style: TextStyle(color: _roleColor, fontSize: 10, fontWeight: FontWeight.w600))),
            const SizedBox(width: 6),
            Text('• ${badge.zone}', style: TextStyle(color: textS, fontSize: 10)),
          ]),
          Text('Vu: ${badge.lastSeen}', style: TextStyle(color: textS, fontSize: 10)),
        ])),
        Column(children: [
          CupertinoSwitch(value: badge.active, onChanged: onToggle, activeColor: _green),
          const SizedBox(height: 4),
          GestureDetector(onTap: onDelete, child: const Icon(CupertinoIcons.trash, color: _red, size: 16)),
        ]),
      ]),
    );
  }
}

class _LogTile extends StatelessWidget {
  final _LogEntry entry;
  const _LogTile({required this.entry});
  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final textP   = Theme.of(context).colorScheme.onSurface;
    final textS   = Theme.of(context).colorScheme.onSurfaceVariant;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(width: 40, height: 40,
            decoration: BoxDecoration(color: entry.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(entry.icon, color: entry.color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.title, style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(entry.subtitle, style: TextStyle(color: textS, fontSize: 11)),
        ])),
        const SizedBox(width: 8),
        Text(entry.time, style: TextStyle(color: textS, fontSize: 10, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}