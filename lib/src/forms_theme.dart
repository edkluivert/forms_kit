/// Colours and shapes for field surfaces, with a native default per
/// platform.
library;

import 'dart:io' show Platform;

import 'package:dartnative/dartnative.dart';

/// How a text field's surface is drawn. DartNative's `TextField` draws no
/// box of its own; the surface is a composed `Container`.
enum FieldStyle {
  /// iOS grouped-inset look: filled, rounded, no outline.
  filled,

  /// Material 3 outlined text field.
  outlined,
}

class FormsThemeData {
  final FieldStyle style;
  final Color fillColor;
  final Color outlineColor;
  final Color focusedColor;
  final Color errorColor;
  final Color disabledColor;
  final double radius;
  final EdgeInsets contentPadding;
  final TextStyle labelStyle;
  final TextStyle helperStyle;
  final TextStyle errorStyle;
  final TextStyle inputStyle;

  const FormsThemeData({
    required this.style,
    required this.fillColor,
    required this.outlineColor,
    required this.focusedColor,
    required this.errorColor,
    required this.disabledColor,
    required this.radius,
    required this.contentPadding,
    required this.labelStyle,
    required this.helperStyle,
    required this.errorStyle,
    required this.inputStyle,
  });

  /// Apple's inset-grouped field: system grey 6 fill, 10 pt corners, 17 pt
  /// text, red supporting text on error. No outline, as iOS draws none.
  static const ios = FormsThemeData(
    style: FieldStyle.filled,
    fillColor: Color(0xFFF2F2F7),
    outlineColor: Color(0x00000000),
    focusedColor: Color(0x00000000),
    errorColor: Color(0xFFFF3B30),
    disabledColor: Color(0xFF8E8E93),
    radius: 10,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    labelStyle: TextStyle(fontSize: 13, color: Color(0xFF6E6E73)),
    helperStyle: TextStyle(fontSize: 13, color: Color(0xFF6E6E73)),
    errorStyle: TextStyle(fontSize: 13, color: Color(0xFFFF3B30)),
    inputStyle: TextStyle(fontSize: 17, color: Color(0xFF000000)),
  );

  /// Material 3 outlined text field: 4 dp corners, outline that thickens
  /// and takes the primary colour on focus, error colour on error.
  static const material = FormsThemeData(
    style: FieldStyle.outlined,
    fillColor: Color(0x00000000),
    outlineColor: Color(0xFF79747E),
    focusedColor: Color(0xFF6750A4),
    errorColor: Color(0xFFB3261E),
    disabledColor: Color(0x611D1B20),
    radius: 4,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    labelStyle: TextStyle(fontSize: 12, color: Color(0xFF49454F)),
    helperStyle: TextStyle(fontSize: 12, color: Color(0xFF49454F)),
    errorStyle: TextStyle(fontSize: 12, color: Color(0xFFB3261E)),
    inputStyle: TextStyle(fontSize: 16, color: Color(0xFF1D1B20)),
  );

  /// The platform's own look.
  static FormsThemeData get platform => Platform.isAndroid ? material : ios;

  FormsThemeData copyWith({
    FieldStyle? style,
    Color? fillColor,
    Color? outlineColor,
    Color? focusedColor,
    Color? errorColor,
    Color? disabledColor,
    double? radius,
    EdgeInsets? contentPadding,
    TextStyle? labelStyle,
    TextStyle? helperStyle,
    TextStyle? errorStyle,
    TextStyle? inputStyle,
  }) => FormsThemeData(
    style: style ?? this.style,
    fillColor: fillColor ?? this.fillColor,
    outlineColor: outlineColor ?? this.outlineColor,
    focusedColor: focusedColor ?? this.focusedColor,
    errorColor: errorColor ?? this.errorColor,
    disabledColor: disabledColor ?? this.disabledColor,
    radius: radius ?? this.radius,
    contentPadding: contentPadding ?? this.contentPadding,
    labelStyle: labelStyle ?? this.labelStyle,
    helperStyle: helperStyle ?? this.helperStyle,
    errorStyle: errorStyle ?? this.errorStyle,
    inputStyle: inputStyle ?? this.inputStyle,
  );
}

/// Overrides the field look for a subtree. Without one, fields use
/// [FormsThemeData.platform].
class FormsTheme extends InheritedWidget {
  final FormsThemeData data;

  const FormsTheme({super.key, required this.data, required super.child});

  static FormsThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FormsTheme>()?.data ??
      FormsThemeData.platform;

  @override
  bool updateShouldNotify(FormsTheme oldWidget) => data != oldWidget.data;
}
