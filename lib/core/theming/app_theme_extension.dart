import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primary0;
  final Color primary25;
  final Color primary50;
  final Color primary100;
  final Color primary200;
  final Color primary300;
  final Color shadow1Color;
  final Color darkFillColor;

  const AppThemeExtension({
    required this.shadow1Color,
    required this.darkFillColor,
    required this.primary0,
    required this.primary25,
    required this.primary50,
    required this.primary100,
    required this.primary200,
    required this.primary300,
  });

  @override
  AppThemeExtension copyWith({
    Color? primary0,
    Color? primary25,
    Color? primary50,
    Color? primary100,
    Color? primary200,
    Color? primary300,
    Color? shadow1Color,
    Color? darkFillColor,
  }) {
    return AppThemeExtension(
      primary0: primary0 ?? this.primary0,
      primary25: primary25 ?? this.primary25,
      primary50: primary50 ?? this.primary50,
      primary100: primary100 ?? this.primary100,
      primary200: primary200 ?? this.primary200,
      primary300: primary300 ?? this.primary300,
      shadow1Color: shadow1Color ?? this.shadow1Color,
      darkFillColor: darkFillColor ?? this.darkFillColor,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      primary0: Color.lerp(primary0, other.primary0, t)!,
      primary25: Color.lerp(primary25, other.primary25, t)!,
      primary50: Color.lerp(primary50, other.primary50, t)!,
      primary100: Color.lerp(primary100, other.primary100, t)!,
      primary200: Color.lerp(primary200, other.primary200, t)!,
      primary300: Color.lerp(primary300, other.primary300, t)!,
      shadow1Color: Color.lerp(shadow1Color, other.shadow1Color, t)!,
      darkFillColor: Color.lerp(darkFillColor, other.darkFillColor, t)!,
    );
  }
}
