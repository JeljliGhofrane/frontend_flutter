import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nettemp_guard/generated/l10n.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wave_header.dart';
import '../../widgets/common_widgets.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _nom         = TextEditingController();
  final _prenom      = TextEditingController();
  final _email       = TextEditingController();
  final _pass        = TextEditingController();
  final _confirmPass = TextEditingController();
  final _form0       = GlobalKey<FormState>();
  final _form2       = GlobalKey<FormState>();

  int     _step    = 0;
  String? _role;
  bool    _terms   = false;
  bool    _loading = false;

  late AnimationController _ac;
  late Animation<double>   _fade;

  // ✅ Les 3 rôles du système
  static const _roles = [
    (
      'admin',
      'Administrateur',
      'Accès complet : utilisateurs, RFID, visages, historique, alertes',
      Icons.admin_panel_settings_outlined,
    ),
    (
      'technicien',
      'Technicien Réseau',
      'Données temps réel, alertes, prédictions IA, journaux RFID',
      Icons.engineering_outlined,
    ),
    (
      'employe',
      'Employé Autorisé',
      'Accès à la salle réseau via badge RFID + reconnaissance faciale',
      Icons.badge_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _ac = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 280));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeIn));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    for (final c in [_nom, _prenom, _email, _pass, _confirmPass]) c.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step == 0 && !_form0.currentState!.validate()) return;
    if (_step == 1 && _role == null) {
      _snack('Veuillez choisir un rôle', err: true);
      return;
    }
    if (_step < 2) {
      await _ac.reverse();
      setState(() => _step++);
      _ac.forward();
    }
  }

  Future<void> _back() async {
    if (_step > 0) {
      await _ac.reverse();
      setState(() => _step--);
      _ac.forward();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _register() async {
    if (!_form2.currentState!.validate()) return;
    if (!_terms) { _snack('Veuillez accepter les conditions', err: true); return; }
    setState(() => _loading = true);
    final err = await AuthService().register(
      nom     : _nom.text,
      prenom  : _prenom.text,
      email   : _email.text,
      password: _pass.text,
      role    : _role!,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) { _snack(err, err: true); return; }
    _showSuccess();
  }

  void _snack(String msg, {bool err = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: err ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));

  void _showSuccess() => showDialog(
    context: context, barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1.5),
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 38),
          ),
          const SizedBox(height: 18),
          const Text('Compte créé !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          const Text(
            'Votre demande a été envoyée.\nUn administrateur va valider votre compte.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Se connecter',
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (r) => false,
            ),
          ),
        ]),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // ── Wave Header ──────────────────────────────────
            WaveHeader(
              height: _step == 0 ? 240 : 200,
              child: SafeArea(
                bottom: false,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(children: [
                      NavBackBtn(onTap: _back),
                      const Expanded(
                        child: Text('Créer un compte',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                      Text('${_step + 1}/3',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  StepIndicator(current: _step, total: 3),
                  const SizedBox(height: 16),
                  if (_step == 0) _buildAvatar() else _buildStepIcon(),
                  const SizedBox(height: 16),
                ]),
              ),
            ),

            // ── Contenu étape ────────────────────────────────
            FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
        ),
        child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 32),
      ),
      Positioned(
        bottom: 0, right: 0,
        child: Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: AppColors.navyMid, shape: BoxShape.circle,
            border: Border.all(color: AppColors.navyDark, width: 2),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 13),
        ),
      ),
    ],
  );

  Widget _buildStepIcon() {
    final icons = [null, Icons.badge_outlined, Icons.security_rounded];
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), shape: BoxShape.circle),
      child: Icon(icons[_step], color: Colors.white, size: 22),
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case 0:  return _buildInfo();
      case 1:  return _buildRole();
      case 2:  return _buildSecurity();
      default: return const SizedBox();
    }
  }

  // ── Étape 1 : Informations ───────────────────────────────
  Widget _buildInfo() => Form(
    key: _form0,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Informations', 'Entrez vos informations personnelles'),
      const SizedBox(height: 20),
      AppField(
        label: 'Nom', hint: 'Ben Ali',
        prefixIcon: Icons.person_outline_rounded,
        controller: _nom,
        validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
      ),
      const SizedBox(height: 14),
      AppField(
        label: 'Prénom', hint: 'Mohamed',
        prefixIcon: Icons.person_outline_rounded,
        controller: _prenom,
        validator: (v) => v == null || v.isEmpty ? 'Prénom requis' : null,
      ),
      const SizedBox(height: 14),
      AppField(
        label: 'Email professionnel', hint: 'votre@ommp.tn',
        prefixIcon: Icons.alternate_email_rounded,
        controller: _email,
        keyboard: TextInputType.emailAddress,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Email requis';
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
            return 'Email invalide';
          return null;
        },
      ),
      const SizedBox(height: 26),
      PrimaryButton(label: 'Continuer', onTap: _next),
      const SizedBox(height: 16),
      BottomAuthLink(
        question: 'Déjà un compte ?',
        action: 'Se connecter',
        onTap: () => Navigator.pop(context),
      ),
    ]),
  );

  // ── Étape 2 : Rôle ──────────────────────────────────────
  Widget _buildRole() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('Votre rôle', 'Choisissez votre profil dans le système'),
      const SizedBox(height: 8),

      // ✅ Les 3 rôles disponibles
      ..._roles.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => setState(() => _role = r.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _role == r.$1
                  ? _roleColor(r.$1).withOpacity(0.06)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _role == r.$1
                    ? _roleColor(r.$1).withOpacity(0.40)
                    : Colors.grey.withOpacity(0.15),
                width: _role == r.$1 ? 1.5 : 1,
              ),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2),
              )],
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _roleColor(r.$1).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(r.$4, color: _roleColor(r.$1), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.$2, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: _role == r.$1 ? _roleColor(r.$1) : AppColors.textPrimary,
                )),
                const SizedBox(height: 3),
                Text(r.$3, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
              ])),
              if (_role == r.$1)
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(color: _roleColor(r.$1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
                ),
            ]),
          ),
        ),
      )),
      const SizedBox(height: 20),
      PrimaryButton(label: 'Continuer', onTap: _next),
    ],
  );

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':      return const Color(0xFFFF9800);
      case 'technicien': return const Color(0xFF4A6CF7);
      case 'employe':    return const Color(0xFF4CAF50);
      default:           return AppColors.navyMid;
    }
  }

  // ── Étape 3 : Sécurité ──────────────────────────────────
  Widget _buildSecurity() => Form(
    key: _form2,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Sécurité', 'Créez un mot de passe sécurisé'),
      const SizedBox(height: 20),
      AppField(
        label: 'Mot de passe', hint: 'Min. 8 caractères',
        prefixIcon: Icons.lock_outline_rounded,
        obscure: true, controller: _pass,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Mot de passe requis';
          if (v.length < 8)            return 'Minimum 8 caractères';
          if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Au moins une majuscule';
          if (!RegExp(r'[0-9]').hasMatch(v)) return 'Au moins un chiffre';
          return null;
        },
      ),
      // Barre de force
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: _pass,
        builder: (_, val, __) => PasswordStrengthBar(password: val.text),
      ),
      const SizedBox(height: 14),
      AppField(
        label: 'Confirmer le mot de passe', hint: 'Répétez le mot de passe',
        prefixIcon: Icons.lock_outline_rounded,
        obscure: true, controller: _confirmPass,
        action: TextInputAction.done,
        validator: (v) => v != _pass.text ? 'Les mots de passe ne correspondent pas' : null,
      ),
      const SizedBox(height: 18),
      AppCheckbox(
        value: _terms,
        onChanged: (v) => setState(() => _terms = v),
        label: 'J\'accepte les conditions d\'utilisation',
      ),
      const SizedBox(height: 24),
      PrimaryButton(
        label: 'Créer mon compte', onTap: _register,
        isLoading: _loading, icon: Icons.check_circle_outline_rounded,
      ),
    ]),
  );

  Widget _sectionTitle(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
          color: AppColors.textPrimary, letterSpacing: -0.4)),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ],
  );
}