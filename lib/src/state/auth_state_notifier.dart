import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';
import 'value_classes/application_auth_state.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  FirebaseAuth firebaseAuth;

  AuthStateNotifier(this.firebaseAuth,
      [state = const AuthState(
          applicationAuthState: ApplicationAuthState.signedOut)])
      : super(state) {
    _init();
  }

  void _init() {
    firebaseAuth.userChanges().listen((user) {
      if (user != null) {
        if (!user.emailVerified) {
          state = state.copyWith(
              applicationAuthState: ApplicationAuthState.locked);
        } else {
          state = state.copyWith(
              applicationAuthState: ApplicationAuthState.signedIn);
        }
      } else {
        state = state.copyWith(
            applicationAuthState: ApplicationAuthState.signedOut);
      }
    });
  }

  void startLoginFlow() {
    state = state.copyWith(
        applicationAuthState: ApplicationAuthState.emailAddress);
  }

  Future<void> verifyEmail(String email,
      void Function(FirebaseAuthException exception) errorCallback) async {
    if (state.applicationAuthState != ApplicationAuthState.emailAddress) {
      throw StateError(
          "To verify the email you need to be at emailAddress stage!");
    }
    try {
      final methods = await firebaseAuth.fetchSignInMethodsForEmail(email);
      if (methods.contains("password")) {
        state = state.copyWith(
            applicationAuthState: ApplicationAuthState.password);
      } else {
        state = state.copyWith(
            applicationAuthState: ApplicationAuthState.register);
      }
      state = state.copyWith(email: email);
    } on FirebaseAuthException catch (exception) {
      errorCallback(exception);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password,
      void Function(FirebaseAuthException exception) errorCallback) async {
    if (state.applicationAuthState != ApplicationAuthState.password) {
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
    if (state.applicationAuthState != ApplicationAuthState.register) {
      throw StateError(
          "To cancel registration you need to be at register stage!");
    }
    state = state.copyWith(
        applicationAuthState: ApplicationAuthState.emailAddress);
  }

  Future<void> registerAccount(
      String email,
      String password,
      String displayName,
      void Function(FirebaseAuthException exception) errorCallback) async {
    if (state.applicationAuthState != ApplicationAuthState.register) {
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
    if (!(state.applicationAuthState == ApplicationAuthState.signedIn ||
        state.applicationAuthState == ApplicationAuthState.locked)) {
      throw StateError("To sign out you need to sign in first!");
    }
    await firebaseAuth.signOut();
  }

  Future<void> sendEmailToVerifyEmailAddress() async {
    await firebaseAuth.currentUser!.sendEmailVerification();
  }

  void toLoggedOut() {
    state =
        state.copyWith(applicationAuthState: ApplicationAuthState.signedOut);
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
