import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  // ===========================================================
  // FONCTION DE TRADUCTION (Dictionnaire)
  // ===========================================================
  String _translate(String fr, String en, String ar) {
    if (locale.languageCode == 'ar') return ar;
    if (locale.languageCode == 'en') return en;
    return fr; // Par défaut en Français
  }

  // --- Écran Paramètres / Settings ---
  String get settings => _translate("Paramètres", "Settings", "الإعدادات");
  String get logout => _translate("Déconnexion", "Logout", "تسجيل الخروج");
  String get profile => _translate("Profil", "Profile", "الملف الشخصي");
  String get language => _translate("Langue", "Language", "اللغة");
  String get accountSection => _translate("COMPTE", "ACCOUNT", "الحساب");
  String get appSection => _translate("APPLICATION", "APPLICATION", "التطبيق");
  String get password => _translate("Mot de passe", "Password", "كلمة المرور");
  String get notifications => _translate("Notifications", "Notifications", "الإشعارات");

  // --- Auth (Login / Register) ---
  String get loginTitle => _translate("Connexion", "Sign in", "تسجيل الدخول");
  String get loginSubtitle => _translate(
      "Accédez à votre espace de surveillance",
      "Access your monitoring space",
      "ادخل إلى مساحة المراقبة الخاصة بك");
  String get emailLabel => _translate("E-mail", "Email", "البريد الإلكتروني");
  String get emailHint => _translate("nom@ommp.tn", "name@ommp.tn", "name@ommp.tn");
  String get emailRequired => _translate("E-mail requis", "Email is required", "البريد الإلكتروني مطلوب");
  String get emailInvalid => _translate("E-mail invalide", "Invalid email", "بريد إلكتروني غير صالح");
  String get passwordLabel => _translate("Mot de passe", "Password", "كلمة المرور");
  String get passwordHint => _translate("••••••••", "••••••••", "••••••••");
  String get passwordRequired => _translate("Mot de passe requis", "Password is required", "كلمة المرور مطلوبة");
  String get rememberMe => _translate("Se souvenir de moi", "Remember me", "تذكرني");
  String get forgotShort => _translate("Oublié ?", "Forgot?", "نسيت؟");
  String get signIn => _translate("Se connecter", "Sign in", "دخول");
  String get or => _translate("OU", "OR", "أو");
  String get continueWithGoogle => _translate("Continuer avec Google", "Continue with Google", "المتابعة باستخدام Google");
  String get noAccountQuestion => _translate("Pas de compte ? ", "No account? ", "ليس لديك حساب؟ ");
  String get createAccount => _translate("Créer un compte", "Create an account", "إنشاء حساب");
  String get cannotOpenGoogleLogin =>
      _translate("Impossible d'ouvrir Google Login", "Unable to open Google Login", "تعذر فتح تسجيل الدخول عبر Google");
  String googleLoginError(String error) => _translate(
      "Erreur Google Login : $error",
      "Google Login error: $error",
      "خطأ Google: $error");

  String get registerTitle => _translate("Créer un compte", "Create an account", "إنشاء حساب");
  String get continueLabel => _translate("Continuer", "Continue", "متابعة");
  String get alreadyHaveAccountQuestion => _translate("Déjà un compte ? ", "Already have an account? ", "لديك حساب؟ ");
  String get signInAction => _translate("Se connecter", "Sign in", "تسجيل الدخول");
  String get chooseRoleError => _translate("Veuillez choisir votre poste", "Please choose your role", "يرجى اختيار منصبك");
  String get infoTitle => _translate("Informations", "Information", "المعلومات");
  String get infoSubtitle => _translate("Renseignez vos informations personnelles", "Enter your personal information", "أدخل معلوماتك الشخصية");
  String get lastName => _translate("Nom", "Last name", "اللقب");
  String get firstName => _translate("Prénom", "First name", "الاسم");
  String get lastNameRequired => _translate("Nom requis", "Last name is required", "اللقب مطلوب");
  String get firstNameRequired => _translate("Prénom requis", "First name is required", "الاسم مطلوب");
  String get workEmail => _translate("E-mail professionnel", "Work email", "البريد المهني");
  String get roleTitle => _translate("Votre poste", "Your role", "منصبك");
  String get roleSubtitle => _translate("Sélectionnez votre rôle dans OMMP", "Select your role at OMMP", "اختر دورك في OMMP");
  String get securityTitle => _translate("Sécurité", "Security", "الأمان");
  String get securitySubtitle => _translate("Créez votre mot de passe sécurisé", "Create a secure password", "أنشئ كلمة مرور قوية");
  String get confirmPassword => _translate("Confirmer le mot de passe", "Confirm password", "تأكيد كلمة المرور");
  String get min8Chars => _translate("Min. 8 caractères", "Min. 8 characters", "8 أحرف على الأقل");
  String get needUppercase => _translate("Au moins 1 majuscule", "At least 1 uppercase letter", "حرف كبير واحد على الأقل");
  String get needNumber => _translate("Au moins 1 chiffre", "At least 1 number", "رقم واحد على الأقل");
  String get passwordsDontMatch =>
      _translate("Les mots de passe ne correspondent pas", "Passwords do not match", "كلمتا المرور غير متطابقتين");
  String get acceptTerms => _translate(
      "J'accepte les conditions d'utilisation et la politique de confidentialité d'OMMP Bizerte.",
      "I accept the terms of use and OMMP Bizerte privacy policy.",
      "أوافق على شروط الاستخدام وسياسة الخصوصية الخاصة بـ OMMP بنزرت.");
  String get createMyAccount => _translate("Créer mon compte", "Create my account", "إنشاء حسابي");
  String get accountCreated => _translate("Compte créé !", "Account created!", "تم إنشاء الحساب!");
  String get requestSubmitted => _translate(
      "Votre demande est soumise.\nUn admin validera votre accès.",
      "Your request has been submitted.\nAn admin will validate your access.",
      "تم إرسال طلبك.\nسيقوم مسؤول بتفعيل الوصول.");

  // --- Forgot password flow ---
  String get forgotPassword => _translate("Mot de passe oublié", "Forgot password", "نسيت كلمة المرور");
  String get resetTitle => _translate("Réinitialiser", "Reset", "إعادة تعيين");
  String get resetSubtitle => _translate(
      "Entrez votre e-mail OMMP pour recevoir le code et le lien de réinitialisation.",
      "Enter your email to receive the code and reset link.",
      "أدخل بريدك لتلقي الرمز ورابط إعادة التعيين.");
  String get sendCode => _translate("Envoyer le code", "Send code", "إرسال الرمز");
  String get backToLogin => _translate("← Retour à la connexion", "← Back to sign in", "← العودة لتسجيل الدخول");
  String get verificationTitle => _translate("Vérification", "Verification", "التحقق");
  String codeSentTo(String email) => _translate("Code envoyé à\n$email", "Code sent to\n$email", "تم إرسال الرمز إلى\n$email");
  String get code6DigitsRequired => _translate("Code à 6 chiffres requis", "6-digit code required", "رمز مكوّن من 6 أرقام مطلوب");
  String get codeExpiresInfo => _translate(
      "Le code expire dans 15 min. Vérifiez aussi vos spams.",
      "The code expires in 15 minutes. Check your spam folder too.",
      "تنتهي صلاحية الرمز خلال 15 دقيقة. تحقق أيضاً من البريد غير الهام.");
  String get resendCode => _translate("Renvoyer le code", "Resend code", "إعادة إرسال الرمز");
  String get verifyCode => _translate("Vérifier le code", "Verify code", "تحقق من الرمز");
  String get newPasswordTitle => _translate("Nouveau mot de passe", "New password", "كلمة مرور جديدة");
  String get newPasswordSubtitle => _translate(
      "Créez un mot de passe sécurisé pour votre compte.",
      "Create a secure password for your account.",
      "أنشئ كلمة مرور آمنة لحسابك.");
  String get resetAction => _translate("Réinitialiser", "Reset", "إعادة تعيين");
  String get passwordUpdatedTitle => _translate("Mot de passe mis à jour !", "Password updated!", "تم تحديث كلمة المرور!");
  String get canNowLoginInfo => _translate(
      "Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.",
      "You can now sign in with your new password.",
      "يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.");

  // --- Notifications / Analytics ---
  String get notificationsTitle => _translate("Notifications", "Notifications", "الإشعارات");
  String get markAllRead => _translate("Tout lire", "Mark all read", "تحديد الكل كمقروء");
  String timeAgo(String time) => _translate("Il y a $time", "$time ago", "منذ $time");

  String get aiAnalysisTitle => _translate("Analyse IA", "AI Analytics", "تحليل الذكاء الاصطناعي");
  String get recentEvents => _translate("Événements récents", "Recent events", "الأحداث الأخيرة");

  // --- Écran Dashboard / Charts ---
  String get dashboard => _translate("Tableau de bord", "Dashboard", "لوحة القيادة");
  String get temperature => _translate("Température", "Temperature", "درجة الحرارة");
  String get humidity => _translate("Humidité", "Humidity", "الرطوبة");
  String get refresh => _translate("Actualiser", "Refresh", "تحديث");

  // AJOUTE TOUS TES AUTRES MOTS ICI...
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'fr', 'ar'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}