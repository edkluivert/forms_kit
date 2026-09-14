// forms_kit example: a sign-up form on native fields, written the way a
// Flutter form is written.
//
//   dn run -d <ios-simulator-id>
//   dn run -d <android-emulator-id>
//
// The text inputs are the platform's own controls. Only the box around
// them, the labels and the supporting text are composed, and those follow
// each platform's conventions unless a decoration says otherwise.
//
// Walkthrough, in the order a reviewer would tap:
//
//   1. Tap "Create account" with nothing filled in. Every field shows its
//      error at once and the first invalid one takes focus. That is
//      Flutter's FormState.validate(), reached through the GlobalKey.
//   2. Type into a field. Its error clears as you type, and the other
//      fields keep theirs until you touch them (per-field
//      AutovalidateMode.onUserInteraction, as in Flutter).
//   3. Use the keyboard's "next" key: it walks down the form and the last
//      text field shows "done". No focus nodes were wired.
//   4. Sign up as taken@example.com. The fake server rejects it and the
//      message lands under the email field through forceErrorText, the
//      hook formz, bloc or any state holder uses. Editing the field clears it.
//   5. The paintbrush in the bar swaps the field look between the
//      platform's own, iOS, Material and a brand theme. Nothing in the form
//      changes; only the FormsTheme above it.

import 'package:dartnative/dartnative.dart';
import 'package:forms_kit/forms_kit.dart';

import 'dartnative_plugin_registrant.dart';

void main() {
  DartNativePluginRegistrant.registerAll();
  SystemChrome.defaultStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
  runApp(const SignUpScreen());
}

