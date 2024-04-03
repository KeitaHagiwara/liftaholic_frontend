import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../common/dialogs.dart';
import '../../common/messages.dart';
import '../../common/provider.dart';
import '../../common/functions.dart';
import '../training_contents_modal.dart';
import './edit_training_set.dart';

class EditTrainingMenuScreen extends ConsumerStatefulWidget {
  const EditTrainingMenuScreen({super.key, required this.training_plan_id});

  // 画面遷移元からのデータを受け取る変数
  final String training_plan_id;

  @override
  _EditTrainingMenuScreenState createState() => _EditTrainingMenuScreenState();
}

class _EditTrainingMenuScreenState extends ConsumerState<EditTrainingMenuScreen> {
  // ********************
  //
  // イニシャライザ設定
  //
  // ********************
  final itemController = TextEditingController();

  // 画面遷移元から引数で取得した変数
  late String _training_plan_id;
  late Map _user_training_data;

  String _training_plan_name = '';
  String _training_plan_description = '';
  Map _user_training_menu = {};

  String? uid = '';

  bool _loading = false;

  // ********************
  //
  // サーバーアクセス処理
  //
  // ********************

  // ----------------------------
  // トレーニングプランにメニューを追加する
  // ----------------------------
  Future<void> _addTrainingMenu(training_plan_id, training_no) async {
    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/training_plan/add_training_menu");

    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({'training_plan_id': training_plan_id, 'training_no': training_no});

    // POSTリクエストを投げる
    try {
      http.Response response = await http.post(url, headers: headers, body: body).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          _user_training_data['training_menu'][jsonResponse['add_user_training_id'][0].toString()] = jsonResponse['add_data'];
          //リクエストに失敗した場合はエラーメッセージを表示
          AlertDialogTemplate(context, '追加しました', jsonResponse['statusMessage']);
        });
      } else if (jsonResponse['statusCode'] == 409) {
        //リクエストに失敗した場合はエラーメッセージを表示
        AlertDialogTemplate(context, '登録済み', jsonResponse['statusMessage']);
      } else {
        //リクエストに失敗した場合はエラーメッセージを表示
        AlertDialogTemplate(context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
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

  // ----------------------------
  // トレーニングプラン自体を削除する
  // ----------------------------
  Future<void> _deleteUserTrainingPlan(training_plan_id) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/training_plan/delete_training_plan/" + training_plan_id.toString());

    // POSTリクエストを投げる
    try {
      http.Response response = await http.delete(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      // 削除が成功したらプランニング画面に遷移する
      if (jsonResponse['statusCode'] == 200) {
        Navigator.of(context).pop(jsonResponse['deleted_id']);
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

  // ----------------------------
  // トレーニングプランからメニューを削除する
  // ----------------------------
  Future<void> _deleteFromUserTrainingMenu(user_training_id) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/training_plan/delete_user_training_menu/" + user_training_id.toString());

    // POSTリクエストを投げる
    try {
      http.Response response = await http.delete(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      // 削除が成功したら画面をリロード
      if (jsonResponse['statusCode'] == 200) {
        // 画面から該当のトレーニングを削除する
        setState(() {
          // 配列の何行目かを確認して、該当の配列番号の要素を削除する
          _user_training_data['training_menu'].remove(user_training_id.toString());
        });
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

  // ----------------------------
  // トレーニングメニューをプランから削除するダイアログ
  // ----------------------------
  void _deleteTrainingDialog(String user_training_id, String training_name) {
    showDialog(
      context: context,
      builder: (BuildContext context_modal) {
        return AlertDialog(
          title: Text('メニュー削除', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
          content: Text('「' + training_name + '」をトレーニングメニューから削除します。よろしいですか？'),
          actions: [
            TextButton(
              child: Text("キャンセル"),
              onPressed: () {
                Navigator.of(context_modal).pop();
              },
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                _deleteFromUserTrainingMenu(user_training_id);
                Navigator.of(context_modal).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------
  // トレーニングプランを削除するダイアログ
  // ----------------------------
  void _deleteTrainingPlanDialog(String training_plan_id, String training_plan_name) {
    showDialog(
      context: context,
      builder: (BuildContext context_modal) {
        return AlertDialog(
          title: Text('プラン削除', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
          content: Text('トレーニングプラン「' + training_plan_name + '」を削除します。よろしいですか？'),
          actions: [
            // プラン削除キャンセル
            TextButton(
              child: Text("キャンセル"),
              onPressed: () {
                Navigator.of(context_modal).pop();
              },
            ),
            // プラン削除の確認OK
            TextButton(
              child: Text("OK"),
              onPressed: () {
                _deleteUserTrainingPlan(training_plan_id);
                // 確認モーダルを削除する
                Navigator.of(context_modal).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // 受け取ったデータを状態を管理する変数に格納
    _training_plan_id = widget.training_plan_id;
    _user_training_data = ref.read(userTrainingDataProvider)[_training_plan_id];

    _training_plan_name = _user_training_data['training_plan_name'];
    _training_plan_description = _user_training_data['training_plan_description'];
    _user_training_menu = _user_training_data['training_menu'];
  }

  // ********************
  //
  // データを元に表示するWidget
  //
  // ********************
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'プラン編集',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
          : Container(
              // 余白を付ける
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 8),
                  SizedBox(
                    child: Text(
                      _training_plan_name,
                      style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 16.0),
                    ),
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(''),
                    //     Text(
                    //       _training_plan_name,
                    //       style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 16.0),
                    //     ),
                    //     ElevatedButton(
                    //       child: !ref.watch(isDoingWorkoutProvider)
                    //           ? _user_training_menu.length > 0
                    //               ? Icon(Icons.play_arrow, color: Colors.green)
                    //               : Icon(Icons.play_arrow, color: Colors.grey)
                    //           : Icon(Icons.stop, color: Colors.red),
                    //       style: ElevatedButton.styleFrom(
                    //         // side: BorderSide(color: Colors.green),
                    //         backgroundColor: Colors.grey[900], // background
                    //       ),
                    //       onPressed: _user_training_menu.length == 0
                    //           ? null
                    //           : () {
                    //               if (!ref.read(isDoingWorkoutProvider.notifier).state) {
                    //                 showDialog(
                    //                   context: context,
                    //                   builder: (BuildContext context_modal) {
                    //                     return AlertDialog(
                    //                       title: Text('ワークアウト', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
                    //                       content: Text('このトレーニングプランを開始します。よろしいですか？'),
                    //                       actions: [
                    //                         TextButton(
                    //                           child: Text("Cancel"),
                    //                           onPressed: () {
                    //                             Navigator.of(context_modal).pop();
                    //                           },
                    //                         ),
                    //                         TextButton(
                    //                           child: Text("開始"),
                    //                           onPressed: () {
                    //                             ref.read(isDoingWorkoutProvider.notifier).state = true;
                    //                             ref.read(execPlanIdProvider.notifier).state = _training_plan_id;
                    //                             // モーダルを閉じる
                    //                             Navigator.of(context_modal).pop();
                    //                           },
                    //                         ),
                    //                       ],
                    //                     );
                    //                   },
                    //                 );
                    //               } else {
                    //                 showDialog(
                    //                   context: context,
                    //                   builder: (BuildContext context_modal) {
                    //                     return AlertDialog(
                    //                       title: Text('終了', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
                    //                       content: Text('実施中のワークアウトを終了します。よろしいですか？'),
                    //                       actions: [
                    //                         TextButton(
                    //                           child: Text("Cancel"),
                    //                           onPressed: () {
                    //                             Navigator.of(context_modal).pop();
                    //                           },
                    //                         ),
                    //                         TextButton(
                    //                           child: Text("終了"),
                    //                           onPressed: () {
                    //                             ref.read(isDoingWorkoutProvider.notifier).state = false;
                    //                             // モーダルを閉じる
                    //                             Navigator.of(context_modal).pop();
                    //                           },
                    //                         ),
                    //                       ],
                    //                     );
                    //                   },
                    //                 );
                    //               }
                    //             },
                    //     ),
                    //   ],
                    // ),
                  ),
                  // トレーニングプランの説明文を記載する
                  if (_training_plan_description != '') ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      child: Text(
                        _training_plan_description,
                        style: TextStyle(color: Colors.white70, fontSize: 12.0),
                      ),
                    ),
                  ],
                  // トレーニングプランに設定されているトレーニング一覧
                  const SizedBox(height: 8),
                  Flexible(
                    // height: 150,
                    child: _user_training_menu.length == 0
                        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('トレーニングが未登録です。')]))
                        : ListView.builder(
                            itemCount: _user_training_menu.length,
                            itemBuilder: (BuildContext context, int index) {
                              var user_training_id = List.from(_user_training_menu.keys)[index];
                              return buildTrainingListTile(user_training_id, _user_training_menu[user_training_id], index);
                            }),
                  ),
                  // トレーニング追加ボタン
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.only(left: 64, right: 64),
                    // 横幅いっぱいに広げる
                    width: double.infinity,
                    // リスト追加ボタン
                    child: ElevatedButton(
                      child: Text('メニュー追加', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // background
                      ),
                      onPressed: () {
                        // トレーニングメニューのマスタをProviderから取得する
                        var training_menu_master = ref.read(trainingMenuMasterProvider);
                        selectTrainingModal(context, uid, _training_plan_id, training_menu_master);
                      },
                    ),
                  ),
                  // トレーニングプラン削除ボタン
                  // const SizedBox(height: 8),
                  // Container(
                  //   padding: EdgeInsets.only(left: 64, right: 64),
                  //   // 横幅いっぱいに広げる
                  //   width: double.infinity,
                  //   // リスト追加ボタン
                  //   child: ElevatedButton(
                  //     child: Text('プラン削除', style: TextStyle(color: Colors.white)),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.red, // background
                  //     ),
                  //     onPressed: () {
                  //       // Navigator.of(context).pop();
                  //       _deleteTrainingPlanDialog(_training_plan_id, _training_plan_name);
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
    );
  }

  // ********************
  //
  // トレーニングリストタイル
  //
  // ********************
  Widget buildTrainingListTile(String user_training_id, Map training, int index) => Card(
        child: Slidable(
            endActionPane: ActionPane(motion: const BehindMotion(), children: [
              SlidableAction(
                  backgroundColor: Colors.red,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                  icon: Icons.delete,
                  label: '削除',
                  onPressed: (context) {
                    _deleteTrainingDialog(
                      user_training_id,
                      training['training_name'],
                    );
                  })
            ]),
            child: Column(children: <Widget>[
              ListTile(
                dense: true,
                leading: GestureDetector(
                  onTap: () {
                    // トレーニングアイコンのタップでトレーニング詳細を表示する
                    var training = ref.watch(execTrainingMenuProvider)[List.from(ref.read(execTrainingMenuProvider).keys)[index]];
                    showTrainingContentModal(context, training);
                  },
                  child: CircleAvatar(
                    radius: 25,
                    foregroundImage: AssetImage('assets/images/chest.png'),
                  ),
                ),
                title: Text(training['training_name'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(ref.watch(execTrainingMenuProvider)[List.from(ref.read(execTrainingMenuProvider).keys)[index]]['kgs'].toString() +
                    ' kg\n' +
                    ref.watch(execTrainingMenuProvider)[List.from(ref.read(execTrainingMenuProvider).keys)[index]]['reps'].toString() +
                    ' reps\n' +
                    ref.watch(execTrainingMenuProvider)[List.from(ref.read(execTrainingMenuProvider).keys)[index]]['sets'].toString() +
                    ' sets'),
                // trailing: IconButton(icon: Icon(Icons.more_horiz), onPressed: () {}),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      // 遷移先の画面としてリスト追加画面を指定
                      return EditTrainingSetScreen(user_training_menu_id: user_training_id.toString());
                    }),
                  );
                },
              )
            ])),
      );

  // // ********************
  // //
  // // トレーニングメニューのモーダルを作成する
  // //
  // // ********************
  // void selectTrainingModal(context, uid, plan_id) {
  //   // Map<String, dynamic> training_menu_master = {
  //   //   '腕': {
  //   //     '1': {
  //   //       'training_name': '腕トレ１',
  //   //       'description': '',
  //   //       'purpose_name': '',
  //   //       'purpose_comment': '',
  //   //       'sub_part_name': '',
  //   //       'type_name': '',
  //   //       'type_comment': '',
  //   //       'event_name': '',
  //   //       'event_comment': ''
  //   //     },
  //   // };

  //   final training_menu_master = ref.read(trainingMenuMasterProvider);

  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SizedBox(
  //         height: 800,
  //         width: double.infinity,
  //         child: SingleChildScrollView(
  //           child: Padding(
  //             padding: EdgeInsets.all(5),
  //             child: Column(children: [
  //               Align(
  //                 alignment: Alignment.topRight,
  //                 child: IconButton(
  //                     icon: Icon(Icons.cancel),
  //                     onPressed: () {
  //                       Navigator.of(context).pop(); // Close the sheet.
  //                     }),
  //               ),
  //               Container(
  //                 margin: EdgeInsets.only(bottom: 15),
  //                 width: double.infinity,
  //                 child: Text(
  //                   'トレーニングを選択',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
  //                 ),
  //               ),
  //               // // 検索ボックス
  //               // Padding(
  //               //   padding: const EdgeInsets.symmetric(
  //               //     vertical: 12,
  //               //     horizontal: 36,
  //               //   ),
  //               //   child: TextField(
  //               //     style: TextStyle(
  //               //       fontSize: 14,
  //               //       color: Colors.white,
  //               //     ),
  //               //     decoration: InputDecoration(
  //               //       // ← InputDecorationを渡す
  //               //       hintText: '検索ワードを入力してください',
  //               //     ),
  //               //   ),
  //               // ),
  //               SizedBox(
  //                   child: Column(
  //                 children: [
  //                   for (int i = 0; i < training_menu_master.length; i++) ...{
  //                     ExpansionTile(
  //                       title: Container(
  //                         child: ListTile(
  //                           title: Text(
  //                             List.from(training_menu_master.keys)[i],
  //                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey[700],
  //                           borderRadius: BorderRadius.circular(5),
  //                         ),
  //                       ),
  //                       children: [
  //                         for (int i_c1 = 0; i_c1 < training_menu_master[List.from(training_menu_master.keys)[i]].length; i_c1++) ...{
  //                           Slidable(
  //                             startActionPane: ActionPane(motion: const ScrollMotion(), children: [
  //                               SlidableAction(
  //                                   borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
  //                                   backgroundColor: Colors.green,
  //                                   icon: Icons.add,
  //                                   label: '追加',
  //                                   onPressed: (context) {
  //                                     // トレーニングIDを取得する
  //                                     var training_no = List.from(List.from(training_menu_master.values)[i].keys)[i_c1];
  //                                     // プランにトレーニングメニューを追加する
  //                                     _addTrainingMenu(plan_id, training_no);
  //                                   })
  //                             ]),
  //                             child: ListTile(
  //                               title: Text(List.from(List.from(training_menu_master.values)[i].values)[i_c1]['training_name']),
  //                               onTap: () {
  //                                 // トレーニングのコンテンツのモーダルを表示する
  //                                 showTrainingContentModal(context, List.from(List.from(training_menu_master.values)[i].values)[i_c1]);
  //                               },
  //                             ),
  //                           )
  //                         }
  //                       ],
  //                     )
  //                   }
  //                 ],
  //               )),
  //             ]),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
