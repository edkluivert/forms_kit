/// Forms for DartNative, with Flutter's `Form` API.
///
/// DartNative ships a native `TextField` but no `Form`, `TextFormField` or
/// `FormField`. This package provides them with the same names, parameters
/// and lifecycle as Flutter's, rendered on the native field: the input is
/// UIKit's or Android's own control, and only the surface, label, helper and
/// error text are composed, following each platform's conventions.
///
/// ```dart
/// final _formKey = GlobalKey<FormState>();
///
/// Form(
///   key: _formKey,
///   child: Column(children: [
///     TextFormField(
///       decoration: const InputDecoration(labelText: 'Email'),
///       keyboardType: TextInputType.emailAddress,
///       autovalidateMode: AutovalidateMode.onUserInteraction,
///       validator: Validators.email(),
///       onSaved: (v) => _email = v,
///     ),
///     Button(title: 'Sign in', onPressed: () {
///       // validate() shows every error; the button stays enabled so a tap
///       // on an incomplete form reveals what is missing.
///       if (_formKey.currentState!.validate()) {
///         _formKey.currentState!.save();
///         _signIn();
///       }
///     }),
///   ]),
/// )
/// ```
///
/// To gate the button instead, `Form.onChanged` with `FormState.isValid`
/// checks the values without setting any error text.
///
/// `Form`, `FormState`, `FormField` and `TextFormField` are ported from the
/// Flutter framework (BSD-3-Clause, see LICENSE) and keep its API. With formz,
/// a bloc or any other state holder: keep the values there, drive the field
/// with `controller` or `onChanged`, and show the holder's message through
/// `forceErrorText`, exactly as in Flutter. `validator` is optional.
library;

export 'src/input_decorator.dart';
export 'src/debug.dart';
export 'src/form.dart';
export 'src/form_field.dart';
export 'src/forms_theme.dart';
export 'src/text_form_field.dart';
export 'src/validators.dart';
