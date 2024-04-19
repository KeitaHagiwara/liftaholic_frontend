import 'dart:async';
import 'dart:convert';
import 'dart:math';

// import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinbox/cupertino.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/common/dialogs.dart';
import 'package:liftaholic_frontend/src/common/messages.dart';
import 'package:liftaholic_frontend/src/common/functions.dart';
import 'package:liftaholic_frontend/src/workout/execute/timer.dart';

class StopWatchScreen extends ConsumerStatefulWidget {
  const StopWatchScreen({Key? key, required this.user_training_id, required this.exec_training_menu, required this.index}) : super(key: key);

  final String user_training_id;
  final Map exec_training_menu;
  final int index;

  @override
  _StopWatchScreenState createState() => _StopWatchScreenState();
}

class _StopWatchScreenState extends ConsumerState<StopWatchScreen> {
  bool _setComplete = false;

  String timeString = "00:00";
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;

  late String _user_training_id;
  late Map _exec_training_menu;
  late int _menu_index;

  List _training_set_list = [];

  void start() {
    stopwatch.start();
    if (stopwatch.isRunning) {
      setState(() {});
    }
    timer = Timer.periodic(Duration(seconds: 1), update);
  }

  void update(Timer t) {
    if (stopwatch.isRunning) {
      setState(() {
        timeString = (stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") + ":" + (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, "0");

        // millisecond単位
        // timeString =
        //     (stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") + ":" +
        //         (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, "0") + ":" +
        //         (stopwatch.elapsed.inMilliseconds % 1000 / 10).clamp(0, 99).toStringAsFixed(0).padLeft(2, "0");
      });
    }
  }

  void stop() {
    setState(() {
      timer.cancel();
      stopwatch.stop();
    });
  }

  void reset() {
    if (stopwatch.isRunning) {
      Widget callbackButton = TextButton(
        child: Text('リセット'),
        onPressed: () {
          timer.cancel();
          stopwatch.reset();
          setState(() {
            timeString = "00:00";
          });
          stopwatch.stop();
          // モーダルを閉じる
          Navigator.of(context).pop(null);
        },
      );
      ConfirmDialogTemplate(context, callbackButton, 'リセット', 'トレーニングは実施中です。タイマーをリセットしてもよろしいですか？');
    } else {
      timer.cancel();
      stopwatch.reset();
      setState(() {
        timeString = "00:00";
      });
      stopwatch.stop();
    }
  }

  void set_complete() {
    // タイマーが動いていたらストップウォッチを止める
    if (stopwatch.isRunning) {
      timer.cancel();
      stopwatch.reset();
      stopwatch.stop();
    }
    setState(() {
      // リストの更新処理を行う
      _training_set_list[_menu_index]['time'] = timeString;
      _training_set_list[_menu_index]['is_completed'] = true;
      _exec_training_menu[_user_training_id]['progress'] = calcProgress(_training_set_list);
      _setComplete = true;
    });
    // Providerの値を更新する
    ref.read(execTrainingMenuProvider.notifier).state = _exec_training_menu;
  }

  @override
  void initState() {
    super.initState();

    _user_training_id = widget.user_training_id;
    _exec_training_menu = widget.exec_training_menu;
    _menu_index = widget.index;

    _training_set_list = _exec_training_menu[_user_training_id]['sets_achieve'];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 650,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    if (stopwatch.isRunning) {
                      AlertDialogTemplate(context, CFM_MSG_TITLE, 'トレーニング実施中です。タイマーを停止してから閉じてください。');
                    } else {
                      Navigator.of(context).pop(null);
                    }
                  }),
            ),
            SizedBox(
              width: double.infinity,
              child: _training_set_list[_menu_index]['is_completed']
                  ? Text(
                      (_menu_index + 1).toString() + 'セット目は完了しています',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.green, fontSize: 18.0),
                    )
                  : Text(
                      (_menu_index + 1).toString() + 'セット目',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                    ),
            ),
            const SizedBox(height: 20),
            // TimerScreen(),
            SizedBox(
              // Wrap the Container with Expanded widget
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle, boxShadow: [
                  BoxShadow(offset: Offset(10, 10), color: Colors.black38, blurRadius: 15),
                ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.timer, size: 60, color: Colors.grey.shade800),
                    // セットが完了している場合
                    if (_training_set_list[_menu_index]['is_completed']) ...{
                      Text(
                        _training_set_list[_menu_index]['time'],
                        style: TextStyle(fontSize: 40, color: Colors.grey.shade900)
                      )
                    } else ...{
                      // 数値の横幅によるブレをなくす
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (var i = 0; i < 5; i++) ...{
                            if (i == 2)...{
                              Container(
                                alignment: Alignment.center,
                                child: Text(":", style: TextStyle(fontSize: 40, color: Colors.grey.shade900)),
                              ),
                            } else...{
                              Container(
                                alignment: Alignment.center,
                                width: 25,
                                child: Text(timeString.toString().substring(i, i+1), style: TextStyle(fontSize: 40, color: Colors.grey.shade900)),
                              ),
                            }
                          }
                        ]
                      ),
                    }
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                      onPressed: _training_set_list[_menu_index]['is_completed']
                          ? null
                          : () {
                              reset();
                            },
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle, boxShadow: [
                          BoxShadow(offset: Offset(10, 10), color: Colors.black38, blurRadius: 15),
                        ]),
                        child: Icon(Icons.refresh, size: 40, color: Colors.grey.shade800),
                      )),
                  TextButton(
                      onPressed: _training_set_list[_menu_index]['is_completed']
                          ? null
                          : () {
                              stopwatch.isRunning ? stop() : start();
                            },
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle, boxShadow: [
                          BoxShadow(offset: Offset(10, 10), color: Colors.black38, blurRadius: 15),
                        ]),
                        child: stopwatch.isRunning ? Icon(Icons.pause, size: 40, color: Colors.yellow[800]) : Icon(Icons.play_arrow, size: 40, color: Colors.green),
                      ))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
              child: SpinBox(
                min: 0.0,
                max: 500.0,
                value: _training_set_list[_menu_index]['kgs'].toDouble(),
                decimals: 2,
                step: 0.25,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  labelText: 'kgs',
                  labelStyle: TextStyle(
                    fontSize: 24,
                  ),
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white70,
                    ),
                  ),
                ),
                onChanged: (value) {
                  _training_set_list[_menu_index]['kgs'] = value;
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
              child: SpinBox(
                min: 1,
                max: 500,
                value: _training_set_list[_menu_index]['reps'].toDouble(),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  labelText: 'reps',
                  labelStyle: TextStyle(
                    fontSize: 24,
                  ),
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white70,
                    ),
                  ),
                ),
                onChanged: (value) {
                  _training_set_list[_menu_index]['reps'] = value.toInt();
                },
              ),
            ),
            const SizedBox(height: 10),
            if (_training_set_list[_menu_index]['is_completed']) ...{
              ElevatedButton(
                child: Text('閉じる', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
            } else ...{
              ElevatedButton(
                child: Text('セット完了', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  set_complete();
                  var result = {'set': _menu_index + 1};
                  Navigator.of(context).pop(result);
                },
              ),
            },
            const SizedBox(height: 5),
          ]),
        ),
      ),
    );
  }
}
