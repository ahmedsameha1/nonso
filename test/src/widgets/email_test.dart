import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';
import 'package:nonso/src/widgets/email.dart';
import 'package:nonso/src/widgets/register.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../state/auth_bloc_test.mocks.dart';
import 'common_finders.dart';
import 'skeleton_for_widget_testing.dart';

class FakeAuthBloc extends Fake implements AuthBloc {
  final AuthBloc _authBloc;

  FakeAuthBloc(FirebaseAuth firebaseAuth) : _authBloc = AuthBloc(firebaseAuth);

  @override
  Future<void> verifyEmail(String email,
      void Function(FirebaseAuthException exception) errorCallback) async {
    _authBloc.emit(const AuthState(
        applicationAuthState: ApplicationAuthState.emailAddress, email: null));
    _authBloc.verifyEmail(email, errorCallback);
  }

  @override
  Stream<AuthState> get stream => _authBloc.stream;

  @override
  AuthState get state => _authBloc.state;

  @override
  Future<void> close() {
    return _authBloc.close();
  }
}

void main() {
  final toBeTestedButtonFinder = elevatedButtonFinder.at(0);
  const email = "test@test.com";
  final firebaseAuthException = FirebaseAuthException(code: "code");
  const User? nullUser = null;
  late StreamController<User?> streamController;
  late BlocProvider widgetInSkeletonInBlocProvider;
  late FirebaseAuth firebaseAuth;
  late FakeAuthBloc authBloc;
  late Widget widgetInSkeleton;
  late Widget widgetProviderLocalization;
  const validEmail = "test@test.com";
  const invalidEmail = "weohfwo@";

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    streamController = StreamController();
    when(firebaseAuth.userChanges()).thenAnswer((_) => streamController.stream);
    streamController.sink.add(nullUser);
    authBloc = FakeAuthBloc(firebaseAuth);
    widgetInSkeleton = createWidgetInASkeleton(Email());
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => authBloc,
      child: widgetInSkeleton,
    );
  });

  group("English locale", () {
    Locale currentLocale = const Locale("en");

    setUp(() {
      widgetProviderLocalization = Localizations(
        locale: currentLocale,
        delegates: AppLocalizations.localizationsDelegates,
        child: widgetInSkeletonInBlocProvider,
      );
    });

    testWidgets("Test the precense of the main widgets",
        (WidgetTester tester) async {
      AppLocalizations appLocalizations =
          await getLocalizations(tester, currentLocale);
      String expectedEmailString = appLocalizations.email;
      String expectedNextString = appLocalizations.next;
      String expectedCancelString = appLocalizations.cancel;
      when(firebaseAuth.fetchSignInMethodsForEmail(validEmail))
          .thenAnswer((realInvocation) => Future.value(<String>["password"]));
      await tester.pumpWidget(widgetProviderLocalization);
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
      expect(
          (emailTextField.decoration!.label as Text).data, expectedEmailString);
      expect(emailTextField.keyboardType, TextInputType.emailAddress);
      final descendantRowFinder =
          find.descendant(of: columnFinder, matching: rowFinder);
      expect(descendantRowFinder, findsOneWidget);
      final ElevatedButton nextButton = tester.widget(find
          .descendant(of: descendantRowFinder, matching: elevatedButtonFinder)
          .at(0));
      expect((nextButton.child as Text).data, expectedNextString);
      final ElevatedButton cancelButton = tester.widget(find
          .descendant(of: descendantRowFinder, matching: elevatedButtonFinder)
          .at(1));
      expect((cancelButton.child as Text).data, expectedCancelString);
      expect(cancelButton.onPressed, authBloc.toSignedOut);
    });

    testWidgets("Test the TextFormField validation",
        (WidgetTester tester) async {
      AppLocalizations appLocalizations =
          await getLocalizations(tester, currentLocale);
      String expectedInvalidEmailString = appLocalizations.invalidEmailString;
      when(firebaseAuth.fetchSignInMethodsForEmail(validEmail))
          .thenAnswer((realInvocation) => Future.value(<String>["password"]));
      await tester.pumpWidget(widgetProviderLocalization);
      final emailTextFormFieldFinder = textFormFieldFinder.at(0);
      await tester.enterText(emailTextFormFieldFinder, validEmail);
      await tester.tap(toBeTestedButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text(expectedInvalidEmailString), findsNothing);
      await tester.enterText(emailTextFormFieldFinder, "");
      await tester.tap(toBeTestedButtonFinder);
      await tester.pumpAndSettle();
      final validationErrorTextFinder = find.descendant(
          of: emailTextFormFieldFinder,
          matching: find.text(expectedInvalidEmailString));
      expect(validationErrorTextFinder, findsOneWidget);
      await tester.enterText(emailTextFormFieldFinder, " ");
      await tester.tap(toBeTestedButtonFinder);
      await tester.pumpAndSettle();
      expect(validationErrorTextFinder, findsOneWidget);
      await tester.enterText(emailTextFormFieldFinder, "test");
      await tester.tap(toBeTestedButtonFinder);
      await tester.pumpAndSettle();
      expect(validationErrorTextFinder, findsOneWidget);
    });

    group("next button action", () {
      testWidgets(
          "Test that a SnackBar is shown when FirebaseAuthException is thrown",
          (WidgetTester tester) async {
        when(firebaseAuth.fetchSignInMethodsForEmail(invalidEmail))
            .thenThrow(firebaseAuthException);
        await tester.pumpWidget(widgetProviderLocalization);
        final emailTextFormFieldFinder = textFormFieldFinder;
        await tester.enterText(emailTextFormFieldFinder, invalidEmail);
        await tester.tap(toBeTestedButtonFinder);
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
        AppLocalizations appLocalizations =
            await getLocalizations(tester, currentLocale);
        String expectedInvalidEmailString = appLocalizations.invalidEmailString;
        when(firebaseAuth.fetchSignInMethodsForEmail(validEmail))
            .thenAnswer((realInvocation) => Future.value(<String>["password"]));
        await tester.pumpWidget(widgetProviderLocalization);
        final emailTextFormFieldFinder = textFormFieldFinder;
        await tester.enterText(emailTextFormFieldFinder, email);
        await tester.tap(toBeTestedButtonFinder);
        await tester.pumpAndSettle();
        expect(snackBarFinder, findsNothing);
        expect(find.text(expectedInvalidEmailString), findsNothing);
      });
    });
  });
}
