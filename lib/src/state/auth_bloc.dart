import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_login_state.dart';
import 'auth_events.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  FirebaseAuth firebaseAuth;

  AuthBloc(this.firebaseAuth)
      : super(const AuthState(
            applicationLoginState: ApplicationLoginState.loggedOut)) {
    _init();
    on<LogInEvent>(
      (event, emit) => emit(AuthState(
          applicationLoginState: ApplicationLoginState.loggedIn,
          email: event.email)),
    );
    on<LockedEvent>(
      (event, emit) => emit(AuthState(
          applicationLoginState: ApplicationLoginState.locked,
          email: event.email)),
    );
    on<EmailAddressEvent>(
      (event, emit) => emit(const AuthState(
          applicationLoginState: ApplicationLoginState.emailAddress,
          email: null)),
    );
    on<PasswordEvent>(
      (event, emit) => emit(AuthState(
          applicationLoginState: ApplicationLoginState.password,
          email: event.email)),
    );
    on<RegisterEvent>(
      (event, emit) => emit(AuthState(
          applicationLoginState: ApplicationLoginState.register,
          email: event.email)),
    );
    on<CancelRegistrationEvent>(
      (event, emit) => emit(const AuthState(
          applicationLoginState: ApplicationLoginState.emailAddress,
          email: null)),
    );
    on<LogOutEvent>((event, emit) => emit(
          const AuthState(
              applicationLoginState: ApplicationLoginState.loggedOut,
              email: null),
        ));
  }

  void _init() {
    firebaseAuth.userChanges().listen((user) {
      if (user != null) {
        if (user.email != null && user.emailVerified) {
          add(LogInEvent(user.email!));
        } else if (user.email != null && !user.emailVerified) {
          add(LockedEvent(user.email!));
        }
      } else {
        add(LogOutEvent());
      }
    });
  }

  void startLoginFlow() {
    add(EmailAddressEvent());
  }

  Future<void> verifyEmail(String email,
      void Function(FirebaseAuthException exception) errorCallback) async {
    try {
      final methods = await firebaseAuth.fetchSignInMethodsForEmail(email);
      if (methods.contains("password")) {
        add(PasswordEvent(email));
      } else {
        add(RegisterEvent(email));
      }
    } on FirebaseAuthException catch (exception) {
      errorCallback(exception);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password,
      void Function(FirebaseAuthException exception) errorCallback) async {
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
    add(CancelRegistrationEvent());
  }

  Future<void> registerAccount(
      String email,
      String password,
      String displayName,
      void Function(FirebaseAuthException exception) errorCallback) async {
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
    return firebaseAuth.signOut();
  }
}
