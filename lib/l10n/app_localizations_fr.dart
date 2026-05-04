// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get logout => 'Déconnexion';

  @override
  String get profile => 'Profil';

  @override
  String get password => 'Mot de passe';

  @override
  String get notifications => 'Notifications';

  @override
  String get appSection => 'Application';

  @override
  String get accountSection => 'Compte';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitle => 'Accédez à votre espace de surveillance';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'nom@ommp.tn';

  @override
  String get emailRequired => 'E-mail requis';

  @override
  String get emailInvalid => 'E-mail invalide';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordRequired => 'Mot de passe requis';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotShort => 'Oublié ?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get or => 'OU';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get noAccountQuestion => 'Pas de compte ? ';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get cannotOpenGoogleLogin => 'Impossible d\'ouvrir Google Login';

  @override
  String googleLoginError(Object error) {
    return 'Erreur Google Login : $error';
  }

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get alreadyHaveAccountQuestion => 'Déjà un compte ? ';

  @override
  String get signInAction => 'Se connecter';

  @override
  String get chooseRoleError => 'Veuillez choisir votre poste';

  @override
  String get infoTitle => 'Informations';

  @override
  String get infoSubtitle => 'Renseignez vos informations personnelles';

  @override
  String get lastName => 'Nom';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastNameRequired => 'Nom requis';

  @override
  String get firstNameRequired => 'Prénom requis';

  @override
  String get workEmail => 'E-mail professionnel';

  @override
  String get roleTitle => 'Votre poste';

  @override
  String get roleSubtitle => 'Sélectionnez votre rôle dans OMMP';

  @override
  String get securityTitle => 'Sécurité';

  @override
  String get securitySubtitle => 'Créez votre mot de passe sécurisé';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get min8Chars => 'Min. 8 caractères';

  @override
  String get needUppercase => 'Au moins 1 majuscule';

  @override
  String get needNumber => 'Au moins 1 chiffre';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get acceptTerms =>
      'J\'accepte les conditions d\'utilisation et la politique de confidentialité d\'OMMP Bizerte.';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get accountCreated => 'Compte créé !';

  @override
  String get requestSubmitted =>
      'Votre demande est soumise.\nUn admin validera votre accès.';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get resetTitle => 'Réinitialiser';

  @override
  String get resetSubtitle =>
      'Entrez votre e-mail OMMP pour recevoir le code et le lien de réinitialisation.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get backToLogin => '← Retour à la connexion';

  @override
  String get verificationTitle => 'Vérification';

  @override
  String codeSentTo(Object email) {
    return 'Code envoyé à\n$email';
  }

  @override
  String get code6DigitsRequired => 'Code à 6 chiffres requis';

  @override
  String get codeExpiresInfo =>
      'Le code expire dans 15 min. Vérifiez aussi vos spams.';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get verifyCode => 'Vérifier le code';

  @override
  String get newPasswordTitle => 'Nouveau mot de passe';

  @override
  String get newPasswordSubtitle =>
      'Créez un mot de passe sécurisé pour votre compte.';

  @override
  String get resetAction => 'Réinitialiser';

  @override
  String get passwordUpdatedTitle => 'Mot de passe mis à jour !';

  @override
  String get canNowLoginInfo =>
      'Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Tout lire';

  @override
  String timeAgo(Object time) {
    return 'Il y a $time';
  }

  @override
  String get aiAnalysisTitle => 'Analyse IA';

  @override
  String get recentEvents => 'Événements récents';
}
