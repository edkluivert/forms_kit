# forms_kit example

A sign-up form on native fields. The app depends on the package by path, so
edits to `../lib` show up on hot reload.

```sh
dn pub get
dn devices
dn run -d <ios-simulator-id>
dn run -d <android-emulator-id>
```

What to compare between the two platforms:

- The field surface: grey inset fill on iOS, outline on Android that
  thickens and takes the accent colour on focus.
- Keyboard "next" walks down the form; the last field shows "done".
- Leave the email field with a bad address: the error appears under it.
- Type letters into the phone field: the digits-only formatter drops them
  before they are drawn.
- Submit with the terms switch off: the form focuses the first invalid
  field, the error shows under the switch, and iOS gives a haptic.
- The submit button disables itself for the one-second fake API call.

The runner glue in `ios/` and `android/` is what `dn create` generated. Do
not edit it unless you know the runtime.
