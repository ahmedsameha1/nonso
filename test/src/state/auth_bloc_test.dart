import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_login_state.dart';

import '../test_constants.dart';
import 'auth_state_notifier_test.mocks.dart';

abstract class FirebaseAuthExceptionErrorCallbackFunction {
  void call(FirebaseAuthException exception);
}

late FirebaseAuth firebaseAuth;
late User? firebaseUser;
late UserCredential userCredential;
const validEmail = "email@email.com";
const invalidEmail = "invalid_email";
const password = "oiehgrwogherow+%5";
const weakPassword = "123";
const displayName = "displayName";
const workingWithAuthStateNotifier = "Working with AuthStateNotifier class";
const callingStartLoginFlow = "Calling startLoginFlow()";
late AuthBloc sut;
final firebaseAuthExceptionCallback =
    MockFirebaseAuthExceptionErrorCallbackFunction();
const User? nullUser = null;
final User notNullUser = MockUser();
late StreamController<User?> streamController;

@GenerateMocks([
  FirebaseAuthExceptionErrorCallbackFunction,
  FirebaseAuth,
  UserCredential,
  User
])
main() {
  final firebaseAuthException = FirebaseAuthException(code: "code");

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    userCredential = MockUserCredential();
    streamController = StreamController();
    when(firebaseAuth.userChanges()).thenAnswer((_) => streamController.stream);
    sut = AuthBloc(firebaseAuth);
  });

  test("""
        $given $workingWithAuthStateNotifier
        $wheN Creating a new AuthBloc instance
          $and there is no signed in user
        $then state.applicationLoginState should return ApplicationLoginState.loggedOut
      """, () async {
    pushPreparedUserToUserChangesStream(nullUser);
    await expectLater(1, 1);
    expect(
        sut.state,
        const AuthState(
            applicationLoginState: ApplicationLoginState.loggedOut,
            email: null));
  });

  blocTest(
    """
        $given $workingWithAuthStateNotifier
        $wheN Creating a new AuthBloc instance
          $and there is a signed in user
          $and User.emailVerified returns true
        $then state.applicationLoginState should return ApplicationLoginState.loggedIn
      """,
    build: () => sut,
    setUp: () {
      pushPreparedUserToUserChangesStream(notNullUser, true);
    },
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.loggedIn,
          email: "user1@example.com")
    ],
  );

  blocTest(
    """
        $given $workingWithAuthStateNotifier
        $wheN Creating a new AuthStateNotifier instance
          $and there is a signed in user
          $and User.emailVerified returns false
        $then state.applicationLoginState should return ApplicationLoginState.locked
      """,
    build: () => sut,
    setUp: () {
      pushPreparedUserToUserChangesStream(notNullUser, false);
    },
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.locked,
          email: "user1@example.com")
    ],
  );

  blocTest(
    """
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN calling startLoginFlow()
        $then That state.applicationLoginState returns ApplicationLoginState.emailAddress
      """,
    build: () => sut,
    act: (bloc) {
      fromLoggedOutToEmailAddress();
    },
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.emailAddress,
          email: null)
    ],
  );

  blocTest("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling verifyEmail()
          $and FirebaseAuthException has been thrown
        $then the errorCallback() should be called
""",
      setUp: () {
        when(firebaseAuth.fetchSignInMethodsForEmail(invalidEmail))
            .thenThrow(firebaseAuthException);
      },
      build: () => sut,
      act: (bloc) {
        fromLoggedOutToEmailAddress();
        sut.verifyEmail(invalidEmail, firebaseAuthExceptionCallback);
      },
      verify: (bloc) {
        verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
      });

  blocTest(
    """
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling verifyEmail() with a valid email address
        $then the errorCallback() has NOT been called, which imply that a
          FirebaseAuthException has NOT been thrown
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
    },
    build: () => sut,
    act: (bloc) {
      fromLoggedOutToEmailAddress();
      sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    skip: 1,
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.password,
          email: validEmail)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling verifyEmail with a valid email address
          $and verifyEmail returns a Future of List that doesn't contain "password"
        $then state.applicationLoginState should return ApplicationLoginState.register
          $and the email returns the same passed argument email
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatDoesntContainPasswordMethod();
    },
    build: () => sut,
    act: (bloc) {
      fromLoggedOutToEmailAddress();
      sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    skip: 1,
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.register,
          email: validEmail)
    ],
  );

  blocTest("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword()
          $and FirebaseAuthException has been thrown
        $then the errorCallback() should be called
""",
      setUp: () {
        prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
        when(firebaseAuth.signInWithEmailAndPassword(
                email: invalidEmail, password: password))
            .thenThrow(firebaseAuthException);
      },
      build: () => sut,
      act: (bloc) {
        fromLoggedOutToEmailAddress();
        sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
        sut.signInWithEmailAndPassword(
            invalidEmail, password, firebaseAuthExceptionCallback);
      },
      verify: (bloc) {
        verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
      });
}

void pushPreparedUserToUserChangesStream(User? user,
    [bool emailVerified = false]) {
  if (user != null) {
    when(user.emailVerified).thenReturn(emailVerified);
    when(user.email).thenReturn("user1@example.com");
  }
  streamController.sink.add(user);
}

void fromLoggedOutToEmailAddress() {
  sut.startLoginFlow();
}

void
    prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod() {
  when(firebaseAuth.fetchSignInMethodsForEmail(validEmail))
      .thenAnswer((realInvocation) => Future.value(<String>["password"]));
}

void
    prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatDoesntContainPasswordMethod() {
  when(firebaseAuth.fetchSignInMethodsForEmail(validEmail))
      .thenAnswer((realInvocation) => Future.value(<String>[]));
}
