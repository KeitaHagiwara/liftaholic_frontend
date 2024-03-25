import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../common/dialogs.dart';
import '../../common/error_messages.dart';
import '../../common/provider.dart';
import '../../common/functions.dart';
import '../../common/default_value.dart';
import '../training_contents_modal.dart';
import 'exec_workout.dart';

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
  // セットメニューを初期化する
  // ----------------------------
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
            'reps': reps_default == null ? repsDefault : reps_default,
            'kgs': kgs_default == null ? kgsDefault : kgs_default,
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
            : Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                                              color: _exec_training_menu[List.from(_exec_training_menu.keys)[index]]['progress'].toInt() == 100 ? Colors.green : Colors.green,
                                              pointerOffset: 0.1,
                                              cornerStyle: CornerStyle.bothCurve,
                                              sizeUnit: GaugeSizeUnit.factor,
                                            )
                                          ],
                                          annotations: <GaugeAnnotation>[
                                            GaugeAnnotation(
                                              widget: _exec_training_menu[List.from(_exec_training_menu.keys)[index]]['progress'].toInt() == 100
                                                  ? Text(
                                                      'clear', // Display the percentage value with 2 decimal places
                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                                                    )
                                                  : Text(
                                                      _exec_training_menu[List.from(_exec_training_menu.keys)[index]]['progress'].toString() + '%', // Display the percentage value with 2 decimal places
                                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
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

                  // メニュー追加ボタンを配置する
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
                        var uid = FirebaseAuth.instance.currentUser?.uid;
                        var training_plan_id = ref.read(execPlanIdProvider);
                        var training_menu_master = ref.read(trainingMenuMasterProvider);
                        // メニュー追加用のモーダルを起動する
                        selectTrainingModal(context, uid, training_plan_id, training_menu_master);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ワークアウト終了のボタンを配置する
                  Container(
                      padding: EdgeInsets.only(left: 64, right: 64),
                      width: double.infinity, // 横幅いっぱいに広げる
                      child: ElevatedButton(
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
                          })),
                ])));
  }
}
