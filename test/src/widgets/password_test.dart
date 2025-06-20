import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nonso/nonso.dart';
import 'package:nonso/src/state/auth_events.dart';

import 'package:nonso/src/widgets/common.dart';

import 'common_finders.dart';
import 'widget_testing_helper.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockUser extends Mock implements User {}

Widget createWidgetInASkeleton(
    AuthBloc authBloc, Locale locale, Widget widget) {
  return RepositoryProvider.value(
    value: authBloc,
    child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: Scaffold(body: widget)),
  );
}

void main() {
  const validEmail = "test@test.com";
  late User? notNullUser;
  const firebaseAuthExceptionCode = "code";
  final firebaseAuthException =
      FirebaseAuthException(code: firebaseAuthExceptionCode);
  final firebaseAuthExceptionWithMessage = FirebaseAuthException(
      code: firebaseAuthExceptionCode, message: "message");
  late StreamController<AuthState> authStateStreamController;
  late AuthBloc authBloc;
  final signInElevatedButtonFinder =
      find.widgetWithText(ElevatedButton, "Sign in");
  final resetPasswordButtonFinder =
      find.widgetWithText(ElevatedButton, "Reset password");

  setUp(() {
    notNullUser = MockUser();
    authStateStreamController = StreamController();
    authStateStreamController.sink.add(AuthState(
        applicationAuthState: ApplicationAuthState.password, user: null));
    authBloc = MockAuthBloc();
    when(() => authBloc.stream)
        .thenAnswer((_) => authStateStreamController.stream);
    when(() => authBloc.state).thenAnswer((_) => AuthState(
        applicationAuthState: ApplicationAuthState.password, user: null));
    when(() => notNullUser!.displayName).thenReturn("John");
    registerFallbackValue(SignOutEvent());
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
    String expectedRegisterString = "Register";
    String expectedWelcomeString = "Welcome John!";

    testWidgets("Test the precense of the main widgets",
        (WidgetTester tester) async {
      await tester.pumpWidget(
          createWidgetInASkeleton(authBloc, currentLocale, Password()));
      final passwordFinder = find.byType(Password);
      expect(passwordFinder, findsOneWidget);
      expect(find.descendant(of: passwordFinder, matching: centerFinder.at(0)),
          findsOneWidget);
      ListView listView = tester.widget(
          find.descendant(of: centerFinder, matching: find.byType(ListView)));
      expect(listView.padding!.vertical, 20);
      expect(listView.shrinkWrap, isTrue);
      Text signInText = tester.widget(find.descendant(
          of: find.byWidget(listView),
          matching: find.descendant(
              of: centerFinder.at(1), matching: find.byType(Text))));
      expect(signInText.data, expectedSignInString);
      expect(signInText.textAlign, TextAlign.center);
      expect(signInText.style!.fontWeight, FontWeight.w400);
      expect(signInText.style!.fontSize, 36.0);
      Card card = tester.widget(
        find.descendant(of: find.byWidget(listView), matching: cardFinder),
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
          of: find.byWidget(firstRow), matching: elevatedButtonFinder.at(0));
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
          firstRow.children.toList(),
          containsAllInOrder([
            cancelElevatedButton,
            tester.widget(signInElevatedButtonFinder)
          ]));
      expect(
          tester
              .widgetList(find.descendant(
                  of: columnFinder, matching: find.bySubtype<Widget>()))
              .toList(),
          containsAllInOrder([
            tester.widget(passwordFormFinder),
            firstSizedBox,
            firstRow,
            secondSizedBox,
            secondRow
          ]));
      TextButton registerTextButton = tester.widget(find.descendant(
          of: find.byWidget(listView),
          matching: find.descendant(
              of: centerFinder.at(2), matching: find.byType(TextButton))));
      expect((registerTextButton.child as Text).data, expectedRegisterString);
    });

    group("Forms validation", () {
      testWidgets("Test email textfield validation",
          (WidgetTester tester) async {
        final emailTextFormFieldFinder = textFormFieldFinder.at(0);
        final emailValidationErrorTextFinder = find.descendant(
            of: emailTextFormFieldFinder,
            matching: find.text(expectedInvalidEmailString));
        await tester.pumpWidget(
            createWidgetInASkeleton(authBloc, currentLocale, Password()));
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
        await tester.pumpWidget(
            createWidgetInASkeleton(authBloc, currentLocale, Password()));
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
        when(() => authBloc.signInWithEmailAndPassword(validEmail, password))
            .thenAnswer((invocaction) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          throw firebaseAuthException;
        });
        await tester.pumpWidget(
            createWidgetInASkeleton(authBloc, currentLocale, Password()));
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
        when(() => authBloc.signInWithEmailAndPassword(validEmail, password))
            .thenAnswer((invocation) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return Future.value(true);
        });
        authStateStreamController.sink.add(AuthState(
            applicationAuthState: ApplicationAuthState.signedIn,
            user: notNullUser));
        when(() => authBloc.stream)
            .thenAnswer((_) => authStateStreamController.stream);
        when(() => authBloc.state).thenAnswer((_) => AuthState(
            applicationAuthState: ApplicationAuthState.signedIn,
            user: notNullUser));
        await tester.pumpWidget(
            createWidgetInASkeleton(authBloc, currentLocale, Password()));
        await tester.enterText(textFieldFinder.at(0), validEmail);
        await tester.enterText(textFieldFinder.at(1), password);
        await tester.pumpAndSettle();
        await tester.tap(signInElevatedButtonFinder);
        await tester.runAsync(
          () async {
            await tester.pump();
            expect(
                find.descendant(
                    of: centerFinder,
                    matching: circularProgressIndicatorFinder),
                findsOneWidget);
            await tester.pumpAndSettle();
            expect(
                find.descendant(
                    of: snackBarFinder,
                    matching: find.text(expectedWelcomeString)),
                findsOneWidget);
          },
        );
      });
    });

    group("forgot password button action", () {
      testWidgets(
          "Test that a SnackBar with an error text is shown when FirebaseAuthException without a message is thrown",
          (WidgetTester tester) async {
        when(() => authBloc.resetPassword(validEmail))
            .thenAnswer((invocaction) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          throw firebaseAuthException;
        });
        await tester.pumpWidget(
            createWidgetInASkeleton(authBloc, currentLocale, Password()));
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
        when(() => authBloc.resetPassword(validEmail))
            .thenAnswer((invocaction) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          throw firebaseAuthExceptionWithMessage;
        });
        await tester.pumpWidget(
            createWidgetInASkeleton(authBloc, currentLocale, Password()));
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
        when(() => authBloc.resetPassword(validEmail))
            .thenAnswer((invocation) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return Future.value(true);
        });
        await tester.pumpWidget(
            createWidgetInASkeleton(authBloc, currentLocale, Password()));
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

    testWidgets('Register button', (WidgetTester tester) async {
      await tester.pumpWidget(
          createWidgetInASkeleton(authBloc, currentLocale, Password()));
      await tester.tap(find.widgetWithText(TextButton, expectedRegisterString));
      verify(() => authBloc.add((any(that: isA<RegisterEvent>()))));
    });
  });
}
