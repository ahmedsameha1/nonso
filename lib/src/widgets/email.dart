import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../state/auth_bloc.dart';
import 'register.dart';

class Email extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? _email;
  Email({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  value.trim().isEmpty ||
                  !value.contains("@")) {
                return AppLocalizations.of(context)!.invalidEmailString;
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
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  await authBloc.verifyEmail(
                      _email!,
                      (exception) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "${Register.failedString}${exception.code}"))));
                }
              },
              child: Text(AppLocalizations.of(context)!.next),
            ),
            ElevatedButton(
              onPressed: authBloc.toSignedOut,
              child: Text(AppLocalizations.of(context)!.cancel),
            )
          ]),
        ],
      ),
    );
  }
}
