import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_state_notifier.dart';
import 'package:nonso/src/state/providers.dart';
import 'package:nonso/src/widgets/password.dart';
import 'package:nonso/src/widgets/register.dart';

import '../state/auth_state_notifier_test.mocks.dart';
import 'common_finders.dart';
import 'email_test.mocks.dart';
import 'password_test.mocks.dart';
import 'skeleton_for_widget_testing.dart';

abstract class SignInWithEmailAndPasswordFunction {
  Future<void> call(String email, String password,
      void Function(FirebaseAuthException exception) errorCallback);
}

@GenerateMocks([SignInWithEmailAndPasswordFunction])
void main() {
  const email = "test@test.com";
  late Widget widgetInSkeleton;
  const firebaseAuthExceptionCode = "code";
  final firebaseAuthException =
      FirebaseAuthException(code: firebaseAuthExceptionCode);
  const User? nullUser = null;
  late StreamController<User?> streamController;
  late ProviderScope widgetInSkeletonInProviderScope;
  late FirebaseAuth firebaseAuth;
  late AuthStateNotifier authStateNotifier;
  final signInWithEmailAndPasswordFunctionCall =
      MockSignInWithEmailAndPasswordFunction();
  final toLogoutFunctionCall = MockToLogoutFunction();
  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    streamController = StreamController();
    when(firebaseAuth.userChanges()).thenAnswer((_) => streamController.stream);
    streamController.sink.add(nullUser);
    authStateNotifier = AuthStateNotifier(firebaseAuth);
    widgetInSkeleton = createWidgetInASkeleton(Password(
        email, signInWithEmailAndPasswordFunctionCall, toLogoutFunctionCall));
  });
  testWidgets("Test the precense of the main widgets",
      (WidgetTester tester) async {
    await tester.pumpWidget(widgetInSkeleton);
    final passwordFinder = find.byType(Password);
    expect(passwordFinder, findsOneWidget);
    expect(find.descendant(of: passwordFinder, matching: formFinder),
        findsOneWidget);
    expect(find.descendant(of: formFinder, matching: columnFinder),
        findsOneWidget);
    expect(find.descendant(of: columnFinder, matching: find.text(email)),
        findsOneWidget);
    expect(find.descendant(of: columnFinder, matching: textFormFieldFinder),
        findsOneWidget);
    final TextField passwordTextField = tester.widget(
        find.descendant(of: textFormFieldFinder, matching: textFieldFinder));
    expect((passwordTextField.decoration!.label as Text).data,
        Register.passwordString);
    expect(passwordTextField.keyboardType, TextInputType.text);
    expect(passwordTextField.inputFormatters!.elementAt(0),
        Register.noWhiteSpaceInputFormatter);
    expect(passwordTextField.obscureText, true);
    expect(passwordTextField.autocorrect, false);
    expect(passwordTextField.enableSuggestions, false);
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
  testWidgets("Test password textfield validation",
      (WidgetTester tester) async {
    await tester.pumpWidget(widgetInSkeleton);
    final passwordTextFieldFinder = textFieldFinder.at(0);
    await tester.enterText(passwordTextFieldFinder, "8*prt&3k");
    final nextTextButtonFinder = textButtonFinder.at(0);
    await tester.tap(nextTextButtonFinder);
    await tester.pumpAndSettle();
    final passwordValidationErrorTextFinder = find.descendant(
        of: textFormFieldFinder.at(0),
        matching: find.text(Register.passwordValidationErrorString));
    expect(passwordValidationErrorTextFinder, findsNothing);
    await tester.enterText(passwordTextFieldFinder, "");
    await tester.tap(nextTextButtonFinder);
    await tester.pumpAndSettle();
    expect(passwordValidationErrorTextFinder, findsOneWidget);
    await tester.enterText(passwordTextFieldFinder, " ");
    await tester.tap(nextTextButtonFinder);
    await tester.pumpAndSettle();
    final TextField passwordTextField = tester.widget(passwordTextFieldFinder);
    expect(passwordTextField.controller!.text, "");
    expect(passwordValidationErrorTextFinder, findsOneWidget);
    await tester.enterText(passwordTextFieldFinder, " gfh");
    await tester.tap(nextTextButtonFinder);
    await tester.pumpAndSettle();
    expect(passwordTextField.controller!.text, "gfh");
    expect(passwordValidationErrorTextFinder, findsOneWidget);
    verify(signInWithEmailAndPasswordFunctionCall(any, any, any)).called(1);
  });
  group("nextButton action", () {
    setUp(() {
      widgetInSkeleton = createWidgetInASkeleton(Password(email,
          authStateNotifier.signInWithEmailAndPassword, toLogoutFunctionCall));
      widgetInSkeletonInProviderScope = ProviderScope(
          overrides: [authStateProvider.overrideWithValue(authStateNotifier)],
          child: widgetInSkeleton);
    });
    testWidgets(
        "Test that a SnackBar with an error text is shown when FirebaseAuthException is thrown",
        (WidgetTester tester) async {
      const password = "oehgolewrbgowerb";
      authStateNotifier.startLoginFlow();
      when(firebaseAuth.fetchSignInMethodsForEmail(email))
          .thenAnswer((realInvocation) => Future.value(<String>["password"]));
      authStateNotifier.verifyEmail(email, (exception) {});
      when(firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .thenThrow(firebaseAuthException);
      await tester.pumpWidget(widgetInSkeletonInProviderScope);
      await tester.enterText(textFieldFinder.at(0), password);
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
        "Test that no SnackBar is shown when NO FirebaseAuthException is thrown",
        (WidgetTester tester) async {
      late UserCredential userCredential = MockUserCredential();
      const password = "oehgolewrbgowerb";
      authStateNotifier.startLoginFlow();
      when(firebaseAuth.fetchSignInMethodsForEmail(email))
          .thenAnswer((realInvocation) => Future.value(<String>["password"]));
      authStateNotifier.verifyEmail(email, (exception) {});
      when(firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
      await tester.pumpWidget(widgetInSkeletonInProviderScope);
      await tester.enterText(textFieldFinder.at(0), password);
      await tester.tap(textButtonFinder.at(0));
      await tester.pumpAndSettle();
      expect(snackBarFinder, findsNothing);
    });
  });
  testWidgets(
      "Test that the cancel function called when cancel Text Button clicked",
      (WidgetTester tester) async {
    when(toLogoutFunctionCall()).thenReturn(anything);
    await tester.pumpWidget(widgetInSkeleton);
    await tester.tap(textButtonFinder.at(1));
    await tester.pumpAndSettle();
    verify(toLogoutFunctionCall()).called(1);
  });
}
