import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @nonso_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get nonso_register;

  /// No description provided for @nonso_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get nonso_email;

  /// No description provided for @nonso_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nonso_next;

  /// No description provided for @nonso_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get nonso_cancel;

  /// No description provided for @nonso_invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'This an invalid email.'**
  String get nonso_invalidEmail;

  /// No description provided for @nonso_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh account'**
  String get nonso_refresh;

  /// No description provided for @nonso_verifyEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Check your email inbox to verify your email address'**
  String get nonso_verifyEmailAddress;

  /// No description provided for @nonso_signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get nonso_signOut;

  /// No description provided for @nonso_signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get nonso_signIn;

  /// No description provided for @nonso_resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get nonso_resendVerificationEmail;

  /// No description provided for @nonso_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nonso_name;

  /// No description provided for @nonso_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get nonso_password;

  /// No description provided for @nonso_confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get nonso_confirmPassword;

  /// No description provided for @nonso_resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get nonso_resetPassword;

  /// No description provided for @nonso_resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Check your email inbox to reset your password'**
  String get nonso_resetEmailSent;

  /// No description provided for @nonso_nameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nonso_nameValidationError;

  /// No description provided for @nonso_failed.
  ///
  /// In en, this message translates to:
  /// **'Failure: {exceptionCode}'**
  String nonso_failed(String exceptionCode);

  /// No description provided for @nonso_success.
  ///
  /// In en, this message translates to:
  /// **'Success: Check your email inbox to verify your email address.'**
  String get nonso_success;

  /// No description provided for @nonso_passwordValidationError.
  ///
  /// In en, this message translates to:
  /// **'Password needs to be at least {passwordMinimumLength} characters.'**
  String nonso_passwordValidationError(int passwordMinimumLength);

  /// No description provided for @nonso_confirmPasswordValidationError.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t match the given password.'**
  String get nonso_confirmPasswordValidationError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
