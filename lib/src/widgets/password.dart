import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/auth_bloc.dart';

import '../state/auth_state.dart';
import 'register.dart';

class Password extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? _password;
  Password({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(builder: (ctx, state) {
      return Form(
        key: _formKey,
        child: Column(children: [
          Text(state.email!),
          TextFormField(
            decoration:
                const InputDecoration(label: Text(Register.passwordString)),
            keyboardType: TextInputType.text,
            inputFormatters: [Register.noWhiteSpaceInputFormatter],
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            validator: (value) {
              if (value == null ||
                  value.trim().length < Register.passwordMinimumLength) {
                return Register.passwordValidationErrorString;
              }
              return null;
            },
            onSaved: (newValue) {
              if (newValue != null) {
                _password = newValue;
              }
            },
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await authBloc.signInWithEmailAndPassword(
                        state.email!, _password!, ((exception) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "${Register.failedString}${exception.code}")));
                    }));
                  }
                },
                child: const Text(Register.nextString),
              ),
              ElevatedButton(
                onPressed: authBloc.toSignedOut,
                child: const Text(Register.cancelString),
              )
            ],
          ),
        ]),
      );
    });
  }
}
