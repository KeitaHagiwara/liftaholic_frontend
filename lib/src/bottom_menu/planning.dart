import 'dart:convert';
import 'dart:ffi';

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

import '../planning/create_training_plan.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({Key? key}) : super(key: key);

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  // ********************
  // イニシャライザ設定
  // ********************
  String? uid = '';

  bool _loading = false;

  List result = [];

  // List<String> trainingPlanTitle = ["plan1", "plan2", "plan3", ""];
  // List<String> trainingPlanDescription = [
  //   "Bench press",
  //   "Dead lift",
  //   "Squad",
  //   ""
  // ];
  // List<int> trainingPlanCount = [3, 4, 5, 0];

  // List _trainingPlanList = [
  //   {
  //     "plan_title": "Plan1",
  //     "plan_description": "Bench Press",
  //     "plan_counts": 3
  //   },
  //   {"plan_title": "Plan2", "plan_description": "Dead lift", "plan_counts": 4},
  //   {"plan_title": "Plan3", "plan_description": "Squad", "plan_counts": 5},
  //   {"plan_title": "", "plan_description": "", "plan_counts": 0},
  // ];
  List _registeredPlanList = [];

  // Todoリストのデータ
  Map<String, String> createPlanDict = {};

  DateTime _focusedDay = DateTime.now(); // 現在日
  CalendarFormat _calendarFormat = CalendarFormat.month; // 月フォーマット
  DateTime? _selectedDay; // 選択している日付
  List<String> _selectedEvents = [];

  //Map形式で保持　keyが日付　値が文字列
  final calendarMap = {
    DateTime.utc(2024, 2, 20): ['firstEvent', 'secondEvent'],
    DateTime.utc(2024, 2, 5): ['thirdEvent', 'fourthEvent'],
  };

  final calendarEvents = {
    DateTime.utc(2024, 2, 20): ['firstEvent', 'secondEvent'],
    DateTime.utc(2024, 2, 5): ['thirdEvent', 'fourthEvent']
  };

  // ********************
  // サーバーアクセス処理
  // ********************
  // ユーザー情報を取得する
  Future<void> reload() async {
    final instance = FirebaseAuth.instance;
    final User? user = instance.currentUser;
    await user!.reload();
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
        "/api/training_plan/" +
        uid);

    try {
      //リクエストを投げる
      var response = await http.get(url).timeout(Duration(seconds: 10));
      //リクエスト結果をコンソール出力
      // debugPrint(response.body);

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (!mounted) return;
      setState(() {
        result = jsonResponse["training_plans"];
        for (int i = 0; i < result.length; i++) {
          _registeredPlanList.add(
            {
              'plan_title': result[i]['training_title'],
              'plan_description': result[i]['training_description'],
              'plan_counts': result[i]['training_counts'].toString(),
            },
          );
        }
        // 追加ボタンのカード用
        _registeredPlanList.add(
          {"plan_title": "", "plan_description": "", "plan_counts": 0},
        );

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
      'plan_title': newListText['training_title'],
      'plan_description': (newListText['training_description'] == null ||
              newListText['training_description'] == "")
          ? 'プランの説明はありません'
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
                                    onTap: () {
                                      print('test');
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
                          return calendarMap[date] ?? [];
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
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _selectedEvents = calendarEvents[selectedDay] ?? [];
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
      //                 : 'プランの説明はありません');
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
