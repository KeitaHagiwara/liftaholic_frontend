import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';
import '../common/provider.dart';
import '../planning/training_contents_modal.dart';
import './exec_workout.dart';

class ExecWorkoutMenuScreen extends ConsumerStatefulWidget {
  const ExecWorkoutMenuScreen({Key? key}) : super(key: key);

  @override
  _ExecWorkoutMenuScreenState createState() => _ExecWorkoutMenuScreenState();
}

class _ExecWorkoutMenuScreenState extends ConsumerState<ExecWorkoutMenuScreen> {
  // イニシャライザ設定
  bool _loading = false;

  // 実施中のトレーニングプラン
  int training_plan_id = 1;

  String _training_plan_name = '';
  String _training_plan_description = '';
  Map _trainings_registered = {};

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
          _training_plan_name =
              jsonResponse['training_plan']['training_plan_name'];
          _training_plan_description =
              jsonResponse['training_plan']['training_plan_description'];

          // トレーニングメニューのデータを作成
          _trainings_registered = jsonResponse['user_training_menu'];
          // 実行中か否かのフラグを入れる
          for (int i = 0; i < _trainings_registered.length; i++) {
            var _user_training_id = List.from(_trainings_registered.keys)[i];
            _trainings_registered[_user_training_id]['is_doing'] = false;
          }
          print(_trainings_registered);
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

  // トレーニングメニューを開始する
  void _startWorkout(user_training_id) {
    var is_doing = _trainings_registered[user_training_id]['is_doing'];
    var training_name =
        _trainings_registered[user_training_id]['training_name'];

    // 既に実行中になっている場合
    if (is_doing) {
      Widget callbackButton = TextButton(
        child: Text("終了"),
        onPressed: () {
          _trainings_registered[user_training_id]['is_doing'] = false;
          setState(() {
            _trainings_registered;
          });
          // Providerに保存する
          ref.read(execMenuIdProvider.notifier).state = 0;
          // モーダルを閉じる
          Navigator.of(context).pop();
        },
      );
      ConfirmDialogTemplate(
          context, callbackButton, "終了", training_name + "を終了します。よろしいですか？");
    } else {
      if (ref.read(execMenuIdProvider) == 0) {
        Widget callbackButton = TextButton(
          child: Text("開始"),
          onPressed: () {
            _trainings_registered[user_training_id]['is_doing'] = true;
            setState(() {
              _trainings_registered;
            });
            // Providerに保存する
            ref.read(execMenuIdProvider.notifier).state =
                int.parse(user_training_id);
            // モーダルを閉じる
            Navigator.of(context).pop();
            // ワークアウトメイン画面に遷移する
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  // 遷移先の画面としてリスト追加画面を指定
                  return ExecWorkoutScreen(user_training_id: user_training_id);
                }
              )
            );
          },
        );
        ConfirmDialogTemplate(
            context, callbackButton, "開始", training_name + "を開始します。よろしいですか？");
      } else {
        Widget callbackButton = TextButton(
          child: Text("中断"),
          onPressed: () {
            _trainings_registered[ref.read(execMenuIdProvider).toString()]['is_doing'] = false;
            _trainings_registered[user_training_id]['is_doing'] = true;
            setState(() {
              _trainings_registered;
            });
            // Providerに保存する
            ref.read(execMenuIdProvider.notifier).state =
                int.parse(user_training_id);
            // モーダルを閉じる
            Navigator.of(context).pop();
          },
        );
        ConfirmDialogTemplate(
            context, callbackButton, "中断", _trainings_registered[ref.read(execMenuIdProvider).toString()]['training_name'] + 'を中断して' + training_name + "を開始します。よろしいですか？");
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _getRegisteredTrainings(ref.read(execPlanIdProvider.notifier).state);
    // _getRegisteredTrainings(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _loading
            ? const Center(
                child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
            : Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text(
                      _training_plan_name,
                      style: TextStyle(fontWeight: FontWeight.bold)
                          .copyWith(color: Colors.white70, fontSize: 18.0),
                    ),
                    const SizedBox(height: 20),
                    Flexible(
                        child: ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    Divider(color: Colors.grey),
                            itemCount: _trainings_registered.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(children: <Widget>[
                                ListTile(
                                    dense: true,
                                    title: Text(_trainings_registered[List.from(
                                            _trainings_registered.keys)[index]]
                                        ['training_name']),
                                    trailing: ElevatedButton(
                                      child: !_trainings_registered[List.from(
                                              _trainings_registered
                                                  .keys)[index]]['is_doing']
                                          ? Icon(Icons.play_arrow,
                                              color: Colors.green)
                                          : Icon(Icons.pause,
                                              color: Colors.yellow),
                                      onPressed: () {
                                        var tgt_training_id = List.from(
                                            _trainings_registered.keys)[index];
                                        _startWorkout(tgt_training_id);
                                      },
                                    ),
                                    onTap: () {
                                      var tgt_training_id = List.from(
                                            _trainings_registered.keys)[index];
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            // 遷移先の画面としてリスト追加画面を指定
                                            return ExecWorkoutScreen(user_training_id: tgt_training_id);
                                          }
                                        )
                                      );
                                    })
                              ]);
                            })),
                    // ワークアウト終了のボタンを配置する
                    ElevatedButton(
                        child: Text('ワークアウト終了',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          Widget callbackButton = TextButton(
                            child: Text("終了"),
                            onPressed: () {
                              ref.read(isDoingWorkoutProvider.notifier).state =
                                  false;
                              // モーダルを閉じる
                              Navigator.of(context).pop();
                            },
                          );
                          ConfirmDialogTemplate(context, callbackButton, "終了",
                              "実施中のワークアウトを終了します。よろしいですか？");
                        })
                  ])));
  }
}
