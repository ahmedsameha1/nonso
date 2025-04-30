import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'value_classes/application_auth_state.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState(
      {required ApplicationAuthState applicationAuthState,
      User? user}) = _AuthState;
}
