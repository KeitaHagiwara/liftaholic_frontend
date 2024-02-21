import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/dialogs.dart';
import '../common/provider.dart';

class CompleteWorkoutScreen extends ConsumerStatefulWidget {
  const CompleteWorkoutScreen({Key? key}) : super(key: key);

  @override
  _CompleteWorkoutScreenState createState() => _CompleteWorkoutScreenState();
}

class _CompleteWorkoutScreenState extends ConsumerState<CompleteWorkoutScreen> {

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Text('ワークアウト終了'),
        onPressed: () {
          Widget callbackButton = TextButton(
            child: Text("終了"),
            onPressed: () {
              ref.read(isDoingWorkoutProvider.notifier).state = false;
              // モーダルを閉じる
              Navigator.of(context).pop();
            },
          );
          ConfirmDialogTemplate(
              context, callbackButton, "終了", "実施中のワークアウトを終了します。よろしいですか？");
        });
  }
}
