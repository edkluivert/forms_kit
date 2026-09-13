/// Ready-made `validator:` functions for `TextFormField`. Each returns an
/// error message or null, exactly the `FormFieldValidator<String>` shape
/// Flutter uses, so a hand-written closure and these compose freely.
///
/// Every validator except [Validators.required] passes an empty value, so an
/// optional field needs only its format validator.
library;

typedef StringValidator = String? Function(String? value);

abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final _phone = RegExp(r'^\+?[0-9 ()-]{7,}$');
  static final _numeric = RegExp(r'^-?\d+(\.\d+)?$');

  /// Rejects null, empty and whitespace-only values.
  static StringValidator required({String message = 'Required'}) =>
      (value) => (value == null || value.trim().isEmpty) ? message : null;

  static StringValidator email({String message = 'Enter a valid email'}) =>
      _optional((value) => _email.hasMatch(value) ? null : message);

  static StringValidator minLength(int length, {String? message}) => _optional(
    (value) => value.length >= length
        ? null
        : message ?? 'Use at least $length characters',
  );

  static StringValidator maxLength(int length, {String? message}) => _optional(
    (value) => value.length <= length
        ? null
        : message ?? 'Use at most $length characters',
  );

  static StringValidator pattern(RegExp regExp, {required String message}) =>
      _optional((value) => regExp.hasMatch(value) ? null : message);

  static StringValidator numeric({String message = 'Enter a number'}) =>
      _optional((value) => _numeric.hasMatch(value.trim()) ? null : message);

  static StringValidator phone({
    String message = 'Enter a valid phone number',
  }) => _optional((value) => _phone.hasMatch(value.trim()) ? null : message);

  /// Passes when the value equals what [other] returns at validation time.
  /// For confirm-password fields: `Validators.matches(() => _password.text)`.
  static StringValidator matches(
    String? Function() other, {
    String message = 'Values do not match',
  }) =>
      (value) => value == other() ? null : message;

  /// Runs [validators] in order and returns the first error.
  static StringValidator compose(List<StringValidator> validators) => (value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  };

  static StringValidator _optional(String? Function(String value) check) =>
      (value) => (value == null || value.isEmpty) ? null : check(value);
}
