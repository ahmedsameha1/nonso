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
final notifyListenersCall = MockProviderNotifiyListenerFunction();
const User? nullUser = null;
final User notNullUser = MockUser();
late StreamController<User?> streamController;

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
  final firebaseAuthException = FirebaseAuthException(code: "code");

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    sut = ApplicationState(firebaseAuth, initializeCall)
      ..addListener(notifyListenersCall);
    userCredential = MockUserCredential();
    streamController = StreamController();
    when(firebaseAuth.userChanges())
        .thenAnswer((ri) => streamController.stream);
    reset(notifyListenersCall);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Creating a new ApplicationState instance
          $and there is no signed in user
        $then Firbase.initializeApp() should be called
          $and loginState should return ApplicationLoginState.loggedOut
          $and $notifyListenersCalled
      """, () async {
    verify(initializeCall()).called(1);
    pushPreparedUserToUserChangesStream(nullUser);
    await expectLater(1, 1);
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    verify(notifyListenersCall()).called(1);
  });
  test("""
        $given $workingWithApplicationState
        $wheN Creating a new ApplicationState instance
          $and there is a signed in user
          $and User.emailVerified returns true
        $then Firbase.initializeApp() should be called
          $and loginState should return ApplicationLoginState.loggedIn
          $and $notifyListenersCalled
      """, () async {
    verify(initializeCall()).called(1);
    pushPreparedUserToUserChangesStream(notNullUser, true);
    await expectLater(1, 1);
    expect(sut.loginState, ApplicationLoginState.loggedIn);
    verify(notifyListenersCall()).called(1);
  });

  test("""
        $given $workingWithApplicationState
        $wheN Creating a new ApplicationState instance
          $and there is a signed in user
          $and User.emailVerified returns false
        $then Firbase.initializeApp() should be called
          $and loginState should return ApplicationLoginState.locked
          $and $notifyListenersCalled
      """, () async {
    verify(initializeCall()).called(1);
    pushPreparedUserToUserChangesStream(notNullUser, false);
    await expectLater(1, 1);
    expect(sut.loginState, ApplicationLoginState.locked);
    verify(notifyListenersCall()).called(1);
  });

  test("""
        $given $workingWithApplicationState
          $and there is no signed in user
        $wheN calling startLoginFlow()
        $then That loginState returns ApplicationLoginState.emailAddress
          $and $notifyListenersCalled
      """, fromLoggedOutToEmailAddress);

  test("""
        $given $workingWithApplicationState
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
        $given $workingWithApplicationState
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
        $given $workingWithApplicationState
          $and there is no signed in user
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
          $and there is no signed in user
        $wheN Calling verifyEmail with a valid email address
          $and verifyEmail returns a Future of List that doesn't contain "password"
        $then loginState should return ApplicationLoginState.register
          $and the email returns the same passed argument email
          $and $notifyListenersCalled
