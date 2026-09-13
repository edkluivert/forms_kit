// forms_kit example: a sign-up form on native fields, written the way a
// Flutter form is written.
//
//   dn run -d <ios-simulator-id>
//   dn run -d <android-emulator-id>
//
// The text inputs are the platform's own controls. Only the box around
// them, the labels and the supporting text are composed, and those follow
// each platform's conventions unless a decoration says otherwise.

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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const _brand = Color(0xFF0F7A69);
  static const _ink = Color(0xFF16191F);
  static const _muted = Color(0xFF6B7280);

  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  String? _name, _email, _phone, _bio;
  bool _terms = false;
  bool _busy = false;
  bool _canSubmit = false;
  String? _summary;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState!;
    // validate() is Flutter's: it shows the errors and returns false. The
    // next line is a DartNative extra and optional; Flutter has no equivalent.
    if (!form.validate()) {
      form.focusFirstInvalid();
      return;
    }
    form.save();
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(seconds: 1)); // the API call
    if (!mounted) return;
    setState(() {
      _busy = false;
      _summary =
          'name: $_name\nemail: $_email\nphone: ${_phone ?? ''}\n'
          'bio: ${_bio ?? ''}\nterms: $_terms';
    });
    showToast(context, 'Account created for $_email');
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
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // LOOK: the button enables only once every field passes.
        onChanged: () =>
            setState(() => _canSubmit = _formKey.currentState!.isValid),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
          children: [
            // LOOK: no decoration given, so the surface is the platform's
            // own: grey inset fill on iOS, an outline on Android that
            // thickens and takes the accent colour when focused.
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Full name',
                hintText: 'Ada Lovelace',
              ),
              textCapitalization: TextCapitalization.words,
              validator: Validators.required(),
              onSaved: (v) => _name = v,
            ),
            const SizedBox(height: 16),
            // LOOK: keyboard "next" walks down the form; the last text field
            // shows "done". Type a bad address and the error appears as you
            // go (onUserInteraction, as in Flutter).
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: Validators.compose([
                Validators.required(),
                Validators.email(),
              ]),
              onSaved: (v) => _email = v,
            ),
            const SizedBox(height: 16),
            // LOOK: the digits-only formatter runs natively before the
            // keystroke is drawn; letters never appear. A counter shows
            // because maxLength is set.
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: '08012345678',
                helperText: 'Optional',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 15,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: Validators.phone(),
              onSaved: (v) => _phone = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters',
              ),
              obscureText: true,
              validator: Validators.compose([
                Validators.required(),
                Validators.minLength(8),
              ]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Confirm password'),
              obscureText: true,
              validator: (v) =>
                  v == _password.text ? null : 'Passwords do not match',
            ),
            const SizedBox(height: 16),
            // LOOK: an explicit Flutter-style decoration. The outline border
            // and fill are honoured on both platforms, so this one looks the
            // same on iOS and Android, unlike the fields above.
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
              ),
              maxLines: 4,
              minLines: 2,
              validator: Validators.maxLength(200),
              onSaved: (v) => _bio = v,
            ),
            const SizedBox(height: 20),
            // LOOK: a non-text field, Flutter's FormField<T> shape. UISwitch
            // on iOS, Material 3 switch on Android. Submit without accepting
            // and the error renders below, from field.errorText.
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
            // LOOK: a plain DartNative Button. The form is reached through
            // the key, exactly as with Flutter's Form.
            Button(
              title: _busy ? 'Creating…' : 'Create account',
              variant: ButtonVariant.filled,
              color: _brand,
              foregroundColor: Colors.white,
              height: 48,
              onPressed: _busy || !_canSubmit ? null : _submit,
            ),
            const SizedBox(height: 8),
            Button(
              title: 'Reset',
              variant: ButtonVariant.plain,
              color: _brand,
              onPressed: () {
                _formKey.currentState!.reset();
                setState(() => _summary = null);
              },
            ),
            if (_summary != null) ...[
              const SizedBox(height: 24),
              const Text(
                'SAVED VALUES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _summary!,
                style: const TextStyle(fontSize: 14, color: _ink),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
