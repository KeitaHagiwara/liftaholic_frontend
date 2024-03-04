import 'package:flutter_riverpod/flutter_riverpod.dart';

// テスト用のStateProvider
final helloWorldProvider = StateProvider<String>((ref) => 'Hello World');

// 登録済みトレーニングプランのStateProvider
final registeredPlanProvider = StateProvider<List>((ref) => []);

// ワークアウト実施中フラグのStateProvider
final isDoingWorkoutProvider = StateProvider<bool>((ref) => false);

// 選択中のトレーニングプランIDのStateProvider
final selectedPlanProvider = StateProvider<int>((ref) => 0);

// 実施中のトレーニングプランIDのStateProvider
final execPlanIdProvider = StateProvider<int>((ref) => 0);

// 選択中のプランのトレーニングメニューのStateProvider
final selectedTrainingMenuProvider = StateProvider<Map>((ref) => {});

// ワークアウト開始時間
final workoutStartTimeProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

// ワークアウト終了時間
final workoutEndTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());

// // トレーニングメニュー実施中フラグのStateProvider
// final isDoingMenuProvider = StateProvider<bool>((ref) => false);

// 実施中のトレーニングメニューIDのStateProvider
final execMenuIdProvider = StateProvider<int>((ref) => 0);

// 実施中のトレーニングメニューの連想配列
final execUserTrainingMenuProvider = StateProvider<Map>((ref) => {});

// お知らせページの情報を格納するためのStateProvider
final notificationProvider =
    StateProvider<Map>((ref) => {'あなた宛': [], 'ニュース': []});