""", fromLoggedOutToEmailAddressToRegister);

  test("""
        $given $workingWithApplicationState
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
        $given $workingWithApplicationState
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
          $and User.emailVerified returns false
        $then Calling loginState should return ApplicationLoginState.locked
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
  });

  test("""
        $given $workingWithApplicationState
          $and there is no signed in user
        $wheN Calling signInWithEmailAndPassword() with a valid email and
                password
          $and User.emailVerified returns true
        $then Calling loginState returns ApplicationLoginState.loggedIn
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLoggedIn();
  });

  test("""
      $given $workingWithApplicationState
        $and there is no signed in user
      $wheN Calling sendEmailToVerifyEmailAddress()
      $then User.sendEmailVerification() has been called
      """, () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    when(firebaseAuth.currentUser).thenReturn(notNullUser);
    sut.sendEmailToVerifyEmailAddress();
    verify(notNullUser.sendEmailVerification()).called(1);
  });

  test("""
      $given $workingWithApplicationState
      $wheN Calling updateUser()
      $then User.reload() should be called
      """, () {
    when(firebaseAuth.currentUser).thenReturn(notNullUser);
    sut.updateUser();
    verify(notNullUser.reload()).called(1);
  });

  test("""
        $given $workingWithApplicationState
          $and there is no signed in user
        $wheN Calling cancelRegistration()
        $then Calling logginState should return ApplicationLogginState.emailAddress
          $and $notifyListenersCalled
""", () async {
    await fromLoggedOutToEmailAddressToRegister();
    sut.cancelRegistration();
    expect(sut.loginState, ApplicationLoginState.emailAddress);
    verify(notifyListenersCall()).called(1);
  });

  test("""
        $given $workingWithApplicationState
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
        $given $workingWithApplicationState
          $and there is no signed in user
        $wheN Calling registerAccount() with valid, not-already-used email and 
                non-weak password
        $then firebaseAuth.createUserWithEmailAndPassword() should be called once
          $and User.updateDisplayName() has been called
          $and User.sendEmailVerification() has been called
          $and Calling loginState should return ApplicationLoginState.locked
""", () async {
    await fromLoggedOutToEmailAddressToRegister();
    when(notNullUser.updateDisplayName(displayName))
        .thenAnswer((realInvocation) => Completer<void>().future);
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
    expect(sut.loginState, ApplicationLoginState.locked);
  });

  test("""
        $given $workingWithApplicationState
          $and Calling loginState returns ApplicationLoginState.loggedIn
        $wheN Calling signOut()
        $then Calling loginState returns ApplicationLoginState.loggedOut
          $and $notifyListenersCalled
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLoggedIn();
    pushPreparedUserToUserChangesStream(nullUser);
    await sut.signOut();
    verify(firebaseAuth.signOut()).called(1);
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    verify(notifyListenersCall()).called(1);
  });

  test("""
      $given $workingWithApplicationState
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
        $given $workingWithApplicationState
        $wheN Calling resetPassword()
        $then Firebase.instance.sendPasswordResetEmail has been called
      """, () {
    when(firebaseAuth.sendPasswordResetEmail(email: validEmail))
        .thenAnswer((realInvocation) => Completer<void>().future);
    sut.resetPassword(validEmail, firebaseAuthExceptionCallback);
    verify(firebaseAuth.sendPasswordResetEmail(email: validEmail)).called(1);
  });

  test("""
        $given $workingWithApplicationState
          $and Calling loginState returns ApplicationLoginState.locked
        $wheN Calling signOut()
        $then Calling loginState returns ApplicationLoginState.loggedOut
          $and $notifyListenersCalled
""", () async {
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    pushPreparedUserToUserChangesStream(nullUser);
    await sut.signOut();
    verify(firebaseAuth.signOut()).called(1);
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    verify(notifyListenersCall()).called(1);
  });

  test("""
        $given $workingWithApplicationState
        $wheN Calling toLoggedOut()
        $then Calling loginState should return ApplicationLoginState.loggedOut
          $and $notifyListenersCalled
        """, () async {
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    sut.toLoggedOut();
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    verify(notifyListenersCall()).called(1);
    fromLoggedOutToEmailAddress();
    sut.toLoggedOut();
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    verify(notifyListenersCall()).called(1);
    await fromLoggedOutToEmailAddressToRegister();
    sut.toLoggedOut();
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    verify(notifyListenersCall()).called(1);
    await fromLoggedOutToEmailAddressToPassword();
    sut.toLoggedOut();
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    verify(notifyListenersCall()).called(1);
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLoggedIn();
    sut.toLoggedOut();
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    verify(notifyListenersCall()).called(1);
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    sut.toLoggedOut();
    expect(sut.loginState, ApplicationLoginState.loggedOut);
    verify(notifyListenersCall()).called(1);
  });

  test("""
        $given $workingWithApplicationState
          $and Calling loginState returns anything other than ApplicationLoginState.loggedIn & ApplicationLoginState.locked
        $wheN Calling signOut()
        $then StateError should be thrown
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
          $and Calling loginState returns anything other than ApplicationLoginState.password
        $wheN Calling signInWithUsernameAndPassword()
        $then StateError should be thrown
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
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    expectExceptionFromSignInWithEmailAndPassword(
        sut.signInWithEmailAndPassword, message);
  });

  test("""
        $given $workingWithApplicationState
          $and Calling loginState returns anything other than ApplicationLoginState.register
        $wheN Calling registerAccount()
        $then StateError should be thrown
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
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    expectExceptionFromRegisterAccount(sut.registerAccount, message);
  });

  test("""
        $given $workingWithApplicationState
          $and Calling loginState returns anything other than ApplicationLoginState.register
        $wheN Calling cancelRegistration()
        $then StateError should be thrown
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
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    expectExceptionFromCancelRegistration(sut.cancelRegistration, message);
  });

  test("""
        $given $workingWithApplicationState
          $and Calling loginState returns anything other than ApplicationLoginState.emailAddress
        $wheN Calling verifyEmail()
        $then StateError should be thrown
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
    await fromLoggedOutToEmailAddressToPassword();
    await fromPasswordToLocked();
    expectExceptionFromVerifyEmail(sut.verifyEmail, message);
  });
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

void fromLoggedOutToEmailAddress() {
  sut.startLoginFlow();
  expect(sut.loginState, ApplicationLoginState.emailAddress);
  verify(notifyListenersCall()).called(1);
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
  expect(sut.loginState, ApplicationLoginState.password);
  verify(notifyListenersCall()).called(1);
}

Future<void> fromLoggedOutToEmailAddressToRegister() async {
  fromLoggedOutToEmailAddress();
  prepareFetchSignInMethodsForEmailWithValidEmailAndReturnAFutureOfListThatDoesntContainPasswordMethod();
  await sut.verifyEmail(validEmail, firebaseAuthExceptionCallback);
  expect(sut.loginState, ApplicationLoginState.register);
  expect(sut.email, validEmail);
  verify(notifyListenersCall()).called(1);
}

Future<void> fromPasswordToLoggedIn() async {
  when(firebaseAuth.signInWithEmailAndPassword(
          email: validEmail, password: password))
      .thenAnswer((realInvocation) => Future.value(userCredential));
  pushPreparedUserToUserChangesStream(notNullUser, true);
  await sut.signInWithEmailAndPassword(
      validEmail, password, firebaseAuthExceptionCallback);
  //expectLater(1, 1);
  expect(sut.loginState, ApplicationLoginState.loggedIn);
  verify(notifyListenersCall()).called(1);
}

Future<void> fromPasswordToLocked() async {
  when(firebaseAuth.signInWithEmailAndPassword(
          email: validEmail, password: password))
      .thenAnswer((realInvocation) => Future.value(userCredential));
  pushPreparedUserToUserChangesStream(notNullUser, false);
  await sut.signInWithEmailAndPassword(
      validEmail, password, firebaseAuthExceptionCallback);
  expect(sut.loginState, ApplicationLoginState.locked);
  verify(notifyListenersCall()).called(1);
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
