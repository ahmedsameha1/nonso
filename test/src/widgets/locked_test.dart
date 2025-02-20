import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/widgets/locked.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../state/auth_bloc_test.mocks.dart';
import 'common_finders.dart';
import 'widget_testing_helper.dart';

class FakeAuthBloc extends Fake implements AuthBloc {
  final AuthBloc _authBloc;

  FakeAuthBloc(FirebaseAuth firebaseAuth) : _authBloc = AuthBloc(firebaseAuth);

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
  const User? nullUser = null;
  late StreamController<User?> streamController;
  late BlocProvider widgetInSkeletonInBlocProvider;
  late FirebaseAuth firebaseAuth;
  late FakeAuthBloc authBloc;
  late Widget widgetInSkeleton;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    streamController = StreamController();
    when(firebaseAuth.userChanges()).thenAnswer((_) => streamController.stream);
    streamController.sink.add(nullUser);
    authBloc = FakeAuthBloc(firebaseAuth);
    widgetInSkeleton = createWidgetInASkeleton(const Locked());
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => authBloc,
      child: widgetInSkeleton,
    );
  });

  group("English locale", () {
    Locale currentLocale = const Locale("en");
    String expectedRefreshString = "Refresh account";
    String expectedVerifyEmailAddressString =
        "Check your email inbox to verify your email address";
    String expectedSignOutString = "Sign out";
    String expectedResendVerificationEmailString = "Resend verification email";
    testWidgets("Test the precense of the main widgets",
        (WidgetTester tester) async {
      await tester.pumpWidget(Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: currentLocale,
          child: widgetInSkeletonInBlocProvider));
      final lockedFinder = find.byType(Locked);
      expect(lockedFinder, findsOneWidget);
      final centerFinder =
          find.descendant(of: lockedFinder, matching: find.byType(Center));
      expect(centerFinder, findsOneWidget);
      final Column column = tester
          .widget(find.descendant(of: centerFinder, matching: columnFinder));
      expect(find.byWidget(column), findsOneWidget);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
      Container container = tester.widget(
          find.descendant(of: columnFinder, matching: find.byType(Container)));
      expect(container.padding!.vertical, 20);
      expect(container.padding!.horizontal, 20);
      expect(container.margin!.horizontal, 40);
      BoxDecoration boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.border, Border.all(color: Colors.black));
      expect(boxDecoration.borderRadius, BorderRadius.circular(10));
      Text text = tester.widget(find.descendant(
          of: find.byWidget(container),
          matching: find.text(expectedVerifyEmailAddressString)));
      expect(text.textAlign, TextAlign.center);
      expect(text.style!.fontWeight, FontWeight.w400);
      expect(text.style!.letterSpacing, 0.5);
      expect(text.style!.fontSize, 16.0);
      expect(text.style!.height, 1.5);
      SizedBox firstSizedBox = tester.widget(SizedBoxFinder.at(0));
      expect(firstSizedBox.height, 10);
      final refreshAccountElevatedButtonFinder = elevatedButtonFinder.at(0);
      final sendVerificationEmailElevatedButtonFinder =
          elevatedButtonFinder.at(1);
      final logoutElevatedButtonFinder = elevatedButtonFinder.at(2);
      expect(
          find.descendant(
              of: columnFinder, matching: refreshAccountElevatedButtonFinder),
          findsOneWidget);
      expect(
          ((tester.widget(refreshAccountElevatedButtonFinder) as ElevatedButton)
                  .child as Text)
              .data,
          expectedRefreshString);
      expect(
          find.descendant(
              of: columnFinder,
              matching: sendVerificationEmailElevatedButtonFinder),
          findsOneWidget);
      expect(
          ((tester.widget(sendVerificationEmailElevatedButtonFinder)
                      as ElevatedButton)
                  .child as Text)
              .data,
          expectedResendVerificationEmailString);
      expect(
          find.descendant(
              of: columnFinder, matching: logoutElevatedButtonFinder),
          findsOneWidget);
      expect(
          ((tester.widget(logoutElevatedButtonFinder) as ElevatedButton).child
                  as Text)
              .data,
          expectedSignOutString);
      ElevatedButton refreshAccountElevatedButton =
          tester.widget(refreshAccountElevatedButtonFinder);
      SizedBox secondSizedBox = tester.widget(SizedBoxFinder.at(1));
      expect(secondSizedBox.height, 5);
      ElevatedButton sendVerificationEmailElevatedButton =
          tester.widget(sendVerificationEmailElevatedButtonFinder);
      SizedBox thirdSizedBox = tester.widget(SizedBoxFinder.at(2));
      expect(thirdSizedBox.height, 5);
      ElevatedButton logoutElevatedButton =
          tester.widget(logoutElevatedButtonFinder);
      expect(refreshAccountElevatedButton.onPressed, authBloc.updateUser);
      expect(sendVerificationEmailElevatedButton.onPressed,
          authBloc.sendEmailToVerifyEmailAddress);
      expect(logoutElevatedButton.onPressed, authBloc.signOut);
      expect(
          checkWidgetsOrder(
              tester
                  .widgetList(find.descendant(
                      of: find.byWidget(column),
                      matching: find.bySubtype<Widget>()))
                  .toList(),
              [
                container,
                firstSizedBox,
                refreshAccountElevatedButton,
                secondSizedBox,
                sendVerificationEmailElevatedButton,
                thirdSizedBox,
                logoutElevatedButton
              ]),
          isTrue);
    });
  });
}
