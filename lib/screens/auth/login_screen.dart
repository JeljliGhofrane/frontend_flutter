import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nettemp_guard/generated/l10n.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ommp_logo.dart';
import '../../widgets/wave_header.dart';
import '../../widgets/common_widgets.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'dart:html' as html;
import 'dart:convert'; // base64Encode, utf8

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _form    = GlobalKey<FormState>();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();

  bool _loading       = false;
  bool _googleLoading = false;
  bool _remember      = true;

  late AnimationController _ac;
  late Animation<Offset>   _slide;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeIn));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  // ─── Login email/password ──────────────────────────────────
  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    final err = await AuthService().login(_email.text, _pass.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      _snack(err, isError: true);
    } else {
      _goToDashboard();
    }
  }

  // ─── Login Google ──────────────────────────────────────────
  // Redirige dans le MÊME onglet → le backend redirigera vers
  // http://localhost:PORT/auth/callback?token=JWT
  // que SplashScreen (ou initState) interceptera.
  Future<void> _loginGoogle() async {
    setState(() => _googleLoading = true);

    try {
      // Construire l'origine courante (ex: http://localhost:5173)
      final origin = '${html.window.location.protocol}//'
                     '${html.window.location.host}';

      // Encoder en base64 pour passer dans le state OAuth
      final state = base64Encode(utf8.encode(origin));

      // Redirection dans le même onglet (pas launchUrl !)
      html.window.location.href =
          'http://localhost:3000/api/auth/google?redirect=$state';

    } catch (e) {
      if (mounted) {
        _snack(
          AppLocalizations.of(context)!.googleLoginError(e.toString()),
          isError: true,
        );
        setState(() => _googleLoading = false);
      }
    }
    // Note : pas de setState _googleLoading = false ici
    // car la page va se rediriger, le widget sera détruit.
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) =>
          DashboardScreen(userRole: AuthService().currentUser!.role),
      transitionDuration: const Duration(milliseconds: 450),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    ));
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // ── Wave Header ──────────────────────────────────
            WaveHeader(
              height: 260,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const OmmpLogo(width: 88, height: 70),
                    const SizedBox(height: 8),
                    const Text('OMMP',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w800, letterSpacing: 3)),
                    const SizedBox(height: 3),
                    Text('NetTemp Guard',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.50),
                            fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ── Formulaire ───────────────────────────────────
            SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Text(l10n.loginTitle,
                            style: TextStyle(fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text(l10n.loginSubtitle,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 24),

                        // Email
                        AppField(
                          label: l10n.emailLabel, hint: l10n.emailHint,
                          prefixIcon: Icons.alternate_email_rounded,
                          controller: _email,
                          keyboard: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return l10n.emailRequired;
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                              return l10n.emailInvalid;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        AppField(
                          label: l10n.passwordLabel, hint: l10n.passwordHint,
                          prefixIcon: Icons.lock_outline_rounded,
                          obscure: true, controller: _pass,
                          action: TextInputAction.done,
                          validator: (v) => v == null || v.isEmpty
                              ? l10n.passwordRequired : null,
                        ),
                        const SizedBox(height: 14),

                        // Remember + Forgot
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppCheckbox(
                              value: _remember,
                              onChanged: (v) => setState(() => _remember = v),
                              label: l10n.rememberMe,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const ForgotPasswordScreen())),
                              child: Text(l10n.forgotShort,
                                  style: const TextStyle(fontSize: 12,
                                      color: AppColors.navyMid,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Bouton Login
                        PrimaryButton(
                          label: l10n.signIn,
                          onTap: _login,
                          isLoading: _loading,
                        ),
                        const SizedBox(height: 16),

                        // ── Séparateur OU ─────────────────────
                        Row(children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(l10n.or,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ]),
                        const SizedBox(height: 16),

                        // ── Bouton Google ─────────────────────
                        _GoogleButton(
                          onTap: _loginGoogle,
                          isLoading: _googleLoading,
                        ),
                        const SizedBox(height: 14),

                        const SecurityBadge(),
                        const SizedBox(height: 20),

                        BottomAuthLink(
                          question: l10n.noAccountQuestion,
                          action: l10n.createAccount,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen())),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget Bouton Google ──────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _GoogleButton({required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.continueWithGoogle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3C4043),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Google Logo Painter (sans asset externe) ──────────────────
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height),
        -0.5, 2.3, true, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height),
        1.8, 1.6, true, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height),
        3.4, 1.6, true, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height),
        5.0, 1.0, true, paint);

    paint.color = Colors.white;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width * 0.35, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}