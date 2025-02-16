import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'common.dart';

class Register extends HookWidget {
  Register({super.key});
  final GlobalKey<FormState> _nameFormKey = GlobalKey();
  final GlobalKey<FormState> _emailFormKey = GlobalKey();
  final GlobalKey<FormState> _passrodFormKey = GlobalKey();
  final GlobalKey<FormState> _confirmPassrodFormKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    final isNameValid = useState<bool>(false);
    final isEmailValid = useState<bool>(false);
    final isPasswordValid = useState<bool>(false);
    final isConfirmPasswordValid = useState<bool>(false);
    final TextEditingController passwordTextEditingController =
        useTextEditingController();
    final TextEditingController nameTextEditingController =
        useTextEditingController();
    final TextEditingController emailTextEditingController =
        useTextEditingController();
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            key: const Key("paddingAroundColumn"),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _nameFormKey,
                  child: TextFormField(
                    controller: nameTextEditingController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  onChanged: () => isNameValid.value =
                      _nameFormKey.currentState != null &&
                          _nameFormKey.currentState!.validate(),
                ),
                Form(
                  key: _emailFormKey,
                  child: TextFormField(
                    controller: emailTextEditingController,
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
                  onChanged: () => isEmailValid.value =
                      _emailFormKey.currentState != null &&
                          _emailFormKey.currentState!.validate(),
                ),
                Form(
                  key: _passrodFormKey,
                  child: TextFormField(
                    controller: passwordTextEditingController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [noWhiteSpaceInputFormatter],
                    decoration: InputDecoration(
                        label:
                            Text(AppLocalizations.of(context)!.nonso_password)),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value == null ||
                          value.trim().length < passwordMinimumLength) {
                        return AppLocalizations.of(context)!
                            .nonso_passwordValidationError(
                                passwordMinimumLength);
                      }
                      return null;
                    },
                  ),
                  onChanged: () => isPasswordValid.value =
                      _passrodFormKey.currentState != null &&
                          _passrodFormKey.currentState!.validate(),
                ),
                Form(
                  key: _confirmPassrodFormKey,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [noWhiteSpaceInputFormatter],
                    decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!
                            .nonso_confirmPassword)),
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
                  onChanged: () => isConfirmPasswordValid.value =
                      _confirmPassrodFormKey.currentState != null &&
                          _confirmPassrodFormKey.currentState!.validate(),
                ),
                const SizedBox(
                  key: Key(
                    "gapBetweenTextFieldsAndButtons",
                  ),
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: !(isNameValid.value &&
                                isEmailValid.value &&
                                isPasswordValid.value &&
                                isConfirmPasswordValid.value)
                            ? null
                            : () async {
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                final successString =
                                    AppLocalizations.of(context)!.nonso_success;
                                await authBloc.registerAccount(
                                    emailTextEditingController.text,
                                    passwordTextEditingController.text,
                                    nameTextEditingController.text,
                                    ((exception) =>
                                        scaffoldMessenger.showSnackBar(SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .nonso_failed(
                                                        exception.code))))));
                                scaffoldMessenger.showSnackBar(
                                    SnackBar(content: Text(successString)));
                              },
                        child:
                            Text(AppLocalizations.of(context)!.nonso_register)),
                    ElevatedButton(
                      onPressed: authBloc.toSignedOut,
                      child: Text(AppLocalizations.of(context)!.nonso_cancel),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
