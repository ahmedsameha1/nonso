import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'register.dart';

class Email extends StatelessWidget {
  static const String emailString = "Email";
  static const String nextString = "Next";
  static const String cancelString = "Cancel";
  static const String invalidEmailString = "This an invalid email";
  static final RegExp emailRegex =
      RegExp(r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b');
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Future<void> Function(String email,
      void Function(FirebaseException exception) errorCallback) nextAction;
  final void Function() cancelAction;
  String? _email;
  Email(this.nextAction, this.cancelAction, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              label: Text(emailString),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  value.trim().isEmpty ||
                  !value.contains("@")) {
                return invalidEmailString;
              }
              return null;
            },
            onSaved: (newValue) {
              if (newValue != null) {
                _email = newValue;
              }
            },
          ),
          Row(children: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  await nextAction(
                      _email!,
                      (exception) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "${Register.failedString}${exception.code}"))));
                }
              },
              child: const Text(nextString),
            ),
            TextButton(
              onPressed: () {
                cancelAction();
              },
              child: const Text(cancelString),
            )
          ]),
        ],
      ),
    );
  }
}
