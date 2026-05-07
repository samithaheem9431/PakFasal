import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_session_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

/// Renders [child] when the user is signed in (or continuing as guest),
/// otherwise renders the login screen inline.
///
/// Because the gate watches [AuthSessionController], any change to the auth
/// session anywhere in the app (sign-in, sign-out, token expiry) causes the
/// gate to rebuild. This means:
///   * No "flash of authenticated content" before a redirect runs.
///   * Sign-out from any screen automatically returns the user to login,
///     without each caller needing to push a named route.
///   * Authenticated routes can be guarded by simply wrapping their widget
///     in [AuthGate] inside the router.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSessionController>();
    if (auth.isSignedIn) return child;
    return const LoginScreen();
  }
}
