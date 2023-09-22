import 'package:freezed_annotation/freezed_annotation.dart';

import 'value_classes/application_login_state.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState(
      {required ApplicationLoginState applicationLoginState,
      String? email}) = _AuthState;
}
