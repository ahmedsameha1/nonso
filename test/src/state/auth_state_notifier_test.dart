import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/state/auth_state_notifier.dart';
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
const workingWithAuthStateNotifier = "Working with AuthStateNotifier class";
const callingStartLoginFlow = "Calling startLoginFlow()";
late AuthStateNotifier sut;
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
    sut = AuthStateNotifier(firebaseAuth);
  });
  test("""
        $given $workingWithAuthStateNotifier
        $wheN Creating a new AuthStateNotifier instance
          $and there is no signed in user
        $then state.applicationAuthState should return ApplicationLoginState.loggedOut
      """, () async {
    pushPreparedUserToUserChangesStream(nullUser);
    await expectLater(1, 1);
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);
  });

  test("""
        $given $workingWithAuthStateNotifier
        $wheN Creating a new AuthStateNotifier instance
          $and there is a signed in user
          $and User.emailVerified returns true
        $then state.applicationAuthState should return ApplicationLoginState.loggedIn
      """, () async {
    pushPreparedUserToUserChangesStream(notNullUser, true);
    await expectLater(1, 1);
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedIn);
  });

  test("""
        $given $workingWithAuthStateNotifier
        $wheN Creating a new AuthStateNotifier instance
          $and there is a signed in user
          $and User.emailVerified returns false
        $then state.applicationAuthState should return ApplicationLoginState.locked
      """, () async {
    pushPreparedUserToUserChangesStream(notNullUser, false);
    await expectLater(1, 1);
    expect(sut.state.applicationAuthState, ApplicationAuthState.locked);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN calling startLoginFlow()
        $then That state.applicationAuthState returns ApplicationLoginState.emailAddress
      """, fromLoggedOutToEmailAddress);

  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling verifyEmail()
          $and FirebaseAuthException has been thrown
        $then the errorCallback() should be called
""", () {
    when(firebaseAuth.fetchSignInMethodsForEmail(invalidEmail))
        .thenThrow(firebaseAuthException);
    fromLoggedOutToEmailAddress();
    sut.verifyEmail(invalidEmail, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling verifyEmail() with a valid email address
        $then the errorCallback() has NOT been called, which imply that a
          FirebaseAuthException has NOT been thrown
""", () {
    prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
    fromLoggedOutToEmailAddress();
    sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
    verifyNever(firebaseAuthExceptionCallback(firebaseAuthException));
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling verifyEmail with a valid email address
          $and verifyEmail returns a Future of List that contains "password"
        $then state.applicationAuthState should return ApplicationLoginState.password
          $and the email returns the same passed argument email
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    expect(sut.state.email, validEmail);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling verifyEmail with a valid email address
          $and verifyEmail returns a Future of List that doesn't contain "password"
        $then state.applicationAuthState should return ApplicationLoginState.register
          $and the email returns the same passed argument email
""", fromLoggedOutToEmailAddressToRegister);

  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword()
          $and FirebaseAuthException has been thrown
        $then the errorCallback() should be called
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    when(firebaseAuth.signInWithEmailAndPassword(
            email: invalidEmail, password: password))
        .thenThrow(firebaseAuthException);
    sut.signInWithEmailAndPassword(
        invalidEmail, password, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
          $and User.emailVerified returns false
        $then Calling state.applicationAuthState should return ApplicationLoginState.locked
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
          $and User.emailVerified returns true
        $then Calling state.applicationAuthState returns ApplicationLoginState.loggedIn
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLoggedIn();
  });

  test("""
      $given $workingWithAuthStateNotifier
        $and there is signed in user
      $wheN Calling sendEmailToVerifyEmailAddress()
      $then User.sendEmailVerification() has been called
      """, () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    when(firebaseAuth.currentUser).thenReturn(notNullUser);
    await sut.sendEmailToVerifyEmailAddress();
    verify(notNullUser.sendEmailVerification()).called(1);
    expect(sut.state.applicationAuthState, ApplicationAuthState.locked);
  });

  test("""
      $given $workingWithAuthStateNotifier
      $wheN Calling updateUser()
      $then User.reload() should be called
      """, () {
    when(firebaseAuth.currentUser).thenReturn(notNullUser);
    sut.updateUser();
    verify(notNullUser.reload()).called(1);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling cancelRegistration()
        $then Calling logginState should return ApplicationLogginState.emailAddress
""", () async {
    await fromLoggedOutToEmailAddressToRegister();
    sut.cancelRegistration();
    expect(sut.state.applicationAuthState, ApplicationAuthState.emailAddress);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling registerAccount()
          $and FirebaseAuthException has been thrown
        $then the errorCallback() should be called
""", () async {
    await fromLoggedOutToEmailAddressToRegister();
    when(firebaseAuth.createUserWithEmailAndPassword(
            email: validEmail, password: password))
        .thenThrow(firebaseAuthException);
    sut.registerAccount(
        validEmail, password, displayName, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
  });
  test("""
        $given $workingWithAuthStateNotifier
          $and there is no signed in user
        $wheN Calling registerAccount() with valid, not-already-used email and 
                non-weak password
        $then firebaseAuth.createUserWithEmailAndPassword() should be called once
          $and User.updateDisplayName() has been called
          $and User.sendEmailVerification() has been called
          $and Calling state.applicationAuthState should return ApplicationLoginState.locked
""", () async {
    await fromLoggedOutToEmailAddressToRegister();
    when(userCredential.user).thenReturn(notNullUser);
    when(firebaseAuth.createUserWithEmailAndPassword(
            email: validEmail, password: password))
        .thenAnswer((realInvocation) => Future.value(userCredential));
    pushPreparedUserToUserChangesStream(notNullUser, false);
    await sut.registerAccount(
        validEmail, password, displayName, firebaseAuthExceptionCallback);
    verify(firebaseAuth.createUserWithEmailAndPassword(
            email: validEmail, password: password))
        .called(1);
    verify(notNullUser.updateDisplayName(displayName)).called(1);
    verify(notNullUser.sendEmailVerification()).called(1);
    expect(sut.state.applicationAuthState, ApplicationAuthState.locked);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and Calling state.applicationAuthState returns ApplicationLoginState.loggedIn
        $wheN Calling signOut()
        $then Calling state.applicationAuthState returns ApplicationLoginState.loggedOut
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLoggedIn();
    pushPreparedUserToUserChangesStream(nullUser);
    await sut.signOut();
    verify(firebaseAuth.signOut()).called(1);
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);
  });

  test("""
      $given $workingWithAuthStateNotifier
      $wheN Calling resetPassword()
        $and FirebaseAuthException has been thrown
      $then the errorCallback should be called
      """, () {
    when(firebaseAuth.sendPasswordResetEmail(email: validEmail))
        .thenThrow(firebaseAuthException);
    sut.resetPassword(validEmail, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(firebaseAuthException)).called(1);
  });
  test("""
        $given $workingWithAuthStateNotifier
        $wheN Calling resetPassword()
        $then Firebase.instance.sendPasswordResetEmail has been called
      """, () {
    when(firebaseAuth.sendPasswordResetEmail(email: validEmail))
        .thenAnswer((realInvocation) => Completer<void>().future);
    sut.resetPassword(validEmail, firebaseAuthExceptionCallback);
    verify(firebaseAuth.sendPasswordResetEmail(email: validEmail)).called(1);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and Calling state.applicationAuthState returns ApplicationLoginState.locked
        $wheN Calling signOut()
        $then Calling state.applicationAuthState returns ApplicationLoginState.loggedOut
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    pushPreparedUserToUserChangesStream(nullUser);
    await sut.signOut();
    verify(firebaseAuth.signOut()).called(1);
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);
  });

  test("""
        $given $workingWithAuthStateNotifier
        $wheN Calling toLoggedOut()
        $then Calling state.applicationAuthState should return ApplicationLoginState.loggedOut
        """, () async {
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);
    sut.toLoggedOut();
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);

    fromLoggedOutToEmailAddress();
    sut.toLoggedOut();
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);

    await fromLoggedOutToEmailAddressToRegister();
    sut.toLoggedOut();
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);

    await fromLoggedOutToEmailAddressToPassword();
    sut.toLoggedOut();
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);

    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLoggedIn();
    sut.toLoggedOut();
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);

    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    sut.toLoggedOut();
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and Calling state.applicationAuthState returns anything other than ApplicationLoginState.loggedIn & ApplicationLoginState.locked
        $wheN Calling signOut()
        $then StateError should be thrown
