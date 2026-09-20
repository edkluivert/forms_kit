## 0.1.3

- Demo video of the sign-up showcase (`doc/demo.gif`, `doc/demo.mp4`) in the
  README: empty-submit errors, keyboard traversal, a server rejection through
  `forceErrorText`, and the successful save.
- Verified against the DartNative 2026-09-17 preview. The keyboard action key
  now reaches `onFieldSubmitted`, so `textInputAction: next` walks to the next
  field and `done` dismisses the keyboard as documented.

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
