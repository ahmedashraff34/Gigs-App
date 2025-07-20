class ValidationUtils {
  // Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  // Phone validation regex pattern (allows digits, spaces, dashes, and plus sign)
  static final RegExp _phoneRegex = RegExp(r'^[\d\s\-\+]+$');

  /// Validates first name - must be at least 1 letter
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    if (value.trim().length < 1) {
      return 'First name must be at least 1 character';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'First name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates last name - must be at least 1 letter
  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    if (value.trim().length < 1) {
      return 'Last name must be at least 1 character';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Last name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates username - must be at least 3 characters
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validates phone number - must be at least 7 digits
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 7) {
      return 'Phone number must be at least 7 digits';
    }
    
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validates password - must be at least 8 characters
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validates login credentials
  static String? validateLoginUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }
} 