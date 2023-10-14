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
          email: validEmail)
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
          email: validEmail)
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
      act: (bloc) async {
        fromLoggedOutToEmailAddress();
        await sut.verifyEmail(invalidEmail, firebaseAuthExceptionCallback);
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
    act: (bloc) async {
      fromLoggedOutToEmailAddress();
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
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
    act: (bloc) async {
      fromLoggedOutToEmailAddress();
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
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
      act: (bloc) async {
        fromLoggedOutToEmailAddress();
        await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
        await sut.signInWithEmailAndPassword(
            invalidEmail, password, firebaseAuthExceptionCallback);
      },
      verify: (bloc) {
        verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
      });

  blocTest(
    """
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
          $and User.emailVerified returns false
        $then Calling state.applicationLoginState should return ApplicationLoginState.locked
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    act: (bloc) async {
      fromLoggedOutToEmailAddress();
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback);
      pushPreparedUserToUserChangesStream(notNullUser, false);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    skip: 2,
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.locked,
          email: validEmail)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
          $and User.emailVerified returns true
        $then Calling state.applicationLoginState returns ApplicationLoginState.loggedIn
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    act: (bloc) async {
      fromLoggedOutToEmailAddress();
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback);
      pushPreparedUserToUserChangesStream(notNullUser, true);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    skip: 2,
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.loggedIn,
          email: validEmail)
    ],
  );

  blocTest(
    """
      $given $workingWithAuthStateNotifier
        $and there is signed in user
      $wheN Calling sendEmailToVerifyEmailAddress()
      $then User.sendEmailVerification() has been called
      """,
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    act: (bloc) async {
      fromLoggedOutToEmailAddress();
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback);
      pushPreparedUserToUserChangesStream(notNullUser, false);
      when(firebaseAuth.currentUser).thenReturn(notNullUser);
      sut.sendEmailToVerifyEmailAddress();
    },
    verify: (bloc) {
      verify(notNullUser.sendEmailVerification()).called(1);
    },
    skip: 2,
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.locked,
          email: validEmail)
    ],
  );

  blocTest(
    """
      $given $workingWithAuthStateNotifier
      $wheN Calling updateUser()
      $then User.reload() should be called
      """,
    setUp: () {
      when(firebaseAuth.currentUser).thenReturn(notNullUser);
    },
    build: () => sut,
    act: (bloc) {
      sut.updateUser();
    },
    verify: (bloc) {
      verify(notNullUser.reload()).called(1);
    },
  );

  blocTest(
    """
        $given $workingWithAuthStateNotifier
        $and there is no signed in user
        $wheN Calling cancelRegistration()
        $then Calling logginState should return ApplicationLogginState.emailAddress
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatDoesntContainPasswordMethod();
    },
    build: () => sut,
    act: (bloc) async {
      fromLoggedOutToEmailAddress();
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
      sut.cancelRegistration();
    },
    skip: 2,
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.emailAddress,
          email: null)
    ],
  );

  blocTest("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling registerAccount()
          $and FirebaseAuthException has been thrown
        $then the errorCallback() should be called
""",
      setUp: () {
        prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatDoesntContainPasswordMethod();
        when(firebaseAuth.createUserWithEmailAndPassword(
                email: validEmail, password: password))
            .thenThrow(firebaseAuthException);
      },
      build: () => sut,
      act: (bloc) async {
        fromLoggedOutToEmailAddress();
        await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
        sut.registerAccount(
            validEmail, password, displayName, firebaseAuthExceptionCallback);
      },
      verify: (bloc) {
        verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
      });

  blocTest(
    """
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling registerAccount() with valid, not-already-used email and 
                non-weak password
        $then firebaseAuth.createUserWithEmailAndPassword() should be called once
          $and User.updateDisplayName() has been called
          $and User.sendEmailVerification() has been called
          $and Calling state.applicationLoginState should return ApplicationLoginState.locked
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatDoesntContainPasswordMethod();
      when(userCredential.user).thenReturn(notNullUser);
      when(firebaseAuth.createUserWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    act: (bloc) async {
      fromLoggedOutToEmailAddress();
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
      pushPreparedUserToUserChangesStream(notNullUser, false);
      await sut.registerAccount(
          validEmail, password, displayName, firebaseAuthExceptionCallback);
    },
    verify: (bloc) {
      verify(firebaseAuth.createUserWithEmailAndPassword(
              email: validEmail, password: password))
          .called(1);
      verify(notNullUser.updateDisplayName(displayName)).called(1);
      verify(notNullUser.sendEmailVerification()).called(1);
    },
    skip: 2,
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.locked,
          email: validEmail)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthStateNotifier
          $and Calling state.applicationLoginState returns ApplicationLoginState.loggedIn
        $wheN Calling signOut()
        $then Calling state.applicationLoginState returns ApplicationLoginState.loggedOut
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    act: (bloc) async {
      fromLoggedOutToEmailAddress();
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback);
      pushPreparedUserToUserChangesStream(notNullUser, true);
      await sut.signOut();
      pushPreparedUserToUserChangesStream(nullUser);
    },
    verify: (bloc) {
      verify(firebaseAuth.signOut()).called(1);
    },
    skip: 2,
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.loggedIn,
          email: validEmail),
      const AuthState(
          applicationLoginState: ApplicationLoginState.loggedOut, email: null)
    ],
  );

  blocTest(
    """
      $given $workingWithAuthStateNotifier
      $wheN Calling resetPassword()
        $and FirebaseAuthException has been thrown
      $then the errorCallback should be called
      """,
    setUp: () {
      when(firebaseAuth.sendPasswordResetEmail(email: validEmail))
          .thenThrow(firebaseAuthException);
    },
    build: () => sut,
    act: (bloc) {
      sut.resetPassword(validEmail, firebaseAuthExceptionCallback);
    },
    verify: (bloc) {
      verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
    },
  );

  blocTest(
    """
        $given $workingWithAuthStateNotifier
        $wheN Calling resetPassword()
        $then Firebase.instance.sendPasswordResetEmail has been called
      """,
    setUp: () {
      when(firebaseAuth.sendPasswordResetEmail(email: validEmail))
          .thenAnswer((realInvocation) => Completer<void>().future);
    },
    build: () => sut,
    act: (bloc) {
      sut.resetPassword(validEmail, firebaseAuthExceptionCallback);
    },
    verify: (bloc) {
      verify(firebaseAuth.sendPasswordResetEmail(email: validEmail)).called(1);
    },
  );

  blocTest(
    """
        $given $workingWithAuthStateNotifier
          $and Calling state.applicationLoginState returns ApplicationLoginState.locked
        $wheN Calling signOut()
        $then Calling state.applicationLoginState returns ApplicationLoginState.loggedOut
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    act: (bloc) async {
      fromLoggedOutToEmailAddress();
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback);
      pushPreparedUserToUserChangesStream(notNullUser, false);
      await sut.signOut();
      pushPreparedUserToUserChangesStream(nullUser);
    },
    verify: (bloc) {
      verify(firebaseAuth.signOut()).called(1);
    },
    skip: 2,
    expect: () => [
      const AuthState(
          applicationLoginState: ApplicationLoginState.locked,
          email: validEmail),
      const AuthState(
          applicationLoginState: ApplicationLoginState.loggedOut, email: null)
    ],
  );
}

void pushPreparedUserToUserChangesStream(User? user,
    [bool emailVerified = false]) {
  if (user != null) {
    when(user.emailVerified).thenReturn(emailVerified);
    when(user.email).thenReturn(validEmail);
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
