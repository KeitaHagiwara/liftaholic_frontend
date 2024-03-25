import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// テスト用のStateProvider
final helloWorldProvider = StateProvider<String>((ref) => 'Hello World');

// ユーザーIDのStateProvider
final userIdProvider = StateProvider<String?>((ref) => '');

// 全ての元データとなるStateProvider
final userTrainingDataProvider = StateProvider<Map>((ref) => {});

// トレーニングメニューのマスタとなるStateProvider
final trainingMenuMasterProvider = StateProvider<Map>((ref) => {});

// 登録済みトレーニングプランのStateProvider
final registeredPlanProvider = StateProvider<List>((ref) => []);

// ワークアウト実施中フラグのStateProvider
final isDoingWorkoutProvider = StateProvider<bool>((ref) => false);

// 選択中のトレーニングプランIDのStateProvider
final selectedPlanProvider = StateProvider<int>((ref) => 0);

// トレーニングプランにメニューを追加するために一時的に必要となるStateProvider
final addTrainingMenuProvider = StateProvider<Map>((ref) => {});

// 実施中のトレーニングプランIDのStateProvider
final execPlanIdProvider = StateProvider<String>((ref) => '');

// 実施中のトレーニング情報のStateProvider
final execTrainingMenuProvider = StateProvider<Map>((ref) => {});

// 選択中のプランのトレーニングメニューのStateProvider
final selectedTrainingMenuProvider = StateProvider<Map>((ref) => {});

// ワークアウト開始時間
final workoutStartTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());

// ワークアウト終了時間
final workoutEndTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 実施中のトレーニングメニューIDのStateProvider
final execMenuIdProvider = StateProvider<int>((ref) => 0);

// 実施中のトレーニングメニューの連想配列
final execUserTrainingMenuProvider = StateProvider<Map>((ref) => {});

// お知らせページの情報を格納するためのStateProvider
final notificationProvider = StateProvider<Map>((ref) => {'あなた宛': [], 'ニュース': []});
