import 'package:flutter/material.dart';

import '../planning.dart';
import '../workout.dart';
import '../notification.dart';
import '../account.dart';


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
