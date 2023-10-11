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
  }

  void _init() {
    firebaseAuth.userChanges().listen((user) {
      if (user != null) {
        if (user.email != null && user.emailVerified) {
          add(LogInEvent(user.email!));
        } else if (user.email != null && !user.emailVerified) {
          add(LockedEvent(user.email!));
        }
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
}
