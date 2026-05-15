import 'package:flutter_test/flutter_test.dart';
import 'package:forum_e_fast/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns null for valid email', () {
        final result = Validators.validateEmail('test@example.com');
        expect(result, null);
      });

      test('returns error for empty email', () {
        final result = Validators.validateEmail('');
        expect(result, isNotNull);
        expect(result, contains('empty'));
      });

      test('returns error for invalid email format', () {
        final result = Validators.validateEmail('invalid.email');
        expect(result, isNotNull);
        expect(result, contains('valid email'));
      });

      test('returns error for email without domain', () {
        final result = Validators.validateEmail('test@');
        expect(result, isNotNull);
      });
    });

    group('validatePassword', () {
      test('returns null for valid password', () {
        final result = Validators.validatePassword('password123');
        expect(result, null);
      });

      test('returns error for empty password', () {
        final result = Validators.validatePassword('');
        expect(result, isNotNull);
        expect(result, contains('empty'));
      });

      test('returns error for password less than 6 characters', () {
        final result = Validators.validatePassword('pass');
        expect(result, isNotNull);
        expect(result, contains('6 characters'));
      });

      test('returns error for password more than 128 characters', () {
        final result = Validators.validatePassword('a' * 129);
        expect(result, isNotNull);
        expect(result, contains('128 characters'));
      });
    });

    group('validateContent', () {
      test('returns null for valid content', () {
        final result = Validators.validateContent('This is valid content');
        expect(result, null);
      });

      test('returns error for empty content', () {
        final result = Validators.validateContent('');
        expect(result, isNotNull);
        expect(result, contains('empty'));
      });

      test('returns error for content less than minimum length', () {
        final result = Validators.validateContent('ab', minLength: 3);
        expect(result, isNotNull);
        expect(result, contains('3 characters'));
      });

      test('returns error for content more than maximum length', () {
        final result = Validators.validateContent('a' * 1001, maxLength: 1000);
        expect(result, isNotNull);
        expect(result, contains('1000 characters'));
      });
    });

    group('validateUsername', () {
      test('returns null for valid username', () {
        final result = Validators.validateUsername('john_doe');
        expect(result, null);
      });

      test('returns error for empty username', () {
        final result = Validators.validateUsername('');
        expect(result, isNotNull);
        expect(result, contains('empty'));
      });

      test('returns error for username less than 2 characters', () {
        final result = Validators.validateUsername('a');
        expect(result, isNotNull);
        expect(result, contains('2 characters'));
      });

      test('returns error for username more than 50 characters', () {
        final result = Validators.validateUsername('a' * 51);
        expect(result, isNotNull);
        expect(result, contains('50 characters'));
      });
    });
  });
}
