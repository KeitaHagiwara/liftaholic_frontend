import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:uuid/uuid.dart';

import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/common/dialogs.dart';
import 'package:liftaholic_frontend/src/common/messages.dart';
import 'package:liftaholic_frontend/src/common/default_value.dart';
import 'package:liftaholic_frontend/src/workout/execute/exec_workout.dart';
import 'package:liftaholic_frontend/src/workout/select_training_menu_modal.dart';

class ExecWorkoutMenuScreen extends ConsumerStatefulWidget {
  const ExecWorkoutMenuScreen({super.key});

  @override
  _ExecWorkoutMenuScreenState createState() => _ExecWorkoutMenuScreenState();
}

class _ExecWorkoutMenuScreenState extends ConsumerState<ExecWorkoutMenuScreen> {
  // イニシャライザ設定
  bool _loading = false;

  String _trainingPlanName = '';

  Map _execTrainingMenu = {};

  // ----------------------------
  // セットメニューを初期化する
  // ----------------------------
  void initializeSetMenu() {
    var trainingObj = ref.read(userTrainingDataProvider)[ref.read(execPlanIdProvider)];
    _trainingPlanName = trainingObj['training_plan_name'];
    _execTrainingMenu = trainingObj['training_menu'];
    // print(trainingObj);
    for (int i = 0; i < _execTrainingMenu.length; i++) {
      List set_list = [];
      var trainingMenuObj = _execTrainingMenu[List.from(_execTrainingMenu.keys)[i]];
      var setsInit = trainingMenuObj['sets'];
      var repsInit = trainingMenuObj['reps'];
      var kgsInit = trainingMenuObj['kgs'];
      if (setsInit != null) {
        for (int set = 0; set < setsInit.toInt(); set++) {
          set_list.add({
            'reps': repsInit == null ? repsDefault : repsInit,
            'kgs': kgsInit == null ? kgsDefault : kgsInit,
            "time": "00:00",
            'is_completed': false,
          });
        }
      }
      // トレーニングのセットリストを入れる
      _execTrainingMenu[List.from(_execTrainingMenu.keys)[i]]['sets_achieve'] = set_list;
      // 進捗度の数値を入れる
      _execTrainingMenu[List.from(_execTrainingMenu.keys)[i]]['progress'] = 0;
    }
  }

  // ----------------------------
  // ワークアウト終了時に実績を保存する
  // ----------------------------
  Future<Map> _completeWorkout() async {
    setState(() {
      // スピナー表示
      _loading = true;
    });

    // ワークアウトに登録する用のリクエストデータを作成する
    var achieveDataList = [];
    for (var key in _execTrainingMenu.keys) {
      var trainingName = _execTrainingMenu[key]['training_name'];
      var setsAchieve = _execTrainingMenu[key]['sets_achieve'];
      for (var i = 0; i < setsAchieve.length; i++) {
        // セットが完了していたら実績リストに追加
        if (setsAchieve[i]['is_completed']) {
          setsAchieve[i]['training_name'] = trainingName;
          achieveDataList.add(setsAchieve[i]);
        }
      }
    }

    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/workout/complete_workout");

    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({'user_id': FirebaseAuth.instance.currentUser?.uid, 'training_plan_id': ref.read(execPlanIdProvider), 'training_set_achieved': achieveDataList});

    // POSTリクエストを投げる
    try {
      http.Response response = await http.post(url, headers: headers, body: body).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse;
    } catch (e) {
      return {};
      // //リクエストに失敗した場合はエラーメッセージを表示
      // AlertDialogTemplate(context, ERR_MSG_TITLE, ERR_MSG_NETWORK);
    } finally {
      setState(() {
        // スピナー非表示
        _loading = false;
      });
    }
  }

