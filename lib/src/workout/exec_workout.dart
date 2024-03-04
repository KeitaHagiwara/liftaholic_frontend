import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

// import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinbox/cupertino.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';
import '../planning/training_contents_modal.dart';
import './stop_watch.dart';

class ExecWorkoutScreen extends ConsumerStatefulWidget {
  const ExecWorkoutScreen({Key? key, required this.user_training_id})
      : super(key: key);

  final String user_training_id;

  @override
  _ExecWorkoutScreenState createState() => _ExecWorkoutScreenState();
}

class _ExecWorkoutScreenState extends ConsumerState<ExecWorkoutScreen> {
  // ********************
  // イニシャライザ設定
  // ********************
  // 画面遷移元から引数で取得した変数
  late String user_training_id; // ユーザーのトレーニングメニューID

  bool _loading = false;

  Map<String, dynamic> _training = {};
  String _training_name = '';
  double _kgs_default = 0.0;
  int _reps_default = 0;
  List _user_training_menu = [];

  String timeString = "00:00:00";
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;

  // テキストフィールドのコントローラーを設定する
  final TextEditingController _resp_controller = TextEditingController();
  final TextEditingController _kgs_controller = TextEditingController();

  // ********************
  // サーバーアクセス処理
  // ********************
  Future<void> _getUserTrainingMenu(user_training_id) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" +
        dotenv.get('API_HOST') +
        ":" +
        dotenv.get('API_PORT') +
        "/api/workout/get_user_training_menu/" +
        user_training_id.toString());

    try {
      if (!mounted) return;
      var response = await http.get(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          // スピナー非表示
          _training = jsonResponse['training'];
          _training_name = _training['training_name'];
          _kgs_default = _training['kgs_default'];
          _reps_default = _training['reps_default'];
          _user_training_menu = jsonResponse['user_training_menu'];
          print(_training);
          print(_user_training_menu);
        });
      } else {
        //リクエストに失敗した場合はエラーメッセージを表示
        AlertDialogTemplate(
            context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
      }
    } catch (e) {
      //リクエストに失敗した場合はエラーメッセージを表示
      AlertDialogTemplate(context, ERR_MSG_TITLE, ERR_MSG_NETWORK);
    } finally {
      setState(() {
        // スピナー非表示
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    user_training_id = widget.user_training_id;
    _getUserTrainingMenu(user_training_id);
  }

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _training_name,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold)
              .copyWith(color: Colors.white70, fontSize: 18.0),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
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
                            showTrainingContentModal(context,
                                _training);
                          })),
                  Flexible(
                      child: _user_training_menu.length == 0
                          ? Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [Text('トレーニングプランが設定されていません。')]))
                          : ListView.builder(
                              itemCount: _user_training_menu.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                    child: Column(
                                  children: <Widget>[
                                    ListTile(
                                        dense: true,
                                        title: Text(
                                            (index + 1).toString() + 'セット目'),
                                        leading: Icon(Icons.task_alt,
                                            color: _user_training_menu[index]
                                                    ['is_completed']
                                                ? Colors.green
                                                : Colors.grey),
                                        trailing: _user_training_menu[index]
                                                ['is_completed']
                                            ? Text(_user_training_menu[index]
                                                        ['kgs']
                                                    .toString() +
                                                'kgs  ' +
                                                _user_training_menu[index]
                                                        ['reps']
                                                    .toString() +
                                                'reps\n' +
                                                _user_training_menu[index]
                                                    ['time'])
                                            : Text(''),
                                        onTap: () {
                                          startTrainigModal(context, index);
                                        })
                                  ],
                                ));
                              })),
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
                          _user_training_menu.add({
                            'reps': _reps_default,
                            'kgs': _kgs_default,
                            'time': '00:00',
                            'is_completed': false
                          });
                        });
                      },
                      child:
                          Text('セット追加', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                    ),
                  ),
                  // 完了ボタン
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.only(left: 64, right: 64),
                    // 横幅いっぱいに広げる
                    width: double.infinity,
                    // キャンセルボタン
                    child: ElevatedButton(
                      // ボタンをクリックした時の処理
                      onPressed: () {
                        print('done!');
                      },
                      child:
                          Text('種目完了', style: TextStyle(color: Colors.white)),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void startTrainigModal(context, int index) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false, // 背景押下で閉じないようにする
      enableDrag: false, // ドラッグで閉じないようにする
      context: context,
      builder: (BuildContext context) {
        return StopWatchScreen(
            user_training_menu: _user_training_menu, index: index);
      },
    );
  }
}
