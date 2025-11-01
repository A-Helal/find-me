import 'package:find_me_and_my_theme/core/constants/app_fonts.dart';
import 'package:find_me_and_my_theme/core/theming/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'app_theme_extension.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.grey0,
    fontFamily: AppFonts.manrope,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary300,
      brightness: Brightness.light,
    ),
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.grey900,
      displayColor: AppColors.grey900,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary300,
        foregroundColor: AppColors.grey0,
        disabledBackgroundColor: AppColors.grey100,
        disabledForegroundColor: AppColors.grey0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.mSemiBold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.grey100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.grey100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary200),
      ),
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return AppColors.primary0;
        }
        return AppColors.grey0;
      }),
      filled: true,
      hintStyle: AppTextStyles.mRegular.copyWith(color: AppColors.grey400),
    ),
    extensions: const [
      AppThemeExtension(
        primary0: AppColors.primary0,
        primary25: AppColors.primary25,
        primary50: AppColors.primary50,
        primary100: AppColors.primary100,
        primary200: AppColors.primary200,
        primary300: AppColors.primary300,
        shadow1Color: AppColors.shadow1Color,
        darkFillColor: AppColors.darkFillColor,
      ),
    ],
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.grey900,
    fontFamily: AppFonts.manrope,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary300,
      brightness: Brightness.dark,
    ),
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.grey0,
      displayColor: AppColors.grey0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary300,
        foregroundColor: AppColors.grey0,
        disabledBackgroundColor: AppColors.grey800,
        disabledForegroundColor: AppColors.grey400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.mSemiBold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.grey100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.grey100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary200),
      ),
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return AppColors.darkFillColor;
        }
        return AppColors.grey800;
      }),
      filled: true,
      hintStyle: AppTextStyles.mRegular.copyWith(color: AppColors.grey400),
    ),
    extensions: const [
      AppThemeExtension(
        primary0: Color(0xff1B1B1B),
        primary25: Color(0xff2A2A2A),
        primary50: Color(0xff333333),
        primary100: Color(0xff444444),
        primary200: Color(0xff555555),
        primary300: Color(0xff666666),
        shadow1Color: Color(0xff777777),
        darkFillColor: Color(0xff888888),
      ),
    ],
  );
}
