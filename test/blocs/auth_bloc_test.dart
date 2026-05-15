import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forum_e_fast/blocs/auth_bloc/auth_bloc.dart';
import 'package:forum_e_fast/repositories/auth_repository.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('AuthBloc', () {
    late MockAuthRepository mockAuthRepository;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    group('CheckAuthStatusEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when no user is logged in',
        build: () {
          when(mockAuthRepository.getCurrentUser()).thenReturn(null);
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
        expect: () => [isA<AuthUnauthenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthAuthenticated] when user is logged in',
        build: () {
          final mockUser = _createMockUser(
            uid: 'user1',
            email: 'test@test.com',
          );
          when(mockAuthRepository.getCurrentUser()).thenReturn(mockUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
        expect: () => [
          isA<AuthAuthenticated>()
              .having((state) => state.userId, 'userId', 'user1')
              .having((state) => state.email, 'email', 'test@test.com'),
        ],
      );
    });

    group('LoginEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful login',
        build: () {
          final mockUser = _createMockUser(
            uid: 'user1',
            email: 'test@test.com',
          );
          when(
            mockAuthRepository.login(
              email: 'test@test.com',
              password: 'password123',
            ),
          ).thenAnswer((_) async => mockUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginEvent(email: 'test@test.com', password: 'password123'),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>()
              .having((state) => state.userId, 'userId', 'user1')
              .having((state) => state.email, 'email', 'test@test.com'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] on failed login',
        build: () {
          when(
            mockAuthRepository.login(email: 'test@test.com', password: 'wrong'),
          ).thenThrow(Exception('Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginEvent(email: 'test@test.com', password: 'wrong'),
        ),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      );
    });

    group('SignUpEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful signup',
        build: () {
          final mockUser = _createMockUser(
            uid: 'newuser1',
            email: 'newuser@test.com',
          );
          when(
            mockAuthRepository.signUp(
              email: 'newuser@test.com',
              password: 'password123',
            ),
          ).thenAnswer((_) async => mockUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const SignUpEvent(email: 'newuser@test.com', password: 'password123'),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>()
              .having((state) => state.userId, 'userId', 'newuser1')
              .having((state) => state.email, 'email', 'newuser@test.com'),
        ],
      );
    });

    group('LogoutEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on logout',
        build: () {
          when(mockAuthRepository.logout()).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(const LogoutEvent()),
        expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
      );
    });
  });
}

// Helper to create mock User
User _createMockUser({required String uid, required String email}) {
  final mockUser = MockUser();
  when(mockUser.uid).thenReturn(uid);
  when(mockUser.email).thenReturn(email);
  return mockUser;
}

class MockUser extends Mock implements User {}
