import 'package:firebase_auth/firebase_auth.dart';

sealed class AuthEvent {}

final class SignInEvent extends AuthEvent {
  final User user;

  SignInEvent(this.user);
}

final class LockedEvent extends AuthEvent {
  final User user;

  LockedEvent(this.user);
}

final class PasswordEvent extends AuthEvent {}

final class RegisterEvent extends AuthEvent {}

final class SignOutEvent extends AuthEvent {}

final class CancelButtonEvent extends AuthEvent {}
