// Derived from the Flutter framework,
// packages/flutter/lib/src/material/text_form_field.dart.
// Copyright 2014 The Flutter Authors. All rights reserved. BSD-3-Clause; see
// LICENSE. Adapted to DartNative: parameters the native field does not have
// are dropped, restoration is removed, the decoration is drawn by
// [NativeInputDecorator] (DartNative's TextField renders no box), and
// keyboard "next" traversal is automatic when `textInputAction` is null.

import 'package:dartnative/dartnative.dart';

import 'debug.dart';
import 'form.dart';
import 'form_field.dart';
import 'forms_theme.dart';
import 'input_decorator.dart';

typedef InputCounterWidgetBuilder =
    Widget? Function(
      BuildContext context, {
      required int currentLength,
      required int? maxLength,
      required bool isFocused,
    });

/// A [FormField] that contains a DartNative `TextField`.
///
/// This is a convenience widget that wraps a `TextField` widget in a
/// [FormField].
///
/// A [Form] ancestor is not required. The [Form] allows one to save, reset,
/// or validate multiple fields at once. To use without a [Form], pass a
/// [GlobalKey] to the constructor and use [GlobalKey.currentState] to save or
/// reset the form field.
///
/// When a [controller] is specified, its `TextEditingController.text` defines
/// the [initialValue]. If this [FormField] is part of a scrolling container
/// that lazily constructs its children, a [controller] should be specified,
/// so the field's value survives scrolling. Otherwise [initialValue] is
/// enough.
///
/// DartNative differences from Flutter's `TextFormField`:
///
/// * `decoration.labelText` renders above the field: the native input has no
///   floating label.
/// * `decoration.border`, `filled` and `fillColor` are drawn by a composed
///   surface around the native input, which draws no box of its own. With
///   none set, the surface is the platform's own from [FormsTheme].
/// * Errors come from [validator] or [forceErrorText]; DartNative's
///   `InputDecoration` has no `errorText`.
/// * When [textInputAction] is null, "next" is shown while another field
///   follows in the [Form] and moves focus there; the last field shows
///   "done" and dismisses the keyboard.
class TextFormField extends FormField<String> {
  TextFormField({
    super.key,
    this.controller,
    String? initialValue,
    FocusNode? focusNode,
    super.forceErrorText,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    bool obscureText = false,
    bool autocorrect = true,
    int maxLines = 1,
    int? minLines,
    int? maxLength,
    this.onChanged,
    VoidCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    super.onSaved,
    super.validator,
    super.errorBuilder,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    Color? cursorColor,
    InputCounterWidgetBuilder? buildCounter,
    AutovalidateMode? autovalidateMode,
    TextStyle? errorStyle,
    TextStyle? helperStyle,
    IconData? prefixIcon,
    double prefixIconSize = 20,
    Color? prefixIconColor,
    EdgeInsets? prefixIconPadding,
    IconData? suffixIcon,
    double suffixIconSize = 20,
    Color? suffixIconColor,
    EdgeInsets? suffixIconPadding,
    ClearButtonMode clearButtonMode = ClearButtonMode.never,
    IconData? clearIcon,
    Color? clearIconColor,
  }) : assert(initialValue == null || controller == null),
       assert(maxLines > 0),
       assert(minLines == null || minLines > 0),
       assert(
         minLines == null || maxLines >= minLines,
         "minLines can't be greater than maxLines",
       ),
       assert(
         !obscureText || maxLines == 1,
         'Obscured fields cannot be multiline.',
       ),
       assert(maxLength == null || maxLength > 0),
       _focusNode = focusNode,
       _decoration = decoration,
       super(
         initialValue: controller != null
             ? controller.text
             : (initialValue ?? ''),
         enabled: enabled ?? true,
         autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
         builder: (FormFieldState<String> field) {
           final state = field as _TextFormFieldState;
           final effectiveDecoration = decoration ?? const InputDecoration();
           final theme = FormsTheme.of(state.context);
           final errorText = field.errorText;
           final isEnabled = enabled ?? true;
           final focused = state._effectiveFocusNode.hasFocus;
           formsKitLog(
             '${state._tag} build  focused=$focused  '
             'text="${state.value}"  error=$errorText',
           );

           void onChangedHandler(String value) {
             formsKitLog('${state._tag} TextField.onChanged "$value"');
             field.didChange(value);
             state._textFormField.onChanged?.call(value);
           }

           void onSubmittedHandler(String value) {
             formsKitLog('${state._tag} TextField.onSubmitted "$value"');
             onFieldSubmitted?.call(value);
             state._handleSubmitted(textInputAction, maxLines);
           }

           final input = TextField(
             controller: state._effectiveController,
             focusNode: state._effectiveFocusNode,
             decoration: InputDecoration(
               hintText: effectiveDecoration.hintText,
               hintStyle: effectiveDecoration.hintStyle,
               contentPadding: effectiveDecoration.contentPadding,
             ),
             keyboardType: keyboardType,
             textInputAction: state._resolveAction(textInputAction, maxLines),
             style: style ?? theme.inputStyle,
             textAlign: textAlign,
             textAlignVertical: textAlignVertical,
             textCapitalization: textCapitalization,
             autofocus: autofocus,
             readOnly: readOnly,
             obscureText: obscureText,
             autocorrect: autocorrect,
             maxLines: maxLines,
             minLines: minLines,
             maxLength: maxLength,
             onChanged: onChangedHandler,
             // Wrapped only when there is something to call or log.
             onTap: onTap == null && !formsKitDebug
                 ? null
                 : () {
                     formsKitLog('${state._tag} TextField.onTap');
                     onTap?.call();
                   },
             onEditingComplete: onEditingComplete == null && !formsKitDebug
                 ? null
                 : () {
                     formsKitLog('${state._tag} TextField.onEditingComplete');
                     onEditingComplete?.call();
                   },
             onSubmitted: onSubmittedHandler,
             inputFormatters: inputFormatters,
             enabled: isEnabled,
             cursorColor: cursorColor,
             prefixIcon: prefixIcon,
             prefixIconSize: prefixIconSize,
             prefixIconColor: prefixIconColor,
             prefixIconPadding: prefixIconPadding,
             suffixIcon: suffixIcon,
             suffixIconSize: suffixIconSize,
             suffixIconColor: suffixIconColor,
             suffixIconPadding: suffixIconPadding,
             clearButtonMode: clearButtonMode,
             clearIcon: clearIcon,
             clearIconColor: clearIconColor,
           );

           Widget? counter;
           if (effectiveDecoration.counterText != null) {
             final text = effectiveDecoration.counterText!;
             counter = text.isEmpty
                 ? null
                 : Text(text, style: theme.helperStyle);
           } else if (maxLength != null) {
             final currentLength = state._effectiveController.text.length;
             counter = buildCounter != null
                 ? buildCounter(
                     state.context,
                     currentLength: currentLength,
                     maxLength: maxLength,
                     isFocused: focused,
                   )
                 : Text('$currentLength/$maxLength', style: theme.helperStyle);
           }

           return NativeInputDecorator(
             decoration: effectiveDecoration,
             errorText: errorText,
             error: errorText != null && errorBuilder != null
                 ? errorBuilder(state.context, errorText)
                 : null,
             counter: counter,
             focused: focused,
             enabled: isEnabled,
             errorStyle: errorStyle,
             helperStyle: helperStyle,
             child: input,
           );
         },
       );

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController] and
  /// initialize its [TextEditingController.text] with [initialValue].
  final TextEditingController? controller;

  /// Called when the user initiates a change to the field's value: when they
  /// have inserted or deleted text.
  final ValueChanged<String>? onChanged;

  final FocusNode? _focusNode;
  final InputDecoration? _decoration;

  @override
  FormFieldState<String> createState() => _TextFormFieldState();
}

