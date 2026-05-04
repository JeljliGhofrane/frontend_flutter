import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ══ PrimaryButton ════════════════════════════════════════════════════════════
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final IconData? icon;
  const PrimaryButton(
      {super.key,
      required this.label,
      required this.onTap,
      this.isLoading = false,
      this.icon});
  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _s = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp: (_) {
          _c.reverse();
          if (!widget.isLoading) widget.onTap();
        },
        onTapCancel: () => _c.reverse(),
        child: AnimatedBuilder(
          animation: _s,
          builder: (_, child) => Transform.scale(scale: _s.value, child: child),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.btnGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: AppColors.navyMid.withOpacity(0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(widget.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ]),
            ),
          ),
        ),
      );
}

// ══ AppField ═════════════════════════════════════════════════════════════════
class AppField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final TextInputType keyboard;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction action;
  const AppField(
      {super.key,
      required this.label,
      required this.hint,
      required this.prefixIcon,
      this.obscure = false,
      this.keyboard = TextInputType.text,
      this.controller,
      this.validator,
      this.action = TextInputAction.next});
  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool _focused = false;
  late bool _obscure;
  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Focus(
            onFocusChange: (f) => setState(() => _focused = f),
            child: TextFormField(
              controller: widget.controller,
              obscureText: _obscure,
              keyboardType: widget.keyboard,
              textInputAction: widget.action,
              validator: widget.validator,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle:
                    const TextStyle(color: AppColors.textHint, fontSize: 12),
                filled: true,
                fillColor: _focused ? AppColors.navyLight : AppColors.bgField,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(widget.prefixIcon,
                      size: 17,
                      color: _focused ? AppColors.navyMid : AppColors.textHint),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 44, minHeight: 44),
                suffixIcon: widget.obscure
                    ? GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 17,
                            color: AppColors.textHint))
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide:
                        const BorderSide(color: AppColors.border, width: 1.2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide:
                        const BorderSide(color: AppColors.border, width: 1.2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide:
                        const BorderSide(color: AppColors.navyMid, width: 1.8)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 1.2)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 1.8)),
              ),
            ),
          ),
        ],
      );
}

// ══ SecurityBadge ════════════════════════════════════════════════════════════
class SecurityBadge extends StatelessWidget {
  const SecurityBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
            color: AppColors.navyLight,
            borderRadius: BorderRadius.circular(10)),
        child: const Row(children: [
          Icon(Icons.shield_outlined, size: 14, color: AppColors.navyMid),
          SizedBox(width: 7),
          Expanded(
              child: Text('Connexion sécurisée SSL — OMMP Bizerte',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.navyMid,
                      fontWeight: FontWeight.w500))),
        ]),
      );
}

// ══ BottomAuthLink ═══════════════════════════════════════════════════════════
class BottomAuthLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;
  const BottomAuthLink(
      {super.key,
      required this.question,
      required this.action,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(question,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          GestureDetector(
              onTap: onTap,
              child: Text(action,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.navyMid,
                      fontWeight: FontWeight.w700))),
        ],
      );
}

// ══ AppCheckbox ══════════════════════════════════════════════════════════════
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onChanged(!value),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Important : ne prend que l'espace nécessaire
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: value ? AppColors.navyMid : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: value ? AppColors.navyMid : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, color: Colors.white, size: 11)
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              // Permet au texte de s'adapter sans forcer la largeur
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
}

// ══ PasswordStrengthBar ══════════════════════════════════════════════════════
class PasswordStrengthBar extends StatelessWidget {
  final String password;
  const PasswordStrengthBar({super.key, required this.password});

  int get _strength {
    int s = 0;
    if (password.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(password)) s++;
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(password)) s++;
    return s;
  }

  Color get _color {
    if (_strength <= 1) return AppColors.error;
    if (_strength == 2) return AppColors.warning;
    if (_strength == 3) return AppColors.navyMid;
    return AppColors.success;
  }

  String get _label {
    if (_strength <= 1) return 'Faible';
    if (_strength == 2) return 'Moyen';
    if (_strength == 3) return 'Fort';
    return 'Très fort';
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Column(children: [
      const SizedBox(height: 7),
      Row(
          children: List.generate(
              4,
              (i) => Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                          color: i < _strength ? _color : AppColors.border,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ))),
      const SizedBox(height: 4),
      Align(
          alignment: Alignment.centerRight,
          child: Text(_label,
              style: TextStyle(
                  fontSize: 10, color: _color, fontWeight: FontWeight.w600))),
    ]);
  }
}

// ══ StepIndicator ════════════════════════════════════════════════════════════
class StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const StepIndicator({super.key, required this.current, required this.total});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
            total,
            (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: i == current ? 22 : 12,
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i < current
                        ? Colors.white.withOpacity(0.55)
                        : i == current
                            ? Colors.white
                            : Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
      );
}

// ══ RoleChip ═════════════════════════════════════════════════════════════════
class RoleChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const RoleChip(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.navyLight : AppColors.bgField,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppColors.navyMid : AppColors.border,
                width: selected ? 1.8 : 1.2),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: AppColors.navyMid.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: selected ? AppColors.navyMid : const Color(0xFFDDE5F7),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon,
                  color: selected ? Colors.white : AppColors.navyMid, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            )),
            if (selected)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    color: AppColors.navyMid, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
          ]),
        ),
      );
}

// ══ BackButton custom ════════════════════════════════════════════════════════
class NavBackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const NavBackBtn({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
      );
}
