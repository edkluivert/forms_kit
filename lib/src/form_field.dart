// Derived from the Flutter framework, packages/flutter/lib/src/widgets/form.dart.
// Copyright 2014 The Flutter Authors. All rights reserved. BSD-3-Clause; see
// LICENSE. Adapted to DartNative: restoration, semantics and the onUnfocus
// focus wrapper are removed; `deactivate` (absent in DartNative) becomes
// `dispose` for unregistering.

import 'package:dartnative/dartnative.dart';

import 'form.dart';

/// Signature for validating a form field.
///
/// Returns an error string to display if the input is invalid, or null
/// otherwise.
typedef FormFieldValidator<T> = String? Function(T? value);

/// Signature for being notified when a form field changes value.
typedef FormFieldSetter<T> = void Function(T? newValue);

/// Signature for building the widget representing the form field.
typedef FormFieldBuilder<T> = Widget Function(FormFieldState<T> field);

/// Signature for building a custom error widget from an error text.
typedef FormFieldErrorBuilder =
    Widget Function(BuildContext context, String errorText);

/// A single form field.
///
/// This widget maintains the current state of the form field, so that updates
/// and validation errors are visually reflected in the UI.
///
/// When used inside a [Form], you can use methods on [FormState] to query or
/// manipulate the form data as a whole. For example, calling
/// [FormState.save] will invoke each [FormField]'s [onSaved] callback in turn.
///
/// Use a [GlobalKey] with [FormField] if you want to retrieve its current
/// state, for example if you want one form field to depend on another.
///
/// A [Form] ancestor is not required. The [Form] allows one to save, reset,
/// or validate multiple fields at once. To use without a [Form], pass a
/// [GlobalKey] to the constructor and use [GlobalKey.currentState] to save or
/// reset the form field.
class FormField<T> extends StatefulWidget {
  const FormField({
    super.key,
    required this.builder,
    this.onSaved,
    this.onReset,
    this.forceErrorText,
    this.validator,
    this.errorBuilder,
    this.initialValue,
    this.enabled = true,
    AutovalidateMode? autovalidateMode,
  }) : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled;

  /// An optional method to call with the final value when the form is saved
  /// via [FormState.save].
  final FormFieldSetter<T>? onSaved;

  /// An optional method to call when the form is reset via [FormState.reset].
  final VoidCallback? onReset;

  /// An optional property that forces the [FormFieldState] into an error
  /// state by directly setting the [FormFieldState.errorText] property
  /// without running the validator function. This is how an external state
  /// holder such as formz shows its message.
  final String? forceErrorText;

  /// An optional method that validates an input. Returns an error string to
  /// display if the input is invalid, or null otherwise.
  final FormFieldValidator<T>? validator;

  /// Builds a widget for the error text instead of plain [Text].
  final FormFieldErrorBuilder? errorBuilder;

  /// Function that returns the widget representing this form field. It is
  /// passed the form field state as input, containing the current value and
  /// validation state of this field.
  final FormFieldBuilder<T> builder;

  /// An optional value to initialize the form field to, or null otherwise.
  final T? initialValue;

  /// Whether the form is able to receive user input.
  final bool enabled;

  /// Used to enable/disable this form field auto validation and update its
  /// error text.
  final AutovalidateMode autovalidateMode;

  @override
  FormFieldState<T> createState() => FormFieldState<T>();
}

/// The current state of a [FormField]. Passed to the [FormFieldBuilder] method
/// for use in constructing the form field's widget.
class FormFieldState<T> extends State<FormField<T>> {
  late T? _value = widget.initialValue;
  String? _errorText;
  bool _hasInteractedByUser = false;
  FormState? _form;

  /// The current value of the form field.
  T? get value => _value;

  /// The current validation error returned by the [FormField.validator]
  /// callback, or the manually provided error message using the
  /// [FormField.forceErrorText] property.
  String? get errorText => _errorText;

  /// True if this field has any validation errors.
  bool get hasError => _errorText != null;

  /// Returns true if the user has modified the value of this field.
  bool get hasInteractedByUser => _hasInteractedByUser;

  /// True if the current value is valid. Does not set [errorText] or
  /// [hasError].
  bool get isValid =>
      widget.forceErrorText == null && widget.validator?.call(_value) == null;

  /// DartNative extra. Moves keyboard focus to this field, or null when the
  /// field cannot take focus. [TextFormField] overrides it.
  void Function()? get requestFocus => null;

  /// Calls the [FormField]'s onSaved method with the current value.
  void save() {
    widget.onSaved?.call(value);
  }

  /// Resets the field to its initial value.
  void reset() {
    setState(() {
      _value = widget.initialValue;
      clearErrorInternal();
    });
    widget.onReset?.call();
    Form.maybeOf(context)?.fieldDidChange();
  }

  /// Resets the error text without changing the value.
  void clearError() {
    setState(() {
      clearErrorInternal();
    });
    Form.maybeOf(context)?.fieldDidChange();
  }

  /// Calls [FormField.validator] to set the [errorText]. Returns true if there
  /// were no errors.
  bool validate() {
    setState(() {
      _validate();
    });
    return !hasError;
  }

  void clearErrorInternal() {
    _errorText = null;
    _hasInteractedByUser = false;
  }

  void _validate() {
    if (widget.forceErrorText != null) {
      _errorText = widget.forceErrorText;
      return;
    }
    if (widget.validator != null) {
      _errorText = widget.validator!(_value);
    } else {
      _errorText = null;
    }
  }

  /// Updates this field's state to the new value. Useful for responding to
  /// child widget changes, e.g. `Switch.onChanged`.
  void didChange(T? value) {
    setState(() {
      _value = value;
      _hasInteractedByUser = true;
    });
    Form.maybeOf(context)?.fieldDidChange();
  }

  /// Sets the value associated with this form field without triggering a
  /// rebuild or marking the field as interacted with.
  void setValue(T? value) {
    _value = value;
  }

  @override
  void initState() {
    super.initState();
    _errorText = widget.forceErrorText;
  }

  @override
  void didUpdateWidget(FormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forceErrorText != oldWidget.forceErrorText) {
      _errorText = widget.forceErrorText;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final form = Form.maybeOf(context);
    if (form != _form) {
      _form?.unregister(this);
      _form = form;
    }
    switch (form?.widget.autovalidateMode) {
      case AutovalidateMode.always:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.enabled && !hasError && !isValid) {
            validate();
          }
        });
      case AutovalidateMode.onUserInteraction:
      case AutovalidateMode.disabled:
      case null:
        break;
    }
  }

  @override
  void dispose() {
    _form?.unregister(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enabled) {
      switch (widget.autovalidateMode) {
        case AutovalidateMode.always:
          _validate();
        case AutovalidateMode.onUserInteraction:
          if (_hasInteractedByUser) {
            _validate();
          }
        case AutovalidateMode.disabled:
          break;
      }
    }

    Form.maybeOf(context)?.register(this);

    return widget.builder(this);
  }
}
