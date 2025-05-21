// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nonso_register => 'Register';

  @override
  String get nonso_email => 'Email';

  @override
  String get nonso_next => 'Next';

  @override
  String get nonso_cancel => 'Cancel';

  @override
  String get nonso_invalidEmail => 'This an invalid email.';

  @override
  String get nonso_refresh => 'Refresh account';

  @override
  String get nonso_verifyEmailAddress =>
      'Check your email inbox to verify your email address';

  @override
  String get nonso_signOut => 'Sign out';

  @override
  String get nonso_signIn => 'Sign in';

  @override
  String get nonso_resendVerificationEmail => 'Resend verification email';

  @override
  String get nonso_name => 'Name';

  @override
  String get nonso_password => 'Password';

  @override
  String get nonso_confirmPassword => 'Confirm Password';

  @override
  String get nonso_resetPassword => 'Reset password';

  @override
  String get nonso_resetEmailSent =>
      'Check your email inbox to reset your password';

  @override
  String get nonso_nameValidationError => 'Enter your name';

  @override
  String nonso_failed(String exceptionCode) {
    return 'Failure: $exceptionCode';
  }

  @override
  String get nonso_success =>
      'Success: Check your email inbox to verify your email address.';

  @override
  String nonso_passwordValidationError(int passwordMinimumLength) {
    return 'Password needs to be at least $passwordMinimumLength characters.';
  }

  @override
  String get nonso_confirmPasswordValidationError =>
      'This doesn\'t match the given password.';
}
