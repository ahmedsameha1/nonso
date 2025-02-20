import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nonso/src/state/auth_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Locked extends StatelessWidget {
  const Locked({super.key});

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                  textAlign: TextAlign.center,
                  style: TextTheme.of(context).bodyLarge,
                  AppLocalizations.of(context)!.nonso_verifyEmailAddress)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: authBloc.updateUser,
            child: Text(AppLocalizations.of(context)!.nonso_refresh),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: authBloc.sendEmailToVerifyEmailAddress,
            child: Text(
                AppLocalizations.of(context)!.nonso_resendVerificationEmail),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: authBloc.signOut,
            child: Text(AppLocalizations.of(context)!.nonso_signOut),
          )
        ],
      ),
    );
  }
}
