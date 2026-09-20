# forms_kit

Flutter's `Form`, `TextFormField` and `FormField<T>` for
[DartNative](https://dartnative.com), on the native text field.

<p align="center">
  <img src="https://raw.githubusercontent.com/edkluivert/forms_kit/main/doc/demo.gif" width="360" alt="forms_kit: submitting an empty sign-up form shows every error, the fields fill in, a server rejection lands on the email field through forceErrorText, and the corrected form saves" />
</p>


## Why

DartNative ships a native `TextField` and nothing above it. There is no
`Form`, no `TextFormField`, no `validator:`, no `onSaved`, no focus order,
and nowhere to show an error. This package adds exactly those, with the
names, parameters and lifecycle Flutter developers already use, so a screen
written against Flutter's form API ports with its imports changed, and so
formz, bloc, riverpod or any other state holder plugs in the same way it
does in Flutter.

## Native to the core

- The input is DartNative's `TextField`: UIKit's `UITextField` or
  `UITextView`, Android's `EditText`. Nothing here paints a text field.
- The box around it is a composed `Container`. With no `decoration` border
  it takes the platform's own look, Apple's inset-grouped fill on iOS and
  the Material 3 outline on Android. Give `decoration` a border, `filled` or
  `fillColor` and those are honoured instead.
- Errors and helpers are supporting text under the field, with an error
  tint on the surface.
- Keyboard "next" moves to the next field in the form and the last field
  shows "done" and dismisses the keyboard, without wiring focus nodes.
  `validate()` focuses the first invalid field. Focus requests are deferred
  a frame, as the framework asks.
- Pure Dart. No Swift, no Kotlin.

## Usage

```dart
import 'package:dartnative/dartnative.dart';
import 'package:forms_kit/forms_kit.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  String? _email;

  Future<void> _submit() async {
    // Flutter's validate(): runs every validator and shows every error. The button
    // stays enabled, so a tap on an incomplete form is what reveals the errors.
    if (!_formKey.currentState!.validate()) {
      _formKey.currentState!.focusFirstInvalid(); // DartNative extra, optional
      return;
    }
    _formKey.currentState!.save();
    await api.signIn(_email!, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Sign in')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email', hintText: 'you@example.com'),
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction, // re-checks as you type
            validator: Validators.compose([Validators.required(), Validators.email()]),
            onSaved: (v) => _email = v,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: Validators.minLength(8),
          ),
          const SizedBox(height: 24),
          Button(
            title: 'Sign in',
            variant: ButtonVariant.filled,
            onPressed: _submit,   // any DartNative Button; the form is reached through the key
          ),
        ]),
      ),
    );
  }
}
```

To gate the button instead, use `Form.onChanged` with `FormState.isValid`,
which checks the values without setting any error text:

```dart
Form(
  onChanged: () => setState(() => _canSubmit = _formKey.currentState!.isValid),
  ...
)
Button(onPressed: _canSubmit ? _submit : null, ...)
```

A gated button never calls `validate()`, so a tap on an incomplete form shows
nothing; the example keeps the button enabled for that reason.

## With formz, bloc, or your own state

Keep the values in your state holder and let the field be a view of it,
the same three hooks Flutter's `TextFormField` offers:

```dart
TextFormField(
  controller: _emailController,            // or onChanged: (v) => bloc.add(EmailChanged(v))
  forceErrorText: state.email.displayError?.message, // the holder's message, as in Flutter
  decoration: const InputDecoration(labelText: 'Email'),
)
```

`validator` is optional; leave it out when the holder validates. `Form` still
gives you "next" traversal, `isValid`, `onChanged`, and `validate()` for the
fields that do use validators.

## What matches Flutter

| API | Notes |
|---|---|
| `Form(key:, child:, autovalidateMode:, onChanged:)` | `Form.of`, `Form.maybeOf`, `GlobalKey<FormState>` |
| `FormState.validate()` / `validateGranularly()` / `save()` / `reset()` / `clearError()` | Ported from Flutter's `form.dart`. Extras: `isValid` (no error text set), `focusFirstInvalid()` |
| `TextFormField(...)` | `controller`, `initialValue`, `focusNode`, `forceErrorText`, `errorBuilder`, `decoration`, `keyboardType`, `textCapitalization`, `textInputAction`, `style`, `textAlign`, `autofocus`, `readOnly`, `obscureText`, `autocorrect`, `maxLines`, `minLines`, `maxLength`, `inputFormatters`, `enabled`, `cursorColor`, `buildCounter`, `onChanged`, `onTap`, `onEditingComplete`, `onFieldSubmitted`, `onSaved`, `validator`, `autovalidateMode` |
| `FormField<T>(initialValue:, validator:, onSaved:, onReset:, forceErrorText:, errorBuilder:, builder:, enabled:, autovalidateMode:)` | `FormFieldState<T>`: `value`, `errorText`, `hasError`, `hasInteractedByUser`, `isValid`, `didChange`, `setValue`, `validate`, `save`, `reset`, `clearError` |
| `AutovalidateMode.disabled` / `onUserInteraction` / `always` | DartNative's own enum, same values as Flutter |
| `InputDecoration` | `labelText`, `hintText`, `helperText`, `counterText`, `prefixIcon`, `suffixIcon`, `hintStyle`, `labelStyle`, `contentPadding`, `border`, `enabledBorder`, `focusedBorder`, `errorBorder`, `focusedErrorBorder`, `disabledBorder`, `filled`, `fillColor` |

## What differs, and why

- **`labelText` renders above the field.** The native input has no floating
  label to animate.
- **No `decoration.errorText`**: DartNative's `InputDecoration` has no such
  field. Use `forceErrorText`, Flutter's own parameter for an externally
  supplied error. Validator errors need no parameter.
- **`errorStyle` and `helperStyle` are parameters** for the same reason.
- **`prefixIcon` and `suffixIcon` as `IconData`** map to the native field's
  own accessory slots. `decoration.prefixIcon` / `suffixIcon` widgets are
  composed beside the input.
- **`UnderlineInputBorder`** is drawn as a one-pixel row under the field,
  since DartNative renders only uniform borders.
- **Keyboard "next" is automatic** when `textInputAction` is null and
  another field follows. Set it explicitly to opt out.
- Not available on the native field, so not here: `onTapOutside`,
  `enableInteractiveSelection`, `autofillHints`, `expands`,
  `obscuringCharacter`, `restorationId`.

## Validators

`validator:` takes any `String? Function(String?)`. `Validators` has
`required`, `email`, `minLength`, `maxLength`, `pattern`, `numeric`, `phone`,
`matches(() => other.text)` and `compose([...])`. Everything except
`required` passes an empty value, so an optional field needs only its format
validator. A hand-written closure composes with them.

## Theme

`FormsTheme(data: FormsThemeData.ios | .material | .platform | custom)`
sets the default surface, text styles and colours for a subtree. A
`decoration` border overrides the surface per field.

The iOS surface draws no ring on focus, as Apple's inset-grouped fields do
not; the cursor is the cue. To add one:

```dart
FormsTheme(
  data: FormsThemeData.ios.copyWith(focusedColor: const Color(0xFF0F7A69)),
  child: form,
)
```

## Platform behaviour to expect

- **Android** shows the Material 3 outline thickening and taking the accent
  colour on focus; iOS shows the cursor only, unless the theme sets
  `focusedColor`.
- **iOS number pads have no next or return key**, so traversal from a
  `TextInputType.phone` or `number` field is by tapping the next field.
- **iOS wipes a secure field on the first edit after you return to it.** A
  `UITextField` with secure entry discards its text when editing resumes, so
  the first backspace in a password field you tap back into clears it, while
  Android removes one character. Confirmed on both platforms 2026-09-13.
  That is UIKit, and native apps behave the same; Flutter hides it only
  because it draws its own field.
- **Two secure fields on one screen trigger iOS Password AutoFill.** iOS
  reads a password-and-confirm pair as a sign-up form and, when a secure
  field takes focus, tries to present its Automatic Strong Password UI. On a
  device without iCloud Keychain, or for an app without an associated
  domain, that UI is torn down again: the keyboard arrives late and a
  sheet appears to rise and dismiss. This is UIKit, reproduced with two bare
  DartNative `TextField`s and no forms_kit code; a single secure field never
  does it. The UIKit control is `textContentType`, which DartNative's
  `TextField` does not expose yet, so nothing in this package can switch it
  off. With iCloud Keychain on it becomes the normal strong-password
  suggestion, as in any native app.

## Example

`example/` is a runnable DartNative app with a sign-up form: submit on an
empty form to see every error at once and the first bad field take focus,
a password eye toggle, a fake server rejection delivered through
`forceErrorText`, and an app-bar menu that swaps the field look between
platform, iOS, Material and a brand theme.

```sh
cd example
dn pub get
dn run -d <device-id>
```

## Requirements

DartNative framework revision 80edbf105e (2026-09-08) or newer, where
`TextEditingController` is two-way. Run `dn upgrade` on older builds.

## Development

```sh
dn pub get --no-example   # resolves dartnative from the installed SDK
dart test                 # validators; pure Dart
dart analyze              # with assists_kit's DartNative warnings, see analysis_options.yaml
```

`--no-example` matters: a plain `dn pub get` at the package root also sweeps
`example/` with pub alone, which cannot see the SDK's packages and reports
`dartnative_skia` as missing. The package itself still resolves; the message
is noise. Inside `example/`, `dn pub get` and `dn run` work as in any app.

Widget-level tests are not possible yet: DartNative's framework sources ship
as API stubs, and widget testing is on DartNative's own roadmap.

## Licence

MIT. `Form`, `FormField` and `TextFormField` are ported from the Flutter
framework (BSD-3-Clause); the notice is in LICENSE.
