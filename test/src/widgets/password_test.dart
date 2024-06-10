import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/nonso.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nonso/src/widgets/common.dart';
import '../state/auth_bloc_test.mocks.dart';
import 'common_finders.dart';
import 'skeleton_for_widget_testing.dart';

abstract class SignInWithEmailAndPasswordFunction {
  Future<void> call(String email, String password,
      void Function(FirebaseAuthException exception) errorCallback);
}

class FakeAuthBloc extends Fake implements AuthBloc {
  final AuthBloc _authBloc;

  FakeAuthBloc(FirebaseAuth firebaseAuth) : _authBloc = AuthBloc(firebaseAuth);

  @override
  Future<void> signInWithEmailAndPassword(String email, String password,
      void Function(FirebaseAuthException exception) errorCallback) async {
    _authBloc.emit(AuthState(
        applicationAuthState: ApplicationAuthState.password, email: email));
    _authBloc.signInWithEmailAndPassword(email, password, errorCallback);
  }

  @override
  Stream<AuthState> get stream => _authBloc.stream;

  @override
  AuthState get state => const AuthState(
      applicationAuthState: ApplicationAuthState.password,
      email: "test@test.com");

  @override
  Future<void> close() {
    return _authBloc.close();
  }
}

void main() {
  const validEmail = "test@test.com";
  late Widget widgetInSkeleton;
  const firebaseAuthExceptionCode = "code";
  final firebaseAuthException =
      FirebaseAuthException(code: firebaseAuthExceptionCode);
  const User? nullUser = null;
  late StreamController<User?> streamController;
  late BlocProvider widgetInSkeletonInBlocProvider;
  late FirebaseAuth firebaseAuth;
  late FakeAuthBloc authBloc;
  UserCredential userCredential = MockUserCredential();
  late Widget widgetProviderLocalization;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    streamController = StreamController();
    when(firebaseAuth.userChanges()).thenAnswer((_) => streamController.stream);
    streamController.sink.add(nullUser);
    authBloc = FakeAuthBloc(firebaseAuth);
    widgetInSkeleton = createWidgetInASkeleton(Password());
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
        create: (context) => authBloc, child: widgetInSkeleton);
  });

  group("English locale", () {
    Locale currentLocale = const Locale("en");
    String expectedEmailString = "Email";
    String expectedPasswordString = "Password";
    String expectedSignInString = "Sign in";
    String expectedCancelString = "Cancel";
    String expectedPasswordValidationErrorString =
        "Password needs to be at least 8 characters";
    String expectedFailedString = "Failure: code";
    String expectedInvalidEmailString = "This an invalid email";

    setUp(() {
      widgetProviderLocalization = Localizations(
          locale: currentLocale,
          delegates: AppLocalizations.localizationsDelegates,
          child: widgetInSkeletonInBlocProvider);
    });

    testWidgets("Test the precense of the main widgets",
        (WidgetTester tester) async {
      await tester.pumpWidget(widgetProviderLocalization);
      final passwordFinder = find.byType(Password);
      expect(passwordFinder, findsOneWidget);
      expect(find.descendant(of: passwordFinder, matching: formFinder),
          findsOneWidget);
      expect(find.descendant(of: formFinder, matching: columnFinder),
          findsOneWidget);
      final TextField emailTextField = tester.widget(find.descendant(
          of: textFormFieldFinder.at(0), matching: textFieldFinder));
      expect(
          (emailTextField.decoration!.label as Text).data, expectedEmailString);
      expect(emailTextField.keyboardType, TextInputType.emailAddress);
      expect(emailTextField.inputFormatters!.elementAt(0),
          noWhiteSpaceInputFormatter);
      expect(emailTextField.autocorrect, false);
      expect(emailTextField.enableSuggestions, false);
      final TextField passwordTextField = tester.widget(find.descendant(
          of: textFormFieldFinder.at(1), matching: textFieldFinder));
      expect((passwordTextField.decoration!.label as Text).data,
          expectedPasswordString);
      expect(passwordTextField.keyboardType, TextInputType.text);
      expect(passwordTextField.inputFormatters!.elementAt(0),
          noWhiteSpaceInputFormatter);
      expect(passwordTextField.obscureText, true);
      expect(passwordTextField.autocorrect, false);
      expect(passwordTextField.enableSuggestions, false);
      expect(find.descendant(of: columnFinder, matching: rowFinder),
          findsOneWidget);
      final signInElevatedButtonFinder =
          find.descendant(of: rowFinder, matching: elevatedButtonFinder.at(0));
      expect(signInElevatedButtonFinder, findsOneWidget);
      expect(
          ((tester.widget(signInElevatedButtonFinder) as ElevatedButton).child
                  as Text)
              .data,
          expectedSignInString);
      final cancelElevatedButtonFinder =
          find.descendant(of: rowFinder, matching: elevatedButtonFinder.at(1));
      expect(cancelElevatedButtonFinder, findsOneWidget);
      expect(
          ((tester.widget(cancelElevatedButtonFinder) as ElevatedButton).child
                  as Text)
              .data,
          expectedCancelString);
      ElevatedButton cancelElevatedButton =
          tester.widget(cancelElevatedButtonFinder);
      expect(cancelElevatedButton.onPressed, authBloc.toSignedOut);
    });

    group("Form validation", () {
      testWidgets("Test email textfield validation",
          (WidgetTester tester) async {
        final emailTextFormFieldFinder = textFormFieldFinder.at(0);
        final emailValidationErrorTextFinder = find.descendant(
            of: emailTextFormFieldFinder,
            matching: find.text(expectedInvalidEmailString));
        await tester.pumpWidget(widgetProviderLocalization);
        expect(emailValidationErrorTextFinder, findsNothing);
        await tester.enterText(emailTextFormFieldFinder, "f");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(emailTextFormFieldFinder, "test");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(emailTextFormFieldFinder, "test@");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(emailTextFormFieldFinder, validEmail);
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsNothing);
        await tester.enterText(emailTextFormFieldFinder, "test@شبكة.com");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsNothing);
      });

      testWidgets("Test password textfield validation",
          (WidgetTester tester) async {
        final passwordValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(1),
            matching: find.text(expectedPasswordValidationErrorString));
        const validPassword = "8*prt&3k";
        when(firebaseAuth.signInWithEmailAndPassword(
                email: validEmail, password: validPassword))
            .thenAnswer((realInvocation) => Future.value(userCredential));
        await tester.pumpWidget(widgetProviderLocalization);
        expect(passwordValidationErrorTextFinder, findsNothing);
        final passwordTextFieldFinder = textFieldFinder.at(1);
        await tester.enterText(passwordTextFieldFinder, validPassword);
        await tester.pumpAndSettle();
        expect(passwordValidationErrorTextFinder, findsNothing);
        await tester.enterText(passwordTextFieldFinder, "");
        await tester.pumpAndSettle();
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(passwordTextFieldFinder, " ");
        await tester.pumpAndSettle();
        final TextField passwordTextField =
            tester.widget(passwordTextFieldFinder);
        expect(passwordTextField.controller!.text, "");
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(passwordTextFieldFinder, " gfh");
        await tester.pumpAndSettle();
        expect(passwordTextField.controller!.text, "gfh");
        expect(passwordValidationErrorTextFinder, findsOneWidget);
      });
    });

    group("nextButton action", () {
      final signInElevatedButtonFinder = elevatedButtonFinder.at(0);
      testWidgets(
          "Test that a SnackBar with an error text is shown when FirebaseAuthException is thrown",
          (WidgetTester tester) async {
        const password = "oehgolewrbgowerb";
        when(firebaseAuth.signInWithEmailAndPassword(
                email: validEmail, password: password))
            .thenThrow(firebaseAuthException);
        await tester.pumpWidget(widgetInSkeletonInBlocProvider);
        await tester.enterText(textFieldFinder.at(0), validEmail);
        await tester.enterText(textFieldFinder.at(1), password);
        await tester.tap(signInElevatedButtonFinder);
        await tester.pumpAndSettle();
        expect(snackBarFinder, findsOneWidget);
        expect(
            find.descendant(
                of: snackBarFinder, matching: find.text(expectedFailedString)),
            findsOneWidget);
      });

      testWidgets(
          "Test that no SnackBar is shown when NO FirebaseAuthException is thrown",
          (WidgetTester tester) async {
        const password = "oehgolewrbgowerb";
        when(firebaseAuth.signInWithEmailAndPassword(
                email: validEmail, password: password))
            .thenAnswer((realInvocation) => Future.value(userCredential));
        await tester.pumpWidget(widgetInSkeletonInBlocProvider);
        await tester.enterText(textFieldFinder.at(0), validEmail);
        await tester.enterText(textFieldFinder.at(1), password);
        await tester.tap(signInElevatedButtonFinder);
        await tester.pumpAndSettle();
        expect(snackBarFinder, findsNothing);
      });
    });
  });
}
