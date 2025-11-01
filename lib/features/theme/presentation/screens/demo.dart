import 'package:find_me_and_my_theme/core/theming/app_colors.dart';
import 'package:find_me_and_my_theme/core/theming/theme_extension_getters.dart';
import 'package:find_me_and_my_theme/features/theme/data/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                textAlign: TextAlign.center,
                style: TextStyle(color: context.appColors.primary100),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Enabled button"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text("disabled button"),
              ),
              const SizedBox(height: 20),
              const TextField(decoration: InputDecoration(hintText: 'hint')),
              const SizedBox(height: 10),
              const TextField(decoration: InputDecoration(hintText: 'hint')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                child: const Text('Toggle Theme'),
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: const SizedBox()),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary100,
                    ),
                    child: const SizedBox(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
