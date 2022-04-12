import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nonso/src/application_state.dart';

import 'application_state_test.mocks.dart';
import 'test_constants.dart';

abstract class FirebaseInitializeAppFunction {
  Future<FirebaseApp>? call({String? name, FirebaseOptions? options});
}

abstract class ProviderNotifiyListenerFunction {
  void call();
}

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
const workingWithApplicationState = "Working with ApplicationState class";
const notifyListenersCalled =
    "ChangeNotifier.notifyListeners() has been called";
const callingStartLoginFlow = "Calling startLoginFlow()";
late ApplicationState sut;
final firebaseAuthExceptionCallback =
    MockFirebaseAuthExceptionErrorCallbackFunction();
final notifyListenerCall = MockProviderNotifiyListenerFunction();

@GenerateMocks([
  ProviderNotifiyListenerFunction,
  FirebaseAuthExceptionErrorCallbackFunction,
  FirebaseAuth,
  UserCredential,
  User
], customMocks: [
  MockSpec<FirebaseInitializeAppFunction>(returnNullOnMissingStub: true)
])
main() {
  final initializeCall = MockFirebaseInitializeAppFunction();
  final invalidEmailException = FirebaseAuthException(code: "invalid-email");
  final userDisabledException = FirebaseAuthException(code: "user-disabled");
  final userNotFoundException = FirebaseAuthException(code: "user-not-found");
  final wrongPasswordException = FirebaseAuthException(code: "wrong-password");
  final operationNotAllowedException =
      FirebaseAuthException(code: "operation-not-allowed");
  final weakPasswordException = FirebaseAuthException(code: "weak-password");
  final emailAlreadyInUseException =
      FirebaseAuthException(code: "email-already-in-use");
  const User? nullUser = null;
  final User? notNullUser = MockUser();

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    sut = ApplicationState(firebaseAuth, initializeCall)
      ..addListener(notifyListenerCall);
    userCredential = MockUserCredential();
    prepareUserChangesForTest(notNullUser);
    reset(notifyListenerCall);
  });

  test("""
        $given $workingWithApplicationState
        $wheN Creating a new ApplicationState instance
        $then Firbase.initializeApp() should be called
          $and loginState should return ApplicationLoginState.loggedOut
      """, () {
    verify(initializeCall()).called(1);
    expect(sut.loginState, ApplicationLoginState.loggedOut);
  });
  test("""
        $given $workingWithApplicationState
        $wheN $callingStartLoginFlow
        $then That loginState returns ApplicationLoginState.emailAddress
          $and $notifyListenersCalled
      """, fromLoggedOutToEmailAddress);
  test("""
        $given $workingWithApplicationState
        $wheN Calling verifyEmail() with an invalid email address
        $then the errorCallback() has been called, which imply that a
          FirebaseAuthException has been thrown
""", () {
    when(firebaseAuth.fetchSignInMethodsForEmail(invalidEmail))
        .thenThrow(invalidEmailException);
    fromLoggedOutToEmailAddress();
    sut.verifyEmail(invalidEmail, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(invalidEmailException)).called(1);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling verifyEmail() with a valid email address
        $then the errorCallback() has NOT been called, which imply that a
          FirebaseAuthException has NOT been thrown
""", () {
    fromLoggedOutToEmailAddress();
    prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
    sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
    verifyNever(firebaseAuthExceptionCallback(invalidEmailException));
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling verifyEmail with a valid email address
          $and verifyEmail returns a Future of List that contains "password"
        $then loginState should return ApplicationLoginState.password
          $and the email returns the same passed argument email
          $and $notifyListenersCalled
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    expect(sut.email, validEmail);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling verifyEmail with a valid email address
          $and verifyEmail returns a Future of List that doesn't contain "password"
        $then loginState should return ApplicationLoginState.register
          $and the email returns the same passed argument email
          $and $notifyListenersCalled
""", fromLoggedOutToEmailAddressToRegister);
  test("""
        $given $workingWithApplicationState
        $wheN Calling signInWithEmailAndPassword() with invalid email
          $or Calling signInWithEmailAndPassword() with an email that belongs to
                a disabled user
          $or Calling signInWithEmailAndPassword() with an email that belogns to 
                no user
          $or Calling signInWithEmailAndPassword() with an invalid password for 
                the given email or the account of the email doesn't have a 
                password set
        $then errorCallback() should be called, and this imply tha an exception 
                has been thrown
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    when(firebaseAuth.signInWithEmailAndPassword(
            email: invalidEmail, password: password))
        .thenThrow(invalidEmailException);
    sut.signInWithEmailAndPassword(
        invalidEmail, password, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(invalidEmailException)).called(1);
    when(firebaseAuth.signInWithEmailAndPassword(
            email: validEmail, password: password))
        .thenThrow(userDisabledException);
    sut.signInWithEmailAndPassword(
        validEmail, password, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(userDisabledException)).called(1);
    when(firebaseAuth.signInWithEmailAndPassword(
            email: validEmail, password: password))
        .thenThrow(userNotFoundException);
    sut.signInWithEmailAndPassword(
        validEmail, password, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(userNotFoundException)).called(1);
    when(firebaseAuth.signInWithEmailAndPassword(
            email: validEmail, password: password))
        .thenThrow(wrongPasswordException);
    sut.signInWithEmailAndPassword(
        validEmail, password, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(wrongPasswordException)).called(1);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
        $then calling loginState should return ApplicationLoginState.loggedIn
          $and $notifyListenersCalled
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLoggedIn();
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling cancelRegistration()
        $then Calling logginState should return ApplicationLogginState.emailAddress
          $and $notifyListenersCalled
""", () async {
    await fromLoggedOutToEmailAddressToRegister();
    sut.cancelRegistration();
    expect(sut.loginState, ApplicationLoginState.emailAddress);
    verify(notifyListenerCall()).called(1);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling registerAccount() with an email that already used in an 
                account
          $or Calling registerAccount() with an invalid email
          $or Calling registerAccount() while email/password accounts are not enabled
          $or Calling registerAccount() with weak password
        $then errorCallback() should be called, which imply that 
                FirebaseAuthException has been thrown
""", () async {
    await fromLoggedOutToEmailAddressToRegister();
    when(firebaseAuth.createUserWithEmailAndPassword(
            email: validEmail, password: password))
        .thenThrow(emailAlreadyInUseException);
    sut.registerAccount(
        validEmail, password, displayName, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(emailAlreadyInUseException)).called(1);
    /////
    when(firebaseAuth.createUserWithEmailAndPassword(
            email: invalidEmail, password: password))
        .thenThrow(invalidEmailException);
    sut.registerAccount(
        invalidEmail, password, displayName, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(invalidEmailException)).called(1);
    /////
    when(firebaseAuth.createUserWithEmailAndPassword(
            email: validEmail, password: password))
        .thenThrow(operationNotAllowedException);
    sut.registerAccount(
        validEmail, password, displayName, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(operationNotAllowedException))
        .called(1);
    ////
    when(firebaseAuth.createUserWithEmailAndPassword(
            email: validEmail, password: weakPassword))
        .thenThrow(weakPasswordException);
    sut.registerAccount(
        validEmail, weakPassword, displayName, firebaseAuthExceptionCallback);
    verify(firebaseAuthExceptionCallback(weakPasswordException)).called(1);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling registerAccount() with valid, not-already-used email and 
                non-weak password
        $then firebaseAuth.createUserWithEmailAndPassword() should be called once
          $and User.updateDisplayName() has been called
""", () async {
    await fromLoggedOutToEmailAddressToRegister();
    when(notNullUser!.updateDisplayName(displayName))
        .thenAnswer((realInvocation) => Completer<void>().future);
    when(userCredential.user).thenReturn(notNullUser);
    when(firebaseAuth.createUserWithEmailAndPassword(
            email: validEmail, password: password))
        .thenAnswer((realInvocation) => Future.value(userCredential));
    await sut.registerAccount(
        validEmail, password, displayName, firebaseAuthExceptionCallback);
    verify(firebaseAuth.createUserWithEmailAndPassword(
            email: validEmail, password: password))
        .called(1);
    verify(notNullUser.updateDisplayName(displayName)).called(1);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling signInWithEmailAndPassword()
          $and Calling loginState returns ApplicationLoginState.loggedIn
          $and Calling signOut()
        $then Calling loginState returns ApplicationLoginState.loggedOut
          $and $notifyListenersCalled
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    when(firebaseAuth.signInWithEmailAndPassword(
            email: validEmail, password: password))
        .thenAnswer((realInvocation) => Future.value(userCredential));
    await sut.signInWithEmailAndPassword(
        validEmail, password, firebaseAuthExceptionCallback);
    expect(sut.loginState, ApplicationLoginState.loggedIn);
    reset(notifyListenerCall);
    prepareUserChangesForTest(nullUser);
    await sut.signOut();
    verify(firebaseAuth.signOut()).called(1);
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    verify(notifyListenerCall()).called(1);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling signInWithEmailAndPassword()
          $and Calling loginState returns ApplicationLoginState.loggedIn
          $and Calling signOut()
          $and Calling loginState returns ApplicationLoginState.loggedOut
          $and Calling signInWithEmailAndPassword()
        $then Calling loginState should return ApplicationLogginState.loggedIn
          $and $notifyListenersCalled
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    when(firebaseAuth.signInWithEmailAndPassword(
            email: validEmail, password: password))
        .thenAnswer((realInvocation) => Future.value(userCredential));
    await sut.signInWithEmailAndPassword(
        validEmail, password, firebaseAuthExceptionCallback);
    expect(sut.loginState, ApplicationLoginState.loggedIn);
    reset(notifyListenerCall);
    prepareUserChangesForTest(nullUser);
    await sut.signOut();
    verify(firebaseAuth.signOut()).called(1);
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    reset(notifyListenerCall);
    prepareUserChangesForTest(notNullUser);
    await fromLoggedOutToEmailAddressToPassword();
    when(firebaseAuth.signInWithEmailAndPassword(
            email: validEmail, password: password))
        .thenAnswer((realInvocation) => Future.value(userCredential));
    await sut.signInWithEmailAndPassword(
        validEmail, password, firebaseAuthExceptionCallback);
    expect(sut.loginState, ApplicationLoginState.loggedIn);
    verify(notifyListenerCall()).called(1);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling loginState returns anything other than ApplicationLoginState.loggedIn
        $then Calling signOut() should throw StateError
""", () async {
    const message = "To sign out you need to sign in first!";
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    expectExceptionFromSignOut(sut.signOut, message);
    fromLoggedOutToEmailAddress();
    expectExceptionFromSignOut(sut.signOut, message);
    await fromLoggedOutToEmailAddressToRegister();
    expectExceptionFromSignOut(sut.signOut, message);
    await fromLoggedOutToEmailAddressToPassword();
    expectExceptionFromSignOut(sut.signOut, message);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling loginState returns anything other than ApplicationLoginState.password
        $then Calling signInWithUsernameAndPassword() should throw StateError
""", () async {
    const message = "To sign in you need to be at password stage!";
    expect(sut.loginState, ApplicationLoginState.loggedOut);
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
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling loginState returns anything other than ApplicationLoginState.register
        $then Calling registerAccount() should throw StateError
""", () async {
    const message = "To register you need to be at register stage!";
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    expectExceptionFromRegisterAccount(sut.registerAccount, message);
    fromLoggedOutToEmailAddress();
    expectExceptionFromRegisterAccount(sut.registerAccount, message);
    await fromLoggedOutToEmailAddressToPassword();
    expectExceptionFromRegisterAccount(sut.registerAccount, message);
    fromPasswordToLoggedIn();
    expectExceptionFromRegisterAccount(sut.registerAccount, message);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling loginState returns anything other than ApplicationLoginState.register
        $then Calling cancelRegistration() should throw StateError
""", () async {
    const message = "To cancel registration you need to be at register stage!";
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    expectExceptionFromCancelRegistration(sut.cancelRegistration, message);
    fromLoggedOutToEmailAddress();
    expectExceptionFromCancelRegistration(sut.cancelRegistration, message);
    await fromLoggedOutToEmailAddressToPassword();
    expectExceptionFromCancelRegistration(sut.cancelRegistration, message);
    fromPasswordToLoggedIn();
    expectExceptionFromCancelRegistration(sut.cancelRegistration, message);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Calling loginState returns anything other than ApplicationLoginState.emailAddress
        $then Calling verifyEmail() should throw StateError
""", () async {
    const message = "To verify the email you need to be at emailAddress stage!";
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    expectExceptionFromVerifyEmail(sut.verifyEmail, message);
    await fromLoggedOutToEmailAddressToRegister();
    expectExceptionFromVerifyEmail(sut.verifyEmail, message);
    await fromLoggedOutToEmailAddressToPassword();
    expectExceptionFromVerifyEmail(sut.verifyEmail, message);
    await fromPasswordToLoggedIn();
    expectExceptionFromVerifyEmail(sut.verifyEmail, message);
  });
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

void prepareUserChangesForTest(User? user) {
  when(firebaseAuth.userChanges())
      .thenAnswer((realInvocation) => Stream.value(user));
}

Future<void> fromLoggedOutToEmailAddressToPassword() async {
  fromLoggedOutToEmailAddress();
  prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatContainsPasswordMethod();
  await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
  expect(sut.loginState, ApplicationLoginState.password);
  verify(notifyListenerCall()).called(1);
  reset(notifyListenerCall);
}

Future<void> fromLoggedOutToEmailAddressToRegister() async {
  fromLoggedOutToEmailAddress();
  prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatDoesntContainPasswordMethod();
  await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
  expect(sut.loginState, ApplicationLoginState.register);
  expect(sut.email, validEmail);
  verify(notifyListenerCall()).called(1);
  reset(notifyListenerCall);
}

void fromLoggedOutToEmailAddress() {
  sut.startLoginFlow();
  expect(sut.loginState, ApplicationLoginState.emailAddress);
  verify(notifyListenerCall()).called(1);
  reset(notifyListenerCall);
}

Future<void> fromPasswordToLoggedIn() async {
  when(firebaseAuth.signInWithEmailAndPassword(
          email: validEmail, password: password))
      .thenAnswer((realInvocation) => Future.value(userCredential));
  await sut.signInWithEmailAndPassword(
      validEmail, password, firebaseAuthExceptionCallback);
  expect(sut.loginState, ApplicationLoginState.loggedIn);
  verify(notifyListenerCall()).called(1);
  reset(notifyListenerCall);
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
