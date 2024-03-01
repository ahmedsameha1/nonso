import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';
import 'package:nonso/src/widgets/locked.dart';
import 'package:nonso/src/widgets/password.dart';
import 'package:nonso/src/widgets/register.dart';
import 'package:nonso/src/widgets/auth_options.dart';

import '../state/auth_state.dart';
import 'email.dart';

class AuthScreen extends StatelessWidget {
  final Widget child;
  const AuthScreen(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (ctx, state) {
        switch (state.applicationAuthState) {
          case ApplicationAuthState.signedOut:
            return const AuthOptions();
          case ApplicationAuthState.startRegistration:
            return Register();
          case ApplicationAuthState.emailAddress:
            return Email();
          case ApplicationAuthState.password:
            return Password();
          case ApplicationAuthState.register:
            return Register();
          case ApplicationAuthState.locked:
            return const Locked();
          default:
            return child;
        }
      },
    );
  }
}
