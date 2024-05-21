import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../state/auth_state.dart';
import 'common.dart';

class Password extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? _password;
  Password({super.key});

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(builder: (ctx, state) {
      return Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.nonso_email)),
            keyboardType: TextInputType.emailAddress,
            inputFormatters: [noWhiteSpaceInputFormatter],
            autocorrect: false,
            enableSuggestions: false,
            validator: (value) {
              final regexp = RegExp(r"^\S+@\S+$", unicode: true);
              if (value == null || !regexp.hasMatch(value)) {
                return AppLocalizations.of(context)!.nonso_invalidEmail;
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.nonso_password)),
            keyboardType: TextInputType.text,
            inputFormatters: [noWhiteSpaceInputFormatter],
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            validator: (value) {
              if (value == null ||
                  value.trim().length < passwordMinimumLength) {
                return AppLocalizations.of(context)!
                    .nonso_passwordValidationError(passwordMinimumLength);
              }
              return null;
            },
            onSaved: (newValue) {
              if (newValue != null) {
                _password = newValue;
              }
            },
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await authBloc.signInWithEmailAndPassword(
                        state.email!, _password!, ((exception) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(AppLocalizations.of(context)!
                              .nonso_failed(exception.code))));
                    }));
                  }
                },
                child: Text(AppLocalizations.of(context)!.nonso_signIn),
              ),
              ElevatedButton(
                onPressed: authBloc.toSignedOut,
                child: Text(AppLocalizations.of(context)!.nonso_cancel),
              )
            ],
          ),
        ]),
      );
    });
  }
}
