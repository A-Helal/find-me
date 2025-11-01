import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static BoxShadow shadow1 = BoxShadow(
    offset: const Offset(0, 1),
    blurRadius: 2,
    spreadRadius: 0,
    color: AppColors.shadow1Color.withValues(alpha: 0.5),
  );
}
