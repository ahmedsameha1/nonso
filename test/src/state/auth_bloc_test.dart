import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';

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
const workingWithAuthBloc = "Working with AuthBloc class";
const theCurrentStateIs = "the current state is";
const theResultStateIs = "the result state is";
const callingStart = "Calling start()";
const signOutExceptionMessage = "To sign out you need to sign in first!";
const lockedState = AuthState(
    applicationAuthState: ApplicationAuthState.locked, email: validEmail);
const emailAddressState = AuthState(
    applicationAuthState: ApplicationAuthState.emailAddress, email: null);
const signedOutState = AuthState(
    applicationAuthState: ApplicationAuthState.signedOut, email: null);
const signedInState = AuthState(
    applicationAuthState: ApplicationAuthState.signedIn, email: validEmail);
const passwordState = AuthState(
    applicationAuthState: ApplicationAuthState.password, email: validEmail);
const registerState = AuthState(
    applicationAuthState: ApplicationAuthState.register, email: validEmail);
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
        $given $workingWithAuthBloc
        $wheN Creating a new AuthBloc instance
          $and there is no signed in user
        $then $theResultStateIs $signedOutState
      """, () async {
    pushPreparedUserToUserChangesStream(nullUser);
    await expectLater(1, 1);
    expect(sut.state, signedOutState);
  });

  blocTest(
    """
        $given $workingWithAuthBloc
        $wheN Creating a new AuthBloc instance
          $and there is a signed in user
          $and User.emailVerified returns true
        $then $theResultStateIs $signedInState
      """,
    build: () => sut,
    setUp: () {
      pushPreparedUserToUserChangesStream(notNullUser, true);
    },
    expect: () => [signedInState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
        $wheN Creating a new AuthBloc instance
          $and there is a signed in user
          $and User.emailVerified returns false
        $then $theResultStateIs $lockedState
      """,
    build: () => sut,
    setUp: () {
      pushPreparedUserToUserChangesStream(notNullUser, false);
    },
    expect: () => [lockedState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and there is no signed in user
        $wheN calling start()
        $then $theResultStateIs $emailAddressState
      """,
    build: () => sut,
    act: (bloc) {
      fromsignedOutToEmailAddress();
    },
    expect: () => [emailAddressState],
  );

  blocTest("""
        $given $workingWithAuthBloc
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
      seed: () => emailAddressState,
      act: (bloc) async {
        await sut.verifyEmail(invalidEmail, firebaseAuthExceptionCallback);
      },
      verify: (bloc) {
        verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
      });

  blocTest(
    """
        $given $workingWithAuthBloc
          $and there is no signed in user
        $wheN Calling verifyEmail() with a valid email address
        $then the errorCallback() has NOT been called, which imply that a
          FirebaseAuthException has NOT been thrown
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
    },
    build: () => sut,
    seed: () => emailAddressState,
    act: (bloc) async {
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    expect: () => [passwordState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and there is no signed in user
        $wheN Calling verifyEmail with a valid email address
          $and verifyEmail returns a Future of List that doesn't contain "password"
        $then $theResultStateIs $registerState
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatDoesntContainPasswordMethod();
    },
    build: () => sut,
    seed: () => emailAddressState,
    act: (bloc) async {
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    expect: () => [registerState],
  );

  blocTest("""
        $given $workingWithAuthBloc
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
      seed: () => emailAddressState,
      act: (bloc) async {
        await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
        await sut.signInWithEmailAndPassword(
            invalidEmail, password, firebaseAuthExceptionCallback);
      },
      verify: (bloc) {
        verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
      });

  blocTest(
    """
        $given $workingWithAuthBloc
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
          $and User.emailVerified returns false
        $then $theResultStateIs $lockedState
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    seed: () => emailAddressState,
    act: (bloc) async {
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback);
      pushPreparedUserToUserChangesStream(notNullUser, false);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    skip: 1,
    expect: () => [lockedState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
          $and User.emailVerified returns true
        $then $theResultStateIs $signedInState
""",
    setUp: () {
      prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    seed: () => emailAddressState,
    act: (bloc) async {
      await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback);
      pushPreparedUserToUserChangesStream(notNullUser, true);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    skip: 1,
    expect: () => [signedInState],
  );

  blocTest("""
      $given $workingWithAuthBloc
        $and there is signed in user
      $wheN Calling sendEmailToVerifyEmailAddress()
      $then User.sendEmailVerification() has been called
      """,
      setUp: () {
        when(firebaseAuth.currentUser).thenReturn(notNullUser);
      },
      build: () => sut,
      seed: () => lockedState,
      act: (bloc) async {
        sut.sendEmailToVerifyEmailAddress();
      },
      verify: (bloc) {
        verify(notNullUser.sendEmailVerification()).called(1);
      });

  blocTest(
    """
      $given $workingWithAuthBloc
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
        $given $workingWithAuthBloc
        $and there is no signed in user
        $wheN Calling cancelRegistration()
        $then $theResultStateIs $emailAddressState
""",
    build: () => sut,
    seed: () => registerState,
    act: (bloc) async {
      sut.cancelRegistration();
    },
    expect: () => [emailAddressState],
  );

  blocTest("""
        $given $workingWithAuthBloc
          $and there is no signed in user
        $wheN Calling registerAccount()
          $and FirebaseAuthException has been thrown
        $then the errorCallback() should be called
""",
      setUp: () {
        when(firebaseAuth.createUserWithEmailAndPassword(
                email: validEmail, password: password))
            .thenThrow(firebaseAuthException);
      },
      build: () => sut,
      seed: () => registerState,
      act: (bloc) async {
        sut.registerAccount(
            validEmail, password, displayName, firebaseAuthExceptionCallback);
      },
      verify: (bloc) {
        verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
      });

  blocTest(
    """
        $given $workingWithAuthBloc
          $and there is no signed in user
        $wheN Calling registerAccount() with valid, not-already-used email and 
                non-weak password
        $then firebaseAuth.createUserWithEmailAndPassword() should be called once
          $and User.updateDisplayName() has been called
          $and User.sendEmailVerification() has been called
        $then $theResultStateIs $lockedState
""",
    setUp: () {
      when(userCredential.user).thenReturn(notNullUser);
      when(firebaseAuth.createUserWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    seed: () => registerState,
    act: (bloc) async {
      await sut.registerAccount(
          validEmail, password, displayName, firebaseAuthExceptionCallback);
      pushPreparedUserToUserChangesStream(notNullUser, false);
    },
    verify: (bloc) {
      verify(firebaseAuth.createUserWithEmailAndPassword(
              email: validEmail, password: password))
          .called(1);
      verify(notNullUser.updateDisplayName(displayName)).called(1);
      verify(notNullUser.sendEmailVerification()).called(1);
    },
    expect: () => [lockedState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $signedInState
        $wheN Calling signOut()
        $then $theResultStateIs $signedOutState
""",
    build: () => sut,
    seed: () => signedInState,
    act: (bloc) async {
      await sut.signOut();
      pushPreparedUserToUserChangesStream(nullUser);
    },
    verify: (bloc) {
      verify(firebaseAuth.signOut()).called(1);
    },
    expect: () => [
      signedOutState,
    ],
  );

  blocTest(
    """
      $given $workingWithAuthBloc
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
        $given $workingWithAuthBloc
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
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $lockedState
        $wheN Calling signOut()
        $then $theResultStateIs $signedOutState
""",
    build: () => sut,
    seed: () => lockedState,
    act: (bloc) async {
      await sut.signOut();
      pushPreparedUserToUserChangesStream(nullUser);
    },
    verify: (bloc) {
      verify(firebaseAuth.signOut()).called(1);
    },
    expect: () => [signedOutState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $signedOutState
        $wheN Calling signOut()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => signedOutState,
    act: (bloc) async {
      await sut.signOut();
    },
    errors: () => [
      predicate((e) => e is StateError && e.message == signOutExceptionMessage)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $emailAddressState
        $wheN Calling signOut()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => emailAddressState,
    act: (bloc) async {
      await sut.signOut();
    },
    errors: () => [
      predicate((e) => e is StateError && e.message == signOutExceptionMessage)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $passwordState
        $wheN Calling signOut()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => passwordState,
    act: (bloc) async {
      await sut.signOut();
    },
    errors: () => [
      predicate((e) => e is StateError && e.message == signOutExceptionMessage)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $registerState
        $wheN Calling signOut()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => registerState,
    act: (bloc) async {
      await sut.signOut();
    },
    errors: () => [
      predicate((e) => e is StateError && e.message == signOutExceptionMessage)
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

void fromsignedOutToEmailAddress() {
  sut.start();
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
