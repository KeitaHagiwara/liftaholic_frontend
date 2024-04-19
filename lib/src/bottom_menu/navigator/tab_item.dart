import 'package:flutter/material.dart';

import 'package:liftaholic_frontend/src/bottom_menu/planning.dart';
import 'package:liftaholic_frontend/src/bottom_menu/workout.dart';
import 'package:liftaholic_frontend/src/bottom_menu/notification.dart';
import 'package:liftaholic_frontend/src/bottom_menu/account.dart';


enum TabItem {

  planning(
    title: 'プランニング',
    icon: Icons.event_note,
    page: PlanningScreen(),
  ),

  workout(
    title: 'ワークアウト',
    icon: Icons.fitness_center,
    page: WorkoutScreen(),
  ),

  notification(
    title: 'お知らせ',
    icon: Icons.notifications,
    page: NotificationScreen(),
  ),

  account(
    title: 'マイページ',
    icon: Icons.person,
    page: AccountScreen(),
  );

  const TabItem({
    required this.title,
    required this.icon,
    required this.page,
  });

  /// タイトル
  final String title;

  /// アイコン
  final IconData icon;

  /// 画面
  final Widget page;

}
