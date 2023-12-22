import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/nonso.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';

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
  const email = "test@test.com";
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
  final nextElevatedButtonFinder = elevatedButtonFinder.at(0);

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

  testWidgets("Test the precense of the main widgets",
      (WidgetTester tester) async {
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
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
    final nextElevatedButtonFinder =
        find.descendant(of: rowFinder, matching: elevatedButtonFinder.at(0));
    expect(nextElevatedButtonFinder, findsOneWidget);
    expect(
        ((tester.widget(nextElevatedButtonFinder) as ElevatedButton).child
                as Text)
            .data,
        Register.nextString);
    final cancelElevatedButtonFinder =
        find.descendant(of: rowFinder, matching: elevatedButtonFinder.at(1));
    expect(cancelElevatedButtonFinder, findsOneWidget);
    expect(
        ((tester.widget(cancelElevatedButtonFinder) as ElevatedButton).child
                as Text)
            .data,
        Register.cancelString);
    ElevatedButton cancelElevatedButton =
        tester.widget(cancelElevatedButtonFinder);
    expect(cancelElevatedButton.onPressed, authBloc.toSignedOut);
  });

  testWidgets("Test password textfield validation",
      (WidgetTester tester) async {
    const validPassword = "8*prt&3k";
    when(firebaseAuth.signInWithEmailAndPassword(
            email: email, password: validPassword))
        .thenAnswer((realInvocation) => Future.value(userCredential));
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
    final passwordTextFieldFinder = textFieldFinder.at(0);
    await tester.enterText(passwordTextFieldFinder, validPassword);
    await tester.tap(nextElevatedButtonFinder);
    await tester.pumpAndSettle();
    final passwordValidationErrorTextFinder = find.descendant(
        of: textFormFieldFinder.at(0),
        matching: find.text(Register.passwordValidationErrorString));
    expect(passwordValidationErrorTextFinder, findsNothing);
    await tester.enterText(passwordTextFieldFinder, "");
    await tester.tap(nextElevatedButtonFinder);
    await tester.pumpAndSettle();
    expect(passwordValidationErrorTextFinder, findsOneWidget);
    await tester.enterText(passwordTextFieldFinder, " ");
    await tester.tap(nextElevatedButtonFinder);
    await tester.pumpAndSettle();
    final TextField passwordTextField = tester.widget(passwordTextFieldFinder);
    expect(passwordTextField.controller!.text, "");
    expect(passwordValidationErrorTextFinder, findsOneWidget);
    await tester.enterText(passwordTextFieldFinder, " gfh");
    await tester.tap(nextElevatedButtonFinder);
    await tester.pumpAndSettle();
    expect(passwordTextField.controller!.text, "gfh");
    expect(passwordValidationErrorTextFinder, findsOneWidget);
  });

  group("nextButton action", () {
    testWidgets(
        "Test that a SnackBar with an error text is shown when FirebaseAuthException is thrown",
        (WidgetTester tester) async {
      const password = "oehgolewrbgowerb";
      when(firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .thenThrow(firebaseAuthException);
      await tester.pumpWidget(widgetInSkeletonInBlocProvider);
      await tester.enterText(textFieldFinder.at(0), password);
      await tester.tap(nextElevatedButtonFinder);
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
      const password = "oehgolewrbgowerb";
      when(firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
      await tester.pumpWidget(widgetInSkeletonInBlocProvider);
      await tester.enterText(textFieldFinder.at(0), password);
      await tester.tap(nextElevatedButtonFinder);
      await tester.pumpAndSettle();
      expect(snackBarFinder, findsNothing);
    });
  });
}
