# Report for DartNative: expose `textContentType` / `autofillHints` on `TextField`

**Symptom.** On iOS 26, when a screen contains two `TextField(obscureText: true)`
widgets (password and confirm), focusing either secure field makes the keyboard
arrive 700–900 ms late, and a keyboard-sized sheet appears to rise and dismiss
itself. Once it has happened, later secure-field focuses on the same screen
behave the same way. One secure field never shows it.

**Cause.** iOS Password AutoFill classifies two secure fields with no
`textContentType` as a sign-up form and, on focus, requests its Automatic Strong
Password UI. When it cannot provide one, the UI is torn down. Simulator UIKit log
(`xcrun simctl spawn <udid> log show --predicate 'process == "Runner"'`):

```
[com.apple.UIKit:KeyboardSceneDelegate] Reloading input views for key-window scene responder: <dartnative_ios.DNTextField ...>
[com.apple.UIKit:UIKeyboardExtended] Requesting scene for autofill UI
[com.apple.xpc:connection] activating connection: ... name=com.apple.SafariFoundation.AutoFillHelper
[com.apple.mobilesafari:AutoFill] Cannot show Automatic Strong Passwords for app bundleID: com.example.cue due to error: iCloud Keychain is disabled
[com.apple.TextInputUI:KeyboardTrackingCoordinator] ... frame={{0, 638}, {440, 318}}   <- 717 ms after the tap
```

The DartNative side is not at fault: no Dart code runs in that window and the
reconciler flushes nothing. The stall is UIKit waiting on the AutoFill helper.

**Minimal reproduction** (no packages beyond `dartnative`):

```dart
Column(children: [
  TextField(decoration: InputDecoration(hintText: 'Phone'), keyboardType: TextInputType.phone),
  TextField(decoration: InputDecoration(hintText: 'Password'), obscureText: true),
  TextField(decoration: InputDecoration(hintText: 'Confirm'), obscureText: true),
])
```

Tap Phone, type a digit, tap Password. Reproduced on iPhone 17 Pro Max
simulator (iOS 26.1) and a physical iPhone on iOS 26 with iCloud Keychain off.

**Tried and not sufficient:** `autocorrect: false`, `keyboardType:
TextInputType.visiblePassword`, attaching or omitting controllers and focus
nodes, `textInputAction`, handlers, surrounding containers and borders,
deferring rebuilds, form-level vs field-level validation.

**Request.** Expose UIKit's `textContentType` (and Android's autofill hints)
on `TextField`, ideally as Flutter's `autofillHints` so ports carry over:
`AutofillHints.password` → `.password` (login form, no strong-password
attempt), `AutofillHints.newPassword` → `.newPassword` (sign-up, proper
suggestion), `AutofillHints.telephoneNumber`, `.email`, `.username`, and
`.oneTimeCode`. The binary already references `setTextContentType:` and
`setPasswordRules:`.

---

# Second request: mount `TextField` inside Material's `TextInputLayout` on Android

DartNative's `TextField` mounts a bare `EditText`. Material's labelled field,
`TextInputLayout`, must be the EditText's parent at creation, so it cannot be
added from Dart or from a package: forms_kit draws the outline, floating label,
helper, error and counter with a `Container` and `Text` widgets instead, an
approximation of Material 3 rather than the component. Native-first on Android
means the real thing. A `TextField` option that mounts the EditText inside a
`TextInputLayout` and maps `InputDecoration.labelText`, `helperText`,
`counterText`, `border` and the error state onto it would let form packages
use the platform component on both sides, as they already can with the
inset-grouped composition UIKit expects on iOS.
