import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_spinbox/material.dart';
// import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:liftaholic_frontend/src/common/default_value.dart';
import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/common/dialogs.dart';
import 'package:liftaholic_frontend/src/common/functions.dart';
import 'package:liftaholic_frontend/src/workout/training_contents_modal.dart';
import 'package:liftaholic_frontend/src/workout/execute/stop_watch.dart';

class ExecWorkoutScreen extends ConsumerStatefulWidget {
  const ExecWorkoutScreen({Key? key, required this.user_training_id}) : super(key: key);

  final String user_training_id;

  @override
  _ExecWorkoutScreenState createState() => _ExecWorkoutScreenState();
}

class _ExecWorkoutScreenState extends ConsumerState<ExecWorkoutScreen> {
  // ********************
  // イニシャライザ設定
  // ********************
  // 画面遷移元から引数で取得した変数
  late String _user_training_id; // ユーザーのトレーニングメニューID
  late Map _exec_training_menu;

  bool _loading = false;

  String _training_name = '';
  String _intervalStr = intervalDefault;
  Duration _intervalTimer = Duration(minutes: 1);

  // テキストフィールドのコントローラーを設定する
  // final TextEditingController _resp_controller = TextEditingController();
  // final TextEditingController _kgs_controller = TextEditingController();

  // ---------------------------
  // トレーニングのセットを削除する
  // ---------------------------
  // ・params
  //   _exec_training_menu: Map
  //     exp) {
  //            69: {
  //              training_name: プッシュアップ,
  //              description: '',
  //              sets: 3,
  //              reps: 15,
  //              kgs: 70.0,
  //              sets_achieve: [{reps: 15, kgs: 70.0, time: 00:00, is_completed: false},],
  //              progress: 0
  //            },
  //          }
  //   index: int
  //
  // ・return
  //   void
  //
  void _deleteTrainingMenu(_exec_training_menu, index) {
    var _training_set_list = _exec_training_menu[_user_training_id]['sets_achieve'];
    var is_completed = _training_set_list[index]['is_completed'];
    // セットが完了している場合はダイアログで確認する
    if (is_completed) {
      showDialog(
        context: context,
        builder: (BuildContext context_modal) {
          return AlertDialog(
            title: Text('セット削除', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
            content: Text((index + 1).toString() + 'セット目は完了していますが、削除しますか？'),
            actions: [
              TextButton(
                child: Text("キャンセル"),
                onPressed: () {
                  Navigator.of(context_modal).pop();
                },
              ),
              TextButton(
                child: Text("削除"),
                onPressed: () {
                  setState(() {
                    _training_set_list.removeAt(index);
                    _exec_training_menu[_user_training_id]['progress'] = calcProgress(_training_set_list);
                  });
                  Navigator.of(context_modal).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _training_set_list.removeAt(index);
        _exec_training_menu[_user_training_id]['progress'] = calcProgress(_training_set_list);
      });
    }
    // Providerの値を更新する
    ref.read(execTrainingMenuProvider.notifier).state = _exec_training_menu;
  }

  @override
  void initState() {
    super.initState();

    _user_training_id = widget.user_training_id;
    _exec_training_menu = ref.read(execTrainingMenuProvider);
    _training_name = _exec_training_menu[_user_training_id]['training_name'];
    _intervalStr = _exec_training_menu[_user_training_id]['interval'];
    // タイマーの値に設定値を埋め込む
    var initialInterval = getIntervalDuration(_intervalStr);
    _intervalTimer = Duration(minutes: initialInterval['interval_min'], seconds: initialInterval['interval_sec']);
  }

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _training_name,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
          : Container(
              // 余白を付ける
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: TextButton(
                          child: Text('説明を見る'),
                          onPressed: () {
                            // トレーニングのコンテンツのモーダルを表示する
                            showTrainingContentModal(context, _exec_training_menu[_user_training_id]);
                          })),
                  Flexible(
                      child: _exec_training_menu[_user_training_id]['sets_achieve'].length == 0
                          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('トレーニングメニューが設定されていません。')]))
                          : ListView.builder(
                              itemCount: _exec_training_menu[_user_training_id]['sets_achieve'].length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                    elevation: 9,
                                    child: Slidable(
                                        endActionPane: ActionPane(motion: const BehindMotion(), children: [
                                          SlidableAction(
                                              backgroundColor: Colors.red,
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                              icon: Icons.delete,
                                              label: '削除',
                                              onPressed: (context) {
                                                _deleteTrainingMenu(_exec_training_menu, index);
                                              })
                                        ]),
                                        child: Column(
                                          children: <Widget>[
                                            ListTile(
                                                dense: true,
                                                title: Text((index + 1).toString() + 'セット目'),
                                                leading: Icon(Icons.task_alt, color: _exec_training_menu[_user_training_id]['sets_achieve'][index]['is_completed'] ? Colors.green : Colors.grey),
                                                trailing: _exec_training_menu[_user_training_id]['sets_achieve'][index]['is_completed']
                                                    ? Text(_exec_training_menu[_user_training_id]['sets_achieve'][index]['kgs'].toString() +
                                                        'kgs  ' +
                                                        _exec_training_menu[_user_training_id]['sets_achieve'][index]['reps'].toString() +
                                                        'reps\n' +
                                                        _exec_training_menu[_user_training_id]['sets_achieve'][index]['time'])
                                                    : Text(''),
                                                onTap: () {
                                                  // ストップウォッチのモーダルを起動する
                                                  startTrainingModal(context, index);
                                                })
                                          ],
                                        )));
                              })),

