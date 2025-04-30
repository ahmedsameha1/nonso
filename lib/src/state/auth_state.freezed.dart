// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthState {
  ApplicationAuthState get applicationAuthState;
  User? get user;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthStateCopyWith<AuthState> get copyWith =>
      _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthState &&
            (identical(other.applicationAuthState, applicationAuthState) ||
                other.applicationAuthState == applicationAuthState) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, applicationAuthState, user);

  @override
  String toString() {
    return 'AuthState(applicationAuthState: $applicationAuthState, user: $user)';
  }
}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) =
      _$AuthStateCopyWithImpl;
  @useResult
  $Res call({ApplicationAuthState applicationAuthState, User? user});
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res> implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? applicationAuthState = null,
    Object? user = freezed,
  }) {
    return _then(_self.copyWith(
      applicationAuthState: null == applicationAuthState
          ? _self.applicationAuthState
          : applicationAuthState // ignore: cast_nullable_to_non_nullable
              as ApplicationAuthState,
      user: freezed == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc

class _AuthState implements AuthState {
  const _AuthState({required this.applicationAuthState, this.user});

  @override
  final ApplicationAuthState applicationAuthState;
  @override
  final User? user;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthStateCopyWith<_AuthState> get copyWith =>
      __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthState &&
            (identical(other.applicationAuthState, applicationAuthState) ||
                other.applicationAuthState == applicationAuthState) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, applicationAuthState, user);

  @override
  String toString() {
    return 'AuthState(applicationAuthState: $applicationAuthState, user: $user)';
  }
}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(
          _AuthState value, $Res Function(_AuthState) _then) =
      __$AuthStateCopyWithImpl;
  @override
  @useResult
  $Res call({ApplicationAuthState applicationAuthState, User? user});
}

/// @nodoc
class __$AuthStateCopyWithImpl<$Res> implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? applicationAuthState = null,
    Object? user = freezed,
  }) {
    return _then(_AuthState(
      applicationAuthState: null == applicationAuthState
          ? _self.applicationAuthState
          : applicationAuthState // ignore: cast_nullable_to_non_nullable
              as ApplicationAuthState,
      user: freezed == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

// dart format on
