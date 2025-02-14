import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';
import 'package:nonso/src/widgets/auth_screen.dart';
import 'package:nonso/src/widgets/locked.dart';
import 'package:nonso/src/widgets/password.dart';
import 'package:nonso/src/widgets/register.dart';
import 'package:nonso/src/widgets/auth_options.dart';
import 'package:mockito/annotations.dart';

import '../state/auth_bloc_test.dart';
import '../state/auth_bloc_test.mocks.dart';
import 'auth_screen_test.mocks.dart';
import 'common_finders.dart';
import 'widget_testing_helper.dart';

@GenerateMocks([AuthBloc])
void main() {
  const signedOutState = AuthState(
      applicationAuthState: ApplicationAuthState.signedOut, email: null);
  late Widget widgetInSkeleton;
  late FirebaseAuth firebaseAuth;
  late BlocProvider widgetInSkeletonInBlocProvider;
  const User? nullUser = null;
  late AuthBloc mockAuthBloc;
  late Widget someWidget = Container();

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    late StreamController<User?> streamController;
    streamController = StreamController();
    when(firebaseAuth.userChanges()).thenAnswer((_) => streamController.stream);
    streamController.sink.add(nullUser);
    widgetInSkeleton = createWidgetInASkeletonWithoutScaffold(AuthScreen(someWidget));
    mockAuthBloc = MockAuthBloc();
    when(mockAuthBloc.stream)
        .thenAnswer((realInvocation) => Stream.value(signedOutState));
    when(mockAuthBloc.state).thenReturn(signedOutState);
  });

  testWidgets("Test the precense of the main widgets",
      (WidgetTester tester) async {
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: widgetInSkeleton,
    );
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
    expect(scaffoldFinder, findsOneWidget);
  });

  testWidgets("Test signedOut state", (WidgetTester tester) async {
    when(mockAuthBloc.state).thenReturn(signedOutState);
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: widgetInSkeleton,
    );
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
    expect(
        find.descendant(of: scaffoldFinder, matching: find.byType(AuthOptions)),
        findsOneWidget);
  });

  testWidgets("Test register state", (WidgetTester tester) async {
    when(mockAuthBloc.state).thenReturn(registerState);
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: widgetInSkeleton,
    );
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
    expect(find.descendant(of: scaffoldFinder, matching: find.byType(Register)),
        findsOneWidget);
  });

  testWidgets("Test password state", (WidgetTester tester) async {
    when(mockAuthBloc.state).thenReturn(passwordState);
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: widgetInSkeleton,
    );
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
    expect(find.descendant(of: scaffoldFinder, matching: find.byType(Password)),
        findsOneWidget);
  });

  testWidgets("Test passwrord state", (WidgetTester tester) async {
    when(mockAuthBloc.state).thenReturn(passwordState);
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: widgetInSkeleton,
    );
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
    expect(find.descendant(of: scaffoldFinder, matching: find.byType(Password)),
        findsOneWidget);
  });

  testWidgets("Test register state", (WidgetTester tester) async {
    when(mockAuthBloc.state).thenReturn(registerState);
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: widgetInSkeleton,
    );
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
    expect(find.descendant(of: scaffoldFinder, matching: find.byType(Register)),
        findsOneWidget);
  });

  testWidgets("Test locked state", (WidgetTester tester) async {
    when(mockAuthBloc.state).thenReturn(lockedState);
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: widgetInSkeleton,
    );
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
    expect(find.descendant(of: scaffoldFinder, matching: find.byType(Locked)),
        findsOneWidget);
  });

  testWidgets("Test signedIn state", (WidgetTester tester) async {
    widgetInSkeleton = createWidgetInASkeleton(AuthScreen(someWidget));
    when(mockAuthBloc.state).thenReturn(signedInState);
    widgetInSkeletonInBlocProvider = BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: widgetInSkeleton,
    );
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
    expect(
        find.descendant(
            of: scaffoldFinder, matching: find.byType(someWidget.runtimeType)),
        findsOneWidget);
  });
}
