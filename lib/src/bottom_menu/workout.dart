import 'dart:convert';
import 'dart:collection';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';
import '../common/provider.dart';
import '../common/default_value.dart';
import '../workout/execute/exec_workout_menu.dart';
import '../workout/training_contents_modal.dart';
import '../workout/planning/create_training_plan.dart';
import '../workout/planning/edit_training_plan.dart';
import '../workout/planning/edit_training_set.dart';

class Choice {
  const Choice({this.title, this.icon});
  final String? title;
  final IconData? icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Settings', icon: Icons.settings),
  const Choice(title: 'My Location', icon: Icons.my_location),
];

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  // イニシャライザ設定
  bool _loading = false;

  bool isPressed = false;

  String _selectedPlanId = '';

  // ----------------------------
  // ユーザーのトレーニング情報を取得する
  // ----------------------------
  Future<void> _getUserTrainingData(uid) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');

    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/workout/get_user_training_data/" + uid);

    try {
      //リクエストを投げる
      var response = await http.get(url).timeout(Duration(seconds: 10));
      //リクエスト結果をコンソール出力
      // debugPrint(response.body);

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;
      if (jsonResponse['statusCode'] == 200) {
        ref.read(userTrainingDataProvider.notifier).state = jsonResponse['training_plans'];
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
  // 全トレーニングメニューを取得する
  // ----------------------------
  Future<void> _getAllTrainingMenuMaster() async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');

    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/workout/get_all_training_menu_master");

    try {
      var response = await http.get(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (!mounted) return;
      // トレーニングメニューの取得に成功した場合
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          // トレーニングメニューのデータを作成
          ref.read(trainingMenuMasterProvider.notifier).state = jsonResponse['training_menu'];
        });
      } else {
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
  // トレーニングプランにメニューを追加する
  // ----------------------------
  Future<void> _addTrainingMenu(training_plan_id, training_no) async {
    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/training_plan/add_training_menu");

    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({'user_id': FirebaseAuth.instance.currentUser?.uid, 'training_plan_id': training_plan_id, 'training_no': training_no});

    // POSTリクエストを投げる
    try {
      http.Response response = await http.post(url, headers: headers, body: body).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print(jsonResponse);
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          // Providerの値を更新する
          ref.read(userTrainingDataProvider.notifier).state[training_plan_id]['count'] += 1;
          ref.read(userTrainingDataProvider.notifier).state[training_plan_id]['training_menu'][jsonResponse['add_user_training_id'][0].toString()] = jsonResponse['add_data'];
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
  Future<String?> _deleteUserTrainingPlan(training_plan_id) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');

    var uid = FirebaseAuth.instance.currentUser?.uid;
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/workout/delete_training_plan/" + uid.toString() + '/' + training_plan_id.toString());

    // POSTリクエストを投げる
    try {
      http.Response response = await http.delete(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      // 削除が成功したらプランニング画面に遷移する
      if (jsonResponse['statusCode'] == 200) {
        return jsonResponse['deleted_id'].toString();
      } else {
        //リクエストに失敗した場合はエラーメッセージを表示
        AlertDialogTemplate(context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
        return null;
      }
    } catch (e) {
      //リクエストに失敗した場合はエラーメッセージを表示
      AlertDialogTemplate(context, ERR_MSG_TITLE, ERR_MSG_NETWORK);
      return null;
    } finally {
      // スピナー非表示
      setState(() {
        _loading = false;
      });
    }
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
                _deleteUserTrainingPlan(training_plan_id).then((deletePlanId) => {
                      if (deletePlanId != null) {ref.read(userTrainingDataProvider.notifier).state.remove(deletePlanId)}
                    });
                // 確認モーダルを削除する
                Navigator.of(context_modal).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------
  // トレーニングプランからメニューを削除する
  // ----------------------------
  Future<void> _deleteFromUserTrainingMenu(training_plan_id, training_menu_id) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    var uid = FirebaseAuth.instance.currentUser?.uid;
    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/workout/delete_user_training_menu/" + uid.toString() + '/' + training_menu_id.toString());

    // POSTリクエストを投げる
    try {
      http.Response response = await http.delete(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      // 削除が成功したら画面をリロード
      if (jsonResponse['statusCode'] == 200) {
        // Providerの値を更新する
        ref.read(userTrainingDataProvider.notifier).state[training_plan_id]['count'] -= 1;
        ref.read(userTrainingDataProvider.notifier).state[training_plan_id]['training_menu'].remove(training_menu_id);
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

  // トレーニングプランの選択により、メニューのリストにトレーニングメニューを表示する
  void _selectTrainingMenu(index) {
    setState(() {
      // 選択されているプランID
      _selectedPlanId = List.from(ref.read(userTrainingDataProvider).keys)[index];
    });
    // Providerに値を格納する
    ref.read(execPlanIdProvider.notifier).state = _selectedPlanId;
    ref.read(execTrainingMenuProvider.notifier).state = ref.read(userTrainingDataProvider)[_selectedPlanId]['training_menu'];
  }

  @override
  void initState() {
    super.initState();

    // ユーザーのトレーニングデータを取得する
    _getUserTrainingData(FirebaseAuth.instance.currentUser?.uid);
    // トレーニングメニューのマスタを取得する
    _getAllTrainingMenuMaster();
  }

  // ----------------------------
  // ポップアップメニューのカスタマイズ
  // ----------------------------
  PopupMenuItem _buildPopupMenuItem(BuildContext context, String title, IconData iconData, Color color, FontWeight fontWeight, int callbackFunctionId, Map payload) {
    return PopupMenuItem(
        child: InkWell(
      onTap: () async {
        // ------ プラン編集 ------
        if (callbackFunctionId == 1) {
          var training_plan_id = payload['training_plan_id'].toString();
          // プラン編集画面に遷移する
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return EditTrainingPlanScreen(training_plan_id: training_plan_id);
            }),
          ).then((value) {
            setState(() {});
          });
          Navigator.of(context).pop();
          // ------ プラン削除 ------
        } else if (callbackFunctionId == 2) {
          var index = payload['index'];
          _deleteTrainingPlanDialog(List.from(ref.read(userTrainingDataProvider).keys)[index].toString(), ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['training_plan_name'].toString());
          // ポップアップメニューを閉じる
          Navigator.of(context).pop();
          // ------ メニュー削除 ------
        } else if (callbackFunctionId == 3) {
          // ポップアップメニューを閉じる (削除処理よりも先に閉じないとエラーになるため)
          Navigator.of(context).pop();
          var trainingPlanId = payload['training_plan_id'].toString();
          var trainingMenuId = payload['training_menu_id'].toString();
          _deleteFromUserTrainingMenu(trainingPlanId, trainingMenuId);
        }
      },
      child: Row(
        children: [
          Icon(iconData, color: color),
          Text(' '),
          Text(title, style: TextStyle(fontWeight: fontWeight, color: color)),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _loading
            ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
            : !ref.watch(isDoingWorkoutProvider) // ワークアウト実施中ではない場合
                ? Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ref.watch(userTrainingDataProvider).length == 0
                        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.public_off, size: 50)]))
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(
                                  'トレーニングプラン',
                                  style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                                ),
                                IconButton(
                                    icon: Icon(Icons.add_circle),
                                    onPressed: () async {
                                      // リスト追加画面から渡される値を受け取る
                                      final _newPlan = await Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          // 遷移先の画面としてリスト追加画面を指定
                                          return CreateTrainingPlanScreen();
                                        }),
                                      );
                                      if (_newPlan != null) {
                                        setState(() {
                                          // 新規のトレーニングを画面に追加する
                                          ref.read(userTrainingDataProvider.notifier).state[_newPlan['plan_id']] = _newPlan['trainings'];
                                          // トレーニングプランのリストをプランIDでソートする
                                          // ref.read(userTrainingDataProvider.notifier).state = SplayTreeMap.from(ref.read(userTrainingDataProvider), (a, b) => a.compareTo(b));
                                        });
                                      }
                                    })
                              ]),
                            ),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: ref.watch(userTrainingDataProvider).length,
                                itemBuilder: (context, index) {
                                  return Card(
                                      color: List.from(ref.read(userTrainingDataProvider).keys)[index] == _selectedPlanId ? Colors.blue : null,
                                      child: InkWell(
                                        onTap: () {
                                          _selectTrainingMenu(index);
                                        },
                                        child: Container(
                                          width: 180,
                                          child: Column(
                                            children: <Widget>[
                                              ListTile(
                                                title: Text(
                                                  ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['training_plan_name'].toString(),
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                subtitle: ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['training_plan_description'].toString() == ''
                                                    ? Text(
                                                        planDescriptionNotFound + '\n' + ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['count'].toString() + ' trainings',
                                                        style: TextStyle().copyWith(
                                                          color: List.from(ref.read(userTrainingDataProvider).keys)[index] == _selectedPlanId ? Colors.white : Colors.white70,
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    : Text(
                                                        ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['training_plan_description'].toString() +
                                                            '\n' +
                                                            ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['count'].toString() +
                                                            ' trainings',
                                                        style: TextStyle().copyWith(
                                                          color: List.from(ref.read(userTrainingDataProvider).keys)[index] == _selectedPlanId ? Colors.white : Colors.white70,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                trailing: PopupMenuButton(
                                                  icon: Icon(Icons.menu, size: 30, color: List.from(ref.read(userTrainingDataProvider).keys)[index] == _selectedPlanId ? Colors.white : Colors.white70),
                                                  itemBuilder: (ctx) => [
                                                    // _buildPopupMenuItem('ワークアウト開始', Icons.play_arrow_rounded, Colors.green, FontWeight.normal),
                                                    _buildPopupMenuItem(context, 'プラン編集', Icons.edit, Colors.white, FontWeight.normal, 1, {'training_plan_id': List.from(ref.read(userTrainingDataProvider).keys)[index]}),
                                                    _buildPopupMenuItem(context, 'プラン削除', Icons.delete, Colors.red, FontWeight.bold, 2, {'index': index}),
                                                  ],
                                                  // ポップアップメニューが開いた時に起動する
                                                  onOpened: () {
                                                    _selectTrainingMenu(index);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                              alignment: Alignment.centerLeft, //任意のプロパティ
                              width: double.infinity,
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(
                                  'メニュー',
                                  style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                                ),
                                IconButton(
                                    icon: Icon(Icons.add_circle),
                                    onPressed: ref.read(execPlanIdProvider) == ''
                                        ? null
                                        : () {
                                            selectTrainingModal(context, FirebaseAuth.instance.currentUser?.uid, ref.read(execPlanIdProvider), ref.read(trainingMenuMasterProvider));
                                          })
                              ]),
                            ),
                            Flexible(
                                child: ref.watch(execPlanIdProvider) == ''
                                    // トレーニングプランが選択されていない場合
                                    ? Center(
                                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                                        Text('トレーニングプランが未選択です。'),
                                      ]))
                                    // トレーニングプランが選択されている場合
                                    : ref.read(execTrainingMenuProvider).isEmpty
                                        // トレーニングプランにメニューが登録されていない場合
                                        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('トレーニングメニューが未登録です。')]))
                                        // トレーニングプランにメニューが登録されている場合
                                        : ListView.builder(
                                            itemCount: ref.read(execTrainingMenuProvider).length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return Card(
                                                  margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                                  child: Column(children: <Widget>[
                                                    ListTile(
                                                        dense: true,
                                                        leading: GestureDetector(
                                                          onTap: () {
                                                            // トレーニングアイコンのタップでトレーニング詳細を表示する
                                                            var training = ref.watch(execTrainingMenuProvider)[List.from(ref.read(execTrainingMenuProvider).keys)[index]];
                                                            showTrainingContentModal(context, training);
                                                          },
                                                          child: CircleAvatar(radius: 25, foregroundImage: NetworkImage(networkImageDomain + s3Folder + ref.read(execTrainingMenuProvider)[List.from(ref.read(execTrainingMenuProvider).keys)[index]]['part_image_file'])),
                                                        ),
                                                        title: Text(
                                                          ref.watch(execTrainingMenuProvider)[List.from(ref.read(execTrainingMenuProvider).keys)[index]]['training_name'],
                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                        ),
                                                        subtitle: Text(ref.watch(execTrainingMenuProvider)[List.from(ref.read(execTrainingMenuProvider).keys)[index]]['kgs'].toString() +
                                                            ' kg\n' +
                                                            ref.watch(execTrainingMenuProvider)[List.from(ref.read(execTrainingMenuProvider).keys)[index]]['reps'].toString() +
                                                            ' reps\n' +
                                                            ref.watch(execTrainingMenuProvider)[List.from(ref.read(execTrainingMenuProvider).keys)[index]]['sets'].toString() +
                                                            ' sets'),
                                                        trailing: PopupMenuButton(
                                                          icon: Icon(Icons.more_horiz),
                                                          itemBuilder: (ctx) => [
                                                            _buildPopupMenuItem(context, '削除', Icons.delete, Colors.red, FontWeight.bold, 3, {'training_plan_id': ref.read(execPlanIdProvider), 'training_menu_id': List.from(ref.read(execTrainingMenuProvider).keys)[index]}),
                                                          ],
                                                        ),
                                                        onTap: () {
                                                          var user_training_menu_id = List.from(ref.read(execTrainingMenuProvider).keys)[index];
                                                          Navigator.of(context).push(
                                                            MaterialPageRoute(builder: (context) {
                                                              return EditTrainingSetScreen(user_training_menu_id: user_training_menu_id);
                                                            }),
                                                          ).then((value) {
                                                            // 画面遷移が戻ってきたら、ページをリロードする
                                                            setState(() {});
                                                          });
                                                        })
                                                  ]));
                                            })),
                            Container(
                              padding: EdgeInsets.only(left: 64, right: 64),
                              width: double.infinity, // 横幅いっぱいに広げる
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: ref.watch(execPlanIdProvider) == ''
                                    ? null
                                    : () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext contextModal) {
                                            return AlertDialog(
                                              title: Text('ワークアウト', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
                                              content: Text('選択したトレーニングプランを開始します。よろしいですか？'),
                                              actions: [
                                                TextButton(
                                                  child: Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.of(contextModal).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text("開始"),
                                                  onPressed: () {
                                                    ref.read(isDoingWorkoutProvider.notifier).state = true;
                                                    Navigator.of(contextModal).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                child: Text('ワークアウト開始', style: TextStyle(color: Colors.white)),
                              ),
                            )
                          ]))
                : ExecWorkoutMenuScreen() // ワークアウト実施中の場合
        );
  }

  // ---------------------------
  // トレーニングメニューのモーダルを作成する
  // ---------------------------
  // ・params
  //   - uid: String
  //   - plan_id: String
  //   - training_menu_master: Map<String, dynamic>
  //     exp) '腕': {
  //            '1': {
  //              'training_name': '腕トレ１',
  //              'description': '',
  //              'purpose_name': '',
  //              'purpose_comment': '',
  //              'sub_part_name': '',
  //              'part_image_file': '',
  //              'type_name': '',
  //              'type_comment': '',
  //              'event_name': '',
  //              'event_comment': ''
  //            },
  //          };
  //
  // ・return
  //   - void
  //
  void selectTrainingModal(context, uid, plan_id, training_menu_master) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 800,
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
                        Navigator.of(context).pop(); // Close the sheet.
                      }),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  width: double.infinity,
                  child: Text(
                    'トレーニングを選択',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 18),
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
                    for (int i = 0; i < training_menu_master.length; i++) ...{
                      ExpansionTile(
                        title: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            // dense: true,
                            leading: CircleAvatar(foregroundImage: NetworkImage(networkImageDomain + s3Folder + training_menu_master[List.from(training_menu_master.keys)[i]]['0']['part_image_file'])),
                            title: Text(
                              List.from(training_menu_master.keys)[i],
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        children: [
                          for (int i_c1 = 0; i_c1 < training_menu_master[List.from(training_menu_master.keys)[i]].length; i_c1++) ...{
                            Slidable(
                              startActionPane: ActionPane(motion: const ScrollMotion(), children: [
                                SlidableAction(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                    backgroundColor: Colors.green,
                                    icon: Icons.add,
                                    label: '追加',
                                    onPressed: (context) {
                                      // トレーニングIDを取得する
                                      var training_no = List.from(List.from(training_menu_master.values)[i].keys)[i_c1];
                                      // プランにトレーニングメニューを追加する
                                      _addTrainingMenu(plan_id, training_no);
                                    })
                              ]),
                              child: ListTile(
                                dense: true,
                                leading: IconButton(
                                    // icon: ref.read(addTrainingMenuProvider).containsKey(List.from(List.from(training_menu_master.values)[i].keys)[i_c1].toString()) ? Icon(Icons.radio_button_checked, color: Colors.green) : Icon(Icons.radio_button_unchecked, color: Colors.grey),
                                    icon: Icon(Icons.radio_button_unchecked, color: Colors.grey),
                                    onPressed: () {
                                      var training_no = List.from(List.from(training_menu_master.values)[i].keys)[i_c1].toString();
                                      setState(() {
                                        // if (ref.read(addTrainingMenuProvider).containsKey(training_no)) {
                                        //   ref.read(addTrainingMenuProvider.notifier).state[training_no] = true;
                                        // } else {
                                        //   ref.read(addTrainingMenuProvider.notifier).state[training_no] = !ref.read(addTrainingMenuProvider)[training_no];
                                        // }
                                      });
                                    }),
                                title: Text(List.from(List.from(training_menu_master.values)[i].values)[i_c1]['training_name'], style: TextStyle(fontSize: 12)),
                                // trailing: IconButton(
                                //     icon: Icon(Icons.add_circle, color: Colors.blue),
                                //     onPressed: () {
                                //       print('pressed');
                                //     }),
                                onTap: () {
                                  // トレーニングのコンテンツのモーダルを表示する
                                  showTrainingContentModal(context, List.from(List.from(training_menu_master.values)[i].values)[i_c1]);
                                },
                              ),
                            )
                          }
                        ],
                      )
                    }
                  ],
                )),

                // ワークアウトメニューの更新ボタン
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  padding: EdgeInsets.only(left: 64, right: 64),
                  width: double.infinity, // 横幅いっぱいに広げる
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {},
                    child: Text('更新', style: TextStyle(color: Colors.white)),
                  ),
                )
              ]),
            ),
          ),
        );
      },
    );
  }
}