class _TextFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;
  FocusNode? _focusNode;
  late final String? _initialValue;

  TextEditingController get _effectiveController =>
      _textFormField.controller ?? _controller!;

  FocusNode get _effectiveFocusNode => _textFormField._focusNode ?? _focusNode!;

  TextFormField get _textFormField => super.widget as TextFormField;

  /// Short name for log lines: the label, else the hint, else the hash.
  String get _tag {
    final d = _textFormField._decoration;
    final name = d?.labelText ?? d?.hintText ?? '#${identityHashCode(this)}';
    return '[$name]';
  }

  @override
  void initState() {
    super.initState();
    if (_textFormField.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      _textFormField.controller!.addListener(_handleControllerChanged);
    }
    _initialValue = _textFormField.controller?.text ?? widget.initialValue;
    if (_textFormField._focusNode == null) {
      _focusNode = FocusNode();
    }
    _effectiveFocusNode.addListener(_handleFocusChanged);
    formsKitLog('$_tag initState');
  }

  @override
  void didUpdateWidget(FormField<String> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget as TextFormField;
    formsKitLog(
      '$_tag didUpdateWidget  controllerChanged=${_textFormField.controller != old.controller}  '
      'focusNodeChanged=${_textFormField._focusNode != old._focusNode}',
    );
    if (_textFormField.controller != old.controller) {
      old.controller?.removeListener(_handleControllerChanged);
      _textFormField.controller?.addListener(_handleControllerChanged);

      if (old.controller != null && _textFormField.controller == null) {
        _controller = TextEditingController.fromValue(old.controller!.value);
      }

      if (_textFormField.controller != null) {
        setValue(_textFormField.controller!.text);
        if (old.controller == null) {
          _controller?.dispose();
          _controller = null;
        }
      }
    }
    if (_textFormField._focusNode != old._focusNode) {
      (old._focusNode ?? _focusNode)?.removeListener(_handleFocusChanged);
      if (old._focusNode == null && _textFormField._focusNode != null) {
        _focusNode?.dispose();
        _focusNode = null;
      } else if (_textFormField._focusNode == null) {
        _focusNode = FocusNode();
      }
      _effectiveFocusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    formsKitLog('$_tag dispose');
    _textFormField.controller?.removeListener(_handleControllerChanged);
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    if (_effectiveController.text != value) {
      _effectiveController.text = value ?? '';
    }
  }

  @override
  void reset() {
    _effectiveController.text = _initialValue ?? '';
    super.reset();
    _textFormField.onChanged?.call(_initialValue ?? '');
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class. In the case
    // where a controller has been passed in to this widget, we register this
    // change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }

  void _handleFocusChanged() {
    formsKitLog(
      '$_tag focus changed -> hasFocus=${_effectiveFocusNode.hasFocus}  '
      '(rebuild scheduled for after the frame)',
    );
    // Called from inside the native editingDidBegin / editingDidEnd
    // callback. DartNative's setState is synchronous, so rebuild after the
    // frame instead of inside that callback, as the SDK asks for requestFocus.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      formsKitLog(
        '$_tag focus rebuild firing  hasFocus=${_effectiveFocusNode.hasFocus}',
      );
      setState(() {});
    });
  }

  @override
  void Function()? get requestFocus {
    final node = _effectiveFocusNode;
    return () {
      // Deferred a frame: an inline request during a tap or keyboard callback
      // races the native first-responder sync.
      formsKitLog('$_tag requestFocus scheduled');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formsKitLog('$_tag requestFocus firing');
        if (mounted) node.requestFocus();
      });
    };
  }

  TextInputAction _resolveAction(TextInputAction? explicit, int maxLines) {
    if (explicit != null) return explicit;
    if (maxLines != 1) return TextInputAction.newline;
    final form = Form.maybeOf(context);
    if (form != null && form.hasFieldAfter(this)) return TextInputAction.next;
    return TextInputAction.done;
  }

  void _handleSubmitted(TextInputAction? explicit, int maxLines) {
    final action = _resolveAction(explicit, maxLines);
    formsKitLog('$_tag handleSubmitted action=$action');
    switch (action) {
      case TextInputAction.next:
        final moved = Form.maybeOf(context)?.focusFieldAfter(this) ?? false;
        if (!moved) {
          formsKitLog('$_tag no next field -> unfocus');
          _effectiveFocusNode.unfocus();
        }
      case TextInputAction.done:
      case TextInputAction.go:
      case TextInputAction.search:
      case TextInputAction.send:
        formsKitLog('$_tag $action -> unfocus');
        _effectiveFocusNode.unfocus();
      default:
        break;
    }
  }
}
