import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/widgets/locked.dart';

import 'common_finders.dart';
import 'email_test.mocks.dart';
import 'skeleton_for_widget_testing.dart';

void main() {
  final updateUserFunctionCall = MockToLogoutFunction();
  final sendVerificationEmailFunctionCall = MockToLogoutFunction();
  final signOutFunctionCall = MockToLogoutFunction();
  late Widget widgetInSkeleton;
  setUp(() {
    widgetInSkeleton = createWidgetInASkeleton(Locked(updateUserFunctionCall,
        sendVerificationEmailFunctionCall, signOutFunctionCall));
  });
  testWidgets("Test the precense of the main widgets",
      (WidgetTester tester) async {
    await tester.pumpWidget(widgetInSkeleton);
    final lockedFinder = find.byType(Locked);
    expect(lockedFinder, findsOneWidget);
    expect(find.descendant(of: lockedFinder, matching: columnFinder),
        findsOneWidget);
    expect(
        find.descendant(
            of: columnFinder, matching: find.text(Locked.verifyEmailAddress)),
        findsOneWidget);
    final refreshAccountTextButtonFinder = textButtonFinder.at(0);
    expect(
        find.descendant(
            of: columnFinder, matching: refreshAccountTextButtonFinder),
        findsOneWidget);
    expect(
        ((tester.widget(refreshAccountTextButtonFinder) as TextButton).child
                as Text)
            .data,
        Locked.refreshString);
    final sendVerificationEmailTextButtonFinder = textButtonFinder.at(1);
    expect(
        find.descendant(
            of: columnFinder, matching: sendVerificationEmailTextButtonFinder),
        findsOneWidget);
    expect(
        ((tester.widget(sendVerificationEmailTextButtonFinder) as TextButton)
                .child as Text)
            .data,
        Locked.sendVerificationEmail);
    final logoutTextButtonFinder = textButtonFinder.at(2);
    expect(find.descendant(of: columnFinder, matching: logoutTextButtonFinder),
        findsOneWidget);
    expect(
        ((tester.widget(logoutTextButtonFinder) as TextButton).child as Text)
            .data,
        Locked.logout);
  });
  testWidgets("Test that clicking the refresh TextButton call its action",
      (WidgetTester tester) async {
    when(updateUserFunctionCall()).thenReturn(anything);
    await tester.pumpWidget(widgetInSkeleton);
    await tester.tap(textButtonFinder.at(0));
    verify(updateUserFunctionCall()).called(1);
  });
  testWidgets(
      "Test that clicking the sendVerificationEmail TextButton call its action",
      (WidgetTester tester) async {
    when(sendVerificationEmailFunctionCall()).thenReturn(anything);
    await tester.pumpWidget(widgetInSkeleton);
    await tester.tap(textButtonFinder.at(1));
    verify(sendVerificationEmailFunctionCall()).called(1);
  });
  testWidgets("Test that clicking the logout TextButton calls its action",
      (WidgetTester tester) async {
    when(signOutFunctionCall()).thenReturn(anything);
    await tester.pumpWidget(widgetInSkeleton);
    await tester.tap(textButtonFinder.at(2));
    verify(signOutFunctionCall()).called(1);
  });
}
