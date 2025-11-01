import 'package:find_me_and_my_theme/features/theme/data/cubit/theme_cubit.dart';
import 'package:find_me_and_my_theme/features/theme/presentation/screens/demo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:find_me_and_my_theme/main.dart';

void main() {
  testWidgets('App loads DemoScreen and has a toggle button',
          (WidgetTester tester) async {
        // Build the app
        await tester.pumpWidget(MyApp(themeCubit: ThemeCubit()));

        // Verify DemoScreen appears
        expect(find.byType(DemoScreen), findsOneWidget);

        // (Optional) Check toggle button exists
        expect(find.text('Toggle Theme'), findsOneWidget);
      });
}
