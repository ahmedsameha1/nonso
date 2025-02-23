import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nonso/nonso.dart';

class AuthOptions extends StatelessWidget {
  const AuthOptions({super.key});

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: authBloc.startRegistration,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.app_registration),
                const SizedBox(key: Key("registerGap"), width: 8),
                Text(AppLocalizations.of(context)!.nonso_register),
              ])),
          const SizedBox(key: Key("gapBetweenButtons"), height: 10),
          ElevatedButton(
              onPressed: authBloc.startSigningIn,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.login),
                  const SizedBox(key: Key("signInGap"), width: 8),
                  Text(AppLocalizations.of(context)!.nonso_signIn)
                ],
              ))
        ],
      ),
    );
  }
}
