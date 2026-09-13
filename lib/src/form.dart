// Derived from the Flutter framework, packages/flutter/lib/src/widgets/form.dart.
// Copyright 2014 The Flutter Authors. All rights reserved. BSD-3-Clause; see
// LICENSE. Adapted to DartNative: restoration, semantics announcements and
// the deprecated WillPopScope path are removed; `AutovalidateMode` is
// DartNative's own enum (disabled, always, onUserInteraction).

import 'package:dartnative/dartnative.dart';

import 'debug.dart';
import 'form_field.dart';

typedef PopInvokedWithResultCallback<T> = void Function(bool didPop, T? result);

/// An optional container for grouping together multiple form field widgets
/// (e.g. [TextFormField] widgets).
///
/// Each individual form field should be wrapped in a [FormField] widget, with
/// the [Form] widget as a common ancestor of all of those. Call methods on
/// [FormState] to save, reset, or validate each [FormField] that is a
/// descendant of this [Form]. To obtain the [FormState], you may use [Form.of]
/// with a context whose ancestor is the [Form], or pass a [GlobalKey] to the
/// [Form] constructor and call [GlobalKey.currentState].
class Form extends StatefulWidget {
  const Form({
    super.key,
    required this.child,
    this.canPop,
    this.onPopInvokedWithResult,
    this.onChanged,
    AutovalidateMode? autovalidateMode,
  }) : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled;

  /// Returns the [FormState] of the closest [Form] widget which encloses the
  /// given context, or null if none is found.
  static FormState? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FormScope>();
    return scope?._formState;
  }

  /// Returns the [FormState] of the closest [Form] widget which encloses the
  /// given context.
  static FormState of(BuildContext context) {
    final formState = maybeOf(context);
    assert(
      formState != null,
      'Form.of() was called with a context that does not contain a Form '
      'widget.',
    );
    return formState!;
  }

  final Widget child;

  /// Whether the form's route can be popped. See `PopScope.canPop`.
  final bool? canPop;

  /// Called after a pop attempt. See `PopScope.onPopInvokedWithResult`.
  final PopInvokedWithResultCallback<Object?>? onPopInvokedWithResult;

  /// Called when one of the form fields changes.
  final VoidCallback? onChanged;

  /// Used to enable/disable form fields auto validation and update their
  /// error text.
  final AutovalidateMode autovalidateMode;

  @override
  FormState createState() => FormState();
}

/// State associated with a [Form] widget.
class FormState extends State<Form> {
  int _generation = 0;
  bool _hasInteractedByUser = false;
  final Set<FormFieldState<dynamic>> _fields = <FormFieldState<dynamic>>{};

  /// The fields currently registered with this form, in build order.
  Iterable<FormFieldState<dynamic>> get fields => _fields;

  // Called when a form field has changed. This will cause all form fields
  // to rebuild, useful if form fields have interdependencies.
  void fieldDidChange() {
    formsKitLog('Form.fieldDidChange -> rebuild generation ${_generation + 1}');
    widget.onChanged?.call();
    _hasInteractedByUser = _fields.any(
      (FormFieldState<dynamic> field) => field.hasInteractedByUser,
    );
    _forceRebuild();
  }

  void _forceRebuild() {
    setState(() {
      ++_generation;
    });
  }

  void register(FormFieldState<dynamic> field) {
    _fields.add(field);
  }

  void unregister(FormFieldState<dynamic> field) {
    _fields.remove(field);
  }

  @override
  Widget build(BuildContext context) {
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

    final scope = _FormScope(
      formState: this,
      generation: _generation,
      child: widget.child,
    );
    if (widget.canPop != null || widget.onPopInvokedWithResult != null) {
      return PopScope(
        canPop: widget.canPop ?? true,
        onPopInvokedWithResult: widget.onPopInvokedWithResult,
        child: scope,
      );
    }
    return scope;
  }

  /// Saves every [FormField] that is a descendant of this [Form].
  void save() {
    for (final FormFieldState<dynamic> field in _fields) {
      field.save();
    }
  }

  /// Resets every [FormField] that is a descendant of this [Form] back to its
  /// [FormField.initialValue].
  void reset() {
    for (final FormFieldState<dynamic> field in _fields) {
      field.reset();
    }
    _hasInteractedByUser = false;
    fieldDidChange();
  }

  /// Resets the error text of every [FormField] without changing values.
  void clearError() {
    for (final FormFieldState<dynamic> field in _fields) {
      field.clearErrorInternal();
    }
    fieldDidChange();
  }

  /// Validates every [FormField] that is a descendant of this [Form], and
  /// returns true if there are no errors.
  ///
  /// The form will rebuild to report the results.
  bool validate() {
    formsKitLog('Form.validate');
    _hasInteractedByUser = true;
    _forceRebuild();
    return _validate();
  }

  /// Validates every [FormField] and returns the set of fields that failed.
  Set<FormFieldState<Object?>> validateGranularly() {
    final invalidFields = <FormFieldState<Object?>>{};
    _hasInteractedByUser = true;
    _forceRebuild();
    _validate(invalidFields);
    return invalidFields;
  }

  bool _validate([Set<FormFieldState<Object?>>? invalidFields]) {
    var hasError = false;
    for (final FormFieldState<dynamic> field in _fields) {
      final isFieldValid = field.validate();
      hasError |= !isFieldValid;
      if (invalidFields != null && !isFieldValid) {
        invalidFields.add(field);
      }
    }
    return !hasError;
  }

  /// DartNative extra. True when every registered field's current value
  /// passes its validator. Unlike [validate], this sets no error text, so it
  /// is the right check for enabling a submit button from [Form.onChanged].
  bool get isValid => _fields.every((field) => field.isValid);

  /// DartNative extra. Moves focus to the first field that currently has an
  /// error and can take focus. Returns whether one was found. Typically
  /// called right after a failed [validate].
  bool focusFirstInvalid() {
    for (final field in _fields) {
      if (field.hasError && field.requestFocus != null) {
        field.requestFocus!();
        return true;
      }
    }
    return false;
  }

  /// DartNative extra. Whether a focusable, enabled field follows [from] in
  /// build order; used by [TextFormField] to pick "next" over "done".
  bool hasFieldAfter(FormFieldState<dynamic> from) {
    var seen = false;
    for (final field in _fields) {
      if (seen && field.widget.enabled && field.requestFocus != null) {
        return true;
      }
      if (field == from) seen = true;
    }
    return false;
  }

  /// DartNative extra. Focuses the first focusable, enabled field after
  /// [from]. Returns false when there is none.
  bool focusFieldAfter(FormFieldState<dynamic> from) {
    var seen = false;
    for (final field in _fields) {
      if (seen && field.widget.enabled && field.requestFocus != null) {
        formsKitLog('Form.focusFieldAfter -> requestFocus on next field');
        field.requestFocus!();
        return true;
      }
      if (field == from) seen = true;
    }
    return false;
  }
}

class _FormScope extends InheritedWidget {
  const _FormScope({
    required super.child,
    required FormState formState,
    required int generation,
  }) : _formState = formState,
       _generation = generation;

  final FormState _formState;

  /// Incremented every time a form field has changed. This lets us know when
  /// to rebuild the form.
  final int _generation;

  /// The [Form] associated with this widget.
  Form get form => _formState.widget;

  @override
  bool updateShouldNotify(_FormScope old) => _generation != old._generation;
}
