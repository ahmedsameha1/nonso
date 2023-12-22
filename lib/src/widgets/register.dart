import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nonso/src/state/auth_bloc.dart';
import 'package:nonso/src/state/auth_state.dart';

class Register extends HookWidget {
  static const nameString = "Name";
  static const passwordString = "Password";
  static const confirmPasswordString = "Confirm Password";
  static const nextString = "Next";
  static const cancelString = "Cancel";
  static const nameValidationErrorString = "Enter a name";
  static const failedString = "Failure: ";
  static const successString =
      "Success: Check your email to verify your email address";
  static const passwordMinimumLength = 6;
  static const passwordValidationErrorString =
      "Password needs to be at least $passwordMinimumLength characters";
  static const confirmPasswordValidationErrorString =
      "This doesn't match the above password";
  static final FilteringTextInputFormatter noWhiteSpaceInputFormatter =
      FilteringTextInputFormatter.deny(RegExp(r'\s'));
  final GlobalKey<FormState> _formKey = GlobalKey();
  Register({Key? key}) : super(key: key);

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
              decoration: const InputDecoration(label: Text(nameString)),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().isEmpty) {
                  return nameValidationErrorString;
                }
                return null;
              },
            ),
            TextFormField(
              controller: passwordTextEditingController,
              inputFormatters: [noWhiteSpaceInputFormatter],
              decoration: const InputDecoration(label: Text(passwordString)),
              keyboardType: TextInputType.text,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              validator: (value) {
                if (value == null ||
                    value.trim().length < passwordMinimumLength) {
                  return passwordValidationErrorString;
                }
                return null;
              },
            ),
            TextFormField(
              inputFormatters: [noWhiteSpaceInputFormatter],
              decoration:
                  const InputDecoration(label: Text(confirmPasswordString)),
              keyboardType: TextInputType.text,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              validator: (value) {
                if (value == null ||
                    value != passwordTextEditingController.text) {
                  return confirmPasswordValidationErrorString;
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
                        await authBloc.registerAccount(
                            state.email!,
                            passwordTextEditingController.text,
                            nameTextEditingController.text,
                            ((exception) => scaffoldMessenger.showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "$failedString${exception.code}")))));
                        scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text(successString)));
                      }
                    },
                    child: const Text(nextString)),
                ElevatedButton(
                  onPressed: authBloc.toSignedOut,
                  child: const Text(cancelString),
                )
              ],
            ),
          ],
        ),
      );
    });
  }
}
