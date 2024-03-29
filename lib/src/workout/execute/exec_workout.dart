import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/cupertino.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_spinbox/material.dart';
// import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:liftaholic_frontend/src/common/default_value.dart';
import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/common/functions.dart';
import '../training_contents_modal.dart';
import 'stop_watch.dart';

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
                child: Text("Cancel"),
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
      // 実績を更新する -> これがないと画面が更新されない
      setState(() {});
    });
  }
}
