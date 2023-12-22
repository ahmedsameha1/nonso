import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nonso/src/state/auth_bloc.dart';

class Locked extends StatelessWidget {
  static const refreshString = "Refresh Account";
  static const verifyEmailAddress =
      "Check your email to verify your email address";
  static const sendVerificationEmail = "Resend verification email";
  static const logout = "Log out";
  const Locked(
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return Column(
      children: [
        const Text(verifyEmailAddress),
        ElevatedButton(
          onPressed: authBloc.updateUser,
          child: const Text(refreshString),
        ),
        ElevatedButton(
          onPressed: authBloc.sendEmailToVerifyEmailAddress,
          child: const Text(sendVerificationEmail),
        ),
        ElevatedButton(
          onPressed: authBloc.signOut,
          child: const Text(logout),
        )
      ],
    );
  }
}
