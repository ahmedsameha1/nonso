import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:nonso/src/state/value_classes/application_login_state.dart';
import 'auth_events.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc()
      : super(const AuthState(
            applicationLoginState: ApplicationLoginState.loggedOut));
}
