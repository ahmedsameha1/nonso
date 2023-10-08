sealed class AuthEvent {}

final class LogInEvent extends AuthEvent {
  final String email;

  LogInEvent(this.email);
}
