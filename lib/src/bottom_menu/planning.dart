import 'dart:convert';

// import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../planning/create_training_plan.dart';
import '../planning/edit_training_plan.dart';
import '../planning/show_calendar_modal.dart';
import '../firebase/user_info.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({Key? key}) : super(key: key);

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  // ********************
  // イニシャライザ設定
  // ********************
  static const plan_not_registered = 'プランの説明はありません';

  String? uid = ''; // ユーザーID
  String? username = ''; // 表示名

  bool _loading = false; // スピナーの状態

  List _registeredPlanList = []; // 登録済みのトレーニングプランのデータを格納するリスト

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
  // サーバーアクセス処理
  // ********************
  // ユーザー名を強制的に設定させる
  Future<void> UpdateUserNameDialog(BuildContext context) async {
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

  Future<void> getTrainingPlans(uid) async {
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
        "/api/training_plan/get_user_training_plans/" +
        uid);

    try {
      //リクエストを投げる
      var response = await http.get(url).timeout(Duration(seconds: 10));
      //リクエスト結果をコンソール出力
      // debugPrint(response.body);

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (!mounted) return;
      setState(() {
        // --------
        // トレーニングプランのデータを作成
        // --------
        List result_tp = jsonResponse['training_plans'];
        for (int i = 0; i < result_tp.length; i++) {
          _registeredPlanList.add(
            {
              'plan_id': result_tp[i]['training_plan_id'],
              'plan_title': result_tp[i]['training_title'],
              'plan_description': result_tp[i]['training_description'] == ''
                  ? plan_not_registered
                  : result_tp[i]['training_description'],
              'plan_counts': result_tp[i]['training_counts'].toString(),
            },
          );
        }
        // 追加ボタンのカード用
        _registeredPlanList.add(
          {"plan_title": "", "plan_description": "", "plan_counts": 0},
        );

        // --------
        // ユーザーカレンダーのデータを作成
        // --------
        List result_ce = jsonResponse['calendar_events'];
        for (int i = 0; i < result_ce.length; i++) {
          var key = DateTime.utc(result_ce[i]['ce_year'],
              result_ce[i]['ce_month'], result_ce[i]['ce_day']);
          final event_list = result_ce[i]['event_list'].cast<String>();
          _calendarMap[key] = event_list;
          _calendarEvents[key] = event_list;
        }

        // スピナー非表示
        _loading = false;
      });
    } catch (e) {
      //リクエストに失敗した場合は"error"と表示
      print(e);
      debugPrint('error');
    }
  }

  void createNewPlan(newListText) {
    // リスト追加
    final _newPlan = {
      'plan_id': newListText['plan_id'],
      'plan_title': newListText['training_title'],
      'plan_description': (newListText['training_description'] == null ||
              newListText['training_description'] == "")
          ? plan_not_registered
          : newListText['training_description'],
      'plan_counts': newListText['training_count']
    };
    _registeredPlanList.insert(_registeredPlanList.length - 1, _newPlan);
  }

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
        UpdateUserNameDialog(context);
      });
    }
    getTrainingPlans(uid);
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
          ? const Center(
              child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
          : Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  Container(
                      margin: EdgeInsets.only(left: 15),
                      alignment: Alignment.centerLeft, //任意のプロパティ
                      width: double.infinity,
                      child: Text(
                        'トレーニングプラン',
                        style: TextStyle(fontWeight: FontWeight.bold)
                            .copyWith(color: Colors.white70, fontSize: 18.0),
                      )),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Card(
                            child: index == _registeredPlanList.length - 1
                                ? InkWell(
                                    onTap: () async {
                                      // "push"で新規画面に遷移
                                      // リスト追加画面から渡される値を受け取る
                                      final newListText =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          // 遷移先の画面としてリスト追加画面を指定
                                          return CreateTrainingPlanScreen();
                                        }),
                                      );
                                      if (newListText != null) {
                                        // キャンセルした場合は newListText が null となるので注意
                                        setState(() {
                                          createNewPlan(newListText);
                                        });
                                      }
                                    },
                                    child: Container(
                                        width: 180,
                                        child: Icon(Icons.add_circle,
                                            color: Colors.blue)))
                                : InkWell(
                                    onTap: () async {
                                      // "push"で新規画面に遷移
                                      // リスト追加画面から渡される値を受け取る
                                      print(_registeredPlanList[index]
                                          ['plan_id']);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditTrainingPlanScreen(
                                                    training_plan_id:
                                                        _registeredPlanList[
                                                            index]['plan_id'].toString())),
                                      );
                                    },
                                    child: Container(
                                      width: 180,
                                      child: Column(
                                        children: <Widget>[
                                          ListTile(
                                            // leading: CircleAvatar(
                                            //   child: Text((index + 1).toString()),
                                            //   backgroundColor: Colors.blue,
                                            // ),
                                            // leading: CircleAvatar(foregroundImage: AssetImage("assets/test_user.jpeg")),
                                            title: Text(
                                                _registeredPlanList[index]
                                                        ['plan_title']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            subtitle: Text(
                                                _registeredPlanList[index]
                                                            ['plan_description']
                                                        .toString() +
                                                    '\n' +
                                                    _registeredPlanList[index]
                                                            ['plan_counts']
                                                        .toString() +
                                                    ' trainings'),
                                            trailing: Icon(Icons
                                                .arrow_forward_ios_rounded),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ));
                      },
                      itemCount: _registeredPlanList.length,
                    ),
                  ),
                  // --------------------
                  // プランここまで
                  // --------------------

                  // --------------------
                  // カレンダーここから
                  // --------------------
                  Container(
                      margin: EdgeInsets.only(left: 15.0, top: 20.0),
                      alignment: Alignment.centerLeft, //任意のプロパティ
                      width: double.infinity,
                      child: Text(
                        'スケジュール',
                        style: TextStyle(fontWeight: FontWeight.bold)
                            .copyWith(color: Colors.white70, fontSize: 18.0),
                      )),
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
                        calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
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
                            showCalendarModal(
                                context, uid, selectedDay, ['test1', 'test2']);
                          }

                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _selectedEvents =
                                _calendarEvents[selectedDay] ?? [];
                          });
                        }),
                  ),
                  // タップした時表示するリスト
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = _selectedEvents[index];
                        return Card(
                          child: ListTile(
                            title: Text(event),
                            onTap: () {
                              print(event);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // --------------------
                  // カレンダーここまで
                  // --------------------
                ])),
      // floatingActionButton: FloatingActionButton(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(100), //角の丸み
      //   ),
      //   onPressed: () async {
      //     // "push"で新規画面に遷移
      //     // リスト追加画面から渡される値を受け取る
      //     final newListText = await Navigator.of(context).push(
      //       MaterialPageRoute(builder: (context) {
      //         // 遷移先の画面としてリスト追加画面を指定
      //         return CreateTrainingPlanScreen();
      //       }),
      //     );
      //     if (newListText != null) {
      //       // キャンセルした場合は newListText が null となるので注意
      //       setState(() {
      //         // リスト追加
      //         trainingPlanTitle.add(newListText['training_title']);
      //         trainingPlanDescription.add(
      //             newListText['training_description'] != null
      //                 ? newListText['training_description']
      //                 : plan_not_registered);
      //         trainingPlanCount.add(int.parse(newListText['training_count']));
      //       });
      //     }
      //   },
      //   child: Icon(Icons.add),
      //   backgroundColor: Colors.blue,
      // ),
    );
  }
}