""", () async {
    const message = "To sign out you need to sign in first!";
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);
    expectExceptionFromSignOut(sut.signOut, message);
    fromLoggedOutToEmailAddress();
    expectExceptionFromSignOut(sut.signOut, message);
    await fromLoggedOutToEmailAddressToRegister();
    expectExceptionFromSignOut(sut.signOut, message);
    await fromLoggedOutToEmailAddressToPassword();
    expectExceptionFromSignOut(sut.signOut, message);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and Calling state.applicationAuthState returns anything other than ApplicationLoginState.password
        $wheN Calling signInWithUsernameAndPassword()
        $then StateError should be thrown
""", () async {
    const message = "To sign in you need to be at password stage!";
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);
    expectExceptionFromSignInWithEmailAndPassword(
        sut.signInWithEmailAndPassword, message);
    fromLoggedOutToEmailAddress();
    expectExceptionFromSignInWithEmailAndPassword(
        sut.signInWithEmailAndPassword, message);
    fromLoggedOutToEmailAddressToRegister();
    expectExceptionFromSignInWithEmailAndPassword(
        sut.signInWithEmailAndPassword, message);
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLoggedIn();
    expectExceptionFromSignInWithEmailAndPassword(
        sut.signInWithEmailAndPassword, message);
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    expectExceptionFromSignInWithEmailAndPassword(
        sut.signInWithEmailAndPassword, message);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and Calling state.applicationAuthState returns anything other than ApplicationLoginState.register
        $wheN Calling registerAccount()
        $then StateError should be thrown
