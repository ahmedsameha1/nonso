import 'package:nonso/src/auth_state_notifier.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState(
      {required ApplicationLoginState applicationLoginState,
      String? email}) = _AuthState;
}
