import 'package:freezed_annotation/freezed_annotation.dart';

import 'value_classes/application_auth_state.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState(
      {required ApplicationAuthState applicationAuthState,
      String? email}) = _AuthState;
}
