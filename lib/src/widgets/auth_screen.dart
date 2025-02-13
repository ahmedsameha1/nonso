import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/value_classes/application_auth_state.dart';
import 'package:nonso/src/widgets/locked.dart';
import 'package:nonso/src/widgets/password.dart';
import 'package:nonso/src/widgets/register.dart';
import 'package:nonso/src/widgets/auth_options.dart';

import '../state/auth_state.dart';

class AuthScreen extends StatelessWidget {
  final Widget child;
  const AuthScreen(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (ctx, state) {
        if (state.applicationAuthState != ApplicationAuthState.signedIn) {
          late Widget notSignedInChild;
          switch (state.applicationAuthState) {
            case ApplicationAuthState.locked:
              notSignedInChild = const Locked();
            case ApplicationAuthState.password:
              notSignedInChild = Password();
            case ApplicationAuthState.register:
              notSignedInChild = Register();
            default:
              notSignedInChild = const AuthOptions();
          }
          return Scaffold(body: notSignedInChild);
        } else {
          return child;
        }
      },
    );
  }
}
