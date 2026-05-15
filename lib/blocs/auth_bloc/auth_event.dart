part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Sign up with email and password
class SignUpEvent extends AuthEvent {
  final String email;
  final String password;

  const SignUpEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Login with email and password
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Logout the current user
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Check if user is already authenticated (on app startup)
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Listen to auth state changes
class ListenToAuthStateEvent extends AuthEvent {
  const ListenToAuthStateEvent();
}
