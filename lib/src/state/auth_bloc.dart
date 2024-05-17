import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';
import 'auth_events.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  FirebaseAuth firebaseAuth;

  AuthBloc(this.firebaseAuth)
      : super(const AuthState(
            applicationAuthState: ApplicationAuthState.signedOut)) {
    _init();
    on<SignInEvent>(
      (event, emit) => emit(AuthState(
          applicationAuthState: ApplicationAuthState.signedIn,
          email: event.email)),
    );
    on<LockedEvent>(
      (event, emit) => emit(AuthState(
          applicationAuthState: ApplicationAuthState.locked,
          email: event.email)),
    );
    on<PasswordEvent>(
      (event, emit) => emit(const AuthState(
          applicationAuthState: ApplicationAuthState.password,
          email: null)),
    );
    on<RegisterEvent>(
      (event, emit) => emit(const AuthState(
          applicationAuthState: ApplicationAuthState.register, email: null)),
    );
    on<CancelRegistrationEvent>(
      (event, emit) => emit(const AuthState(
          applicationAuthState: ApplicationAuthState.emailAddress,
          email: null)),
    );
    on<SignOutEvent>((event, emit) => emit(
          const AuthState(
              applicationAuthState: ApplicationAuthState.signedOut,
              email: null),
        ));
    on<CancelButtonEvent>((event, emit) => emit(
          const AuthState(
              applicationAuthState: ApplicationAuthState.signedOut,
              email: null),
        ));
  }

  void _init() {
    firebaseAuth.userChanges().listen((user) {
      if (user != null) {
        if (user.email != null && user.emailVerified) {
          add(SignInEvent(user.email!));
        } else if (user.email != null && !user.emailVerified) {
          add(LockedEvent(user.email!));
        }
      } else {
        add(SignOutEvent());
      }
    });
  }

  void startRegistration() {
    add(RegisterEvent());
  }

  void startSigningIn() {
    add(PasswordEvent());
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
        add(PasswordEvent());
      } else {
        add(RegisterEvent());
      }
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

  Future<void> sendEmailToVerifyEmailAddress() {
    return firebaseAuth.currentUser!.sendEmailVerification();
  }

  void updateUser() {
    firebaseAuth.currentUser!.reload();
  }

  void cancelRegistration() {
    if (state.applicationAuthState != ApplicationAuthState.register) {
      throw StateError(
          "To cancel registration you need to be at register stage!");
    }
    add(CancelRegistrationEvent());
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

  Future<void> signOut() {
    if (!(state.applicationAuthState == ApplicationAuthState.signedIn ||
        state.applicationAuthState == ApplicationAuthState.locked)) {
      throw StateError("To sign out you need to sign in first!");
    }
    return firebaseAuth.signOut();
  }

  void resetPassword(String email,
      void Function(FirebaseAuthException exception) errorCallback) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (exception) {
      errorCallback(exception);
    }
  }

  void toSignedOut() {
    add(CancelButtonEvent());
  }
}
