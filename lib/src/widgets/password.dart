import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../state/auth_bloc.dart';
import 'package:nonso/l10n/app_localizations.dart';

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
    final isAwaiting = useState<bool>(false);
    final TextEditingController emailTextEditingController =
        useTextEditingController();
    final TextEditingController passwordTextEditingController =
        useTextEditingController();
    return Center(
      child: isAwaiting.value
          ? const CircularProgressIndicator()
          : Card(
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                    key: const Key("paddingAroundColumn"),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Form(
                          key: _emailformKey,
                          child: TextFormField(
                            controller: emailTextEditingController,
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            decoration: InputDecoration(
                                label: Text(
                                    AppLocalizations.of(context).nonso_email)),
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [noWhiteSpaceInputFormatter],
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final regexp =
                                  RegExp(r"^\S+@\S+$", unicode: true);
                              if (value == null || !regexp.hasMatch(value)) {
                                return AppLocalizations.of(context)
                                    .nonso_invalidEmail;
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
                                label: Text(AppLocalizations.of(context)
                                    .nonso_password)),
                            keyboardType: TextInputType.text,
                            inputFormatters: [noWhiteSpaceInputFormatter],
                            obscureText: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length < passwordMinimumLength) {
                                return AppLocalizations.of(context)
                                    .nonso_passwordValidationError(
                                        passwordMinimumLength);
                              }
                              return null;
                            },
                          ),
                          onChanged: () => isPasswordValid.value =
                              _passwordformKey.currentState != null &&
                                  _passwordformKey.currentState!.validate(),
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
                              onPressed: authBloc.toSignedOut,
                              child: Text(
                                  AppLocalizations.of(context).nonso_cancel),
                            ),
                            ElevatedButton(
                              onPressed: !isEmailValid.value ||
                                      !isPasswordValid.value
                                  ? null
                                  : () async {
                                      final scaffoldMessenger =
                                          ScaffoldMessenger.of(context);
                                      isAwaiting.value = true;
                                      try {
                                        await authBloc
                                            .signInWithEmailAndPassword(
                                                emailTextEditingController.text,
                                                passwordTextEditingController
                                                    .text);
                                      } on FirebaseAuthException catch (exception) {
                                        if (context.mounted) {
                                          scaffoldMessenger.showSnackBar(
                                              SnackBar(
                                                  content: Text(AppLocalizations
                                                          .of(context)
                                                      .nonso_failed(
                                                          exception.code))));
                                        }
                                      }
                                      if (context.mounted) {
                                        isAwaiting.value = false;
                                      }
                                    },
                              child: Text(
                                  AppLocalizations.of(context).nonso_signIn),
                            ),
                          ],
                        ),
                        const SizedBox(
                          key: Key(
                            "gapBetweenButtons",
                          ),
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: !isEmailValid.value
                                  ? null
                                  : () async {
                                      final scaffoldMessenger =
                                          ScaffoldMessenger.of(context);
                                      try {
                                        await authBloc.resetPassword(
                                          emailTextEditingController.text,
                                        );
                                      } on FirebaseAuthException catch (exception) {
                                        if (context.mounted) {
                                          scaffoldMessenger
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)
                                                    .nonso_failed(
                                                        exception.message ??
                                                            exception.code)),
                                          ));
                                        }
                                      }
                                      if (context.mounted) {
                                        scaffoldMessenger.showSnackBar(SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)
                                                    .nonso_resetEmailSent)));
                                      }
                                    },
                              child: Text(AppLocalizations.of(context)
                                  .nonso_resetPassword),
                            )
                          ],
                        )
                      ],
                    )),
              ),
            ),
    );
  }
}
