import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/nonso.dart';

import 'package:nonso/src/widgets/common.dart';
import '../state/auth_bloc_test.mocks.dart';
import 'common_finders.dart';
import 'widget_testing_helper.dart';

abstract class SignInWithEmailAndPasswordFunction {
  Future<void> call(String email, String password,
      void Function(FirebaseAuthException exception) errorCallback);
}

class FakeAuthBloc extends Fake implements AuthBloc {
  final AuthBloc _authBloc;

  FakeAuthBloc(FirebaseAuth firebaseAuth) : _authBloc = AuthBloc(firebaseAuth);

  @override
  Future<bool> signInWithEmailAndPassword(String email, String password,
      void Function(FirebaseAuthException exception) errorCallback) async {
    _authBloc.emit(AuthState(
        applicationAuthState: ApplicationAuthState.password, email: email));
    return _authBloc.signInWithEmailAndPassword(email, password, errorCallback);
  }

  @override
  Future<void> resetPassword(String email,
      void Function(FirebaseAuthException exception) errorCallback) async {
    _authBloc.resetPassword(email, errorCallback);
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
  final firebaseAuthExceptionWithMessage = FirebaseAuthException(
      code: firebaseAuthExceptionCode, message: "message");
  const User? nullUser = null;
  late StreamController<User?> streamController;
  late BlocProvider widgetInSkeletonInBlocProvider;
  late FirebaseAuth firebaseAuth;
  late FakeAuthBloc authBloc;
  UserCredential userCredential = MockUserCredential();
  late Widget widgetProviderLocalization;
  final signInElevatedButtonFinder =
      find.widgetWithText(ElevatedButton, "Sign in");
  final resetPasswordButtonFinder =
      find.widgetWithText(ElevatedButton, "Reset password");

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
    String expectedResetPasswordString = "Reset password";
    String expectedCancelString = "Cancel";
    String expectedPasswordValidationErrorString =
        "Password needs to be at least 8 characters.";
    String expectedFailureCodeString = "Failure: code";
    String expectedFailureMessageString = "Failure: message";
    String expectedInvalidEmailString = "This an invalid email.";
    String expectedResetCodeSet =
        "Check your email inbox to reset your password";

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
      expect(find.descendant(of: passwordFinder, matching: centerFinder),
          findsOneWidget);
      Card card = tester.widget(
        find.descendant(of: centerFinder, matching: cardFinder),
      );
      expect(card.margin!.horizontal, 40);
      expect(card.margin!.vertical, 40);
      expect(
          find.descendant(
              of: find.byWidget(card), matching: singleChildScrollViewFinder),
          findsOneWidget);
      Padding padding = tester.widget(
        find.descendant(
            of: singleChildScrollViewFinder,
            matching: find.byKey(const Key("paddingAroundColumn"))),
      );
      expect(padding.padding.horizontal, 32);
      expect(padding.padding.vertical, 32);
      Column column = tester.widget(
        find.descendant(of: find.byWidget(padding), matching: columnFinder),
      );
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(find.descendant(of: find.byWidget(column), matching: formFinder),
          findsNWidgets(2));
      final emailFormFinder = formFinder.at(0);
      final passwordFormFinder = formFinder.at(1);
      final TextField emailTextField = tester.widget(find.descendant(
          of: textFormFieldFinder.at(0), matching: textFieldFinder));
      expect(
          find.descendant(
              of: emailFormFinder, matching: find.byWidget(emailTextField)),
          findsOneWidget);
      expect(
          (emailTextField.decoration!.label as Text).data, expectedEmailString);
      expect(emailTextField.keyboardType, TextInputType.emailAddress);
      expect(emailTextField.inputFormatters!.elementAt(0),
          noWhiteSpaceInputFormatter);
      expect(emailTextField.autocorrect, false);
      expect(emailTextField.textInputAction, TextInputAction.next);
      final TextField passwordTextField = tester.widget(find.descendant(
          of: textFormFieldFinder.at(1), matching: textFieldFinder));
      expect(
          find.descendant(
              of: passwordFormFinder,
              matching: find.byWidget(passwordTextField)),
          findsOneWidget);
      expect((passwordTextField.decoration!.label as Text).data,
          expectedPasswordString);
      expect(passwordTextField.keyboardType, TextInputType.text);
      expect(passwordTextField.inputFormatters!.elementAt(0),
          noWhiteSpaceInputFormatter);
      expect(passwordTextField.obscureText, true);
      expect(passwordTextField.autocorrect, false);
      expect(passwordTextField.enableSuggestions, false);
      expect(passwordTextField.textInputAction, TextInputAction.done);
      SizedBox firstSizedBox = tester
          .widget(find.byKey(const Key("gapBetweenTextFieldsAndButtons")));
      expect(firstSizedBox.height, 15);
      Row firstRow = tester
          .widget(find.descendant(of: columnFinder, matching: rowFinder.at(0)));
      expect(firstRow.mainAxisAlignment, MainAxisAlignment.spaceEvenly);
      final signInElevatedButtonInARowFinder = find.descendant(
          of: find.byWidget(firstRow), matching: signInElevatedButtonFinder);
      expect(signInElevatedButtonInARowFinder, findsOneWidget);
      expect(
          ((tester.widget(signInElevatedButtonInARowFinder) as ElevatedButton)
                  .child as Text)
              .data,
          expectedSignInString);
      final cancelElevatedButtonFinder = find.descendant(
          of: find.byWidget(firstRow), matching: elevatedButtonFinder.at(1));
      expect(cancelElevatedButtonFinder, findsOneWidget);
      expect(
          ((tester.widget(cancelElevatedButtonFinder) as ElevatedButton).child
                  as Text)
              .data,
          expectedCancelString);
      SizedBox secondSizedBox =
          tester.widget(find.byKey(const Key("gapBetweenButtons")));
      expect(secondSizedBox.height, 5);
      Row secondRow = tester
          .widget(find.descendant(of: columnFinder, matching: rowFinder.at(1)));
      expect(secondRow.mainAxisAlignment, MainAxisAlignment.center);
      final resetPasswordButtonInARowFinder = find.descendant(
          of: find.byWidget(secondRow), matching: resetPasswordButtonFinder);
      expect(resetPasswordButtonInARowFinder, findsOneWidget);
      expect(
          ((tester.widget(resetPasswordButtonInARowFinder) as ElevatedButton)
                  .child as Text)
              .data,
          expectedResetPasswordString);
      ElevatedButton cancelElevatedButton =
          tester.widget(cancelElevatedButtonFinder);
      expect(cancelElevatedButton.onPressed, authBloc.toSignedOut);
      expect(
          checkWidgetsOrder(
              tester
                  .widgetList(find.descendant(
                      of: columnFinder, matching: find.bySubtype<Widget>()))
                  .toList(),
              [
                tester.widget(passwordFormFinder),
                firstSizedBox,
                firstRow,
                secondSizedBox,
                secondRow
              ]),
          isTrue);
    });

    group("Forms validation", () {
      testWidgets("Test email textfield validation",
          (WidgetTester tester) async {
        final emailTextFormFieldFinder = textFormFieldFinder.at(0);
        final emailValidationErrorTextFinder = find.descendant(
            of: emailTextFormFieldFinder,
            matching: find.text(expectedInvalidEmailString));
        await tester.pumpWidget(widgetProviderLocalization);
        ElevatedButton signInElevatedButton =
            tester.widget<ElevatedButton>(signInElevatedButtonFinder);
        ElevatedButton resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isFalse);
        expect(emailValidationErrorTextFinder, findsNothing);
        await tester.enterText(emailTextFormFieldFinder, "f");
        await tester.pumpAndSettle();
        signInElevatedButton =
            tester.widget<ElevatedButton>(signInElevatedButtonFinder);
        resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        expect(emailValidationErrorTextFinder, findsOneWidget);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isFalse);
        await tester.enterText(emailTextFormFieldFinder, "test");
        await tester.pumpAndSettle();
        signInElevatedButton =
            tester.widget<ElevatedButton>(signInElevatedButtonFinder);
        resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        expect(emailValidationErrorTextFinder, findsOneWidget);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isFalse);
        await tester.enterText(emailTextFormFieldFinder, "test@");
        await tester.pumpAndSettle();
        signInElevatedButton =
            tester.widget<ElevatedButton>(signInElevatedButtonFinder);
        resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        expect(emailValidationErrorTextFinder, findsOneWidget);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isFalse);
        await tester.enterText(emailTextFormFieldFinder, validEmail);
        await tester.pumpAndSettle();
        signInElevatedButton =
            tester.widget<ElevatedButton>(signInElevatedButtonFinder);
        resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        expect(emailValidationErrorTextFinder, findsNothing);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isTrue);
        await tester.enterText(emailTextFormFieldFinder, "test@شبكة.com");
        await tester.pumpAndSettle();
        signInElevatedButton =
            tester.widget<ElevatedButton>(signInElevatedButtonFinder);
        resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        expect(emailValidationErrorTextFinder, findsNothing);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isTrue);
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
        ElevatedButton signInElevatedButton =
            tester.widget<ElevatedButton>(signInElevatedButtonFinder);
        ElevatedButton resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isFalse);
        expect(passwordValidationErrorTextFinder, findsNothing);
        final passwordTextFieldFinder = textFieldFinder.at(1);
        await tester.enterText(passwordTextFieldFinder, validPassword);
        await tester.pumpAndSettle();
        expect(passwordValidationErrorTextFinder, findsNothing);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isFalse);
        await tester.enterText(passwordTextFieldFinder, "");
        await tester.pumpAndSettle();
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isFalse);
        await tester.enterText(passwordTextFieldFinder, " ");
        await tester.pumpAndSettle();
        final TextField passwordTextField =
            tester.widget(passwordTextFieldFinder);
        expect(passwordTextField.controller!.text, "");
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isFalse);
        await tester.enterText(passwordTextFieldFinder, " gfh");
        await tester.pumpAndSettle();
        expect(passwordTextField.controller!.text, "gfh");
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        expect(signInElevatedButton.enabled, isFalse);
        expect(resetPasswordElevatedButton.enabled, isFalse);
      });
    });

    group("signIn button action", () {
      testWidgets(
          "Test that a SnackBar with an error text is shown when FirebaseAuthException is thrown",
          (WidgetTester tester) async {
        const password = "oehgolewrbgowerb";
        when(firebaseAuth.signInWithEmailAndPassword(
                email: validEmail, password: password))
            .thenAnswer((invocaction) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          throw firebaseAuthException;
        });
        await tester.pumpWidget(widgetInSkeletonInBlocProvider);
        await tester.enterText(textFieldFinder.at(0), validEmail);
        await tester.enterText(textFieldFinder.at(1), password);
        await tester.pumpAndSettle();
        ElevatedButton signInElevatedButton =
            tester.widget<ElevatedButton>(signInElevatedButtonFinder);
        expect(signInElevatedButton.enabled, isTrue);
        await tester.tap(signInElevatedButtonFinder);
        await tester.pump();
        expect(
            find.descendant(
                of: centerFinder, matching: circularProgressIndicatorFinder),
            findsOneWidget);
        await tester.pumpAndSettle();
        expect(snackBarFinder, findsOneWidget);
        expect(
            find.descendant(
                of: snackBarFinder,
                matching: find.text(expectedFailureCodeString)),
            findsOneWidget);
      });

      testWidgets(
          "Test that no SnackBar is shown when NO FirebaseAuthException is thrown",
          (WidgetTester tester) async {
        const password = "oehgolewrbgowerb";
        when(firebaseAuth.signInWithEmailAndPassword(
                email: validEmail, password: password))
            .thenAnswer((invocation) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return Future.value(userCredential);
        });
        await tester.pumpWidget(widgetInSkeletonInBlocProvider);
        await tester.enterText(textFieldFinder.at(0), validEmail);
        await tester.enterText(textFieldFinder.at(1), password);
        await tester.pumpAndSettle();
        await tester.tap(signInElevatedButtonFinder);
        await tester.pump();
        expect(
            find.descendant(
                of: centerFinder, matching: circularProgressIndicatorFinder),
            findsOneWidget);
        await tester.pumpAndSettle();
        expect(snackBarFinder, findsNothing);
      });
    });

    group("forgot password button action", () {
      testWidgets(
          "Test that a SnackBar with an error text is shown when FirebaseAuthException without a message is thrown",
          (WidgetTester tester) async {
        when(firebaseAuth.sendPasswordResetEmail(email: validEmail))
            .thenThrow(firebaseAuthException);
        await tester.pumpWidget(widgetInSkeletonInBlocProvider);
        await tester.enterText(textFieldFinder.at(0), validEmail);
        await tester.pumpAndSettle();
        ElevatedButton resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        expect(resetPasswordElevatedButton.enabled, isTrue);
        await tester.tap(resetPasswordButtonFinder);
        await tester.pumpAndSettle();
        expect(snackBarFinder, findsOneWidget);
        expect(
            find.descendant(
                of: snackBarFinder,
                matching: find.text(expectedFailureCodeString)),
            findsOneWidget);
      });

      testWidgets(
          "Test that a SnackBar with an error text is shown when FirebaseAuthException with a message is thrown",
          (WidgetTester tester) async {
        when(firebaseAuth.sendPasswordResetEmail(email: validEmail))
            .thenThrow(firebaseAuthExceptionWithMessage);
        await tester.pumpWidget(widgetInSkeletonInBlocProvider);
        await tester.enterText(textFieldFinder.at(0), validEmail);
        await tester.pumpAndSettle();
        ElevatedButton resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        expect(resetPasswordElevatedButton.enabled, isTrue);
        await tester.tap(resetPasswordButtonFinder);
        await tester.pumpAndSettle();
        expect(snackBarFinder, findsOneWidget);
        expect(
            find.descendant(
                of: snackBarFinder,
                matching: find.text(expectedFailureMessageString)),
            findsOneWidget);
      });

      testWidgets(
          "Test that a SnackBar with that directs user to check his email inbox is displayed",
          (WidgetTester tester) async {
        when(firebaseAuth.sendPasswordResetEmail(email: validEmail));
        await tester.pumpWidget(widgetInSkeletonInBlocProvider);
        await tester.enterText(textFieldFinder.at(0), validEmail);
        await tester.pumpAndSettle();
        ElevatedButton resetPasswordElevatedButton =
            tester.widget<ElevatedButton>(resetPasswordButtonFinder);
        expect(resetPasswordElevatedButton.enabled, isTrue);
        await tester.tap(resetPasswordButtonFinder);
        await tester.pumpAndSettle();
        expect(snackBarFinder, findsOneWidget);
        expect(
            find.descendant(
                of: snackBarFinder, matching: find.text(expectedResetCodeSet)),
            findsOneWidget);
      });
    });
  });
}
