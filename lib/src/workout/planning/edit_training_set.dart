import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';

// 自作モジュール
import 'package:liftaholic_frontend/src/common/default_value.dart';
import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/common/dialogs.dart';
import 'package:liftaholic_frontend/src/common/messages.dart';
import 'package:liftaholic_frontend/src/common/functions.dart';
import 'package:liftaholic_frontend/src/workout/training_contents_modal.dart';

class EditTrainingSetScreen extends ConsumerStatefulWidget {
  const EditTrainingSetScreen({super.key, required this.user_training_menu_id});

  final String user_training_menu_id;

  @override
  _EditTrainingSetScreenState createState() => _EditTrainingSetScreenState();
}

class _EditTrainingSetScreenState extends ConsumerState<EditTrainingSetScreen> {
  // ********************
  // イニシャライザ設定
  // ********************
  bool _loading = false;

  // 初期値
  static const padding_vertical = 10;
  static const padding_horizontal = 70;

  late String _user_training_menu_id;
  late Map _training;

  late int _sets;
  late double _kgs;
  late int _reps;
  Duration _intervalTimer = Duration(minutes: 1);
  String _intervalStr = '01:00';

  // ********************
  // サーバーアクセス処理
  // ********************
  // トレーニングメニューの回数を設定する
  Future<void> _updateUserTrainingSets(context, userTrainingId, setsInput, repsInput, kgsInput, intervalStr) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    if (setsInput == '' || repsInput == '' || kgsInput == '') {
      AlertDialogTemplate(context, CFM_MSG_TITLE, CFM_MSG_INPUT_NULL);
      return;
    }
    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/workout/update_training_set");

    Map<String, String> headers = {'content-type': 'application/json'};
    Map update_data = {'user_id': FirebaseAuth.instance.currentUser?.uid, 'user_training_id': userTrainingId, 'sets': setsInput, 'reps': repsInput, 'kgs': kgsInput, 'interval': intervalStr};
    print(update_data);
    String body = json.encode(update_data);

    // POSTリクエストを投げる
    try {
      http.Response response = await http.post(url, headers: headers, body: body).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          _training['sets'] = _sets;
          _training['kgs'] = _kgs;
          _training['reps'] = _reps;
          _training['interval'] = _intervalStr;
        });
        //リクエストに失敗した場合はエラーメッセージを表示
        await AlertDialogTemplate(context, '更新しました。', jsonResponse['statusMessage']);
        Navigator.of(context).pop();
      } else {
        //リクエストに失敗した場合はエラーメッセージを表示
        AlertDialogTemplate(context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
      }
    } catch (e) {
      //リクエストに失敗した場合はエラーメッセージを表示
      AlertDialogTemplate(context, ERR_MSG_TITLE, ERR_MSG_NETWORK);
    } finally {
      // スピナー非表示
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _user_training_menu_id = widget.user_training_menu_id;
    _training = ref.read(execTrainingMenuProvider)[_user_training_menu_id];

    // 初期値を設定する
    _training['sets'] == null ? _sets = setsDefault : _sets = _training['sets'];
    _training['kgs'] == null ? _kgs = kgsDefault : _kgs = _training['kgs'];
    _training['reps'] == null ? _reps = repsDefault : _reps = _training['reps'];
    _training['interval'] == null ? _intervalStr = intervalDefault : _intervalStr = _training['interval'];
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
          'メニュー編集',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
          : Container(
              // 余白を付ける
              padding: EdgeInsets.all(10),
              child: Column(children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    _training['training_name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                  ),
                ),
                TextButton(
                  child: Text('詳細'),
                  onPressed: () {
                    showTrainingContentModal(context, _training);
                  },
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding_horizontal.toDouble(), vertical: padding_vertical.toDouble()),
                  child: SpinBox(
                    min: 1,
                    max: 500,
                    value: _sets.toDouble(),
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      labelText: 'sets',
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
                      setState(() {
                        _sets = value.toInt();
                      });
                    },
                  ),
                ),
                // const SizedBox(height: 3),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding_horizontal.toDouble(), vertical: padding_vertical.toDouble()),
                  child: SpinBox(
                    min: 0.0,
                    max: 500.0,
                    value: _kgs.toDouble(),
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
                      setState(() {
                        _kgs = value.toDouble();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding_horizontal.toDouble(), vertical: padding_vertical.toDouble()),
                  child: SpinBox(
                    min: 1,
                    max: 500,
                    value: _reps.toDouble(),
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
                      setState(() {
                        _reps = value.toInt();
                      });
                    },
                  ),
                ),
                // const SizedBox(height: 3),
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
                                          _intervalStr = _intervalTimer.toString().split('.').first.split(':')[1] + ':' + _intervalTimer.toString().split('.').first.split(':')[2];
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
                          Text(_intervalStr, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                        ],
                      )),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: padding_horizontal.toDouble(), vertical: padding_vertical.toDouble()),
                  // 横幅いっぱいに広げる
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {
                      _updateUserTrainingSets(context, _user_training_menu_id, _sets, _reps, _kgs, _intervalStr);
                    },
                    child: Text("更新", style: TextStyle(color: Colors.white)), // Add the button text.
                  ),
                ),
              ]),
            ),
    );
  }
}
