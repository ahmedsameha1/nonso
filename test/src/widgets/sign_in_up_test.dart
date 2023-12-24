import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/widgets/sign_in_up.dart';

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
    widgetInSkeleton = createWidgetInASkeleton(const SignInUp());
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: widgetInSkeleton,
    );
  });

  group("English locale", () {
    Locale currentLocale = const Locale("en");

    testWidgets("Test the precense of the main widgets",
        (WidgetTester tester) async {
      AppLocalizations appLocalizations =
          await getLocalizations(tester, currentLocale);
      String expectedSignInUpString = appLocalizations.nonso_signInUp;
      await tester.pumpWidget(Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: currentLocale,
          child: widgetInSkeletonInBlocProvider));
      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);
      final signInUpButtonFinder = elevatedButtonFinder;
      expect(find.descendant(of: centerFinder, matching: signInUpButtonFinder),
          findsOneWidget);
      expect(
          find.descendant(
              of: signInUpButtonFinder,
              matching: find.text(expectedSignInUpString)),
          findsOneWidget);
      await tester.tap(signInUpButtonFinder);
      verify(mockAuthBloc.start()).called(1);
    });
  });
}
