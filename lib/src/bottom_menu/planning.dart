import 'dart:convert';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:liftaholic_frontend/src/common/dialogs.dart';
import 'package:liftaholic_frontend/src/common/error_messages.dart';
import 'package:liftaholic_frontend/src/planning/show_calendar_modal.dart';
import 'package:liftaholic_frontend/src/firebase/user_info.dart';
import 'package:liftaholic_frontend/src/mypage/line_chart_2.dart';

class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key});

  @override
  _PlanningScreenState createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  // ********************
  // イニシャライザ設定
  // ********************
  String? uid = ''; // ユーザーID
  String? username = ''; // 表示名

  bool _loading = false; // スピナーの状態

  // ユーザーのトレーニングデータのマスタ
  // Map _userTrainingData = {};

  DateTime _focusedDay = DateTime.now(); // 現在日
  CalendarFormat _calendarFormat = CalendarFormat.month; // 月フォーマット
  DateTime? _selectedDay; // 選択している日付
  List<String> _selectedEvents = [];

  //Map形式で保持　keyが日付　値が文字列
  final _calendarMap = {};
  final _calendarEvents = {};

  // final calendarMap = {
  //   DateTime.utc(2024, 2, 20): ['firstEvent', 'secondEvent'],
  //   DateTime.utc(2024, 2, 5): ['thirdEvent', 'fourthEvent'],
  // };

  // final calendarEvents = {
  //   DateTime.utc(2024, 2, 20): ['firstEvent', 'secondEvent'],
  //   DateTime.utc(2024, 2, 5): ['thirdEvent', 'fourthEvent']
  // };

  // ********************
  //
  // サーバーアクセス処理
  //
  // ********************
  // ----------------------------
  // ユーザー名を強制的に設定させる
  // ----------------------------
  Future<void> _updateUserNameDialog(BuildContext context) async {
    //処理が重い(?)からか、非同期処理にする
    return showDialog(
        context: context,
        barrierDismissible: false, // ボタンが押されるまでダイアログは閉じない
        builder: (context) {
          return AlertDialog(
            title: Text('ユーザー名を設定しましょう🎉', style: TextStyle(fontSize: 18.0)),
            content: TextField(
              autofocus: true,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                hintText: 'ここに入力',
                labelText: 'ユーザー名',
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              onChanged: (String value) {
                setState(() {
                  username = value;
                });
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  // FirebaseのdisplayNameに登録する処理
                  if (username != null && username != '') {
                    updateDisplayName(username!);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
  }

  // ----------------------------
  // ユーザーのトレーニング情報を取得する
  // ----------------------------
  Future<void> _getTrainingPlans(uid) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');

    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/training_plan/get_user_training_plans/" + uid);

    try {
      //リクエストを投げる
      var response = await http.get(url).timeout(Duration(seconds: 10));
      //リクエスト結果をコンソール出力
      // debugPrint(response.body);

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          // --------
          // トレーニングプランのデータを作成
          // --------
          // _userTrainingData = jsonResponse['training_plans'];
          // // トレーニングプラン追加用のカードを作成するために、要素を追加する
          // _userTrainingData['add_training_plan'] = {}; //{training_plan_name: null, training_plan_description: null, count: 0, training_menu: {}};

          // ref.read(userTrainingDataProvider.notifier).state = _userTrainingData;

          // --------
          // ユーザーカレンダーのデータを作成
          // --------
          List result_ce = jsonResponse['calendar_events'];
          for (int i = 0; i < result_ce.length; i++) {
            var key = DateTime.utc(result_ce[i]['ce_year'], result_ce[i]['ce_month'], result_ce[i]['ce_day']);
            final event_list = result_ce[i]['event_list'].cast<String>();
            _calendarMap[key] = event_list;
            _calendarEvents[key] = event_list;
          }
        });
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

  // 削除したトレーニングプランを画面更新を行う
  // void _deleteRegisteredPlan(training_plan_id) async {
  //   final deleted_plan_id = await Navigator.of(context).push(
  //     MaterialPageRoute(builder: (context) {
  //       // 遷移先の画面としてリスト追加画面を指定
  //       return EditTrainingPlanScreen(
  //           training_plan_id: training_plan_id.toString(),
  //           registered_plan_list: _registeredPlanList);
  //     }),
  //   );
  //   if (deleted_plan_id != null) {
  //     for (int idx = 0; idx < _registeredPlanList.length; idx++) {
  //       if (_registeredPlanList[idx]['plan_id'] == deleted_plan_id) {
  //         setState(() {
  //           _registeredPlanList.removeAt(idx);
  //         });
  //       }
  //     }
  //   }
  //   // トレーニングプラン編集画面から戻ってきた場合は画面をリロードする
  //   _getTrainingPlans(uid);
  // }

  // void _deleteRegisteredPlan(training_plan_id) async {
  //   final deleted_plan_id = await Navigator.of(context).push(
  //     MaterialPageRoute(builder: (context) {
  //       // 遷移先の画面としてリスト追加画面を指定
  //       return EditTrainingPlanScreen(training_plan_id: training_plan_id.toString(), user_training_data: _userTrainingData);
  //     }),
  //   );
  //   if (deleted_plan_id != null) {
  //     for (int idx = 0; idx < _registeredPlanList.length; idx++) {
  //       if (_registeredPlanList[idx]['plan_id'] == deleted_plan_id) {
  //         setState(() {
  //           _registeredPlanList.removeAt(idx);
  //         });
  //       }
  //     }
  //   }
  //   // トレーニングプラン編集画面から戻ってきた場合は画面をリロードする
  //   // _getTrainingPlans(uid);
  // }

  // ********************
  // 画面初期化処理
  // ********************
  @override
  void initState() {
    super.initState();

    reload();
    uid = FirebaseAuth.instance.currentUser?.uid;
    username = FirebaseAuth.instance.currentUser?.displayName;

    if (username == null) {
      Future.delayed(Duration.zero, () {
        _updateUserNameDialog(context);
      });
    }
    _getTrainingPlans(uid);
  }

  // ********************
  // 描画
  // ********************
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'トレーニングプラン',
      //     textAlign: TextAlign.center,
      //     style: TextStyle(fontWeight: FontWeight.bold)
      //         .copyWith(color: Colors.white70, fontSize: 18.0),
      //   ),
      // ),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
          : Center(
              // child: _userTrainingData.length == 0
              //     ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.public_off, size: 50)]))
              child: ListView(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  // --------------------
                  // アニメーションここから
                  // --------------------
                  // Lottie.network(
                  //   // 'https://lottie.host/84241c93-f84c-4133-9d2b-4eeff328313a/XPxdU0Zv81.json',
                  //   // 'https://lottie.host/c40cfa4e-ab6d-4c6e-aa13-2901a6bd5100/dG0o8nAXpc.json',
                  //   'https://lottie.host/808890fb-72b9-4685-a6c4-e53abb13faeb/A5Pzml6y3B.json',
                  //   width: 300,
                  //   errorBuilder: (context, error, stackTrace) {
                  //     return const Padding(
                  //       padding: EdgeInsets.all(30.0),
                  //       child: CircularProgressIndicator(),
                  //     );
                  //   },
                  // ),
                  // --------------------
                  // アニメーションここまで
                  // --------------------

                  // --------------------
                  // プランここから
                  // --------------------
                  // Container(
                  //     margin: EdgeInsets.only(left: 15),
                  //     alignment: Alignment.centerLeft, //任意のプロパティ
                  //     width: double.infinity,
                  //     child: Text(
                  //       'トレーニングプラン',
                  //       style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                  //     )),
                  // SizedBox(
                  //   height: 150,
                  //   child: ListView.builder(
                  //     scrollDirection: Axis.horizontal,
                  //     itemCount: _userTrainingData.length,
                  //     itemBuilder: (context, index) {
                  //       return Card(
                  //           child: List.from(_userTrainingData.keys)[index] == 'add_training_plan'
                  //               ? InkWell(
                  //                   onTap: () async {
                  //                     // リスト追加画面から渡される値を受け取る
                  //                     final _newPlan = await Navigator.of(context).push(
                  //                       MaterialPageRoute(builder: (context) {
                  //                         // 遷移先の画面としてリスト追加画面を指定
                  //                         return CreateTrainingPlanScreen();
                  //                       }),
                  //                     );
                  //                     if (_newPlan != null) {
                  //                       setState(() {
                  //                         // トレーニングプランに追加する
                  //                         _userTrainingData[_newPlan['plan_id']] = _newPlan['trainings'];
                  //                         // plan_idでソートする
                  //                         _userTrainingData = SplayTreeMap.from(_userTrainingData, (a, b) => a.compareTo(b));
                  //                       });
                  //                       // Providerにデータを保存する
                  //                       ref.read(userTrainingDataProvider.notifier).state = _userTrainingData;
                  //                     }
                  //                   },
                  //                   child: Container(width: 180, child: Icon(Icons.add_circle, color: Colors.blue)))
                  //               : InkWell(
                  //                   onTap: () async {
                  //                     var training_plan_id = List.from(_userTrainingData.keys)[index].toString();
                  //                     final delete_plan_id = await Navigator.of(context).push(
                  //                       MaterialPageRoute(builder: (context) {
                  //                         return EditTrainingPlanScreen(training_plan_id: training_plan_id, user_training_data: _userTrainingData[training_plan_id]);
                  //                       }),
                  //                     );
                  //                     if (delete_plan_id != null) {
                  //                       setState(() {
                  //                         _userTrainingData.remove(delete_plan_id.toString());
                  //                       });
                  //                       // Providerにデータを保存する
                  //                       ref.read(userTrainingDataProvider.notifier).state = _userTrainingData;
                  //                     }
                  //                   },
                  //                   child: Container(
                  //                     width: 180,
                  //                     child: Column(
                  //                       children: <Widget>[
                  //                         ListTile(
                  //                           title: Text(
                  //                             _userTrainingData[List.from(_userTrainingData.keys)[index]]['training_plan_name'].toString(),
                  //                             style: TextStyle(fontWeight: FontWeight.bold),
                  //                           ),
                  //                           subtitle: _userTrainingData[List.from(_userTrainingData.keys)[index]]['training_plan_description'].toString() == ''
                  //                               ? Text(planDescriptionNotFound + '\n' + _userTrainingData[List.from(_userTrainingData.keys)[index]]['count'].toString() + ' trainings')
                  //                               : Text(_userTrainingData[List.from(_userTrainingData.keys)[index]]['training_plan_description'].toString() + '\n' + _userTrainingData[List.from(_userTrainingData.keys)[index]]['count'].toString() + ' trainings'),
                  //                           trailing: Icon(Icons.arrow_forward_ios_rounded),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ));
                  //     },
                  //   ),
                  // ),
                  // --------------------
                  // プランここまで
                  // --------------------

                  // --------------------
                  // カレンダーここから
                  // --------------------
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(
                        'スケジュール',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 18),
                      ),
                      IconButton(icon: Icon(Icons.add_circle), onPressed: () async {})
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: TableCalendar(
                        locale: 'ja_JP',
                        firstDay: DateTime.utc(2023, 1, 1),
                        lastDay: DateTime.utc(2024, 12, 31),
                        focusedDay: _focusedDay,
                        eventLoader: (date) {
                          // イベントドット処理
                          return _calendarMap[date] ?? [];
                        },
                        calendarBuilders: CalendarBuilders(markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              right: 5,
                              bottom: 5,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red[300],
                                ),
                                width: 16.0,
                                height: 16.0,
                                child: Center(
                                  child: Text(
                                    '${events.length}',
                                    style: TextStyle().copyWith(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          ;
                        }),
                        calendarStyle: CalendarStyle(
                          // defaultTextStyle:TextStyle(color: Colors.blue),
                          // weekNumberTextStyle:TextStyle(color: Colors.red),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          // todayDecoration: BoxDecoration(
                          //   color: Colors.red[300],
                          //   shape: BoxShape.circle,
                          // ),
                          weekendTextStyle: TextStyle(color: Colors.orange),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarFormat: _calendarFormat, // デフォを月表示に設定
                        onFormatChanged: (format) {
                          // 「月」「週」変更
                          if (_calendarFormat != format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          }
                        },
                        // 選択日のアニメーション
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        // 日付が選択されたときの処理
                        onDaySelected: (selectedDay, focusedDay) {
                          // 選択された日付が2回タップされた場合にモーダルを表示する
                          if (_selectedDay == selectedDay) {
                            print(_selectedEvents);
                            showCalendarModal(context, uid, selectedDay, ['test1', 'test2']);
                          }

                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _selectedEvents = _calendarEvents[selectedDay] ?? [];
                          });
                        }),
                  ),
                  // タップした時表示するリスト
                  // Expanded(
                  //   child: _selectedEvents.length == 0
                  //       ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('予定はありません。')]))
                  //       : ListView.builder(
                  //           itemCount: _selectedEvents.length,
                  //           itemBuilder: (context, index) {
                  //             final event = _selectedEvents[index];
                  //             return Card(
                  //               child: ListTile(
                  //                 title: Text(event),
                  //                 onTap: () {
                  //                   print(event);
                  //                 },
                  //               ),
                  //             );
                  //           },
                  //         ),
                  // ),
                  // --------------------
                  // カレンダーここまで
                  // --------------------

                  // --------------------
                  // 予実の折れ線グラフここから
                  // --------------------
                  Container(
                      margin: EdgeInsets.only(left: 15.0, top: 20.0),
                      alignment: Alignment.centerLeft, //任意のプロパティ
                      width: double.infinity,
                      child: Text(
                        '予定と実績',
                        style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                      )),
                  SizedBox(child: LineChartSample1()),
                  // --------------------
                  // 予実の折れ線グラフここまで
                  // --------------------

                ])),
    );
  }
}
