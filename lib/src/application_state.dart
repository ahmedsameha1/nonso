import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

//const String toFakeEmailDomain = "@d013d88ad-f72e-45d1-bb30-86aaa2d43b94.com";

class ApplicationState extends ChangeNotifier {
  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  FirebaseAuth firebaseAuth;

  String? _email;
  String? get email => _email;

  ApplicationState(
    this.firebaseAuth, [
    Future<FirebaseApp>? Function({String? name, FirebaseOptions? options})
        firebaseInitializeAppFunction = Firebase.initializeApp,
  ]) {
    _init(firebaseInitializeAppFunction);
  }

  Future<void> _init(
      Future<FirebaseApp>? Function({String? name, FirebaseOptions? options})
          firebaseInitializeAppFunction) async {
    await firebaseInitializeAppFunction();
  }

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> verifyEmail(String email,
      void Function(FirebaseAuthException exception) errorCallback) async {
    if (_loginState != ApplicationLoginState.emailAddress) {
      throw StateError(
          "To verify the email you need to be at emailAddress stage!");
    }
    try {
      final methods = await firebaseAuth.fetchSignInMethodsForEmail(email);
      if (methods.contains("password")) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (exception) {
      errorCallback(exception);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password,
      void Function(FirebaseAuthException exception) errorCallback) async {
    if (_loginState != ApplicationLoginState.password) {
      throw StateError("To sign in you need to be at password stage!");
    }
    firebaseAuth.userChanges().listen(_whenNotNullUser);
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (exception) {
      errorCallback(exception);
    }
  }

  void cancelRegistration() {
    if (_loginState != ApplicationLoginState.register) {
      throw StateError(
          "To cancel registration you need to be at register stage!");
    }
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> registerAccount(
      String email,
      String password,
      String displayName,
      void Function(FirebaseAuthException exception) errorCallback) async {
    if (_loginState != ApplicationLoginState.register) {
      throw StateError("To register you need to be at register stage!");
    }
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      userCredential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (exception) {
      errorCallback(exception);
    }
  }

  Future<void> signOut() async {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw StateError("To sign out you need to sign in first!");
    }
    firebaseAuth.userChanges().listen(_whenNullUser);
    await firebaseAuth.signOut();
  }

  void _whenNullUser(User? user) {
    if (user == null) {
      _loginState = ApplicationLoginState.loggedOut;
      notifyListeners();
    }
  }

  void _whenNotNullUser(User? user) {
    if (user != null) {
      _loginState = ApplicationLoginState.loggedIn;
      notifyListeners();
    }
  }
}

enum ApplicationLoginState {
  loggedOut,
  loggedIn,
  emailAddress,
  password,
  register,
}
