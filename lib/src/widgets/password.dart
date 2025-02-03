import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../state/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../state/auth_state.dart';
import 'common.dart';

class Password extends HookWidget {
  Password({super.key});
  final GlobalKey<FormState> _emailformKey = GlobalKey();
  final GlobalKey<FormState> _passwordformKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    final isEmailValid = useState<bool>(false);
    final isPasswordValid = useState<bool>(false);
    final TextEditingController emailTextEditingController =
        useTextEditingController();
    final TextEditingController passwordTextEditingController =
        useTextEditingController();
    return BlocBuilder<AuthBloc, AuthState>(builder: (ctx, state) {
      return Column(
        children: [
          Form(
            key: _emailformKey,
            child: TextFormField(
              controller: emailTextEditingController,
              autovalidateMode: AutovalidateMode.onUnfocus,
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
            onChanged: () => isEmailValid.value =
                _emailformKey.currentState != null &&
                    _emailformKey.currentState!.validate(),
          ),
          Form(
            key: _passwordformKey,
            child: TextFormField(
              controller: passwordTextEditingController,
              autovalidateMode: AutovalidateMode.onUnfocus,
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
            onChanged: () => isPasswordValid.value =
                _passwordformKey.currentState != null &&
                    _passwordformKey.currentState!.validate(),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: !isEmailValid.value || !isPasswordValid.value
                    ? null
                    : () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        await authBloc.signInWithEmailAndPassword(
                            emailTextEditingController.text,
                            passwordTextEditingController.text, ((exception) {
                          scaffoldMessenger.showSnackBar(SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .nonso_failed(exception.code))));
                        }));
                      },
                child: Text(AppLocalizations.of(context)!.nonso_signIn),
              ),
              ElevatedButton(
                onPressed: authBloc.toSignedOut,
                child: Text(AppLocalizations.of(context)!.nonso_cancel),
              ),
              ElevatedButton(
                onPressed: !isEmailValid.value ? null : () {},
                child: Text(AppLocalizations.of(context)!.nonso_forgotPassword),
              )
            ],
          ),
        ],
      );
    });
  }
}
