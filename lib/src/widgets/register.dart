import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'common.dart';

class Register extends HookWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _emailFormFieldKey = GlobalKey<FormFieldState>();
  final _passwordFormFieldKey = GlobalKey<FormFieldState>();
  final _confirmPasswordFormFieldKey = GlobalKey<FormFieldState>();
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
            Focus(
              child: TextFormField(
                key: _emailFormFieldKey,
                decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.nonso_email)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().isEmpty ||
                      !value.contains("@")) {
                    return AppLocalizations.of(context)!.nonso_invalidEmail;
                  }
                  return null;
                },
              ),
              onFocusChange: (hasFocus) {
                _emailFormFieldKey.currentState!.validate();
              },
            ),
            Focus(
              child: TextFormField(
                key: _passwordFormFieldKey,
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
              onFocusChange: (hasFocus) {
                _passwordFormFieldKey.currentState!.validate();
              },
            ),
            Focus(
              child: TextFormField(
                key: _confirmPasswordFormFieldKey,
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
              onFocusChange: (hasFocus) {
                _confirmPasswordFormFieldKey.currentState!.validate();
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
