import 'package:forms_kit/src/validators.dart';
import 'package:test/test.dart';

void main() {
  group('required', () {
    final v = Validators.required();
    test('rejects null, empty and whitespace', () {
      expect(v(null), 'Required');
      expect(v(''), 'Required');
      expect(v('   '), 'Required');
    });
    test('accepts text', () => expect(v('a'), isNull));
  });

  group('email', () {
    final v = Validators.email();
    test('accepts a plain address', () => expect(v('a@b.co'), isNull));
    test('rejects a missing domain', () => expect(v('a@b'), isNotNull));
    test('passes empty, leaving emptiness to required', () {
      expect(v(''), isNull);
      expect(v(null), isNull);
    });
  });

  test('minLength and maxLength', () {
    expect(Validators.minLength(3)('ab'), isNotNull);
    expect(Validators.minLength(3)('abc'), isNull);
    expect(Validators.maxLength(3)('abcd'), isNotNull);
    expect(Validators.maxLength(3)(''), isNull);
  });

  test('numeric and phone', () {
    expect(Validators.numeric()('12.5'), isNull);
    expect(Validators.numeric()('12a'), isNotNull);
    expect(Validators.phone()('+234 806 123 4567'), isNull);
    expect(Validators.phone()('12'), isNotNull);
  });

  test('matches compares against a live value', () {
    var other = 'x';
    final v = Validators.matches(() => other);
    expect(v('x'), isNull);
    other = 'y';
    expect(v('x'), 'Values do not match');
  });

  test('compose returns the first failure', () {
    final v = Validators.compose([
      Validators.required(),
      Validators.email(message: 'bad email'),
    ]);
    expect(v(''), 'Required');
    expect(v('nope'), 'bad email');
    expect(v('a@b.co'), isNull);
  });

  test('validators are plain functions, so hand-written ones compose too', () {
    final v = Validators.compose([
      Validators.required(),
      (value) => value == 'admin' ? 'That name is taken' : null,
    ]);
    expect(v('admin'), 'That name is taken');
    expect(v('ada'), isNull);
  });
}
