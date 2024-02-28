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
      child: ElevatedButton(
          onPressed: authBloc.start,
          child: Text(AppLocalizations.of(context)!.nonso_register)),
    );
  }
}
