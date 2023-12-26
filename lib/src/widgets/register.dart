import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Register extends HookWidget {
  static const passwordString = "Password";
  static const nextString = "Next";
  static const cancelString = "Cancel";
  static const failedString = "Failure: ";
  static const passwordValidationErrorString =
      "Password needs to be at least $passwordMinimumLength characters";
  static const passwordMinimumLength = 6;
  static final FilteringTextInputFormatter noWhiteSpaceInputFormatter =
      FilteringTextInputFormatter.deny(RegExp(r'\s'));
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
            Text(state.email!),
            TextFormField(
              controller: nameTextEditingController,
              decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.nonso_name)),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!
                      .nonso_nameValidationError;
                }
                return null;
              },
            ),
            TextFormField(
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
                      .nonso_passwordValidationError;
                }
                return null;
              },
            ),
            TextFormField(
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
                            ((exception) => scaffoldMessenger.showSnackBar(SnackBar(
                                content: Text(
                                    "${AppLocalizations.of(context)!.nonso_failed}${exception.code}")))));
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
