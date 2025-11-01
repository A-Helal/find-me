import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

extension AppThemeGetter on BuildContext {
  AppThemeExtension get appColors =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
