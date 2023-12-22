import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/widgets/locked.dart';

import '../state/auth_bloc_test.mocks.dart';
import 'common_finders.dart';
import 'skeleton_for_widget_testing.dart';

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

  testWidgets("Test the precense of the main widgets",
      (WidgetTester tester) async {
    await tester.pumpWidget(widgetInSkeletonInBlocProvider);
    final lockedFinder = find.byType(Locked);
    expect(lockedFinder, findsOneWidget);
    expect(find.descendant(of: lockedFinder, matching: columnFinder),
        findsOneWidget);
    expect(
        find.descendant(
            of: columnFinder, matching: find.text(Locked.verifyEmailAddress)),
        findsOneWidget);
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
        Locked.refreshString);
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
        Locked.sendVerificationEmail);
    expect(
        find.descendant(of: columnFinder, matching: logoutElevatedButtonFinder),
        findsOneWidget);
    expect(
        ((tester.widget(logoutElevatedButtonFinder) as ElevatedButton).child
                as Text)
            .data,
        Locked.logout);
    ElevatedButton refreshAccountElevatedButton =
        tester.widget(refreshAccountElevatedButtonFinder);
    ElevatedButton sendVerificationEmailElevatedButton =
        tester.widget(sendVerificationEmailElevatedButtonFinder);
    ElevatedButton logoutElevatedButton =
        tester.widget(logoutElevatedButtonFinder);
    expect(refreshAccountElevatedButton.onPressed, authBloc.updateUser);
    expect(sendVerificationEmailElevatedButton.onPressed,
        authBloc.sendEmailToVerifyEmailAddress);
    expect(logoutElevatedButton.onPressed, authBloc.signOut);
  });
}
