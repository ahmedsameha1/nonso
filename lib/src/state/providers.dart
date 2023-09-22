import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';
import 'auth_state_notifier.dart';

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return ref.read(authStateNotifierProvider);
});

final authStateNotifierProvider = Provider<AuthStateNotifier>(
    (ref) => AuthStateNotifier(FirebaseAuth.instance));