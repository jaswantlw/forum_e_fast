import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_e_fast/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<User?> _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    // Register event handlers
    on<SignUpEvent>(_onSignUpEvent);
    on<LoginEvent>(_onLoginEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<CheckAuthStatusEvent>(_onCheckAuthStatusEvent);
    on<ListenToAuthStateEvent>(_onListenToAuthStateEvent);
  }

  /// Handle SignUpEvent
  Future<void> _onSignUpEvent(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(userId: user.uid, email: user.email ?? ''));
    } on Exception catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle LoginEvent
  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(userId: user.uid, email: user.email ?? ''));
    } on Exception catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle LogoutEvent
  Future<void> _onLogoutEvent(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } on Exception catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle CheckAuthStatusEvent - check if user is already logged in
  Future<void> _onCheckAuthStatusEvent(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(userId: user.uid, email: user.email ?? ''));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle ListenToAuthStateEvent - listen to auth state changes in real-time
  void _onListenToAuthStateEvent(
    ListenToAuthStateEvent event,
    Emitter<AuthState> emit,
  ) {
    _authStateSubscription = _authRepository.authStateChanges().listen(
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(userId: user.uid, email: user.email ?? ''));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
      onError: (e) {
        emit(AuthError(message: e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
