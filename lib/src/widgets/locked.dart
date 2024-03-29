import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nonso/src/state/auth_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Locked extends StatelessWidget {
  const Locked(
      {super.key});

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return Column(
      children: [
        Text(AppLocalizations.of(context)!.nonso_verifyEmailAddress),
        ElevatedButton(
          onPressed: authBloc.updateUser,
          child: Text(AppLocalizations.of(context)!.nonso_refresh),
        ),
        ElevatedButton(
          onPressed: authBloc.sendEmailToVerifyEmailAddress,
          child: Text(AppLocalizations.of(context)!.nonso_resendVerificationEmail),
        ),
        ElevatedButton(
          onPressed: authBloc.signOut,
          child: Text(AppLocalizations.of(context)!.nonso_signOut),
        )
      ],
    );
  }
}