""", () async {
    const message = "To register you need to be at register stage!";
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);
    expectExceptionFromRegisterAccount(sut.registerAccount, message);
    fromLoggedOutToEmailAddress();
    expectExceptionFromRegisterAccount(sut.registerAccount, message);
    await fromLoggedOutToEmailAddressToPassword();
    expectExceptionFromRegisterAccount(sut.registerAccount, message);
    fromPasswordToLoggedIn();
    expectExceptionFromRegisterAccount(sut.registerAccount, message);
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    expectExceptionFromRegisterAccount(sut.registerAccount, message);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and Calling state.applicationAuthState returns anything other than ApplicationLoginState.register
        $wheN Calling cancelRegistration()
        $then StateError should be thrown
""", () async {
    const message = "To cancel registration you need to be at register stage!";
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);
    expectExceptionFromCancelRegistration(sut.cancelRegistration, message);
    fromLoggedOutToEmailAddress();
    expectExceptionFromCancelRegistration(sut.cancelRegistration, message);
    await fromLoggedOutToEmailAddressToPassword();
    expectExceptionFromCancelRegistration(sut.cancelRegistration, message);
    fromPasswordToLoggedIn();
    expectExceptionFromCancelRegistration(sut.cancelRegistration, message);
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    expectExceptionFromCancelRegistration(sut.cancelRegistration, message);
  });

  test("""
        $given $workingWithAuthStateNotifier
          $and Calling state.applicationAuthState returns anything other than ApplicationLoginState.emailAddress
        $wheN Calling verifyEmail()
        $then StateError should be thrown
""", () async {
    const message = "To verify the email you need to be at emailAddress stage!";
    expect(sut.state.applicationAuthState, ApplicationAuthState.signedOut);
    expectExceptionFromVerifyEmail(sut.verifyEmail, message);
    await fromLoggedOutToEmailAddressToRegister();
    expectExceptionFromVerifyEmail(sut.verifyEmail, message);
    await fromLoggedOutToEmailAddressToPassword();
    expectExceptionFromVerifyEmail(sut.verifyEmail, message);
    await fromPasswordToLoggedIn();
    expectExceptionFromVerifyEmail(sut.verifyEmail, message);
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    expectExceptionFromVerifyEmail(sut.verifyEmail, message);
  });
}

