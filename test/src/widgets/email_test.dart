import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_state_notifier.dart';
import 'package:nonso/src/state/providers.dart';
import 'package:nonso/src/widgets/email.dart';
import 'package:nonso/src/widgets/register.dart';

import '../state/auth_state_notifier_test.mocks.dart';
import 'common_finders.dart';
import 'email_test.mocks.dart';
import 'skeleton_for_widget_testing.dart';

abstract class VerifyEmailFunction {
  Future<void> call(String email,
      void Function(FirebaseAuthException exception) errorCallback);
}

abstract class ToLogoutFunction {
  call();
}

@GenerateMocks([VerifyEmailFunction, ToLogoutFunction])
void main() {
  final firebaseAuthException = FirebaseAuthException(code: "code");
  const User? nullUser = null;
  late StreamController<User?> streamController;
  late ProviderScope widgetInSkeletonInProviderScope;
  late FirebaseAuth firebaseAuth;
  late AuthStateNotifier authStateNotifier;
  final MockVerifyEmailFunction verifyEmailFunctionCall =
      MockVerifyEmailFunction();
  final MockToLogoutFunction toLogoutFunctionCall = MockToLogoutFunction();
  late Widget widgetInSkeleton;

  testWidgets("Test the precense of the main widgets",
      (WidgetTester tester) async {
    widgetInSkeleton = createWidgetInASkeleton(
        Email(verifyEmailFunctionCall, toLogoutFunctionCall));
    await tester.pumpWidget(widgetInSkeleton);
    final emailWhileAuthFinder = find.byType(Email);
    expect(emailWhileAuthFinder, findsOneWidget);
    expect(find.descendant(of: emailWhileAuthFinder, matching: formFinder),
        findsOneWidget);
    expect(find.descendant(of: formFinder, matching: columnFinder),
        findsOneWidget);
    final emailTextFormFieldFinder = textFormFieldFinder;
    expect(
        find.descendant(of: columnFinder, matching: emailTextFormFieldFinder),
        findsOneWidget);
    final TextField emailTextField = tester.widget(find.descendant(
        of: emailTextFormFieldFinder, matching: textFieldFinder));
    expect((emailTextField.decoration!.label as Text).data, Email.emailString);
    expect(emailTextField.keyboardType, TextInputType.emailAddress);
    final descendantRowFinder =
        find.descendant(of: columnFinder, matching: rowFinder);
    expect(descendantRowFinder, findsOneWidget);
    final TextButton nextButton = tester.widget(find
        .descendant(of: descendantRowFinder, matching: textButtonFinder)
        .at(0));
    expect((nextButton.child as Text).data, Email.nextString);
    final TextButton cancelButton = tester.widget(find
        .descendant(of: descendantRowFinder, matching: textButtonFinder)
        .at(1));
    expect((cancelButton.child as Text).data, Email.cancelString);
  });

  testWidgets("Test the TextFormField validation", (WidgetTester tester) async {
    widgetInSkeleton = createWidgetInASkeleton(
        Email(verifyEmailFunctionCall, toLogoutFunctionCall));
    await tester.pumpWidget(widgetInSkeleton);
    final emailTextFormFieldFinder = textFormFieldFinder.at(0);
    await tester.enterText(emailTextFormFieldFinder, "test@test.com");
    await tester.tap(textButtonFinder.at(0));
    await tester.pumpAndSettle();
    expect(find.text(Email.invalidEmailString), findsNothing);
    await tester.enterText(emailTextFormFieldFinder, "");
    await tester.tap(textButtonFinder.at(0));
    await tester.pumpAndSettle();
    final validationErrorTextFinder = find.descendant(
        of: emailTextFormFieldFinder,
        matching: find.text(Email.invalidEmailString));
    expect(validationErrorTextFinder, findsOneWidget);
    await tester.enterText(emailTextFormFieldFinder, " ");
    await tester.tap(textButtonFinder.at(0));
    await tester.pumpAndSettle();
    expect(validationErrorTextFinder, findsOneWidget);
    await tester.enterText(emailTextFormFieldFinder, "test");
    await tester.tap(textButtonFinder.at(0));
    await tester.pumpAndSettle();
    expect(validationErrorTextFinder, findsOneWidget);
    verify(verifyEmailFunctionCall(any, any)).called(1);
  });

  group("next button action", () {
    setUp(() {
      firebaseAuth = MockFirebaseAuth();
      streamController = StreamController();
      when(firebaseAuth.userChanges())
          .thenAnswer((_) => streamController.stream);
      streamController.sink.add(nullUser);
      authStateNotifier = AuthStateNotifier(firebaseAuth);
      widgetInSkeleton = createWidgetInASkeleton(
          Email(authStateNotifier.verifyEmail, toLogoutFunctionCall));
      widgetInSkeletonInProviderScope = ProviderScope(
          overrides: [authStateProvider.overrideWithValue(authStateNotifier)],
          child: widgetInSkeleton);
    });
    testWidgets(
        "Test that a SnackBar is shown when FirebaseAuthException is thrown",
        (WidgetTester tester) async {
      const invalidEmail = "test@test.com";
      authStateNotifier.startLoginFlow();
      when(firebaseAuth.fetchSignInMethodsForEmail(invalidEmail))
          .thenThrow(firebaseAuthException);
      await tester.pumpWidget(widgetInSkeletonInProviderScope);
      final emailTextFormFieldFinder = textFormFieldFinder;
      await tester.enterText(emailTextFormFieldFinder, invalidEmail);
      await tester.tap(textButtonFinder.at(0));
      await tester.pumpAndSettle();
      expect(snackBarFinder, findsOneWidget);
      expect(
          find.descendant(
              of: snackBarFinder,
              matching: find.text(
                  "${Register.failedString}${firebaseAuthException.code}")),
          findsOneWidget);
    });
    testWidgets(
        "Test that a SnackBar is NOT shown when NO FirebaseAuthException is thrown",
        (WidgetTester tester) async {
      const invalidEmail = "test@test.com";
      authStateNotifier.startLoginFlow();
      when(firebaseAuth.fetchSignInMethodsForEmail(invalidEmail))
          .thenAnswer((realInvocation) => Future.value(<String>["password"]));
      await tester.pumpWidget(widgetInSkeletonInProviderScope);
      final emailTextFormFieldFinder = textFormFieldFinder;
      await tester.enterText(emailTextFormFieldFinder, invalidEmail);
      await tester.tap(textButtonFinder.at(0));
      await tester.pumpAndSettle();
      expect(snackBarFinder, findsNothing);
      expect(find.text(Email.invalidEmailString), findsNothing);
    });
  });

  testWidgets("Test that cancel Button call the cancel action function",
      (WidgetTester tester) async {
    when(toLogoutFunctionCall()).thenReturn(anything);
    widgetInSkeleton = createWidgetInASkeleton(
        Email(verifyEmailFunctionCall, toLogoutFunctionCall));
    await tester.pumpWidget(widgetInSkeleton);
    await tester.tap(textButtonFinder.at(1));
    verify(toLogoutFunctionCall()).called(1);
  });
}
