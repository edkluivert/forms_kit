# forms_kit example

A sign-up form on native fields. The app depends on the package by path, so
edits to `../lib` show up on hot reload.

```sh
dn pub get
dn devices
dn run -d <ios-simulator-id>
dn run -d <android-emulator-id>
```

Walkthrough, in the order a reviewer would tap:

1. **Tap Create account with nothing filled in.** Every field shows its
   error at once, the first invalid field takes focus and the keyboard
   opens on it, and a status line counts the fields that still need
   attention. The button is never disabled; that is Flutter's
   `FormState.validate()` reached through the `GlobalKey`.
2. **Type into a field.** Its error clears as you type. The other fields
   keep their errors until you touch them, because each field has
   `AutovalidateMode.onUserInteraction`, as in Flutter. The status line
   updates on every keystroke from `FormState.isValid`, which checks values
   without setting error text.
3. **Keyboard "next"** walks down the form and the last text field shows
   "done". No focus nodes were wired.
4. **Type letters into the phone field.** The digits-only formatter drops
   them before they are drawn. The counter comes from `maxLength`.
5. **Tap the eye** on the password field. Both password fields flip between
   obscured and plain; the eye is a composed `suffixIcon` widget beside the
   native input, while the padlock and envelope are the native field's own
   accessory slots.
6. **Sign up as taken@example.com.** After the one-second fake API call the
   server's rejection lands under the email field through `forceErrorText`,
   the same hook formz, bloc or any other state holder uses. Focus moves to
   the field, and editing it clears the message.
7. **Submit a valid form.** The button reads "Creating…" for the fake call,
   then a toast confirms and a card lists what `FormState.save()` handed to
   the `onSaved` callbacks. Reset clears everything.
8. **The paintbrush in the app bar** swaps the field look between the
   platform's own, iOS, Material and a brand theme. Only the `FormsTheme`
   above the form changes. The About you field keeps its explicit
   `InputDecoration` border in every look, as it would in Flutter.

What to compare between the two platforms:

- The field surface: grey inset fill on iOS, outline on Android that
  thickens and takes the accent colour on focus.
- iOS number pads have no next key, so traversal from the phone field is by
  tapping the next field.
- Submit with the terms switch off: the error renders under the switch from
  `field.errorText`, and iOS gives a haptic.

The runner glue in `ios/` and `android/` is what `dn create` generated. Do
not edit it unless you know the runtime.
