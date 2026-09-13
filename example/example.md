# forms_kit example

The runnable app lives in `../example_app` (a `dn create` project depending
on the package by path):

```sh
cd example_app
dn pub get
dn run -d <device-id>
```

The shape of a form:

```dart
final _formKey = GlobalKey<FormState>();
bool _canSubmit = false;

Form(
  key: _formKey,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  onChanged: () => setState(() => _canSubmit = _formKey.currentState!.isValid),
  child: Column(children: [
    TextFormField(
      decoration: const InputDecoration(labelText: 'Email', hintText: 'you@example.com'),
      keyboardType: TextInputType.emailAddress,
      validator: Validators.compose([Validators.required(), Validators.email()]),
      onSaved: (v) => _email = v,
    ),
    TextFormField(
      controller: _password,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: Validators.minLength(8),
    ),
    Button(
      title: 'Sign in',
      onPressed: !_canSubmit ? null : () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          _signIn();
        }
      },
    ),
  ]),
)
```
