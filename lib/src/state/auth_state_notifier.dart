import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';
import 'value_classes/application_login_state.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  FirebaseAuth firebaseAuth;

  AuthStateNotifier(this.firebaseAuth,
      [state = const AuthState(
          applicationLoginState: ApplicationLoginState.loggedOut)])
      : super(state) {
    _init();
  }

  void _init() {
    firebaseAuth.userChanges().listen((user) {
      if (user != null) {
        if (!user.emailVerified) {
          state = state.copyWith(
              applicationLoginState: ApplicationLoginState.locked);
        } else {
          state = state.copyWith(
              applicationLoginState: ApplicationLoginState.loggedIn);
        }
      } else {
        state = state.copyWith(
            applicationLoginState: ApplicationLoginState.loggedOut);
      }
    });
  }

  void startLoginFlow() {
    state = state.copyWith(
        applicationLoginState: ApplicationLoginState.emailAddress);
  }

  Future<void> verifyEmail(String email,
      void Function(FirebaseAuthException exception) errorCallback) async {
    if (state.applicationLoginState != ApplicationLoginState.emailAddress) {
      throw StateError(
          "To verify the email you need to be at emailAddress stage!");
    }
    try {
      final methods = await firebaseAuth.fetchSignInMethodsForEmail(email);
      if (methods.contains("password")) {
        state = state.copyWith(
            applicationLoginState: ApplicationLoginState.password);
      } else {
        state = state.copyWith(
            applicationLoginState: ApplicationLoginState.register);
      }
      state = state.copyWith(email: email);
    } on FirebaseAuthException catch (exception) {
      errorCallback(exception);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password,
      void Function(FirebaseAuthException exception) errorCallback) async {
    if (state.applicationLoginState != ApplicationLoginState.password) {
      throw StateError("To sign in you need to be at password stage!");
    }
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (exception) {
      errorCallback(exception);
    }
  }

  void cancelRegistration() {
    if (state.applicationLoginState != ApplicationLoginState.register) {
      throw StateError(
          "To cancel registration you need to be at register stage!");
    }
    state = state.copyWith(
        applicationLoginState: ApplicationLoginState.emailAddress);
  }

  Future<void> registerAccount(
      String email,
      String password,
      String displayName,
      void Function(FirebaseAuthException exception) errorCallback) async {
    if (state.applicationLoginState != ApplicationLoginState.register) {
      throw StateError("To register you need to be at register stage!");
    }
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.sendEmailVerification();
    } on FirebaseAuthException catch (exception) {
      errorCallback(exception);
    }
  }

  Future<void> signOut() async {
    if (!(state.applicationLoginState == ApplicationLoginState.loggedIn ||
        state.applicationLoginState == ApplicationLoginState.locked)) {
      throw StateError("To sign out you need to sign in first!");
    }
    await firebaseAuth.signOut();
  }

  Future<void> sendEmailToVerifyEmailAddress() async {
    await firebaseAuth.currentUser!.sendEmailVerification();
  }

  void toLoggedOut() {
    state =
        state.copyWith(applicationLoginState: ApplicationLoginState.loggedOut);
  }

  void updateUser() {
    firebaseAuth.currentUser!.reload();
  }

  void resetPassword(String email,
      void Function(FirebaseAuthException exception) errorCallback) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (exception) {
      errorCallback(exception);
    }
  }
}
