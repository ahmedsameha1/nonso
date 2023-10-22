import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:nonso/nonso.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';
import 'package:nonso/src/widgets/register.dart';

import '../state/auth_bloc_test.mocks.dart';
import 'common_finders.dart';
import 'email_test.mocks.dart';
import 'register_test.mocks.dart';
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
}

const email = "test@test.com";

@GenerateMocks([RegisterAccountFunction])
void main() {
  late Widget widgetInSkeleton;
  const firebaseAuthExceptionCode = "code";
  final firebaseAuthException =
      FirebaseAuthException(code: firebaseAuthExceptionCode);
  const User? nullUser = null;
  final User notNullUser = MockUser();
  late StreamController<User?> streamController;
  late BlocProvider widgetInSkeletonInBlocProvider;
  late FirebaseAuth firebaseAuth;
  late FakeAuthBloc authBloc;
  late UserCredential userCredential;
  final registerAccountFunctionCall = MockRegisterAccountFunction();
  final toLogoutFunctionCall = MockToLogoutFunction();
  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    streamController = StreamController();
    userCredential = MockUserCredential();
    when(firebaseAuth.userChanges()).thenAnswer((_) => streamController.stream);
    streamController.sink.add(nullUser);
    authBloc = FakeAuthBloc(firebaseAuth);
    widgetInSkeleton = createWidgetInASkeleton(
        Register(email, registerAccountFunctionCall, toLogoutFunctionCall));
  });
  testWidgets("Test the precence of the main widgets",
      (WidgetTester tester) async {
    await tester.pumpWidget(widgetInSkeleton);
    expect(find.byType(Register), findsOneWidget);
    expect(find.descendant(of: find.byType(Register), matching: formFinder),
        findsOneWidget);
    expect(find.descendant(of: formFinder, matching: columnFinder),
        findsOneWidget);
    final emailTextFinder = find.byType(Text).at(0);
    expect(find.descendant(of: columnFinder, matching: emailTextFinder),
        findsOneWidget);
    expect((tester.widget(emailTextFinder) as Text).data, email);
    final displayNameTextFormFieldFinder = textFormFieldFinder.at(0);
    expect(
        find.descendant(
            of: columnFinder, matching: displayNameTextFormFieldFinder),
        findsOneWidget);
    final TextField nameTextField = tester.widget(find.descendant(
        of: displayNameTextFormFieldFinder,
        matching: textFieldFinder.at(0))) as TextField;
    expect((nameTextField.decoration!.label as Text).data, Register.nameString);
    expect(nameTextField.keyboardType, TextInputType.text);
    final passwordTextFormFieldFinder = textFormFieldFinder.at(1);
    expect(
        find.descendant(
            of: columnFinder, matching: passwordTextFormFieldFinder),
        findsOneWidget);
    final TextField passwordTextField = tester.widget(find.descendant(
        of: passwordTextFormFieldFinder,
        matching: textFieldFinder.at(1))) as TextField;
    expect((passwordTextField.decoration!.label as Text).data,
        Register.passwordString);
    expect(passwordTextField.keyboardType, TextInputType.text);
    expect(passwordTextField.inputFormatters!.elementAt(0),
        Register.noWhiteSpaceInputFormatter);
    expect(passwordTextField.obscureText, true);
    expect(passwordTextField.autocorrect, false);
    expect(passwordTextField.enableSuggestions, false);
    final confirmPasswordTextFormFieldFinder = textFormFieldFinder.at(2);
    expect(
        find.descendant(
            of: columnFinder, matching: confirmPasswordTextFormFieldFinder),
        findsOneWidget);
    final confirmPasswordTextField = tester.widget(find.descendant(
        of: confirmPasswordTextFormFieldFinder,
        matching: textFieldFinder.at(2))) as TextField;
    expect((confirmPasswordTextField.decoration!.label as Text).data,
        Register.confirmPasswordString);
    expect(confirmPasswordTextField.keyboardType, TextInputType.text);
    expect(confirmPasswordTextField.inputFormatters!.elementAt(0),
        Register.noWhiteSpaceInputFormatter);
    expect(confirmPasswordTextField.obscureText, true);
    expect(confirmPasswordTextField.autocorrect, false);
    expect(confirmPasswordTextField.enableSuggestions, false);
    expect(
        find.descendant(of: columnFinder, matching: rowFinder), findsOneWidget);
    final nextTextButtonFinder =
        find.descendant(of: rowFinder, matching: textButtonFinder.at(0));
    expect(nextTextButtonFinder, findsOneWidget);
    expect(
        ((tester.widget(nextTextButtonFinder) as TextButton).child as Text)
            .data,
        Register.nextString);
    final cancelTextButtonFinder =
        find.descendant(of: rowFinder, matching: textButtonFinder.at(1));
    expect(cancelTextButtonFinder, findsOneWidget);
    expect(
        ((tester.widget(cancelTextButtonFinder) as TextButton).child as Text)
            .data,
        Register.cancelString);
  });

  group("Form validation", () {
    testWidgets("name textfield validation", (WidgetTester tester) async {
      await tester.pumpWidget(widgetInSkeleton);
      final nameTextFieldFinder = textFieldFinder.at(0);
      await tester.enterText(nameTextFieldFinder, "f");
      final nextTextButtonFinder = textButtonFinder.at(0);
      await tester.tap(nextTextButtonFinder);
      await tester.pumpAndSettle();
      final nameValidationErrorTextFinder = find.descendant(
          of: textFormFieldFinder.at(0),
          matching: find.text(Register.nameValidationErrorString));
      expect(nameValidationErrorTextFinder, findsNothing);
      await tester.enterText(nameTextFieldFinder, "");
      await tester.tap(nextTextButtonFinder);
      await tester.pumpAndSettle();
      expect(nameValidationErrorTextFinder, findsOneWidget);
      await tester.enterText(nameTextFieldFinder, " ");
      await tester.tap(nextTextButtonFinder);
      await tester.pumpAndSettle();
      expect(nameValidationErrorTextFinder, findsOneWidget);
      verifyNever(registerAccountFunctionCall(any, any, any, any));
    });

    testWidgets("password textfield validation", (WidgetTester tester) async {
      await tester.pumpWidget(widgetInSkeleton);
      final passwordTextFieldFinder = textFieldFinder.at(1);
      await tester.enterText(passwordTextFieldFinder, "8*prt&3k");
      final nextTextButtonFinder = textButtonFinder.at(0);
      await tester.tap(nextTextButtonFinder);
      await tester.pumpAndSettle();
      final passwordValidationErrorTextFinder = find.descendant(
          of: textFormFieldFinder.at(1),
          matching: find.text(Register.passwordValidationErrorString));
      expect(passwordValidationErrorTextFinder, findsNothing);
      await tester.enterText(passwordTextFieldFinder, "");
      await tester.tap(nextTextButtonFinder);
      await tester.pumpAndSettle();
      expect(passwordValidationErrorTextFinder, findsOneWidget);
      await tester.enterText(passwordTextFieldFinder, " ");
      await tester.tap(nextTextButtonFinder);
      await tester.pumpAndSettle();
      final TextField passwordTextField =
          tester.widget(passwordTextFieldFinder);
      expect(passwordTextField.controller!.text, "");
      expect(passwordValidationErrorTextFinder, findsOneWidget);
      await tester.enterText(passwordTextFieldFinder, " gfh");
      await tester.tap(nextTextButtonFinder);
      await tester.pumpAndSettle();
      expect(passwordTextField.controller!.text, "gfh");
      expect(passwordValidationErrorTextFinder, findsOneWidget);
      verifyNever(registerAccountFunctionCall(any, any, any, any));
    });

    testWidgets("confirm password textfield validation",
        (WidgetTester tester) async {
      await tester.pumpWidget(widgetInSkeleton);
      final passwordTextFieldFinder = textFieldFinder.at(1);
      final confirmPasswordTextFieldFinder = textFieldFinder.at(2);
      await tester.enterText(passwordTextFieldFinder, "8*prt&3k");
      await tester.enterText(confirmPasswordTextFieldFinder, "8*prt&3k");
      final nextTextButtonFinder = textButtonFinder.at(0);
      await tester.tap(nextTextButtonFinder);
      await tester.pumpAndSettle();
      final confirmPasswordValidationErrorTextFinder = find.descendant(
          of: textFormFieldFinder.at(2),
          matching: find.text(Register.confirmPasswordValidationErrorString));
      expect(confirmPasswordValidationErrorTextFinder, findsNothing);
      await tester.enterText(passwordTextFieldFinder, "");
      await tester.enterText(confirmPasswordTextFieldFinder, "");
      await tester.tap(nextTextButtonFinder);
      await tester.pumpAndSettle();
      expect(confirmPasswordValidationErrorTextFinder, findsNothing);
      await tester.enterText(passwordTextFieldFinder, "hbefr");
      await tester.enterText(confirmPasswordTextFieldFinder, "r hg");
      await tester.tap(nextTextButtonFinder);
      await tester.pumpAndSettle();
      expect(confirmPasswordValidationErrorTextFinder, findsOneWidget);
      expect(
          (tester.widget(confirmPasswordTextFieldFinder) as TextField)
              .controller!
              .text,
          "rhg");
      verifyNever(registerAccountFunctionCall(any, any, any, any));
    });
  });
  group("nextButton action", () {
    const userDisplayName = "name";
    setUp(() {
      widgetInSkeleton = createWidgetInASkeleton(
          Register(email, authBloc.registerAccount, toLogoutFunctionCall));
      widgetInSkeletonInBlocProvider =
          BlocProvider(create: (context) => authBloc, child: widgetInSkeleton);
    });
    testWidgets(
        "Test that a SnackBar is shown when FirebaseAuthException is thrown",
        (WidgetTester tester) async {
      const password = "oehgolewrbgowerb";
      when(notNullUser.updateDisplayName(userDisplayName))
          .thenAnswer((realInvocation) => Completer<void>().future);
      when(userCredential.user).thenReturn(notNullUser);
      when(firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .thenThrow(firebaseAuthException);
      await tester.pumpWidget(widgetInSkeletonInBlocProvider);
      await tester.enterText(textFieldFinder.at(0), userDisplayName);
      await tester.enterText(textFieldFinder.at(1), password);
      await tester.enterText(textFieldFinder.at(2), password);
      await tester.tap(textButtonFinder.at(0));
      await tester.pumpAndSettle();
      expect(snackBarFinder, findsOneWidget);
      expect(
          find.descendant(
              of: snackBarFinder,
              matching: find
                  .text("${Register.failedString}$firebaseAuthExceptionCode")),
          findsOneWidget);
    });
    testWidgets(
        "Test that a SnackBar is shown to guide user to check his email",
        (WidgetTester tester) async {
      const password = "oehgolewrbgowerb";
      when(notNullUser.updateDisplayName(userDisplayName))
          .thenAnswer((realInvocation) => Completer<void>().future);
      when(userCredential.user).thenReturn(notNullUser);
      when(firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
      await tester.pumpWidget(widgetInSkeletonInBlocProvider);
      await tester.enterText(textFieldFinder.at(0), userDisplayName);
      await tester.enterText(textFieldFinder.at(1), password);
      await tester.enterText(textFieldFinder.at(2), password);
      await tester.tap(textButtonFinder.at(0));
      await tester.pumpAndSettle();
      expect(snackBarFinder, findsOneWidget);
      expect(
          find.descendant(
              of: snackBarFinder, matching: find.text(Register.successString)),
          findsOneWidget);
    });
  });
  testWidgets("Test that cancelButton call the cancel action function",
      (WidgetTester tester) async {
    when(toLogoutFunctionCall()).thenReturn(anything);
    await tester.pumpWidget(widgetInSkeleton);
    await tester.tap(textButtonFinder.at(1));
    verify(toLogoutFunctionCall()).called(1);
  });
}
