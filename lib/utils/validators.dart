/// Input validators for forum app

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }
    return null;
  }

  // Post/Reply/Comment content validation
  static String? validateContent(
    String? value, {
    int minLength = 1,
    int maxLength = 1000,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Content cannot be empty';
    }
    if (value.trim().length < minLength) {
      return 'Content must be at least $minLength characters';
    }
    if (value.trim().length > maxLength) {
      return 'Content must be less than $maxLength characters';
    }
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    if (value.trim().length < 2) {
      return 'Username must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Username must be less than 50 characters';
    }
    return null;
  }
}
