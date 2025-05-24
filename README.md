Implement email and password authentication in your app by inserting ONE widget from this package in your widget tree.  
It is based on [Firebase Authentication](https://firebase.google.com/docs/auth) and [Bloc](https://bloclibrary.dev/).

<img alt="auth_options" src="https://raw.githubusercontent.com/ahmedsameha1/nonso/main/screenshots/auth_options.png" width="30%" hspace="10" vspace="5"><img alt="register" src="https://raw.githubusercontent.com/ahmedsameha1/nonso/main/screenshots/register.png" width="30%" hspace="10" vspace="5"><img alt="sign_in" src="https://raw.githubusercontent.com/ahmedsameha1/nonso/main/screenshots/sign_in.png" width="30%" hspace="5" vspace="10">

## Features

- Register user accounts using email and password authentication.
- Send and resend verification emails to confirm email addresses.
- Sign in users with email and password.
- Sign out users.
- Handle password reset scenarios.

## Usage

1. [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup?platform=ios).
2. Install the [`firebase_auth`](https://pub.dev/packages/firebase_auth) plugin.
3. Install the [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) package.
4. Install this package!
5. Pass your widget to the `AuthScreen` constructor as a descendat of a widget that can provide a `AuthBloc` instance, like `BlocBrovider<AuthBloc>`.
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nonso/nonso.dart' as nonso;

class MyApp extends StatelessWidget {
  final FirebaseAuth firebaseAuthInstance;
  const MyApp(this.firebaseAuthInstance, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<nonso.AuthBloc>(
      create: (context) => nonso.AuthBloc(firebaseAuthInstance),
      child: MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: [nonso.AppLocalizations.delegate],
        supportedLocales: nonso.AppLocalizations.supportedLocales,
        home: nonso.AuthScreen(
          // This is your home screen
          const YourHomePage(title: 'Flutter Demo Home Page'),
        ),
      ),
    );
  }
}
```
6. Use `context.read<AuthBloc>().state.user!` to get information about the signed in user.
```dart
  import 'package:firebase_auth/firebase_auth.dart';

  Widget build(BuildContext context) {
    final User currentSignedInUser = context.read<AuthBloc>().state.user!;
    return Text("${currentSignedInUser.uid}");
  }
```

#### Here's an example of a Flutter app that uses this package to handle email and password authentication [here](https://github.com/ahmedsameha1/nonso/tree/main/example). Make sure to use the correct values of your Firebase project in the `firebase_options.dart` file.
