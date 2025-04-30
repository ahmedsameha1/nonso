import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';
import 'package:nonso/src/widgets/common.dart';
import 'package:nonso/src/widgets/register.dart';

import 'package:nonso/l10n/app_localizations.dart';
import 'common_finders.dart';
import 'widget_testing_helper.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  const validEmail = "test@test.com";
  late Widget widgetInSkeleton;
  const firebaseAuthExceptionCode = "code";
  final firebaseAuthException =
      FirebaseAuthException(code: firebaseAuthExceptionCode);
  final firebaseAuthExceptionWithMessage = FirebaseAuthException(
      code: firebaseAuthExceptionCode, message: "message");
  late StreamController<AuthState> authStateStreamController;
  late BlocProvider widgetInSkeletonInBlocProvider;
  late Widget widgetProviderLocalization;
  late AuthBloc authBloc;
  final registerElevatedButtonFinder = elevatedButtonFinder.at(1);

  setUp(() {
    authStateStreamController = StreamController();
    authStateStreamController.sink.add(const AuthState(
        applicationAuthState: ApplicationAuthState.register, email: null));
    authBloc = MockAuthBloc();
    when(() => authBloc.stream)
        .thenAnswer((_) => authStateStreamController.stream);
    when(() => authBloc.close()).thenAnswer((_) => Completer<void>().future);
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
    String expectedRegisterString = "Register";
    String expectedCancelString = "Cancel";
    String expectedNameValidationErrorString = "Enter your name";
    String expectedInvalidEmailString = "This an invalid email.";
    String expectedPasswordValidationErrorString =
        "Password needs to be at least 8 characters.";
    String expectedConfirmPasswordValidationErrorString =
        "This doesn't match the given password.";
    String expectedSuccessString =
        "Success: Check your email inbox to verify your email address.";
    String expectedFailureCodeString = "Failure: code";
    String expectedFailureMessageString = "Failure: message";

    setUp(() {
      widgetProviderLocalization = Localizations(
          locale: currentLocale,
          delegates: AppLocalizations.localizationsDelegates,
          child: widgetInSkeletonInBlocProvider);
    });

    testWidgets("Test the precence of the main widgets",
        (WidgetTester tester) async {
      await tester.pumpWidget(widgetProviderLocalization);
      final registerFinder = find.byType(Register);
      expect(registerFinder, findsOneWidget);
      expect(find.descendant(of: registerFinder, matching: centerFinder),
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
      expect(find.descendant(of: columnFinder, matching: formFinder),
          findsNWidgets(4));
      final nameFormFinder = formFinder.at(0);
      final emailFormFinder = formFinder.at(1);
      final passwordFormFinder = formFinder.at(2);
      final confirmPasswordFormFinder = formFinder.at(3);
      final TextField nameTextField = tester.widget(find.descendant(
          of: textFormFieldFinder.at(0),
          matching: textFieldFinder.at(0))) as TextField;
      expect(
          find.descendant(
              of: nameFormFinder, matching: find.byWidget(nameTextField)),
          findsOneWidget);
      expect(
          (nameTextField.decoration!.label as Text).data, expectedNameString);
      expect(nameTextField.keyboardType, TextInputType.text);
      expect(nameTextField.textInputAction, TextInputAction.next);
      final TextField emailTextField = tester.widget(find.descendant(
          of: textFormFieldFinder.at(1),
          matching: textFieldFinder.at(1))) as TextField;
      expect(
          find.descendant(
              of: emailFormFinder, matching: find.byWidget(emailTextField)),
          findsOneWidget);
      expect(
          (emailTextField.decoration!.label as Text).data, expectedEmailString);
      expect(emailTextField.keyboardType, TextInputType.emailAddress);
      expect(emailTextField.textInputAction, TextInputAction.next);
      final TextField passwordTextField = tester.widget(find.descendant(
          of: textFormFieldFinder.at(2),
          matching: textFieldFinder.at(2))) as TextField;
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
      expect(passwordTextField.textInputAction, TextInputAction.next);
      final TextField confirmPasswordTextField = tester.widget(find.descendant(
          of: textFormFieldFinder.at(3),
          matching: textFieldFinder.at(3))) as TextField;
      expect(
          find.descendant(
              of: confirmPasswordFormFinder,
              matching: find.byWidget(confirmPasswordTextField)),
          findsOneWidget);
      expect((confirmPasswordTextField.decoration!.label as Text).data,
          expectedConfirmPasswordString);
      expect(confirmPasswordTextField.keyboardType, TextInputType.text);
      expect(confirmPasswordTextField.inputFormatters!.elementAt(0),
          noWhiteSpaceInputFormatter);
      expect(confirmPasswordTextField.obscureText, true);
      expect(confirmPasswordTextField.autocorrect, false);
      expect(confirmPasswordTextField.enableSuggestions, false);
      expect(confirmPasswordTextField.textInputAction, TextInputAction.done);
      Row row =
          tester.widget(find.descendant(of: columnFinder, matching: rowFinder));
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceEvenly);
      expect(find.descendant(of: columnFinder, matching: rowFinder),
          findsOneWidget);
      final registerElevatedButtonFinder =
          find.descendant(of: rowFinder, matching: elevatedButtonFinder.at(1));
      expect(registerElevatedButtonFinder, findsOneWidget);
      expect(
          ((tester.widget(registerElevatedButtonFinder) as ElevatedButton).child
                  as Text)
              .data,
          expectedRegisterString);
      final cancelElevatedButtonFinder =
          find.descendant(of: rowFinder, matching: elevatedButtonFinder.at(0));
      expect(cancelElevatedButtonFinder, findsOneWidget);
      expect(
          ((tester.widget(cancelElevatedButtonFinder) as ElevatedButton).child
                  as Text)
              .data,
          expectedCancelString);
      ElevatedButton cancelElevatedButton =
          tester.widget(cancelElevatedButtonFinder);
      expect(cancelElevatedButton.onPressed, authBloc.toSignedOut);
      expect(
          checkWidgetsOrder(row.children.toList(), [
            cancelElevatedButton,
            tester.widget(registerElevatedButtonFinder)
          ]),
          isTrue);
      SizedBox sizedBox = tester
          .widget(find.byKey(const Key("gapBetweenTextFieldsAndButtons")));
      expect(sizedBox.height, 15);
      expect(
          checkWidgetsOrder(
              tester
                  .widgetList(find.descendant(
                      of: columnFinder, matching: find.bySubtype<Widget>()))
                  .toList(),
              [tester.widget(confirmPasswordFormFinder), sizedBox, row]),
          isTrue);
    });

    group("Form validation", () {
      testWidgets("name textfield validation", (WidgetTester tester) async {
        final nameValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(0),
            matching: find.text(expectedNameValidationErrorString));
        await tester.pumpWidget(widgetProviderLocalization);
        ElevatedButton registerElevatedButton =
            tester.widget<ElevatedButton>(registerElevatedButtonFinder);
        expect(nameValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
        final nameTextFieldFinder = textFieldFinder.at(0);
        await tester.enterText(nameTextFieldFinder, " ");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsOneWidget);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(nameTextFieldFinder, "~");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsOneWidget);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(nameTextFieldFinder, "f");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(nameTextFieldFinder, "David");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(nameTextFieldFinder, "foo bar");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(nameTextFieldFinder, " حسن حسان ");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(nameTextFieldFinder, "س");
        await tester.pumpAndSettle();
        expect(nameValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
      });

      testWidgets("email textfield validation", (WidgetTester tester) async {
        final emailValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(1),
            matching: find.text(expectedInvalidEmailString));
        await tester.pumpWidget(widgetProviderLocalization);
        ElevatedButton registerElevatedButton =
            tester.widget<ElevatedButton>(registerElevatedButtonFinder);
        expect(emailValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
        final emailTextFieldFinder = textFieldFinder.at(1);
        await tester.enterText(emailTextFieldFinder, "f");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(emailTextFieldFinder, "test");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(emailTextFieldFinder, "test@");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsOneWidget);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(emailTextFieldFinder, validEmail);
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(emailTextFieldFinder, "test@شبكة.com");
        await tester.pumpAndSettle();
        expect(emailValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
      });

      testWidgets("password textfield validation", (WidgetTester tester) async {
        final passwordValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(2),
            matching: find.text(expectedPasswordValidationErrorString));
        await tester.pumpWidget(widgetProviderLocalization);
        ElevatedButton registerElevatedButton =
            tester.widget<ElevatedButton>(registerElevatedButtonFinder);
        expect(passwordValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
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
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(passwordTextFieldFinder, " gfh");
        expect(passwordTextField.controller!.text, "gfh");
        await tester.pumpAndSettle();
        expect(passwordValidationErrorTextFinder, findsOneWidget);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(passwordTextFieldFinder, "8*prt&3k");
        await tester.pumpAndSettle();
        expect(passwordValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
      });

      testWidgets("confirm password textfield validation",
          (WidgetTester tester) async {
        final confirmPasswordValidationErrorTextFinder = find.descendant(
            of: textFormFieldFinder.at(3),
            matching: find.text(expectedConfirmPasswordValidationErrorString));
        await tester.pumpWidget(widgetProviderLocalization);
        ElevatedButton registerElevatedButton =
            tester.widget<ElevatedButton>(registerElevatedButtonFinder);
        expect(confirmPasswordValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
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
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(passwordTextFieldFinder, "hbefrf23g293g");
        await tester.enterText(confirmPasswordTextFieldFinder, " rhghanady667");
        await tester.pumpAndSettle();
        expect(
            (tester.widget(confirmPasswordTextFieldFinder) as TextField)
                .controller!
                .text,
            "rhghanady667");
        expect(confirmPasswordValidationErrorTextFinder, findsOneWidget);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(confirmPasswordTextFieldFinder, "rhghanady667 ");
        await tester.pumpAndSettle();
        expect(
            (tester.widget(confirmPasswordTextFieldFinder) as TextField)
                .controller!
                .text,
            "rhghanady667");
        expect(confirmPasswordValidationErrorTextFinder, findsOneWidget);
        expect(registerElevatedButton.enabled, isFalse);
        await tester.enterText(passwordTextFieldFinder, "8*prt&3k");
        await tester.enterText(confirmPasswordTextFieldFinder, "8*prt&3k");
        await tester.pumpAndSettle();
        expect(confirmPasswordValidationErrorTextFinder, findsNothing);
        expect(registerElevatedButton.enabled, isFalse);
      });
    });

    group("register button action", () {
      const userDisplayName = "name";
      testWidgets(
          "Test that a SnackBar is shown when FirebaseAuthException without a message is thrown",
          (WidgetTester tester) async {
        await tester.pumpWidget(widgetProviderLocalization);
        const password = "oehgolewrbgowerb";
        when(() =>
                authBloc.registerAccount(validEmail, password, userDisplayName))
            .thenAnswer((invodcation) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          throw firebaseAuthException;
        });
        await tester.enterText(textFieldFinder.at(0), userDisplayName);
        await tester.enterText(textFieldFinder.at(1), validEmail);
        await tester.enterText(textFieldFinder.at(2), password);
        await tester.enterText(textFieldFinder.at(3), password);
        await tester.pumpAndSettle();
        await tester.tap(registerElevatedButtonFinder);
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        expect(snackBarFinder, findsNothing);
      });

      testWidgets(
          "Test that a SnackBar is shown when FirebaseAuthException with a message is thrown",
          (WidgetTester tester) async {
        await tester.pumpWidget(widgetProviderLocalization);
        const password = "oehgolewrbgowerb";
        when(() =>
                authBloc.registerAccount(validEmail, password, userDisplayName))
            .thenAnswer((invodcation) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          throw firebaseAuthExceptionWithMessage;
        });
        await tester.enterText(textFieldFinder.at(0), userDisplayName);
        await tester.enterText(textFieldFinder.at(1), validEmail);
        await tester.enterText(textFieldFinder.at(2), password);
        await tester.enterText(textFieldFinder.at(3), password);
        await tester.pumpAndSettle();
        await tester.tap(registerElevatedButtonFinder);
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
                matching: find.text(expectedFailureMessageString)),
            findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        expect(snackBarFinder, findsNothing);
      });

      testWidgets(
          "Test that a SnackBar is shown to guide user to check his email",
          (WidgetTester tester) async {
        await tester.pumpWidget(widgetProviderLocalization);
        const password = "oehgolewrbgowerb";
        when(() =>
                authBloc.registerAccount(validEmail, password, userDisplayName))
            .thenAnswer((realInvocation) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return Future.value(true);
        });
        await tester.enterText(textFieldFinder.at(0), userDisplayName);
        await tester.enterText(textFieldFinder.at(1), validEmail);
        await tester.enterText(textFieldFinder.at(2), password);
        await tester.enterText(textFieldFinder.at(3), password);
        await tester.pumpAndSettle();
        await tester.tap(registerElevatedButtonFinder);
        await tester.pump();
        expect(
            find.descendant(
                of: centerFinder, matching: circularProgressIndicatorFinder),
            findsOneWidget);
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
