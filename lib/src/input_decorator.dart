/// The label, surface, helper, error and counter around a native field.
///
/// In Flutter this is Material's `InputDecorator`, which `TextField` wraps
/// around its editable. DartNative's `TextField` renders the input alone and
/// documents that the surface belongs to a wrapping `Container`, so this is
/// the DartNative counterpart: composed from `Container`, `Text`, `Row` and
/// `Column`, honouring an [InputDecoration]'s border, fill and text, and
/// falling back to the platform's own look from [FormsTheme].
library;

import 'package:dartnative/dartnative.dart';

import 'forms_theme.dart';

class NativeInputDecorator extends StatelessWidget {
  final InputDecoration decoration;
  final Widget child;

  /// The error to show; null shows [InputDecoration.helperText] instead.
  final String? errorText;

  /// Replaces the plain error [Text] when set.
  final Widget? error;
  final Widget? counter;
  final bool focused;
  final bool enabled;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;

  const NativeInputDecorator({
    super.key,
    required this.decoration,
    required this.child,
    this.errorText,
    this.error,
    this.counter,
    this.focused = false,
    this.enabled = true,
    this.errorStyle,
    this.helperStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FormsTheme.of(context);
    final d = decoration;
    final hasError = errorText != null || error != null;

    Widget content = child;
    if (d.prefixIcon != null || d.suffixIcon != null) {
      content = Row(
        children: [
          ?d.prefixIcon,
          Expanded(child: child),
          ?d.suffixIcon,
        ],
      );
    }

    final supporting = errorText ?? d.helperText;
    final supportingStyle = hasError
        ? (errorStyle ?? theme.errorStyle)
        : (helperStyle ?? theme.helperStyle);
    final Widget? supportingWidget =
        error ??
        (supporting == null ? null : Text(supporting, style: supportingStyle));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (d.labelText != null) ...[
          Text(d.labelText!, style: d.labelStyle ?? theme.labelStyle),
          const SizedBox(height: 6),
        ],
        _surface(theme, hasError, content),
        if (supportingWidget != null || counter != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: supportingWidget ?? const SizedBox()),
              ?counter,
            ],
          ),
        ],
      ],
    );
  }

  Widget _surface(FormsThemeData t, bool hasError, Widget content) {
    final d = decoration;
    final border = _borderForState(d, hasError);
    final fill = d.filled ? d.fillColor : null;
    if (border != null || fill != null) {
      return _fromDecoration(t, border, fill, hasError, content);
    }
    return _fromTheme(t, hasError, content);
  }

  /// Flutter's resolution order for the state-specific borders.
  InputBorder? _borderForState(InputDecoration d, bool hasError) {
    if (!enabled) return d.disabledBorder ?? d.border;
    if (hasError && focused) {
      return d.focusedErrorBorder ??
          d.errorBorder ??
          d.focusedBorder ??
          d.border;
    }
    if (hasError) return d.errorBorder ?? d.border;
    if (focused) return d.focusedBorder ?? d.enabledBorder ?? d.border;
    return d.enabledBorder ?? d.border;
  }

  Widget _fromDecoration(
    FormsThemeData t,
    InputBorder? border,
    Color? fill,
    bool hasError,
    Widget content,
  ) {
    final padding = decoration.contentPadding == null
        ? t.contentPadding
        : EdgeInsets.zero;
    if (border is OutlineInputBorder) {
      final side = border.borderSide;
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: border.borderRadius,
          border: side.width == 0
              ? null
              : Border.all(color: side.color, width: side.width),
        ),
        child: content,
      );
    }
    if (border is UnderlineInputBorder) {
      // DartNative renders only uniform borders, so the underline is its own
      // one-pixel row beneath the field.
      final side = border.borderSide;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(padding: padding, color: fill, child: content),
          Container(
            height: side.width == 0 ? 1 : side.width,
            color: side.color,
          ),
        ],
      );
    }
    // InputBorder.none, or fill only.
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(t.radius),
      ),
      child: content,
    );
  }

  Widget _fromTheme(FormsThemeData t, bool hasError, Widget content) {
    final Color borderColor;
    final double borderWidth;
    switch (t.style) {
      case FieldStyle.filled:
        // Apple's inset-grouped fields show no ring on focus; the cursor is
        // the cue. A theme with a visible focusedColor opts into one.
        final focusRing = focused && (t.focusedColor.value >> 24) != 0;
        borderColor = hasError
            ? t.errorColor
            : focusRing
            ? t.focusedColor
            : t.outlineColor;
        borderWidth = hasError || focusRing ? 1 : 0;
      case FieldStyle.outlined:
        borderColor = !enabled
            ? t.disabledColor
            : hasError
            ? t.errorColor
            : focused
            ? t.focusedColor
            : t.outlineColor;
        borderWidth = focused || hasError ? 2 : 1;
    }
    return Container(
      padding: t.contentPadding,
      decoration: BoxDecoration(
        color: t.fillColor,
        borderRadius: BorderRadius.circular(t.radius),
        border: borderWidth == 0
            ? null
            : Border.all(color: borderColor, width: borderWidth),
      ),
      child: content,
    );
  }
}
