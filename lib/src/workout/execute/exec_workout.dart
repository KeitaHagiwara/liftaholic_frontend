import 'dart:async';
import 'dart:convert';

// import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinbox/cupertino.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:liftaholic_frontend/src/common/default_value.dart';

import '../../common/provider.dart';
import '../../common/dialogs.dart';
import '../../common/error_messages.dart';
import '../../common/functions.dart';
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
  double _kgs_default = kgsDefault;
  int _reps_default = repsDefault;

  String timeString = "00:00:00";
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;

  // テキストフィールドのコントローラーを設定する
  final TextEditingController _resp_controller = TextEditingController();
  final TextEditingController _kgs_controller = TextEditingController();

  // ********************
  // サーバーアクセス処理
  // ********************
  // Future<void> _getUserTrainingMenu(_user_training_id) async {
  //   // スピナー表示
  //   setState(() {
  //     _loading = true;
  //   });

  //   await dotenv.load(fileName: '.env');
  //   //リクエスト先のurl
  //   Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/workout/get_user_training_menu/" + _user_training_id.toString());

  //   try {
  //     if (!mounted) return;
  //     var response = await http.get(url).timeout(Duration(seconds: 10));

  //     var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
  //     if (jsonResponse['statusCode'] == 200) {
  //       print(jsonResponse);
  //       setState(() {
  //         // スピナー非表示
  //         _training = jsonResponse['training'];
  //         _training_name = _training['training_name'];
  //         _kgs_default = _training['kgs_default'];
  //         _reps_default = _training['reps_default'];
  //         _user_training_menu = jsonResponse['user_training_menu'];
  //         print(_training);
  //         print(_user_training_menu);
  //       });
  //     } else {
  //       //リクエストに失敗した場合はエラーメッセージを表示
  //       AlertDialogTemplate(context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
  //     }
  //   } catch (e) {
  //     //リクエストに失敗した場合はエラーメッセージを表示
  //     AlertDialogTemplate(context, ERR_MSG_TITLE, ERR_MSG_NETWORK);
  //   } finally {
  //     setState(() {
  //       // スピナー非表示
  //       _loading = false;
  //     });
  //   }
  // }

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
                    _exec_training_menu[_user_training_id]['progress'] = calc_progress(_user_training_id, _training_set_list);
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
        _exec_training_menu[_user_training_id]['progress'] = calc_progress(_user_training_id, _training_set_list);
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
    _reps_default = _exec_training_menu[_user_training_id]['reps'];
    _kgs_default = _exec_training_menu[_user_training_id]['kgs'];
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
                          _exec_training_menu[_user_training_id]['progress'] = calc_progress(_user_training_id, _training_set_list);
                          // Providerの値を更新する
                          ref.read(execTrainingMenuProvider.notifier).state = _exec_training_menu;
                        });
                      },
                      child: Text('セット追加', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                  ),
                  // 完了ボタン -> 一旦不要
                  // const SizedBox(height: 8),
                  // Container(
                  //   padding: EdgeInsets.only(left: 64, right: 64),
                  //   // 横幅いっぱいに広げる
                  //   width: double.infinity,
                  //   // キャンセルボタン
                  //   child: ElevatedButton(
                  //     // ボタンをクリックした時の処理
                  //     onPressed: () {
                  //       print('done!');
                  //     },
                  //     child: Text('種目完了', style: TextStyle(color: Colors.white)),
                  //     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  //   ),
                  // ),
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
