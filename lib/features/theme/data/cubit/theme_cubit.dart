import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial(themeMode: ThemeMode.system));

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode');

    if (savedTheme == 'light') {
      emit(ThemeLight(themeMode: ThemeMode.light));
    } else if (savedTheme == 'dark') {
      emit(ThemeDark(themeMode: ThemeMode.dark));
    } else {
      emit(ThemeInitial(themeMode: ThemeMode.system));
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (state.themeMode == ThemeMode.light) {
      await prefs.setString('themeMode', 'dark');
      emit(ThemeDark(themeMode: ThemeMode.dark));
    } else {
      await prefs.setString('themeMode', 'light');
      emit(ThemeLight(themeMode: ThemeMode.light));
    }
  }
}
