sealed class AuthEvent {}

final class LogInEvent extends AuthEvent {
  final String email;

  LogInEvent(this.email);
}

final class LockedEvent extends AuthEvent {
  final String email;

  LockedEvent(this.email);
}

final class EmailAddressEvent extends AuthEvent {}

final class PasswordEvent extends AuthEvent {
  final String email;

  PasswordEvent(this.email);
}
