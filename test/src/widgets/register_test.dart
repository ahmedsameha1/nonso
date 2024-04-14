import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';
import 'package:nonso/src/widgets/common.dart';
import 'package:nonso/src/widgets/register.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../state/auth_bloc_test.dart';
import '../state/auth_bloc_test.mocks.dart';
import 'common_finders.dart';
import 'skeleton_for_widget_testing.dart';

abstract class RegisterAccountFunction {
  Future<void> call(String email, String password, String displayName,
      void Function(FirebaseAuthException exception) errorCallback);
}

class FakeAuthBloc extends Fake implements AuthBloc {
  final AuthBloc _authBloc;

  FakeAuthBloc(FirebaseAuth firebaseAuth) : _authBloc = AuthBloc(firebaseAuth);

  @override
  Future<void> registerAccount(
      String email,
      String password,
      String displayName,
      void Function(FirebaseAuthException exception) errorCallback) async {
    _authBloc.emit(AuthState(
        applicationAuthState: ApplicationAuthState.register, email: email));
    _authBloc.registerAccount(email, password, displayName, errorCallback);
  }

  @override
  Stream<AuthState> get stream => _authBloc.stream;

  @override
  AuthState get state => const AuthState(
      applicationAuthState: ApplicationAuthState.register,
      email: "test@test.com");

  @override
  Future<void> close() {
    return _authBloc.close();
  }
}