  // ----------------------------
  // トレーニング進行中だった場合に出力するダイアログ
  // ----------------------------
  Future<bool> showFutureDialog(String trainingName) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context_modal) {
        return AlertDialog(
          title: Text('セット削除', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
          content: Text(trainingName + 'は進行中ですが、メニューから削除しますか？'),
          actions: [
            TextButton(
              child: Text("キャンセル"),
              onPressed: () {
                Navigator.of(context_modal).pop(false);
              },
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context_modal).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------
  // トレーニングメニューを更新する
  // ----------------------------
  updateUserTrainingMenu(Map trainingMenuMaster) {
    // ユーザートレーニングのMapを作成する -> {training_name: training_no}
    final Map userTrainingMap = {};
    for (var key in _execTrainingMenu.keys) {
      var trainingName = _execTrainingMenu[key]['training_name'];
      userTrainingMap[trainingName] = key;
    }

    for (var partKey in trainingMenuMaster.keys) {
      for (var trainingNo in trainingMenuMaster[partKey].keys) {
        var trainingName = trainingMenuMaster[partKey][trainingNo]['training_name'];
        var isSelected = trainingMenuMaster[partKey][trainingNo]['is_selected'];
        if (isSelected && !userTrainingMap.containsKey(trainingName)) {
          // isSelectedがtrueで、userTrainingMapに存在しなかった場合は_execTrainingMenuに追加する
          var uuid = Uuid().v4(); // IDを生成する
          var setsAchieve = [];
          for (var i = 0; i < setsDefault; i++) {
            setsAchieve.add({'reps': repsDefault, 'kgs': kgsDefault, 'time': '00:00', 'is_completed': false});
          }
          setState(() {
            _execTrainingMenu[uuid] = {
              'training_name': trainingName,
              'description': trainingMenuMaster[partKey][trainingNo]['description'],
              'part_name': trainingMenuMaster[partKey][trainingNo]['part_name'],
              'part_image_file': trainingMenuMaster[partKey][trainingNo]['part_image_file'],
              'type_name': trainingMenuMaster[partKey][trainingNo]['type_name'],
              'event_name': trainingMenuMaster[partKey][trainingNo]['event_name'],
              'sets': setsDefault,
              'reps': repsDefault,
              'kgs': kgsDefault,
              'interval': intervalDefault,
              'sets_achieve': setsAchieve,
              'progress': 0
            };
          });
        } else if (!isSelected && userTrainingMap.containsKey(trainingName)) {
          // isSelectedがfalseで、userTrainingMapに存在した場合は_execTrainingMenuから削除する
          var userTrainingNo = userTrainingMap[trainingName];
          var progress = _execTrainingMenu[userTrainingNo]['progress'];
          // トレーニングが進行中だった場合はアラートダイアログを表示する
          if (progress > 0) {
            showFutureDialog(trainingName).then((value) {
              if (value) {
                setState(() {
                  _execTrainingMenu.remove(userTrainingNo);
                });
              }
            });
            // トレーニングが進行中ではない場合はそのまま削除する
          } else {
            setState(() {
              _execTrainingMenu.remove(userTrainingNo);
            });
          }
        }
      }
    }
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    // トレーニングメニュー用のデータを初期化する
    initializeSetMenu();
  }

  PopupMenuItem _buildPopupMenuItem(BuildContext context, String title, IconData iconData, Color color, FontWeight fontWeight, int callbackFunctionId, Map payload) {
    return PopupMenuItem(
        child: InkWell(
      onTap: () async {
        // ------ トレーニングプラン削除 ------
        if (callbackFunctionId == 1) {
          var training_no = payload['user_training_no'].toString();
          // トレーニングが進行中の場合はメッセージを出して確認する
          if (_execTrainingMenu[training_no]['progress'] > 0) {
            showDialog(
              context: context,
              builder: (BuildContext context_modal) {
                return AlertDialog(
                  title: Text('セット削除', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
                  content: Text('トレーニングは進行中ですが、メニューから削除しますか？'),
                  actions: [
                    TextButton(
                      child: Text("キャンセル"),
                      onPressed: () {
                        Navigator.of(context_modal).pop();
                      },
                    ),
                    TextButton(
                      child: Text("削除"),
                      onPressed: () {
                        setState(() {
                          _execTrainingMenu.remove(training_no);
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
              _execTrainingMenu.remove(training_no);
            });
          }
          Navigator.of(context).pop();
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
            : Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(''),
                    Text(
                      _trainingPlanName,
                      style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                    ),
                    IconButton(
                        icon: Icon(Icons.edit_note),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBottomSheet(
                                userTrainingMenu: ref.read(userTrainingDataProvider)[ref.read(execPlanIdProvider)]['training_menu'],
                                trainingMenuMaster: ref.read(trainingMenuMasterProvider),
                                valueChanged: updateUserTrainingMenu,
                              );
                            }
                          );
                        })
                  ]),

                  const SizedBox(height: 10),

                  Flexible(
                      child: _execTrainingMenu.isEmpty
                          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('トレーニングメニューが未登録です。')]))
                          : SizedBox(
                              child: ListView.builder(
                                  itemCount: _execTrainingMenu.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: index == 0 ? BorderSide(width: 0.5, color: Colors.grey) : BorderSide(color: Colors.transparent),
                                            bottom: BorderSide(width: 0.5, color: Colors.grey),
                                          ),
                                        ),
                                        child: ListTile(
                                            dense: true,
                                            title: Text(_execTrainingMenu[List.from(_execTrainingMenu.keys)[index]]['training_name']),
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
                                                        value: _execTrainingMenu[List.from(_execTrainingMenu.keys)[index]]['progress'].toDouble(),
                                                        width: 0.2,
                                                        color: _execTrainingMenu[List.from(_execTrainingMenu.keys)[index]]['progress'].toInt() == 100 ? Colors.green : Colors.green,
                                                        pointerOffset: 0.1,
                                                        cornerStyle: CornerStyle.bothCurve,
                                                        sizeUnit: GaugeSizeUnit.factor,
                                                      )
                                                    ],
                                                    annotations: <GaugeAnnotation>[
                                                      GaugeAnnotation(
                                                        widget: _execTrainingMenu[List.from(_execTrainingMenu.keys)[index]]['progress'].toInt() == 100
                                                            ? Text(
                                                                'clear', // Display the percentage value with 2 decimal places
                                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                                                              )
                                                            : Text(
                                                                _execTrainingMenu[List.from(_execTrainingMenu.keys)[index]]['progress'].toString() + '%', // Display the percentage value with 2 decimal places
                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                                                              ),
                                                        angle: 90,
                                                        positionFactor: 0.5,
                                                      ),
                                                    ],
                                                  )
                                                ])),
                                            trailing: PopupMenuButton(
                                              icon: Icon(Icons.more_horiz, color: Colors.white70),
                                              itemBuilder: (ctx) => [
                                                _buildPopupMenuItem(context, 'メニュー削除', Icons.delete, Colors.red, FontWeight.bold, 1, {'user_training_no': List.from(_execTrainingMenu.keys)[index]}),
                                              ],
                                            ),
                                            // trailing: IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz)),
                                            onTap: () {
                                              var tgt_training_id = List.from(_execTrainingMenu.keys)[index];
                                              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                                // 遷移先の画面としてリスト追加画面を指定
                                                return ExecWorkoutScreen(user_training_id: tgt_training_id);
                                              })).then((value) {
                                                setState(() {
                                                  _execTrainingMenu = ref.read(execTrainingMenuProvider);
                                                });
                                              });
                                            }));
                                  }))),
                  const SizedBox(height: 8),
                  // ワークアウト完了のボタンを配置する
                  Container(
                    padding: EdgeInsets.only(left: 64, right: 64),
                    width: double.infinity, // 横幅いっぱいに広げる
                    child: SlideAction(
                      text: 'スライドして終了',
                      textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                      animationDuration: const Duration(milliseconds: 500),
                      reversed: true,
                      sliderButtonIcon: Icon(
                        Icons.stop_rounded,
                        color: Colors.red,
                      ),
                      outerColor:  Colors.red,
                      height: 50,
                      sliderButtonIconSize: 60,
                      sliderButtonIconPadding: 8,
                      onSubmit: () {
                        // スライドした時に実行したい処理を記載
                        // 実績に登録する
                        _completeWorkout().then((value) {
                          if (value['statusCode'] == 200) {
                            ref.read(isDoingWorkoutProvider.notifier).state = false;
                            // ワークアウト終了時のアクションボタンを設定する
                            Widget actionButton(contextModal) {
                              return TextButton(
                                child: Text("OK"),
                                onPressed: () {
                                  // 確認モーダルを削除する
                                  Navigator.of(contextModal).pop();
                                },
                              );
                            }

                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext contextModal) {
                                  return lottieDialogTemplate(context, 'ワークアウト完了🎉', 'assets/lottie_json/finish_trainings.json', {'width': 300, 'height': 300}, [actionButton(contextModal)]);
                                });

                            // lottieDialogTemplate(context, 'ワークアウト完了🎉', value['statusMessage'], 'assets/lottie_json/finish_trainings.json');
                          } else {
                            //リクエストに失敗した場合はエラーメッセージを表示
                            AlertDialogTemplate(context, ERR_MSG_TITLE, value['statusMessage']);
                          }
                        });
                      },
                    ),
                  ),

                  // Container(
                  //     padding: EdgeInsets.only(left: 64, right: 64),
                  //     width: double.infinity, // 横幅いっぱいに広げる
                  //     child: ElevatedButton(
                  //         child: Text('ワークアウト完了', style: TextStyle(color: Colors.white)),
                  //         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  //         onPressed: () {
                  //           showDialog(
                  //             context: context,
                  //             builder: (BuildContext context_modal) {
                  //               return AlertDialog(
                  //                 title: Text('確認', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
                  //                 content: Text('実施中のワークアウトを終了します。\nよろしいですか？'),
                  //                 actions: [
                  //                   TextButton(
                  //                     child: Text("キャンセル"),
                  //                     onPressed: () {
                  //                       Navigator.of(context_modal).pop();
                  //                     },
                  //                   ),
                  //                   TextButton(
                  //                     child: Text("終了"),
                  //                     onPressed: () {
                  //                       // 実績に登録する
                  //                       _completeWorkout().then((value) {
                  //                         if (value['statusCode'] == 200) {
                  //                           ref.read(isDoingWorkoutProvider.notifier).state = false;
                  //                           // ワークアウト終了時のアクションボタンを設定する
                  //                           Widget actionButton(contextModal) {
                  //                             return TextButton(
                  //                               child: Text("OK"),
                  //                               onPressed: () {
                  //                                 // 確認モーダルを削除する
                  //                                 Navigator.of(contextModal).pop();
                  //                               },
                  //                             );
                  //                           }

                  //                           showDialog(
                  //                               context: context,
                  //                               barrierDismissible: false,
                  //                               builder: (BuildContext contextModal) {
                  //                                 return lottieDialogTemplate(context, 'ワークアウト完了🎉', 'assets/lottie_json/finish_trainings.json', {'width': 300, 'height': 300}, [actionButton(contextModal)]);
                  //                               });

                  //                           // lottieDialogTemplate(context, 'ワークアウト完了🎉', value['statusMessage'], 'assets/lottie_json/finish_trainings.json');
                  //                         } else {
                  //                           //リクエストに失敗した場合はエラーメッセージを表示
                  //                           AlertDialogTemplate(context, ERR_MSG_TITLE, value['statusMessage']);
                  //                         }
                  //                       });
                  //                       Navigator.of(context_modal).pop();
                  //                     },
                  //                   ),
                  //                 ],
                  //               );
                  //             },
                  //           );
                  //         })),
                ])));
  }
}
