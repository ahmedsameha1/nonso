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
        "Password needs to be at least 8 characters";
    String expectedConfirmPasswordValidationErrorString =
        "This doesn't match the given password";
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
        final nameValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(0),
            matching: find.text(expectedNameValidationErrorString));
        await tester.pumpWidget(widgetProviderLocalization);
        expect(nameValidationErrorTextFinder, findsNothing);
        final nameTextFieldFinder = textFieldFinder.at(0);
        await tester.enterText(nameTextFieldFinder, " ");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(nameTextFieldFinder, "~");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(nameTextFieldFinder, "f");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsNothing);
        await tester.enterText(nameTextFieldFinder, "David");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsNothing);
        await tester.enterText(nameTextFieldFinder, "foo bar");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsNothing);
        await tester.enterText(nameTextFieldFinder, " حسن حسان ");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsNothing);
        await tester.enterText(nameTextFieldFinder, "س");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsNothing);
      });

      testWidgets("email textfield validation", (WidgetTester tester) async {
        final emailValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(1),
            matching: find.text(expectedInvalidEmailString));
        const validEmail = "test@test.com";
        await tester.pumpWidget(widgetProviderLocalization);
        expect(emailValidationErrorTextFinder, findsNothing);
        final emailTextFieldFinder = textFieldFinder.at(1);
        await tester.enterText(emailTextFieldFinder, "f");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(emailTextFieldFinder, "test");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(emailTextFieldFinder, "test@");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(emailTextFieldFinder, validEmail);
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsNothing);
        await tester.enterText(emailTextFieldFinder, "test@شبكة.com");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsNothing);
      });

      testWidgets("password textfield validation", (WidgetTester tester) async {
        final passwordValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(2),
            matching: find.text(expectedPasswordValidationErrorString));
        await tester.pumpWidget(widgetProviderLocalization);
        expect(passwordValidationErrorTextFinder, findsNothing);
        final passwordTextFieldFinder = textFieldFinder.at(2);
        final TextField passwordTextField =
            tester.widget(passwordTextFieldFinder);
        await tester.enterText(passwordTextFieldFinder, " ");
        expect(passwordTextField.controller!.text, "");
        await tester.pumpAndSettle();
        await tester.enterText(passwordTextFieldFinder, "x b ");
        expect(passwordTextField.controller!.text, "xb");
        await tester.pumpAndSettle();
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(passwordTextFieldFinder, " gfh");
        expect(passwordTextField.controller!.text, "gfh");
        await tester.pumpAndSettle();
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(passwordTextFieldFinder, "8*prt&3k");
        await tester.pumpAndSettle();
        expect(passwordValidationErrorTextFinder, findsNothing);
      });

      testWidgets("confirm password textfield validation",
          (WidgetTester tester) async {
        final confirmPasswordValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(3),
            matching: find.text(expectedConfirmPasswordValidationErrorString));
        await tester.pumpWidget(widgetProviderLocalization);
        expect(confirmPasswordValidationErrorTextFinder, findsNothing);
        final passwordTextFieldFinder = textFieldFinder.at(2);
        final confirmPasswordTextFieldFinder = textFieldFinder.at(3);
        await tester.enterText(passwordTextFieldFinder, "hbefrf23g293g");
        await tester.enterText(confirmPasswordTextFieldFinder, "r hghanady667");
        await tester.pumpAndSettle();
        expect(
            (tester.widget(confirmPasswordTextFieldFinder) as TextField)
                .controller!
                .text,
            "rhghanady667");
        expect(confirmPasswordValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(passwordTextFieldFinder, "hbefrf23g293g");
        await tester.enterText(confirmPasswordTextFieldFinder, " rhghanady667");
        await tester.pumpAndSettle();
        expect(
            (tester.widget(confirmPasswordTextFieldFinder) as TextField)
                .controller!
                .text,
            "rhghanady667");
        expect(confirmPasswordValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(confirmPasswordTextFieldFinder, "rhghanady667 ");
        await tester.pumpAndSettle();
        expect(
            (tester.widget(confirmPasswordTextFieldFinder) as TextField)
                .controller!
                .text,
            "rhghanady667");
        expect(confirmPasswordValidationErrorTextFinder, findsOneWidget);
        await tester.enterText(passwordTextFieldFinder, "8*prt&3k");
        await tester.enterText(confirmPasswordTextFieldFinder, "8*prt&3k");
        await tester.pumpAndSettle();
        expect(confirmPasswordValidationErrorTextFinder, findsNothing);
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
