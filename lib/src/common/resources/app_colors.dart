import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);

  // partsに対応するカラー
  static const Color colorAbdomen = Color(0xFF2196F3);
  static const Color colorAbdomenUpper = Color(0xFF2196F3);
  static const Color colorAbdomenSide = Color(0xFF2196F3);
  static const Color colorAbdomenLower = Color(0xFF2196F3);
  static const Color colorArm = Color(0xFF2196F3);
  static const Color colorArmUpper = Color(0xFF2196F3);
  static const Color colorForeArm = Color(0xFF2196F3);
  static const Color colorBackUpper = Color(0xFF2196F3);
  static const Color colorBackSide = Color(0xFF2196F3);
  static const Color colorBackLower = Color(0xFF2196F3);
  static const Color colorButtock = Color(0xFF2196F3);
  static const Color colorCalfFront = Color(0xFF2196F3);
  static const Color colorCalfBack = Color(0xFF2196F3);
  static const Color colorChest = Color(0xFF2196F3);
  static const Color colorHamstrings = Color(0xFF2196F3);
  static const Color colorNeck = Color(0xFF2196F3);
  static const Color colorShoulderFront = Color(0xFF2196F3);
  static const Color colorShoulderBack = Color(0xFF2196F3);
  static const Color colorThlgh = Color(0xFF2196F3);

}

Map partsColors = {
  'abdomen': AppColors.colorAbdomen,
  'abdomen_upper': AppColors.colorAbdomenUpper,
  'abdomen_side': AppColors.colorAbdomenSide,
  'abdomen_lower': AppColors.colorAbdomenLower,
  'arm': AppColors.colorArm,
  'arm_upper': AppColors.colorArmUpper,
  'fore_arm': AppColors.colorForeArm,
  'back_upper': AppColors.colorBackUpper,
  'back_side': AppColors.colorBackSide,
  'back_lower': AppColors.colorBackLower,
  'buttock': AppColors.colorButtock,
  'calf_front': AppColors.colorCalfFront,
  'calf_back': AppColors.colorCalfBack,
  'chest': AppColors.colorChest,
  'hamstrings': AppColors.colorHamstrings,
  'neck': AppColors.colorNeck,
  'shoulder_front': AppColors.colorShoulderFront,
  'shoulder_back': AppColors.colorShoulderBack,
  'thlgh': AppColors.colorThlgh,
};
