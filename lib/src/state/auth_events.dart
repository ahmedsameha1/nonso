sealed class AuthEvent {}

final class SignInEvent extends AuthEvent {
  final String email;

  SignInEvent(this.email);
}

final class LockedEvent extends AuthEvent {
  final String email;

  LockedEvent(this.email);
}

final class PasswordEvent extends AuthEvent {
  PasswordEvent();
}

final class RegisterEvent extends AuthEvent {
  RegisterEvent();
}

final class SignOutEvent extends AuthEvent {}

final class CancelButtonEvent extends AuthEvent {}
