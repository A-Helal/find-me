import 'package:find_me_and_my_theme/core/DI/di.dart';
import 'package:find_me_and_my_theme/core/theming/app_theme.dart';
import 'package:find_me_and_my_theme/features/map/presentation/cubit/maps_cubit.dart';
import 'package:find_me_and_my_theme/features/map/presentation/screens/maps_screen.dart';
import 'package:find_me_and_my_theme/features/theme/data/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDependencies();

  // Initialize Theme
  final themeCubit = ThemeCubit();
  await themeCubit.loadTheme();

  runApp(MyApp(themeCubit: themeCubit));
}

class MyApp extends StatelessWidget {
  final ThemeCubit themeCubit;

  const MyApp({super.key, required this.themeCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider(create: (_) => sl<MapsCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.themeMode,
            home: const MapsScreen(),
          );
        },
      ),
    );
  }
}