/////////////////////////////////////////////////////////////////////////////////////////////////

void fromLoggedOutToEmailAddress() {
  sut.startLoginFlow();
  expect(sut.state.applicationAuthState, ApplicationAuthState.emailAddress);
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

void pushPreparedUserToUserChangesStream(User? user,
    [bool emailVerified = false]) {
  if (user != null) {
    when(user.emailVerified).thenReturn(emailVerified);
  }
  streamController.sink.add(user);
}

Future<void> fromLoggedOutToEmailAddressToPassword() async {
  fromLoggedOutToEmailAddress();
  prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
  await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
  expect(sut.state.applicationAuthState, ApplicationAuthState.password);
}

Future<void> fromLoggedOutToEmailAddressToRegister() async {
  fromLoggedOutToEmailAddress();
  prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatDoesntContainPasswordMethod();
  await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
  expect(sut.state.applicationAuthState, ApplicationAuthState.register);
  expect(sut.state.email, validEmail);
}

Future<void> fromPasswordToLoggedIn() async {
  when(firebaseAuth.signInWithEmailAndPassword(
          email: validEmail, password: password))
      .thenAnswer((realInvocation) => Future.value(userCredential));
  pushPreparedUserToUserChangesStream(notNullUser, true);
  await sut.signInWithEmailAndPassword(
      validEmail, password, firebaseAuthExceptionCallback);
  expect(sut.state.applicationAuthState, ApplicationAuthState.signedIn);
}

Future<void> fromPasswordToLocked() async {
  when(firebaseAuth.signInWithEmailAndPassword(
          email: validEmail, password: password))
      .thenAnswer((realInvocation) => Future.value(userCredential));
  pushPreparedUserToUserChangesStream(notNullUser, false);
  await sut.signInWithEmailAndPassword(
      validEmail, password, firebaseAuthExceptionCallback);
  expect(sut.state.applicationAuthState, ApplicationAuthState.locked);
}

void expectExceptionFromSignOut(Function() function, String message) {
  expect(() => function(),
      throwsA(predicate((e) => e is StateError && e.message == message)));
}

void expectExceptionFromSignInWithEmailAndPassword(
    Function(String validEmail, String password,
            Function(FirebaseAuthException) func)
        function,
    String message) {
  expect(() => function(validEmail, password, firebaseAuthExceptionCallback),
      throwsA(predicate((e) => e is StateError && e.message == message)));
}

void expectExceptionFromRegisterAccount(
    Function(String validEmail, String password, String displayName,
            Function(FirebaseAuthException) func)
        function,
    String message) {
  expect(
      () => function(
          validEmail, password, displayName, firebaseAuthExceptionCallback),
      throwsA(predicate((e) => e is StateError && e.message == message)));
}

void expectExceptionFromCancelRegistration(
    Function() function, String message) {
  expect(() => function(),
      throwsA(predicate((e) => e is StateError && e.message == message)));
}

void expectExceptionFromVerifyEmail(
    Function(String email, Function(FirebaseAuthException) func) function,
    String message) {
  expect(() => function(validEmail, firebaseAuthExceptionCallback),
      throwsA(predicate((e) => e is StateError && e.message == message)));
}
