import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'common.dart';

class Register extends HookWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Register({super.key});

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    final TextEditingController passwordTextEditingController =
        useTextEditingController();
    final TextEditingController nameTextEditingController =
        useTextEditingController();
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: nameTextEditingController,
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.nonso_name)),
              keyboardType: TextInputType.text,
              validator: (value) {
                final regexp = RegExp(r"\s*\p{L}+\s*", unicode: true);
                if (value == null || !regexp.hasMatch(value)) {
                  return AppLocalizations.of(context)!
                      .nonso_nameValidationError;
                }
                return null;
              },
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.nonso_email)),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final regexp = RegExp(r"^\S+@\S+$", unicode: true);
                if (value == null || !regexp.hasMatch(value)) {
                  return AppLocalizations.of(context)!.nonso_invalidEmail;
                }
                return null;
              },
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: passwordTextEditingController,
              inputFormatters: [noWhiteSpaceInputFormatter],
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.nonso_password)),
              keyboardType: TextInputType.text,
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
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [noWhiteSpaceInputFormatter],
              decoration: InputDecoration(
                  label: Text(
                      AppLocalizations.of(context)!.nonso_confirmPassword)),
              keyboardType: TextInputType.text,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              validator: (value) {
                if (value == null ||
                    value != passwordTextEditingController.text) {
                  return AppLocalizations.of(context)!
                      .nonso_confirmPasswordValidationError;
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
                        final successString =
                            AppLocalizations.of(context)!.nonso_success;
                        await authBloc.registerAccount(
                            state.email!,
                            passwordTextEditingController.text,
                            nameTextEditingController.text,
                            ((exception) => scaffoldMessenger.showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .nonso_failed(exception.code))))));
                        scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text(successString)));
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.nonso_next)),
                ElevatedButton(
                  onPressed: authBloc.toSignedOut,
                  child: Text(AppLocalizations.of(context)!.nonso_cancel),
                )
              ],
            ),
          ],
        ),
      );
    });
  }
}
