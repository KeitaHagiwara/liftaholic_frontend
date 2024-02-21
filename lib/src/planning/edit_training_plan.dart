import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';
import '../common/provider.dart';
import '../planning/training_contents_modal.dart';

class EditTrainingPlanScreen extends ConsumerStatefulWidget {
  const EditTrainingPlanScreen(
      {Key? key,
      required this.training_plan_id,
      required this.registered_plan_list})
      : super(key: key);

  // 画面遷移元からのデータを受け取る変数
  final String training_plan_id;
  final List registered_plan_list;

  @override
  _EditTrainingPlanScreenState createState() => _EditTrainingPlanScreenState();
}

class _EditTrainingPlanScreenState
    extends ConsumerState<EditTrainingPlanScreen> {
  // ********************
  //
  // イニシャライザ設定
  //
  // ********************
  final itemController = TextEditingController();

  // 画面遷移元から引数で取得した変数
  late String training_plan_id;
  late List registered_plan_list;

  String training_plan_name = '';
  String training_plan_description = '';

  String? uid = '';

  bool _loading = false;

  // トレーニングプランを作成するときに使用する辞書
  Map<String, String> _createPlanDict = {};

  Map _trainings_registered = {};

  // Map _trainings_registered = {
  //   1: {'training_name': 'ベンチプレス', 'description': 'bench'},
  //   2: {'training_name': 'プッシュアップ', 'description': 'push-up'},
  //   3: {'training_name': 'インクラインダンベルプレス', 'description': 'press'}
  // };

  // トレーニングメニューを入れる辞書
  Map<String, dynamic> training_menu = {};

  // ********************
  //
  // サーバーアクセス処理
  //
  // ********************
  // ----------------------------
  // 全トレーニングメニューを取得する
  // ----------------------------
  Future<void> _getAllTrainingMenu() async {
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
        "/api/training_plan/get_all_training_menu");

    try {
      var response = await http.get(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (!mounted) return;
      // トレーニングメニューの取得に成功した場合
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          // トレーニングメニューのデータを作成
          training_menu = jsonResponse['training_menu'];
        });
      } else {
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

  // ----------------------------
  // トレーニングプランに登録済みのトレーニングを取得する
  // ----------------------------
  Future<void> _getRegisteredTrainings(training_plan_id) async {
    setState(() {
      // スピナー非表示
      _loading = true;
    });

    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" +
        dotenv.get('API_HOST') +
        ":" +
        dotenv.get('API_PORT') +
        "/api/training_plan/get_registered_trainings/" +
        training_plan_id.toString());

    try {
      if (!mounted) return;
      var response = await http.get(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          // トレーニングプランの詳細をWidgetに設定
          training_plan_name =
              jsonResponse['training_plan']['training_plan_name'];
          training_plan_description =
              jsonResponse['training_plan']['training_plan_description'];

          // トレーニングメニューのデータを作成
          _trainings_registered = jsonResponse['user_training_menu'];
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

  // ----------------------------
  // トレーニングプランにメニューを追加する
  // ----------------------------
  Future<void> _addTrainingMenu(training_plan_id, training_no) async {
    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" +
        dotenv.get('API_HOST') +
        ":" +
        dotenv.get('API_PORT') +
        "/api/training_plan/add_training_menu");

    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode(
        {'training_plan_id': training_plan_id, 'training_no': training_no});

    // POSTリクエストを投げる
    try {
      http.Response response = await http
          .post(url, headers: headers, body: body)
          .timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          _trainings_registered[jsonResponse['add_user_training_id'][0].toString()] =
              jsonResponse['add_data'];
          //リクエストに失敗した場合はエラーメッセージを表示
          AlertDialogTemplate(context, '追加しました', jsonResponse['statusMessage']);
        });
      } else if (jsonResponse['statusCode'] == 409) {
        //リクエストに失敗した場合はエラーメッセージを表示
        AlertDialogTemplate(context, '登録済み', jsonResponse['statusMessage']);
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
    Uri url = Uri.parse("http://" +
        dotenv.get('API_HOST') +
        ":" +
        dotenv.get('API_PORT') +
        "/api/training_plan/delete_training_plan/" +
        training_plan_id.toString());

    // POSTリクエストを投げる
    try {
      http.Response response =
          await http.delete(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      // 削除が成功したらプランニング画面に遷移する
      if (jsonResponse['statusCode'] == 200) {
        Navigator.of(context).pop(jsonResponse['deleted_id']);
      } else {
        //リクエストに失敗した場合はエラーメッセージを表示
        AlertDialogTemplate(
            context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
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
    Uri url = Uri.parse("http://" +
        dotenv.get('API_HOST') +
        ":" +
        dotenv.get('API_PORT') +
        "/api/training_plan/delete_user_training_menu/" +
        user_training_id.toString());

    // POSTリクエストを投げる
    try {
      http.Response response =
          await http.delete(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      // 削除が成功したら画面をリロード
      if (jsonResponse['statusCode'] == 200) {
        // 画面から該当のトレーニングを削除する
        setState(() {
          // 配列の何行目かを確認して、該当の配列番号の要素を削除する
          _trainings_registered.remove(user_training_id);
        });
      }
      // スピナーを非表示にする
      _loading = false;
    } catch (e) {
      print(e);
    }
  }

  // ----------------------------
  // トレーニングメニューをプランから削除するダイアログ
  // ----------------------------
  void _deleteTrainingDialog(String user_training_id, String training_name) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          // title: Text(training_name),
          content: Text(training_name + "をトレーニングプランから削除します。よろしいですか？"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                _deleteFromUserTrainingMenu(user_training_id);
                Navigator.of(context).pop();
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
  void _deleteTrainingPlanDialog(
      String training_plan_id, String training_plan_name) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          // title: Text(training_name),
          content: Text("トレーニングプラン「" + training_plan_name + "」を削除します。よろしいですか？"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                _deleteUserTrainingPlan(training_plan_id);
                Navigator.of(context).pop();
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
    training_plan_id = widget.training_plan_id;
    registered_plan_list = widget.registered_plan_list;

    // トレーニングプランに登録済みのトレーニングメニューを取得する
    _getRegisteredTrainings(training_plan_id);

    // 登録済みの全トレーニングメニューを取得する
    _getAllTrainingMenu();
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
          'トレーニングプラン編集',
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
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 8),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(''),
                        Text(
                          training_plan_name,
                          style: TextStyle(fontWeight: FontWeight.bold)
                              .copyWith(color: Colors.white70, fontSize: 16.0),
                        ),
                        ElevatedButton(
                          child: !ref.watch(isDoingWorkoutProvider)
                              ? _trainings_registered.length > 0
                                  ? Icon(Icons.play_arrow, color: Colors.green)
                                  : Icon(Icons.play_arrow, color: Colors.grey)
                              : Icon(Icons.stop, color: Colors.red),
                          style: ElevatedButton.styleFrom(
                            // side: BorderSide(color: Colors.green),
                            backgroundColor: Colors.grey[900], // background
                          ),
                          onPressed: _trainings_registered.length == 0
                              ? null
                              : () {
                                  if (!ref
                                      .read(isDoingWorkoutProvider.notifier)
                                      .state) {
                                    Widget callbackButton = TextButton(
                                      child: Text('開始'),
                                      onPressed: () {
                                        ref
                                            .read(
                                                isDoingWorkoutProvider.notifier)
                                            .state = true;
                                        ref
                                            .read(execPlanIdProvider.notifier)
                                            .state = int.parse(training_plan_id);
                                        // モーダルを閉じる
                                        Navigator.of(context).pop();
                                      },
                                    );
                                    ConfirmDialogTemplate(
                                        context,
                                        callbackButton,
                                        'ワークアウト',
                                        'このトレーニングプランを開始します。よろしいですか？');
                                  } else {
                                    // ワークアウト実施中の場合
                                    // ワークアウト終了の機能を表示する
                                    Widget callbackButton = TextButton(
                                      child: Text("終了"),
                                      onPressed: () {
                                        ref
                                            .read(
                                                isDoingWorkoutProvider.notifier)
                                            .state = false;
                                        // モーダルを閉じる
                                        Navigator.of(context).pop();
                                      },
                                    );
                                    ConfirmDialogTemplate(
                                        context,
                                        callbackButton,
                                        "終了",
                                        "実施中のワークアウトを終了します。よろしいですか？");
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    child: Text(
                      training_plan_description,
                      style: TextStyle()
                          .copyWith(color: Colors.white70, fontSize: 12.0),
                    ),
                  ),
                  // トレーニングプランに設定されているトレーニング一覧
                  const SizedBox(height: 8),
                  Flexible(
                    // height: 150,
                    child: _trainings_registered.length == 0
                        ? Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [Text('トレーニングが未登録です。')]))
                        : ListView.builder(
                            itemCount: _trainings_registered.length,
                            itemBuilder: (BuildContext context, int index) {
                              var user_training_id =
                                  List.from(_trainings_registered.keys)[index];
                              return buildTrainingListTile(user_training_id,
                                  _trainings_registered[user_training_id]);
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
                      child: Text('追加', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // background
                      ),
                      onPressed: () {
                        selectTrainingModal(
                            context, uid, training_plan_id, training_menu);
                      },
                    ),
                  ),
                  // const SizedBox(height: 8),
                  // Container(
                  //   padding: EdgeInsets.only(left: 64, right: 64),
                  //   // 横幅いっぱいに広げる
                  //   width: double.infinity,
                  //   // リスト追加ボタン
                  //   child: ElevatedButton(
                  //     child: Text('ワークアウト開始',
                  //         style: TextStyle(color: Colors.white)),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.green, // background
                  //     ),
                  //     onPressed: () {
                  //       print('ワークアウト開始');
                  //     },
                  //   ),
                  // ),
                  // トレーニングプラン削除ボタン
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.only(left: 64, right: 64),
                    // 横幅いっぱいに広げる
                    width: double.infinity,
                    // リスト追加ボタン
                    child: ElevatedButton(
                      child:
                          Text('プラン削除', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // background
                      ),
                      onPressed: () {
                        _deleteTrainingPlanDialog(
                            training_plan_id, training_plan_name);
                      },
                    ),
                  ),
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
  Widget buildTrainingListTile(String training_id, Map training) => Card(
        child: Slidable(
            endActionPane: ActionPane(motion: const BehindMotion(), children: [
              SlidableAction(
                  backgroundColor: Colors.red,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  icon: Icons.delete,
                  label: '削除',
                  onPressed: (context) {
                    print(training_id);
                    _deleteTrainingDialog(
                      training_id,
                      training['training_name'],
                    );
                  })
            ]),
            child: Column(children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                    foregroundImage: AssetImage("assets/images/chest.png")),
                title: Text(training['training_name']),
                trailing: (training['sets'] != null &&
                        training['reps'] != null &&
                        training['kgs'] != null)
                    ? Icon(Icons.check, color: Colors.green)
                    : Icon(Icons.settings, color: Colors.white70),
                onTap: () {
                  // トレーニングのコンテンツのモーダルを表示する
                  var is_setting = true;
                  showTrainingContentModal(context, training, is_setting);
                },
              )
            ])),
      );

  // ********************
  //
  // トレーニングメニューのモーダルを作成する
  //
  // ********************
  void selectTrainingModal(context, uid, plan_id, trainings) {
    // Map<String, dynamic> trainings = {
    //   '腕': {
    //     '1': {
    //       'training_name': '腕トレ１',
    //       'description': '',
    //       'purpose_name': '',
    //       'purpose_comment': '',
    //       'sub_part_name': '',
    //       'type_name': '',
    //       'type_comment': '',
    //       'event_name': '',
    //       'event_comment': ''
    //     },
    // };

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 800,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  width: double.infinity,
                  child: Text(
                    'トレーニングを選択',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)
                        .copyWith(color: Colors.white70, fontSize: 18.0),
                  ),
                ),
                // // 検索ボックス
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //     vertical: 12,
                //     horizontal: 36,
                //   ),
                //   child: TextField(
                //     style: TextStyle(
                //       fontSize: 14,
                //       color: Colors.white,
                //     ),
                //     decoration: InputDecoration(
                //       // ← InputDecorationを渡す
                //       hintText: '検索ワードを入力してください',
                //     ),
                //   ),
                // ),
                SizedBox(
                    child: Column(
                  children: [
                    for (int i = 0; i < trainings.length; i++) ...{
                      ExpansionTile(
                        title: Container(
                          child: ListTile(
                            title: Text(
                              List.from(trainings.keys)[i],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        children: [
                          for (int i_c1 = 0;
                              i_c1 <
                                  trainings[List.from(trainings.keys)[i]]
                                      .length;
                              i_c1++) ...{
                            Slidable(
                              startActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10)),
                                        backgroundColor: Colors.green,
                                        icon: Icons.add,
                                        label: '追加',
                                        onPressed: (context) {
                                          // トレーニングIDを取得する
                                          var training_no = List.from(
                                              List.from(trainings.values)[i]
                                                  .keys)[i_c1];

                                          // プランにトレーニングメニューを追加する
                                          _addTrainingMenu(
                                              plan_id, training_no);
                                        })
                                  ]),
                              child: ListTile(
                                title: Text(List.from(
                                    List.from(trainings.values)[i]
                                        .values)[i_c1]['training_name']),
                                onTap: () {
                                  // トレーニングのコンテンツのモーダルを表示する
                                  var is_setting = false;
                                  showTrainingContentModal(
                                      context,
                                      List.from(List.from(trainings.values)[i]
                                          .values)[i_c1],
                                      is_setting);
                                },
                              ),
                            )
                          }
                        ],
                      )
                    }
                  ],
                )),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the sheet.
                  },
                  child: Text("閉じる",
                      style: TextStyle(
                          color: Colors.white)), // Add the button text.
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
