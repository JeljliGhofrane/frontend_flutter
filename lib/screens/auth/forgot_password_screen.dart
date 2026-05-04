import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nettemp_guard/generated/l10n.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wave_header.dart';
import '../../widgets/common_widgets.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  // Pré-rempli si on arrive via le lien email
  final String? emailFromLink;
  final String? tokenFromLink;

  const ForgotPasswordScreen({
    super.key,
    this.emailFromLink,
    this.tokenFromLink,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────
  final _formEmail = GlobalKey<FormState>();
  final _formCode = GlobalKey<FormState>();
  final _formPass = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────
  int _step = 0; // 0=email | 1=code | 2=nouveau mdp | 3=succès
  bool _loading = false;
  String _email = '';
  String _resetToken = '';

  // ── Animations ────────────────────────────────────────────
  late AnimationController _scaleAc; // pour l'animation succès
  late Animation<double> _scaleAnim;
  late AnimationController _fadeAc; // pour les transitions d'étapes
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _scaleAc = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleAc, curve: Curves.elasticOut));

    _fadeAc = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeAc, curve: Curves.easeIn));
    _fadeAc.forward();

    // Si on arrive via le lien email → étape 2 directement
    if (widget.emailFromLink != null && widget.tokenFromLink != null) {
      _email = widget.emailFromLink!;
      _resetToken = widget.tokenFromLink!;
      _step = 2;
    }
  }

  @override
  void dispose() {
    _scaleAc.dispose();
    _fadeAc.dispose();
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ─── Étape 0 → Envoyer email ──────────────────────────────
  Future<void> _sendEmail() async {
    if (!_formEmail.currentState!.validate()) return;
    setState(() => _loading = true);
    _email = _emailCtrl.text.trim().toLowerCase();
    final err = await AuthService().sendPasswordReset(_email);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      _snack(err, isError: true);
    } else {
      _snack(AppLocalizations.of(context)!.codeSentTo(_email));
      _goToStep(1);
    }
  }

  // ─── Étape 1 → Vérifier code ──────────────────────────────
  Future<void> _verifyCode() async {
    if (!_formCode.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await AuthService().verifyCode(_email, _codeCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.error != null) {
      _snack(result.error!, isError: true);
    } else {
      _resetToken = result.resetToken ?? '';
      _goToStep(2);
    }
  }

  // ─── Étape 2 → Nouveau mot de passe ───────────────────────
  Future<void> _resetPassword() async {
    if (!_formPass.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await AuthService().resetPassword(
      email: _email,
      token: _resetToken,
      newPassword: _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      _snack(err, isError: true);
    } else {
      _goToStep(3);
      _scaleAc.forward();
    }
  }

  Future<void> _goToStep(int step) async {
    await _fadeAc.reverse();
    setState(() => _step = step);
    _fadeAc.forward();
  }

  void _snack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));

  // ─── Icône selon étape ─────────────────────────────────────
  IconData get _stepIcon => [
        Icons.key_rounded,
        Icons.pin_outlined,
        Icons.lock_reset_rounded,
        Icons.mark_email_read_rounded,
      ][_step];

  // ─── Titre header selon étape ──────────────────────────────
  String get _headerTitle => [
        AppLocalizations.of(context)!.forgotPassword,
        AppLocalizations.of(context)!.forgotPassword,
        AppLocalizations.of(context)!.newPasswordTitle,
        AppLocalizations.of(context)!.forgotPassword,
      ][_step];

  // ─── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // ── Wave Header (design original conservé)
            WaveHeader(
              height: 220,
              child: SafeArea(
                bottom: false,
                child: Column(children: [
                  // Barre navigation
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(children: [
                      NavBackBtn(onTap: () {
                        if (_step == 1) {
                          _goToStep(0);
                        } else if (_step == 2 && widget.tokenFromLink == null) {
                          _goToStep(1);
                        } else {
                          Navigator.pop(context);
                        }
                      }),
                      Expanded(
                        child: Text(_headerTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ),
                      // Indicateur étape (masqué sur succès)
                      _step < 3
                          ? Text('${_step + 1}/3',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.40),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600))
                          : const SizedBox(width: 34),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  // Barre de progression (design original)
                  if (_step < 3) StepIndicator(current: _step, total: 3),
                  const SizedBox(height: 20),
                  // Icône (design original)
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 1.5),
                    ),
                    child: Icon(_stepIcon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 28),
                ]),
              ),
            ),

            // ── Contenu animé
            FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
                child: [
                  _buildStepEmail(),
                  _buildStepCode(),
                  _buildStepPassword(),
                  _buildSuccess(),
                ][_step],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ÉTAPE 0 : Email (design original) ────────────────────
  Widget _buildStepEmail() => Form(
        key: _formEmail,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.resetTitle,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text(
              AppLocalizations.of(context)!.resetSubtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
          AppField(
            label: AppLocalizations.of(context)!.workEmail, hint: AppLocalizations.of(context)!.emailHint,
            prefixIcon: Icons.alternate_email_rounded,
            controller: _emailCtrl,
            keyboard: TextInputType.emailAddress,
            action: TextInputAction.done,
            // ✅ APRÈS — accepte tous les emails
            validator: (v) {
              if (v == null || v.isEmpty) return AppLocalizations.of(context)!.emailRequired;
              if (!v.contains('@') || !v.contains('.'))
                return AppLocalizations.of(context)!.emailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 26),
          PrimaryButton(
              label: AppLocalizations.of(context)!.sendCode,
              onTap: _sendEmail,
              isLoading: _loading,
              icon: Icons.send_rounded),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.backToLogin,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.navyMid,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      );

  // ─── ÉTAPE 1 : Code 6 chiffres ────────────────────────────
  Widget _buildStepCode() => Form(
        key: _formCode,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.verificationTitle,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context)!.codeSentTo(_email),
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 28),

          // Champ code stylisé centré
          Center(
            child: SizedBox(
              width: 220,
              child: TextFormField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                  color: AppColors.textPrimary,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '• • • • • •',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 20,
                      letterSpacing: 6),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.navyMid, width: 2),
                  ),
                ),
                validator: (v) => (v == null || v.length != 6)
                    ? AppLocalizations.of(context)!.code6DigitsRequired
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info expiration
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.navyMid, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.codeExpiresInfo,
                  style: const TextStyle(
                      color: AppColors.navyMid, fontSize: 12, height: 1.5),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // Renvoyer le code
          Center(
            child: GestureDetector(
              onTap: _loading ? null : () => _goToStep(0),
              child: Text(AppLocalizations.of(context)!.resendCode,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.navyMid,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline)),
            ),
          ),

          const SizedBox(height: 28),
          PrimaryButton(
              label: AppLocalizations.of(context)!.verifyCode,
              onTap: _verifyCode,
              isLoading: _loading,
              icon: Icons.verified_outlined),
        ]),
      );

  // ─── ÉTAPE 2 : Nouveau mot de passe ───────────────────────
  Widget _buildStepPassword() => Form(
        key: _formPass,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.newPasswordTitle,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context)!.newPasswordSubtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
          AppField(
            label: AppLocalizations.of(context)!.newPasswordTitle,
            hint: AppLocalizations.of(context)!.passwordHint,
            prefixIcon: Icons.lock_outline_rounded,
            obscure: true,
            controller: _passCtrl,
            validator: (v) {
              if (v == null || v.isEmpty) return AppLocalizations.of(context)!.passwordRequired;
              if (v.length < 8) return AppLocalizations.of(context)!.min8Chars;
              if (!RegExp(r'[A-Z]').hasMatch(v)) return AppLocalizations.of(context)!.needUppercase;
              if (!RegExp(r'[0-9]').hasMatch(v)) return AppLocalizations.of(context)!.needNumber;
              return null;
            },
          ),
          // Barre de force (widget existant dans ton projet)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _passCtrl,
            builder: (_, val, __) => PasswordStrengthBar(password: val.text),
          ),
          const SizedBox(height: 14),
          AppField(
            label: AppLocalizations.of(context)!.confirmPassword,
            hint: AppLocalizations.of(context)!.passwordHint,
            prefixIcon: Icons.lock_outline_rounded,
            obscure: true,
            controller: _confirmCtrl,
            action: TextInputAction.done,
            validator: (v) => v != _passCtrl.text
                ? AppLocalizations.of(context)!.passwordsDontMatch
                : null,
          ),
          const SizedBox(height: 28),
          PrimaryButton(
              label: AppLocalizations.of(context)!.resetAction,
              onTap: _resetPassword,
              isLoading: _loading,
              icon: Icons.check_circle_outline_rounded),
        ]),
      );

  // ─── ÉTAPE 3 : Succès (design original conservé) ──────────
  Widget _buildSuccess() => Column(
        children: [
          const SizedBox(height: 10),
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.30),
                    width: 1.5),
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.success, size: 40),
            ),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.passwordUpdatedTitle,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Text(
              'Votre mot de passe a été réinitialisé\nsuccessfully pour $_email',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.6)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.navyMid, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.canNowLoginInfo,
                  style: const TextStyle(
                      color: AppColors.navyMid, fontSize: 12, height: 1.5),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: AppLocalizations.of(context)!.signIn,
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (r) => false,
            ),
          ),
        ],
      );
}
