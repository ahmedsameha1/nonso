import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../state/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../state/auth_state.dart';
import 'common.dart';

class Password extends HookWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Password({super.key});

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    final TextEditingController emailTextEditingController =
        useTextEditingController();
    final TextEditingController passwordTextEditingController =
        useTextEditingController();
    return BlocBuilder<AuthBloc, AuthState>(builder: (ctx, state) {
      return Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            controller: emailTextEditingController,
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
            controller: passwordTextEditingController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    await authBloc.signInWithEmailAndPassword(
                        emailTextEditingController.text,
                        passwordTextEditingController.text, ((exception) {
                      scaffoldMessenger.showSnackBar(SnackBar(
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
