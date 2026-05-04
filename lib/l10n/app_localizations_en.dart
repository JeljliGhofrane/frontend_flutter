// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Logout';

  @override
  String get profile => 'Edit Profile';

  @override
  String get password => 'Change Password';

  @override
  String get notifications => 'Notifications';

  @override
  String get appSection => 'APPLICATION';

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Access your monitoring space';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'name@ommp.tn';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotShort => 'Forgot?';

  @override
  String get signIn => 'Sign in';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccountQuestion => 'No account? ';

  @override
  String get createAccount => 'Create an account';

  @override
  String get cannotOpenGoogleLogin => 'Unable to open Google Login';

  @override
  String googleLoginError(Object error) {
    return 'Google Login error: $error';
  }

  @override
  String get registerTitle => 'Create an account';

  @override
  String get continueLabel => 'Continue';

  @override
  String get alreadyHaveAccountQuestion => 'Already have an account? ';

  @override
  String get signInAction => 'Sign in';

  @override
  String get chooseRoleError => 'Please choose your role';

  @override
  String get infoTitle => 'Information';

  @override
  String get infoSubtitle => 'Enter your personal information';

  @override
  String get lastName => 'Last name';

  @override
  String get firstName => 'First name';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get workEmail => 'Work email';

  @override
  String get roleTitle => 'Your role';

  @override
  String get roleSubtitle => 'Select your role at OMMP';

  @override
  String get securityTitle => 'Security';

  @override
  String get securitySubtitle => 'Create a secure password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get min8Chars => 'Min. 8 characters';

  @override
  String get needUppercase => 'At least 1 uppercase letter';

  @override
  String get needNumber => 'At least 1 number';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get acceptTerms =>
      'I accept the terms of use and OMMP Bizerte privacy policy.';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get accountCreated => 'Account created!';

  @override
  String get requestSubmitted =>
      'Your request has been submitted.\nAn admin will validate your access.';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get resetTitle => 'Reset';

  @override
  String get resetSubtitle =>
      'Enter your email to receive the code and reset link.';

  @override
  String get sendCode => 'Send code';

  @override
  String get backToLogin => '← Back to sign in';

  @override
  String get verificationTitle => 'Verification';

  @override
  String codeSentTo(Object email) {
    return 'Code sent to\n$email';
  }

  @override
  String get code6DigitsRequired => '6-digit code required';

  @override
  String get codeExpiresInfo =>
      'The code expires in 15 minutes. Check your spam folder too.';

  @override
  String get resendCode => 'Resend code';

  @override
  String get verifyCode => 'Verify code';

  @override
  String get newPasswordTitle => 'New password';

  @override
  String get newPasswordSubtitle =>
      'Create a secure password for your account.';

  @override
  String get resetAction => 'Reset';

  @override
  String get passwordUpdatedTitle => 'Password updated!';

  @override
  String get canNowLoginInfo => 'You can now sign in with your new password.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String timeAgo(Object time) {
    return '$time ago';
  }

  @override
  String get aiAnalysisTitle => 'AI Analytics';

  @override
  String get recentEvents => 'Recent events';
}
