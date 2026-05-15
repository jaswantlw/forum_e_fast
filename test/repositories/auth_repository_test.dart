import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_service/firebase_service_exports.dart';
import 'package:forum_e_fast/repositories/auth_repository.dart';

@GenerateMocks([FirebaseService])
void main() {
  group('AuthRepository', () {
    late MockFirebaseService mockFirebaseService;
    late AuthRepository authRepository;

    setUp(() {
      mockFirebaseService = MockFirebaseService();
      authRepository = AuthRepository(firebaseService: mockFirebaseService);
    });

    group('signUp', () {
      test('calls firebaseService.signUp with correct parameters', () async {
        // Mock user
        final mockUser = _createMockUser(uid: 'user1', email: 'test@test.com');

        when(
          mockFirebaseService.signUp(
            email: 'test@test.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockUser);

        final result = await authRepository.signUp(
          email: 'test@test.com',
          password: 'password123',
        );

        expect(result.uid, 'user1');
        expect(result.email, 'test@test.com');
        verify(
          mockFirebaseService.signUp(
            email: 'test@test.com',
            password: 'password123',
          ),
        ).called(1);
      });

      test('throws exception when signUp fails', () async {
        when(
          mockFirebaseService.signUp(email: 'test@test.com', password: 'weak'),
        ).thenThrow(Exception('Weak password'));

        expect(
          () => authRepository.signUp(email: 'test@test.com', password: 'weak'),
          throwsException,
        );
      });
    });

    group('login', () {
      test('calls firebaseService.login with correct parameters', () async {
        final mockUser = _createMockUser(uid: 'user1', email: 'test@test.com');

        when(
          mockFirebaseService.login(
            email: 'test@test.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockUser);

        final result = await authRepository.login(
          email: 'test@test.com',
          password: 'password123',
        );

        expect(result.uid, 'user1');
        expect(result.email, 'test@test.com');
        verify(
          mockFirebaseService.login(
            email: 'test@test.com',
            password: 'password123',
          ),
        ).called(1);
      });

      test('throws exception when login fails', () async {
        when(
          mockFirebaseService.login(email: 'test@test.com', password: 'wrong'),
        ).thenThrow(Exception('Invalid credentials'));

        expect(
          () => authRepository.login(email: 'test@test.com', password: 'wrong'),
          throwsException,
        );
      });
    });

    group('logout', () {
      test('calls firebaseService.logout', () async {
        when(mockFirebaseService.logout()).thenAnswer((_) async => {});

        await authRepository.logout();

        verify(mockFirebaseService.logout()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('returns user when logged in', () {
        final mockUser = _createMockUser(uid: 'user1', email: 'test@test.com');

        when(mockFirebaseService.getCurrentUser()).thenReturn(mockUser);

        final result = authRepository.getCurrentUser();

        expect(result, isNotNull);
        expect(result?.uid, 'user1');
      });

      test('returns null when not logged in', () {
        when(mockFirebaseService.getCurrentUser()).thenReturn(null);

        final result = authRepository.getCurrentUser();

        expect(result, null);
      });
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