                  // インターバル設定ボタン
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.only(left: 64, right: 64),
                    // 横幅いっぱいに広げる
                    width: double.infinity,
                    // キャンセルボタン
                    child: CupertinoButton(
                        // ボタンをクリックした時の処理
                        onPressed: () {
                          showModalBottomSheet(
                              showDragHandle: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              context: context,
                              builder: (BuildContext builder) {
                                return Container(
                                    height: MediaQuery.of(context).copyWith().size.height / 4,
                                    child: SizedBox.expand(
                                      // height: double.infinity,
                                      // width: double.infinity,
                                      child: CupertinoTimerPicker(
                                        mode: CupertinoTimerPickerMode.ms,
                                        minuteInterval: 1,
                                        secondInterval: 1,
                                        initialTimerDuration: _intervalTimer,
                                        onTimerDurationChanged: (Duration changedtimer) {
                                          setState(() {
                                            _intervalTimer = changedtimer;
                                          });
                                        },
                                      ),
                                    ));
                              });
                        },
                        // style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('セット間インターバル: ', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            Text(_intervalTimer.toString().split('.').first.split(':')[1] + ':' + _intervalTimer.toString().split('.').first.split(':')[2] + '', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                          ],
                        )),
                  ),

                  // セット追加ボタン
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.only(left: 64, right: 64),
                    // 横幅いっぱいに広げる
                    width: double.infinity,
                    // キャンセルボタン
                    child: ElevatedButton(
                      // ボタンをクリックした時の処理
                      onPressed: () {
                        setState(() {
                          // セットを追加する
                          _exec_training_menu[_user_training_id]['sets_achieve'].add({'reps': _exec_training_menu[_user_training_id]['reps'], 'kgs': _exec_training_menu[_user_training_id]['kgs'], 'time': '00:00', 'is_completed': false});
                          // プログレスの数値を再計算する
                          var _training_set_list = _exec_training_menu[_user_training_id]['sets_achieve'];
                          _exec_training_menu[_user_training_id]['progress'] = calcProgress(_training_set_list);
                          // Providerの値を更新する
                          ref.read(execTrainingMenuProvider.notifier).state = _exec_training_menu;
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: Text('セット追加', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  startTrainingModal(context, int index) {
    // トレーニング実績を取得する
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false, // 背景押下で閉じないようにする
      enableDrag: false, // ドラッグで閉じないようにする
      context: context,
      builder: (BuildContext context) {
        return StopWatchScreen(user_training_id: _user_training_id, exec_training_menu: _exec_training_menu, index: index);
      },
    ).then((value) {
      // valueは完了有無のbooleanを返却する
      if (value != null) {
        // インターバルタイマーのモーダルを表示する
        var all_complete = true;
        var training_name = _exec_training_menu[_user_training_id]['training_name'];
        var interval = _exec_training_menu[_user_training_id]['interval'];
        // print(_exec_training_menu[_user_training_id]['sets_achieve']);

        for (var i = 0; i < _exec_training_menu[_user_training_id]['sets_achieve'].length; i++) {
          if (!_exec_training_menu[_user_training_id]['sets_achieve'][i]['is_completed']) {
            all_complete = false;
          }
        }

        // 全てのセットが完了してない場合、インターバルのポップアップを表示する
        if (!all_complete) {
          showDialog(
            context: context,
            barrierDismissible: false, // ボタンが押されるまでダイアログは閉じない
            builder: (BuildContext contextModal) {
              return IntervalModalScreen(intervalStr: interval);
            },
          );
          // 全てのセットが完了してる場合、完了のポップアップを表示する
        } else {
          // トレーニングメニュー終了時のアクションボタンを設定する
          Widget actionButton(contextModal) {
            return TextButton(
              child: Text("OK"),
              onPressed: () {
                // 確認モーダルを削除する
                Navigator.of(contextModal).pop();
                Navigator.of(context).pop();
              },
            );
          }

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext contextModal) {
                return lottieDialogTemplate(context, 'トレーニングメニュー完了🎉', 'assets/lottie_json/complete_sets.json', {'width': 100, 'height': 100}, [actionButton(contextModal)]);
              });
        }
      }
      // 実績を更新する -> これがないと画面が更新されない
      setState(() {});
    });
  }
}

class IntervalModalScreen extends ConsumerStatefulWidget {
  const IntervalModalScreen({super.key, required this.intervalStr});

  final String intervalStr;

  @override
  _IntervalModalScreenState createState() => _IntervalModalScreenState();
}

class _IntervalModalScreenState extends ConsumerState<IntervalModalScreen> {
  late Timer _timer;
  late int _currentSeconds;
  late String _intervalStr;

  String timerString(int leftSeconds) {
    final minutes = (leftSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (leftSeconds % 60).floor().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Timer countTimer() {
    return Timer.periodic(
      const Duration(seconds: 1),
      (Timer _timer) {
        if (_currentSeconds < 1) {
          _timer.cancel();
        } else {
          setState(() {
            _currentSeconds = _currentSeconds - 1;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // インターバルの文字列を取得する
    _intervalStr = widget.intervalStr;
    // 秒数換算する
    _currentSeconds = getIntervalDuration(_intervalStr)['interval_min'] * 60 + getIntervalDuration(_intervalStr)['interval_sec'];
    // タイマーを起動する
    _timer = countTimer();
  }

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('インターバル', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_currentSeconds > 0) ...{
          // 数値の横幅によるブレをなくす
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            for (var i = 0; i < 5; i++) ...{
              if (i == 2) ...{
                Container(
                  alignment: Alignment.center,
                  child: Text(":", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                ),
              } else ...{
                Container(
                  alignment: Alignment.center,
                  width: 25,
                  child: Text(timerString(_currentSeconds).substring(i, i + 1), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                ),
              }
            }
          ]),
        } else ...{
          Text('インターバルは終了です。\n次のセットに進んでください。', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
        }
      ]),
      actions: [
        TextButton(
          child: _currentSeconds > 0 ? Text("終了") : Text("OK"),
          onPressed: () {
            _timer.cancel();
            // 確認モーダルを削除する
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
