import 'package:GADI/common/constant/app_colors.dart';
import 'package:flutter/material.dart';

export 'package:GADI/common/constant/app_colors.dart';

typedef ColorProvider = Color Function();

abstract class AbstractThemeColors {
  const AbstractThemeColors();

  Color get seedColor => const Color(0xFF734DFF);

  Color get sub1 => const Color(0xFFF4F1FF);

  Color get sub2 => const Color(0xFFA797E0);

  Color get sub3 => const Color(0xFF3E2F84);

  Color get sub4 => const Color(0xFF454545);

  Color get veryBrightGrey => AppColors.brightGrey;

  Color get drawerBg => const Color.fromARGB(255, 255, 255, 255);

  Color get scrollableItem => const Color.fromARGB(255, 57, 57, 57);

  Color get iconButton => Colors.white;

  Color get iconButtonInactivate => const Color(0xFFE6E1FF);

  Color get inActivate => const Color.fromARGB(255, 200, 207, 220);

  Color get activate => const Color.fromARGB(255, 63, 72, 95);

  Color get badgeBg => AppColors.blueGreen;

  Color get textBadgeText => Colors.white;

  Color get badgeBorder => Colors.transparent;

  Color get divider => const Color.fromARGB(255, 228, 228, 228);

  Color get text => const Color(0xFFE6E1FF);

  Color get hintText => AppColors.middleGrey;

  Color get focusedBorder => AppColors.darkGrey;

  Color get confirmText => AppColors.blue;

  Color get drawerText => text;

  Color get snackbarBgColor => AppColors.mediumBlue;

  Color get blueButtonBackground => AppColors.darkBlue;
}
