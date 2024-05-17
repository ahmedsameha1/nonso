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
import 'skeleton_for_widget_testing.dart';

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
      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);
      final columnFinder = find.byType(Column);
      expect(find.descendant(of: centerFinder, matching: columnFinder),
          findsOneWidget);
      final registerButtonFinder = elevatedButtonFinder.at(0);
      final registerTextFinder = find.text(expectedRegisterString);
      expect(find.descendant(of: registerButtonFinder, matching: registerTextFinder),
          findsOneWidget);
      final signInButtonFinder = elevatedButtonFinder.at(1);
      final signInTextFinder = find.text(expectedSignInString);
      expect(find.descendant(of: signInButtonFinder, matching: signInTextFinder),
          findsOneWidget);
      expect(find.descendant(of: columnFinder, matching: registerButtonFinder),
          findsOneWidget);
      await tester.tap(registerButtonFinder);
      verify(mockAuthBloc.startRegistration()).called(1);
      expect(find.descendant(of: columnFinder, matching: signInButtonFinder),
          findsOneWidget);
      await tester.tap(signInButtonFinder);
      verify(mockAuthBloc.startSigningIn()).called(1);
    });
  });
}