/// The field look chosen from the app bar menu.
enum _Look { platform, ios, material, brand }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const _brand = Color(0xFF0F7A69);
  static const _ink = Color(0xFF16191F);
  static const _muted = Color(0xFF6B7280);
  static const _danger = Color(0xFFD92D20);

  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState<String>>();
  final _password = TextEditingController();

  String? _name, _email, _phone, _bio;
  bool _terms = false;

  bool _busy = false;
  bool _showPassword = false;

  /// True after the first submit attempt; the status line shows from then.
  bool _attempted = false;

  /// The fake server's rejection of the email, shown via forceErrorText.
  String? _emailServerError;

  Map<String, String>? _saved;
  _Look _look = _Look.platform;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  FormsThemeData get _theme => switch (_look) {
    _Look.platform => FormsThemeData.platform,
    _Look.ios => FormsThemeData.ios,
    _Look.material => FormsThemeData.material,
    _Look.brand => FormsThemeData.ios.copyWith(
      fillColor: const Color(0xFFF0F7F5),
      focusedColor: _brand,
      radius: 14,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _brand,
      ),
      inputStyle: const TextStyle(fontSize: 16, color: _ink),
    ),
  };

  Future<void> _submit() async {
    final form = _formKey.currentState!;
    setState(() => _attempted = true);

    // LOOK: validate() is Flutter's. It runs every validator, shows every
    // error, and returns false. The button is never disabled for this; a
    // tap on an incomplete form is how the user finds out what is missing.
    if (!form.validate()) {
      // DartNative extra, optional: put the keyboard on the first bad field.
      form.focusFirstInvalid();
      showToast(context, 'Fix the highlighted fields');
      return;
    }

    form.save();
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(seconds: 1)); // the API call
    if (!mounted) return;

    // LOOK: a server-side rejection. forceErrorText puts a message under the
    // field without a validator, the same hook a formz or bloc state holder
    // uses to display its own error.
    if (_email!.trim().toLowerCase() == 'taken@example.com') {
      setState(() {
        _busy = false;
        _emailServerError = 'That email is already registered';
      });
      // The field shows the message on its next build. Focus it the way
      // focusFirstInvalid() would; this is FormFieldState.requestFocus, a
      // DartNative extra.
      _emailKey.currentState!.requestFocus!();
      return;
    }

    setState(() {
      _busy = false;
      _saved = {
        'Name': _name ?? '',
        'Email': _email ?? '',
        'Phone': (_phone ?? '').isEmpty ? '(none)' : _phone!,
        'About': (_bio ?? '').isEmpty ? '(none)' : _bio!,
        'Terms': _terms ? 'accepted' : 'not accepted',
      };
    });
    showToast(context, 'Account created for $_email');
  }

  void _reset() {
    _formKey.currentState!.reset();
    setState(() {
      _attempted = false;
      _emailServerError = null;
      _saved = null;
      _showPassword = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      appBar: AppBar(
        title: const Text(
          'Create account',
          style: TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // LOOK: swaps the look of every field below. The form does not
          // change; FormsTheme is an InheritedWidget above it.
          BarButtonItem(
            icon: 'paintbrush',
            fontIcon: CupertinoIcons.paintbrush,
            menu: [
              for (final look in _Look.values)
                MenuAction(
                  title: switch (look) {
                    _Look.platform => 'Platform look',
                    _Look.ios => 'iOS look',
                    _Look.material => 'Material look',
                    _Look.brand => 'Brand look',
                  },
                  icon: look == _look ? CupertinoIcons.checkmark : null,
                  onTap: () => setState(() => _look = look),
                ),
            ],
          ),
        ],
      ),
      body: FormsTheme(
        data: _theme,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
            children: [
              const Text(
                'Tap Create account with nothing filled in to see every '
                'error at once.',
                style: TextStyle(fontSize: 13, color: _muted),
              ),
              const SizedBox(height: 20),
              // LOOK: no decoration border given, so the surface is the
              // platform's own: grey inset fill on iOS, an outline on Android
              // that thickens and takes the accent colour when focused. The
              // person glyph is the native field's own accessory slot.
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  hintText: 'Ada Lovelace',
                ),
                prefixIcon: CupertinoIcons.person,
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: Validators.required(message: 'Enter your name'),
                onSaved: (v) => _name = v,
              ),
              const SizedBox(height: 16),
              // LOOK: keyboard "next" walks down the form. The native clear
              // button appears while editing. A bad address errors as you
              // type; the server's rejection arrives through forceErrorText
              // and clears the moment the field is edited.
              TextFormField(
                key: _emailKey,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                  helperText: 'Try taken@example.com to see a server error',
                ),
                prefixIcon: CupertinoIcons.envelope,
                clearButtonMode: ClearButtonMode.whileEditing,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                forceErrorText: _emailServerError,
                validator: Validators.compose([
                  Validators.required(message: 'Enter your email'),
                  Validators.email(),
                ]),
                onChanged: (_) {
                  if (_emailServerError != null) {
                    setState(() => _emailServerError = null);
                  }
                },
                onSaved: (v) => _email = v,
              ),
              const SizedBox(height: 16),
              // LOOK: the digits-only formatter runs natively before the
              // keystroke is drawn; letters never appear. The counter shows
              // because maxLength is set. Optional, so only the format
              // validator is attached.
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: '08012345678',
                  helperText: 'Optional',
                ),
                prefixIcon: CupertinoIcons.phone,
                keyboardType: TextInputType.phone,
                maxLength: 15,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: Validators.phone(),
                onSaved: (v) => _phone = v,
              ),
              const SizedBox(height: 16),
              // LOOK: a composed suffix widget beside the native input. The
              // eye flips obscureText on both password fields.
              TextFormField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: 'At least 8 characters',
                  suffixIcon: _VisibilityToggle(
                    visible: _showPassword,
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
                prefixIcon: CupertinoIcons.lock,
                obscureText: !_showPassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: Validators.compose([
                  Validators.required(message: 'Choose a password'),
                  Validators.minLength(8),
                ]),
              ),
              const SizedBox(height: 16),
              // LOOK: Validators.matches reads the other controller at
              // validation time, so it stays correct after either field
              // changes.
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
                prefixIcon: CupertinoIcons.lock,
                obscureText: !_showPassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: Validators.compose([
                  Validators.required(message: 'Repeat your password'),
                  Validators.matches(
                    () => _password.text,
                    message: 'Passwords do not match',
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              // LOOK: an explicit Flutter-style decoration. The outline
              // border and fill are honoured on both platforms and survive
              // the look switcher, so this field is the same everywhere.
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'About you',
                  hintText: 'A line or two',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD5D9E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _brand, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _danger, width: 2),
                  ),
                ),
                maxLines: 4,
                minLines: 2,
                maxLength: 120,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: Validators.maxLength(120),
                onSaved: (v) => _bio = v,
              ),
              const SizedBox(height: 20),
              // LOOK: a non-text field, Flutter's FormField<T> shape. UISwitch
              // on iOS, Material 3 switch on Android. Submit without
              // accepting and the error renders below, from field.errorText.
              FormField<bool>(
                initialValue: false,
                validator: (v) =>
                    v == true ? null : 'Accept the terms to continue',
                onSaved: (v) => _terms = v ?? false,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'I accept the terms',
                          style: TextStyle(fontSize: 15, color: _ink),
                        ),
                        Switch(
                          value: field.value ?? false,
                          onChanged: field.didChange,
                          activeTrackColor: _brand,
                        ),
                      ],
                    ),
                    if (field.hasError) ...[
                      const SizedBox(height: 6),
                      Text(
                        field.errorText!,
                        style: FormsTheme.of(context).errorStyle,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // LOOK: a plain DartNative Button, always enabled. The form is
              // reached through the key, exactly as with Flutter's Form.
              Button(
                title: _busy ? 'Creating…' : 'Create account',
                variant: ButtonVariant.filled,
                color: _brand,
                foregroundColor: Colors.white,
                height: 48,
                onPressed: _busy ? null : _submit,
              ),
              if (_attempted) ...[
                const SizedBox(height: 12),
                // LOOK: reads FormState.isValid per field on every change,
                // which checks values without setting any error text.
                // Not const: it must rebuild with this screen too, so it
                // sees a forceErrorText set from here.
                _StatusLine(),
              ],
              const SizedBox(height: 8),
              Button(
                title: 'Reset',
                variant: ButtonVariant.plain,
                color: _brand,
                onPressed: _reset,
              ),
              if (_saved != null) ...[
                const SizedBox(height: 24),
                _SavedCard(values: _saved!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The eye beside the password field. A composed widget in
/// `InputDecoration.suffixIcon`, laid out next to the native input.
class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.visible, required this.onPressed});

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(visible ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
      iconSize: 20,
      color: const Color(0xFF6B7280),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onPressed: onPressed,
    );
  }
}

/// "3 fields need attention" or "Everything looks good", shown once the
/// user has tried to submit.
///
/// Sits below the fields inside the Form, so it builds after them on every
/// change (Form.of registers it for the form's rebuilds) and reads each
/// field's `isValid`, which runs the validator without setting error text.
class _StatusLine extends StatelessWidget {
  const _StatusLine();

  @override
  Widget build(BuildContext context) {
    final invalidCount = Form.of(context).fields.where((f) => !f.isValid).length;
    final ok = invalidCount == 0;
    final color = ok ? const Color(0xFF0F7A69) : const Color(0xFFD92D20);
    final text = ok
        ? 'Everything looks good'
        : invalidCount == 1
        ? '1 field needs attention'
        : '$invalidCount fields need attention';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          ok
              ? CupertinoIcons.checkmark_circle_fill
              : CupertinoIcons.exclamationmark_circle_fill,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// What `FormState.save()` handed to the `onSaved` callbacks.
class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.values});

  final Map<String, String> values;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF0F7F5),
      elevation: 0,
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SAVED VALUES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F7A69),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          for (final entry in values.entries) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF16191F),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}
