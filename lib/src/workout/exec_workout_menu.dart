import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';
import '../common/provider.dart';
import '../planning/training_contents_modal.dart';
import './exec_workout.dart';

class ExecWorkoutMenuScreen extends ConsumerStatefulWidget {
  const ExecWorkoutMenuScreen({super.key});

  @override
  _ExecWorkoutMenuScreenState createState() => _ExecWorkoutMenuScreenState();
}

class _ExecWorkoutMenuScreenState extends ConsumerState<ExecWorkoutMenuScreen> {
  // イニシャライザ設定
  bool _loading = false;

  String _training_plan_name = '';
  String _training_plan_description = '';
  Map _exec_training_menu = {};

  // ----------------------------
  // トレーニングプランに登録済みのトレーニングを取得する
  // ----------------------------
  // Future<void> _getRegisteredTrainings(training_plan_id) async {
  //   setState(() {
  //     // スピナー非表示
  //     _loading = true;
  //   });

  //   await dotenv.load(fileName: '.env');
  //   //リクエスト先のurl
  //   Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/training_plan/get_registered_trainings/" + training_plan_id.toString());

  //   try {
  //     if (!mounted) return;
  //     var response = await http.get(url).timeout(Duration(seconds: 10));

  //     var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
  //     if (jsonResponse['statusCode'] == 200) {
  //       setState(() {
  //         print(jsonResponse);
  //         // トレーニングプランの詳細をWidgetに設定
  //         _training_plan_name = jsonResponse['training_plan']['training_plan_name'];
  //         _training_plan_description = jsonResponse['training_plan']['training_plan_description'];

  //         // トレーニングメニューのデータを作成
  //         _trainings_registered = jsonResponse['user_training_menu'];
  //         // 実行中か否かのフラグを入れる
  //         for (int i = 0; i < _trainings_registered.length; i++) {
  //           var _user_training_id = List.from(_trainings_registered.keys)[i];
  //           _trainings_registered[_user_training_id]['is_doing'] = false;
  //         }
  //         print(_trainings_registered);
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

  void initialize_set_menu() {
    var training_obj = ref.read(userTrainingDataProvider)[ref.read(execPlanIdProvider)];
    _training_plan_name = training_obj['training_plan_name'];
    _training_plan_description = training_obj['training_plan_description'];
    _exec_training_menu = training_obj['training_menu'];
    for (int i = 0; i < _exec_training_menu.length; i++) {
      List set_list = [];
      var training_menu_obj = _exec_training_menu[List.from(_exec_training_menu.keys)[i]];
      var sets_default = training_menu_obj['sets'];
      var reps_default = training_menu_obj['reps'];
      var kgs_default = training_menu_obj['kgs'];
      if (sets_default != null) {
        for (int set = 0; set < sets_default.toInt(); set++) {
          set_list.add({
            'reps': reps_default == null ? 1 : reps_default,
            'kgs': kgs_default == null ? 0.25 : kgs_default,
            "time": "00:00",
            'is_completed': false,
          });
        }
      }
      // トレーニングのセットリストを入れる
      _exec_training_menu[List.from(_exec_training_menu.keys)[i]]['sets_achieve'] = set_list;
      // 進捗度の数値を入れる
      _exec_training_menu[List.from(_exec_training_menu.keys)[i]]['progress'] = 0;
    }
  }

  @override
  void initState() {
    super.initState();

    // トレーニングメニュー用のデータを初期化する
    initialize_set_menu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _loading
            ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
            : Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  _training_plan_name,
                  style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                ),
                const SizedBox(height: 20),
                Flexible(
                    child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.grey),
                        itemCount: _exec_training_menu.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(children: <Widget>[
                            ListTile(
                                dense: true,
                                title: Text(_exec_training_menu[List.from(_exec_training_menu.keys)[index]]['training_name']),
                                leading: SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: SfRadialGauge(axes: <RadialAxis>[
                                      RadialAxis(
                                        minimum: 0,
                                        maximum: 100,
                                        showLabels: false,
                                        showTicks: false,
                                        startAngle: 270,
                                        endAngle: 270,
                                        axisLineStyle: AxisLineStyle(
                                          thickness: 1,
                                          color: Colors.white, //const Color.fromARGB(255, 0, 169, 181),
                                          thicknessUnit: GaugeSizeUnit.factor,
                                        ),
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            value: _exec_training_menu[List.from(_exec_training_menu.keys)[index]]['progress'].toDouble(),
                                            width: 0.2,
                                            color: _exec_training_menu[List.from(_exec_training_menu.keys)[index]]['progress'].toInt() == 100 ? Colors.red : Colors.green,
                                            pointerOffset: 0.1,
                                            cornerStyle: CornerStyle.bothCurve,
                                            sizeUnit: GaugeSizeUnit.factor,
                                          )
                                        ],
                                        annotations: <GaugeAnnotation>[
                                          GaugeAnnotation(
                                            widget: _exec_training_menu[List.from(_exec_training_menu.keys)[index]]['progress'].toInt() == 100
                                                ? Text(
                                                    '完', // Display the percentage value with 2 decimal places
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(color: Colors.red),
                                                  )
                                                : Text(
                                                    _exec_training_menu[List.from(_exec_training_menu.keys)[index]]['progress'].toString() + '%', // Display the percentage value with 2 decimal places
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(color: Colors.green),
                                                  ),
                                            angle: 90,
                                            positionFactor: 0.5,
                                          ),
                                        ],
                                      )
                                    ])),
                                onTap: () {
                                  var tgt_training_id = List.from(_exec_training_menu.keys)[index];
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                    // 遷移先の画面としてリスト追加画面を指定
                                    return ExecWorkoutScreen(user_training_id: tgt_training_id);
                                  })).then((value) {
                                    setState(() {
                                      _exec_training_menu = ref.read(execTrainingMenuProvider);
                                    });
                                  });
                                })
                          ]);
                        })),
                // ワークアウト終了のボタンを配置する
                ElevatedButton(
                    child: Text('ワークアウト終了', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context_modal) {
                          return AlertDialog(
                            title: Text('ワークアウト終了', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
                            content: Text('実施中のワークアウトを終了します。よろしいですか？'),
                            actions: [
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context_modal).pop();
                                },
                              ),
                              TextButton(
                                child: Text("終了"),
                                onPressed: () {
                                  ref.read(isDoingWorkoutProvider.notifier).state = false;
                                  Navigator.of(context_modal).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    })
              ])));
  }
}
