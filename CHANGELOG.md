## 0.1.0

Initial release: Flutter's form API on DartNative's native text field.

- `Form`, `FormState`, `FormField<T>` and `FormFieldState<T>` ported from
  Flutter's `form.dart` (BSD-3-Clause): `validate()`, `validateGranularly()`,
  `save()`, `reset()`, `clearError()`, `onChanged`, `canPop` /
  `onPopInvokedWithResult`, `forceErrorText`, `errorBuilder`, `onReset`,
  `hasInteractedByUser`, `isValid`.
- `TextFormField` ported from Flutter's `text_form_field.dart` with the
  parameters DartNative's `TextField` supports, plus `prefixIcon` /
  `suffixIcon` as `IconData` and `clearButtonMode` from the native field.
- `NativeInputDecorator`: label, surface, helper, error and counter around
  the native input, honouring `InputDecoration` borders and fill, or the
  platform look from `FormsTheme`.
- DartNative extras: automatic keyboard "next" traversal,
  `FormState.focusFirstInvalid()`, `hasFieldAfter()`, `focusFieldAfter()`.
- `Validators`: `required`, `email`, `minLength`, `maxLength`, `pattern`,
  `numeric`, `phone`, `matches`, `compose`.
- `formsKitDebug`: prints focus, rebuild and keyboard-action order for
  device investigations.
- Known platform behaviour, documented in the README: two secure fields on
  one iOS screen trigger the system's Automatic Strong Password attempt.
