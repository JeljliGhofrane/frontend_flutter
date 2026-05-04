// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get profile => 'تعديل الملف الشخصي';

  @override
  String get password => 'تغيير كلمة المرور';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get appSection => 'التطبيق';

  @override
  String get accountSection => 'الحساب';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'ادخل إلى مساحة المراقبة الخاصة بك';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'name@ommp.tn';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'بريد إلكتروني غير صالح';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotShort => 'نسيت؟';

  @override
  String get signIn => 'دخول';

  @override
  String get or => 'أو';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get noAccountQuestion => 'ليس لديك حساب؟ ';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get cannotOpenGoogleLogin => 'تعذر فتح تسجيل الدخول عبر Google';

  @override
  String googleLoginError(Object error) {
    return 'خطأ Google: $error';
  }

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get alreadyHaveAccountQuestion => 'لديك حساب؟ ';

  @override
  String get signInAction => 'تسجيل الدخول';

  @override
  String get chooseRoleError => 'يرجى اختيار منصبك';

  @override
  String get infoTitle => 'المعلومات';

  @override
  String get infoSubtitle => 'أدخل معلوماتك الشخصية';

  @override
  String get lastName => 'اللقب';

  @override
  String get firstName => 'الاسم';

  @override
  String get lastNameRequired => 'اللقب مطلوب';

  @override
  String get firstNameRequired => 'الاسم مطلوب';

  @override
  String get workEmail => 'البريد المهني';

  @override
  String get roleTitle => 'منصبك';

  @override
  String get roleSubtitle => 'اختر دورك في OMMP';

  @override
  String get securityTitle => 'الأمان';

  @override
  String get securitySubtitle => 'أنشئ كلمة مرور قوية';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get min8Chars => '8 أحرف على الأقل';

  @override
  String get needUppercase => 'حرف كبير واحد على الأقل';

  @override
  String get needNumber => 'رقم واحد على الأقل';

  @override
  String get passwordsDontMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get acceptTerms =>
      'أوافق على شروط الاستخدام وسياسة الخصوصية الخاصة بـ OMMP بنزرت.';

  @override
  String get createMyAccount => 'إنشاء حسابي';

  @override
  String get accountCreated => 'تم إنشاء الحساب!';

  @override
  String get requestSubmitted => 'تم إرسال طلبك.\nسيقوم مسؤول بتفعيل الوصول.';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get resetTitle => 'إعادة تعيين';

  @override
  String get resetSubtitle => 'أدخل بريدك لتلقي الرمز ورابط إعادة التعيين.';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get backToLogin => '← العودة لتسجيل الدخول';

  @override
  String get verificationTitle => 'التحقق';

  @override
  String codeSentTo(Object email) {
    return 'تم إرسال الرمز إلى\n$email';
  }

  @override
  String get code6DigitsRequired => 'رمز مكوّن من 6 أرقام مطلوب';

  @override
  String get codeExpiresInfo =>
      'تنتهي صلاحية الرمز خلال 15 دقيقة. تحقق أيضاً من البريد غير الهام.';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get verifyCode => 'تحقق من الرمز';

  @override
  String get newPasswordTitle => 'كلمة مرور جديدة';

  @override
  String get newPasswordSubtitle => 'أنشئ كلمة مرور آمنة لحسابك.';

  @override
  String get resetAction => 'إعادة تعيين';

  @override
  String get passwordUpdatedTitle => 'تم تحديث كلمة المرور!';

  @override
  String get canNowLoginInfo => 'يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String timeAgo(Object time) {
    return 'منذ $time';
  }

  @override
  String get aiAnalysisTitle => 'تحليل الذكاء الاصطناعي';

  @override
  String get recentEvents => 'الأحداث الأخيرة';
}