void main() {
  const email = "test@test.com";
  late Widget widgetInSkeleton;
  const firebaseAuthExceptionCode = "code";
  final firebaseAuthException =
      FirebaseAuthException(code: firebaseAuthExceptionCode);
  const User? nullUser = null;
  final User notNullUser = MockUser();
  late StreamController<User?> streamController;
  late BlocProvider widgetInSkeletonInBlocProvider;
  late Widget widgetProviderLocalization;
  late FirebaseAuth firebaseAuth;
  late FakeAuthBloc authBloc;
  late UserCredential userCredential;
  final nextElevatedButtonFinder = elevatedButtonFinder.at(0);

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    streamController = StreamController();
    userCredential = MockUserCredential();
    when(firebaseAuth.userChanges()).thenAnswer((_) => streamController.stream);
    streamController.sink.add(nullUser);
    authBloc = FakeAuthBloc(firebaseAuth);
    widgetInSkeleton = createWidgetInASkeleton(Register());
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
        create: (context) => authBloc, child: widgetInSkeleton);
  });

  group("English locale", () {
    Locale currentLocale = const Locale("en");
    String expectedNameString = "Name";
    String expectedEmailString = "Email";
    String expectedPasswordString = "Password";
    String expectedConfirmPasswordString = "Confirm Password";
    String expectedNextString = "Next";
    String expectedCancelString = "Cancel";
    String expectedNameValidationErrorString = "Enter your name";
    String expectedInvalidEmailString = "This an invalid email";
    String expectedPasswordValidationErrorString =
        "Password needs to be at least 6 characters";
    String expectedConfirmPasswordValidationErrorString =
        "This doesn't match the above password";
    String expectedSuccessString =
        "Success: Check your email to verify your email address";
    String expectedFailedString = "Failure: code";

    setUp(() {
      widgetProviderLocalization = Localizations(
          locale: currentLocale,
          delegates: AppLocalizations.localizationsDelegates,
          child: widgetInSkeletonInBlocProvider);
    });

    testWidgets("Test the precence of the main widgets",
        (WidgetTester tester) async {
      await tester.pumpWidget(widgetProviderLocalization);
      expect(find.byType(Register), findsOneWidget);
      expect(find.descendant(of: find.byType(Register), matching: formFinder),
          findsOneWidget);
      expect(find.descendant(of: formFinder, matching: columnFinder),
          findsOneWidget);
      final displayNameTextFormFieldFinder = textFormFieldFinder.at(0);
      expect(
          find.descendant(
              of: columnFinder, matching: displayNameTextFormFieldFinder),
          findsOneWidget);
      final TextField nameTextField = tester.widget(find.descendant(
          of: displayNameTextFormFieldFinder,
          matching: textFieldFinder.at(0))) as TextField;
      expect(
          (nameTextField.decoration!.label as Text).data, expectedNameString);
      expect(nameTextField.keyboardType, TextInputType.text);
      final emailTextFormFieldFinder = textFormFieldFinder.at(1);
      expect(
          find.descendant(of: columnFinder, matching: emailTextFormFieldFinder),
          findsOneWidget);
      final TextField emailTextField = tester.widget(find.descendant(
          of: emailTextFormFieldFinder,
          matching: textFieldFinder.at(1))) as TextField;
      expect(
          (emailTextField.decoration!.label as Text).data, expectedEmailString);
      expect(emailTextField.keyboardType, TextInputType.emailAddress);
      final passwordTextFormFieldFinder = textFormFieldFinder.at(2);
      expect(
          find.descendant(
              of: columnFinder, matching: passwordTextFormFieldFinder),
          findsOneWidget);
      final TextField passwordTextField = tester.widget(find.descendant(
          of: passwordTextFormFieldFinder,
          matching: textFieldFinder.at(2))) as TextField;
      expect((passwordTextField.decoration!.label as Text).data,
          expectedPasswordString);
      expect(passwordTextField.keyboardType, TextInputType.text);
      expect(passwordTextField.inputFormatters!.elementAt(0),
          noWhiteSpaceInputFormatter);
      expect(passwordTextField.obscureText, true);
      expect(passwordTextField.autocorrect, false);
      expect(passwordTextField.enableSuggestions, false);
      final confirmPasswordTextFormFieldFinder = textFormFieldFinder.at(3);
      expect(
          find.descendant(
              of: columnFinder, matching: confirmPasswordTextFormFieldFinder),
          findsOneWidget);
      final confirmPasswordTextField = tester.widget(find.descendant(
          of: confirmPasswordTextFormFieldFinder,
          matching: textFieldFinder.at(3))) as TextField;
      expect((confirmPasswordTextField.decoration!.label as Text).data,
          expectedConfirmPasswordString);
      expect(confirmPasswordTextField.keyboardType, TextInputType.text);
      expect(confirmPasswordTextField.inputFormatters!.elementAt(0),
          noWhiteSpaceInputFormatter);
      expect(confirmPasswordTextField.obscureText, true);
      expect(confirmPasswordTextField.autocorrect, false);
      expect(confirmPasswordTextField.enableSuggestions, false);
      expect(find.descendant(of: columnFinder, matching: rowFinder),
          findsOneWidget);
      final nextElevatedButtonFinder =
          find.descendant(of: rowFinder, matching: elevatedButtonFinder.at(0));
      expect(nextElevatedButtonFinder, findsOneWidget);
      expect(
          ((tester.widget(nextElevatedButtonFinder) as ElevatedButton).child
                  as Text)
              .data,
          expectedNextString);
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
      testWidgets("name textfield validation", (WidgetTester tester) async {
        await tester.pumpWidget(widgetProviderLocalization);
        final nameTextFieldFinder = textFieldFinder.at(0);
        await tester.enterText(nameTextFieldFinder, "f");
        final aTextFieldFinder = textFieldFinder.at(1);
        await tester.tap(aTextFieldFinder);
        await tester.pumpAndSettle();
        final nameValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(0),
            matching: find.text(expectedNameValidationErrorString));
        expect(nameValidationErrorTextFinder, findsNothing);
        await tester.enterText(nameTextFieldFinder, "");
        await tester.tap(aTextFieldFinder);
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(nameTextFieldFinder, " ");
        await tester.tap(aTextFieldFinder);
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsOneWidget);
        expect(snackBarFinder, findsNothing);
      });

      testWidgets("email textfield validation", (WidgetTester tester) async {
        const validEmail = "test@test.com";
        await tester.pumpWidget(widgetProviderLocalization);
        final emailTextFieldFinder = textFieldFinder.at(1);
        await tester.enterText(emailTextFieldFinder, validEmail);
        final aTextFieldFinder = textFieldFinder.at(2);
        await tester.tap(aTextFieldFinder);
        await tester.pumpAndSettle();
        final emailValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(1),
            matching: find.text(expectedInvalidEmailString));
        expect(emailValidationErrorTextFinder, findsNothing);
        await tester.enterText(emailTextFieldFinder, "");
        await tester.tap(aTextFieldFinder);
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(emailTextFieldFinder, " ");
        await tester.tap(aTextFieldFinder);
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(emailTextFieldFinder, "test");
        await tester.tap(aTextFieldFinder);
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
      });

      testWidgets("password textfield validation", (WidgetTester tester) async {
        await tester.pumpWidget(widgetProviderLocalization);
        final passwordTextFieldFinder = textFieldFinder.at(2);
        await tester.enterText(passwordTextFieldFinder, "8*prt&3k");
        await tester.tap(nextElevatedButtonFinder);
        await tester.pumpAndSettle();
        final passwordValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(2),
            matching: find.text(expectedPasswordValidationErrorString));
        expect(passwordValidationErrorTextFinder, findsNothing);
        await tester.enterText(passwordTextFieldFinder, "");
        await tester.tap(nextElevatedButtonFinder);
        await tester.pumpAndSettle();
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(passwordTextFieldFinder, " ");
        await tester.tap(nextElevatedButtonFinder);
        await tester.pumpAndSettle();
        final TextField passwordTextField =
            tester.widget(passwordTextFieldFinder);
        expect(passwordTextField.controller!.text, "");
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(passwordTextFieldFinder, " gfh");
        await tester.tap(nextElevatedButtonFinder);
        await tester.pumpAndSettle();
        expect(passwordTextField.controller!.text, "gfh");
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        expect(snackBarFinder, findsNothing);
      });

      testWidgets("confirm password textfield validation",
          (WidgetTester tester) async {
        await tester.pumpWidget(widgetProviderLocalization);
        final passwordTextFieldFinder = textFieldFinder.at(2);
        final confirmPasswordTextFieldFinder = textFieldFinder.at(3);
        await tester.enterText(passwordTextFieldFinder, "8*prt&3k");
        await tester.enterText(confirmPasswordTextFieldFinder, "8*prt&3k");
        await tester.tap(nextElevatedButtonFinder);
        await tester.pumpAndSettle();
        final confirmPasswordValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(3),
            matching: find.text(expectedConfirmPasswordValidationErrorString));
        expect(confirmPasswordValidationErrorTextFinder, findsNothing);
        await tester.enterText(passwordTextFieldFinder, "");
        await tester.enterText(confirmPasswordTextFieldFinder, "");
        await tester.tap(nextElevatedButtonFinder);
        await tester.pumpAndSettle();
        expect(confirmPasswordValidationErrorTextFinder, findsNothing);
        await tester.enterText(passwordTextFieldFinder, "hbefr");
        await tester.enterText(confirmPasswordTextFieldFinder, "r hg");
        await tester.tap(nextElevatedButtonFinder);
        await tester.pumpAndSettle();
        expect(confirmPasswordValidationErrorTextFinder, findsOneWidget);
        expect(
            (tester.widget(confirmPasswordTextFieldFinder) as TextField)
                .controller!
                .text,
            "rhg");
        expect(snackBarFinder, findsNothing);
      });
    });

    group("nextButton action", () {
      const userDisplayName = "name";
      testWidgets(
          "Test that a SnackBar is shown when FirebaseAuthException is thrown",
          (WidgetTester tester) async {
        await tester.pumpWidget(widgetProviderLocalization);
        const password = "oehgolewrbgowerb";
        when(notNullUser.updateDisplayName(userDisplayName))
            .thenAnswer((realInvocation) => Completer<void>().future);
        when(userCredential.user).thenReturn(notNullUser);
        when(firebaseAuth.createUserWithEmailAndPassword(
                email: email, password: password))
            .thenThrow(firebaseAuthException);
        await tester.enterText(textFieldFinder.at(0), userDisplayName);
        await tester.enterText(textFieldFinder.at(1), validEmail);
        await tester.enterText(textFieldFinder.at(2), password);
        await tester.enterText(textFieldFinder.at(3), password);
        await tester.tap(nextElevatedButtonFinder);
        await tester.pumpAndSettle();
        expect(snackBarFinder, findsOneWidget);
        expect(
            find.descendant(
                of: snackBarFinder, matching: find.text(expectedFailedString)),
            findsOneWidget);
      });

      testWidgets(
          "Test that a SnackBar is shown to guide user to check his email",
          (WidgetTester tester) async {
        await tester.pumpWidget(widgetProviderLocalization);
        const password = "oehgolewrbgowerb";
        when(notNullUser.updateDisplayName(userDisplayName))
            .thenAnswer((realInvocation) => Completer<void>().future);
        when(userCredential.user).thenReturn(notNullUser);
        when(firebaseAuth.createUserWithEmailAndPassword(
                email: email, password: password))
            .thenAnswer((realInvocation) => Future.value(userCredential));
        await tester.enterText(textFieldFinder.at(0), userDisplayName);
        await tester.enterText(textFieldFinder.at(1), validEmail);
        await tester.enterText(textFieldFinder.at(2), password);
        await tester.enterText(textFieldFinder.at(3), password);
        await tester.tap(nextElevatedButtonFinder);
        await tester.pumpAndSettle();
        expect(snackBarFinder, findsOneWidget);
        expect(
            find.descendant(
                of: snackBarFinder, matching: find.text(expectedSuccessString)),
            findsOneWidget);
      });
    });
  });
}
