import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/widgets/auth_options.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../state/auth_bloc_test.dart';
import '../state/auth_bloc_test.mocks.dart';
import 'auth_screen_test.mocks.dart';
import 'common_finders.dart';
import 'widget_testing_helper.dart';

void main() {
  late FirebaseAuth firebaseAuth;
  late AuthBloc mockAuthBloc;
  late Widget widgetInSkeleton;
  late BlocProvider widgetInSkeletonInBlocProvider;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    streamController = StreamController();
    when(firebaseAuth.userChanges()).thenAnswer((_) => streamController.stream);
    mockAuthBloc = MockAuthBloc();
    when(mockAuthBloc.stream)
        .thenAnswer((realInvocation) => Stream.value(signedOutState));
    when(mockAuthBloc.state).thenReturn(signedOutState);
    when(mockAuthBloc.startSigningIn()).thenReturn(() {});
    widgetInSkeleton = createWidgetInASkeleton(const AuthOptions());
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: widgetInSkeleton,
    );
  });

  group("English locale", () {
    Locale currentLocale = const Locale("en");
    String expectedRegisterString = "Register";
    String expectedSignInString = "Sign in";

    testWidgets("Test the precense of the main widgets",
        (WidgetTester tester) async {
      await tester.pumpWidget(Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: currentLocale,
          child: widgetInSkeletonInBlocProvider));
      final centerFinder = find.byType(Center).at(0);
      expect(centerFinder, findsOneWidget);
      final Column column = tester
          .widget(find.descendant(of: centerFinder, matching: columnFinder));
      expect(find.descendant(of: centerFinder, matching: find.byWidget(column)),
          findsOneWidget);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
      final registerButtonFinder = elevatedButtonFinder.at(0);
      final registerTextFinder = find.text(expectedRegisterString);
      final registerRowFinder =
          find.descendant(of: registerButtonFinder, matching: rowFinder);
      expect(registerRowFinder, findsOneWidget);
      Row registerRow = tester.widget(registerRowFinder);
      expect(registerRow.mainAxisSize, MainAxisSize.min);
      Icon registerIcon = tester.widget(find.byIcon(Icons.app_registration));
      SizedBox registerSizedBox =
          tester.widget(find.byKey(const Key("registerGap")));
      expect(registerSizedBox.width, 8);
      Text registerText = tester.widget(registerTextFinder);
      expect(
          checkWidgetsOrder(
              tester
                  .widgetList(find.descendant(
                      of: registerRowFinder,
                      matching: find.bySubtype<Widget>()))
                  .toList(),
              [registerIcon, registerSizedBox, registerText]),
          isTrue);
      await tester.tap(registerButtonFinder);
      verify(mockAuthBloc.startRegistration()).called(1);
      final signInButtonFinder = elevatedButtonFinder.at(1);
      final signInTextFinder = find.text(expectedSignInString);
      final signInRowFinder =
          find.descendant(of: signInButtonFinder, matching: rowFinder);
      expect(signInRowFinder, findsOneWidget);
      Row signInRow = tester.widget(signInRowFinder);
      expect(signInRow.mainAxisSize, MainAxisSize.min);
      Icon signInIcon = tester.widget(find.byIcon(Icons.login));
      SizedBox signInSizedBox =
          tester.widget(find.byKey(const Key("signInGap")));
      expect(signInSizedBox.width, 8);
      Text signInText = tester.widget(signInTextFinder);
      expect(
          checkWidgetsOrder(
              tester
                  .widgetList(find.descendant(
                      of: signInRowFinder, matching: find.bySubtype<Widget>()))
                  .toList(),
              [signInIcon, signInSizedBox, signInText]),
          isTrue);
      await tester.tap(signInButtonFinder);
      verify(mockAuthBloc.startSigningIn()).called(1);
      final SizedBox gapBetweenButtonsSizedBox =
          tester.widget(find.byKey(const Key("gapBetweenButtons")));
      expect(gapBetweenButtonsSizedBox.height, 20);
      expect(
          checkWidgetsOrder(
              tester
                  .widgetList(find.descendant(
                      of: columnFinder, matching: find.bySubtype<Widget>()))
                  .toList(),
              [
                tester.widget(registerButtonFinder),
                gapBetweenButtonsSizedBox,
                tester.widget(signInButtonFinder)
              ]),
          isTrue);
    });
  });
}
