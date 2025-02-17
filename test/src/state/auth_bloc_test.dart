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
import 'auth_bloc_test.mocks.dart';

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
const passswordExceptionMessage =
    "To sign in you need to be at password stage!";
const registerExceptionMessage =
    "To register you need to be at register stage!";
const cancelRegisterExceptionMessage =
    "To cancel registration you need to be at register stage!";
const verifyEmailExceptionMessage =
    "To verify the email you need to be at emailAddress stage!";
const lockedState = AuthState(
    applicationAuthState: ApplicationAuthState.locked, email: validEmail);
const signedOutState = AuthState(
    applicationAuthState: ApplicationAuthState.signedOut, email: null);
const signedInState = AuthState(
    applicationAuthState: ApplicationAuthState.signedIn, email: validEmail);
const passwordState =
    AuthState(applicationAuthState: ApplicationAuthState.password, email: null);
const registerState =
    AuthState(applicationAuthState: ApplicationAuthState.register, email: null);
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
        $wheN calling startRegistration()
        $then $theResultStateIs $registerState
      """,
    build: () => sut,
    act: (bloc) {
      sut.startRegistration();
    },
    expect: () => [registerState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and there is no signed in user
        $wheN calling startSigningIn()
        $then $theResultStateIs $passwordState
      """,
    build: () => sut,
    act: (bloc) {
      sut.startSigningIn();
    },
    expect: () => [passwordState],
  );

  blocTest("""
        $given $workingWithAuthBloc
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword()
          $and FirebaseAuthException has been thrown
        $then the errorCallback() should be called
""",
      setUp: () {
        when(firebaseAuth.signInWithEmailAndPassword(
                email: invalidEmail, password: password))
            .thenThrow(firebaseAuthException);
      },
      build: () => sut,
      seed: () => passwordState,
      act: (bloc) async {
        await sut.signInWithEmailAndPassword(
            invalidEmail, password, firebaseAuthExceptionCallback.call);
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
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    seed: () => passwordState,
    act: (bloc) async {
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback.call);
      pushPreparedUserToUserChangesStream(notNullUser, false);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    expect: () => [lockedState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and tha AuthBloc instance is closed 
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
          $and User.emailVerified returns false
        $then nothing happen to the current state
      """,
    setUp: () {
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    seed: () => passwordState,
    act: (bloc) async {
      await sut.close();
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback.call);
      pushPreparedUserToUserChangesStream(notNullUser, false);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    expect: () => [],
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
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    seed: () => passwordState,
    act: (bloc) async {
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback.call);
      pushPreparedUserToUserChangesStream(notNullUser, true);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    expect: () => [signedInState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and tha AuthBloc instance is closed 
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
          $and User.emailVerified returns true
        $then nothing happen to the current state
      """,
    setUp: () {
      when(firebaseAuth.signInWithEmailAndPassword(
              email: validEmail, password: password))
          .thenAnswer((realInvocation) => Future.value(userCredential));
    },
    build: () => sut,
    seed: () => passwordState,
    act: (bloc) async {
      await sut.close();
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback.call);
      pushPreparedUserToUserChangesStream(notNullUser, true);
    },
    verify: (bloc) {
      verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
    },
    expect: () => [],
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
        final result = await sut.registerAccount(validEmail, password,
            displayName, firebaseAuthExceptionCallback.call);
        expect(result, false);
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
      final result = await sut.registerAccount(validEmail, password,
          displayName, firebaseAuthExceptionCallback.call);
      pushPreparedUserToUserChangesStream(notNullUser, false);
      expect(result, true);
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
          $and tha AuthBloc instance is closed 
          $and there is no signed in user
        $wheN Calling registerAccount() with valid, not-already-used email and 
                non-weak password
        $then firebaseAuth.createUserWithEmailAndPassword() should be called once
          $and User.updateDisplayName() has been called
          $and User.sendEmailVerification() has been called
        $then nothing happen to the current state
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
      await bloc.close();
      final result = await sut.registerAccount(validEmail, password,
          displayName, firebaseAuthExceptionCallback.call);
      pushPreparedUserToUserChangesStream(notNullUser, false);
      expect(result, true);
    },
    verify: (bloc) {
      verify(firebaseAuth.createUserWithEmailAndPassword(
              email: validEmail, password: password))
          .called(1);
      verify(notNullUser.updateDisplayName(displayName)).called(1);
      verify(notNullUser.sendEmailVerification()).called(1);
    },
    expect: () => [],
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
    expect: () => [signedOutState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and tha AuthBloc instance is closed 
          $and $theCurrentStateIs $signedInState
        $wheN Calling signOut()
        $then nothing happen to the current state
""",
    build: () => sut,
    seed: () => signedInState,
    act: (bloc) async {
      await sut.close();
      await sut.signOut();
      pushPreparedUserToUserChangesStream(nullUser);
    },
    verify: (bloc) {
      verify(firebaseAuth.signOut()).called(1);
    },
    expect: () => [],
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
      sut.resetPassword(validEmail, firebaseAuthExceptionCallback.call);
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
      sut.resetPassword(validEmail, firebaseAuthExceptionCallback.call);
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
          $and tha AuthBloc instance is closed 
          $and $theCurrentStateIs $lockedState
        $wheN Calling signOut()
        $then nothing happen to the current state
""",
    build: () => sut,
    seed: () => lockedState,
    act: (bloc) async {
      await bloc.close();
      await sut.signOut();
      pushPreparedUserToUserChangesStream(nullUser);
    },
    verify: (bloc) {
      verify(firebaseAuth.signOut()).called(1);
    },
    expect: () => [],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
        $wheN Calling toSignedOut()
        $then $theResultStateIs $signedOutState
""",
    build: () => sut,
    seed: () => passwordState,
    act: (bloc) async {
      sut.toSignedOut();
    },
    expect: () => [signedOutState],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
        $wheN Calling toSignedOut()
        $then $theResultStateIs $signedOutState
""",
    build: () => sut,
    seed: () => registerState,
    act: (bloc) async {
      sut.toSignedOut();
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

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $signedOutState
        $wheN Calling signInWithUsernameAndPassword()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => signedOutState,
    act: (bloc) async {
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback.call);
    },
    errors: () => [
      predicate(
          (e) => e is StateError && e.message == passswordExceptionMessage)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $signedInState
        $wheN Calling signInWithUsernameAndPassword()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => signedInState,
    act: (bloc) async {
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback.call);
    },
    errors: () => [
      predicate(
          (e) => e is StateError && e.message == passswordExceptionMessage)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $registerState
        $wheN Calling signInWithUsernameAndPassword()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => registerState,
    act: (bloc) async {
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback.call);
    },
    errors: () => [
      predicate(
          (e) => e is StateError && e.message == passswordExceptionMessage)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $lockedState
        $wheN Calling signInWithUsernameAndPassword()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => lockedState,
    act: (bloc) async {
      await sut.signInWithEmailAndPassword(
          validEmail, password, firebaseAuthExceptionCallback.call);
    },
    errors: () => [
      predicate(
          (e) => e is StateError && e.message == passswordExceptionMessage)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $signedOutState
        $wheN Calling registerAccount()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => signedOutState,
    act: (bloc) async {
      await sut.registerAccount(validEmail, password, displayName,
          firebaseAuthExceptionCallback.call);
    },
    errors: () => [
      predicate((e) => e is StateError && e.message == registerExceptionMessage)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $signedInState
        $wheN Calling registerAccount()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => signedInState,
    act: (bloc) async {
      await sut.registerAccount(validEmail, password, displayName,
          firebaseAuthExceptionCallback.call);
    },
    errors: () => [
      predicate((e) => e is StateError && e.message == registerExceptionMessage)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $passwordState
        $wheN Calling registerAccount()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => passwordState,
    act: (bloc) async {
      await sut.registerAccount(validEmail, password, displayName,
          firebaseAuthExceptionCallback.call);
    },
    errors: () => [
      predicate((e) => e is StateError && e.message == registerExceptionMessage)
    ],
  );

  blocTest(
    """
        $given $workingWithAuthBloc
          $and $theCurrentStateIs $lockedState
        $wheN Calling registerAccount()
        $then StateError should be thrown
""",
    build: () => sut,
    seed: () => lockedState,
    act: (bloc) async {
      await sut.registerAccount(validEmail, password, displayName,
          firebaseAuthExceptionCallback.call);
    },
    errors: () => [
      predicate((e) => e is StateError && e.message == registerExceptionMessage)
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
