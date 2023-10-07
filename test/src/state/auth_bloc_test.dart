import 'dart:async';

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
    sut = AuthBloc();
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
}

void pushPreparedUserToUserChangesStream(User? user,
    [bool emailVerified = false]) {
  if (user != null) {
    when(user.emailVerified).thenReturn(emailVerified);
  }
  streamController.sink.add(user);
}
