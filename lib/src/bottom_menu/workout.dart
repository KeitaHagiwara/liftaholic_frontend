import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';
import '../common/provider.dart';
import '../workout/exec_workout_menu.dart';
import '../planning/training_contents_modal.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  // イニシャライザ設定
  bool _loading = false;

  String _selectedPlanId = '';

  Map _user_training_menu = {};

  bool isPressed = false;

  // ----------------------------
  // トレーニングプランに登録済みのトレーニングを取得する
  // ----------------------------
  Future<void> _getRegisteredTrainings() async {
    setState(() {
      // スピナー非表示
      _loading = true;
    });

    // ユーザーIDを設定する
    var uid = FirebaseAuth.instance.currentUser?.uid;

    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/training_plan/get_registered_trainings/" + uid.toString());

    try {
      if (!mounted) return;
      var response = await http.get(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          // トレーニングメニューのデータを作成
          _user_training_menu = jsonResponse['user_training_menu'];
        });
        // Providerに値を保存する
        // ref.read(selectedPlanProvider.notifier).state = training_plan_id;
        ref.read(selectedTrainingMenuProvider.notifier).state = _user_training_menu;
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _loading
            ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
            : !ref.watch(isDoingWorkoutProvider) // ワークアウト実施中ではない場合
                ? Container(
                    child: ref.watch(userTrainingDataProvider).length == 0
                        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.public_off, size: 50)]))
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(
                                margin: EdgeInsets.only(left: 15),
                                alignment: Alignment.centerLeft, //任意のプロパティ
                                width: double.infinity,
                                child: Text(
                                  'トレーニングプラン',
                                  style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                                )),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: ref.watch(userTrainingDataProvider).length - 1,
                                itemBuilder: (context, index) {
                                  return Card(
                                      // color: ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]] == _selectedPlanId ? Colors.blue : null,
                                      color: List.from(ref.read(userTrainingDataProvider).keys)[index] == _selectedPlanId ? Colors.blue : null,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            // 選択されているプランID
                                            _selectedPlanId = List.from(ref.read(userTrainingDataProvider).keys)[index];
                                            // print(ref.read(userTrainingDataProvider)[_selectedPlanId]);

                                            // _getRegisteredTrainings(_selectedPlanId);

                                            // メニューに表示するトレーニングメニュー
                                            _user_training_menu = ref.read(userTrainingDataProvider)[_selectedPlanId]['training_menu'];
                                          });
                                          // Providerに値を格納する
                                          ref.read(execPlanIdProvider.notifier).state = _selectedPlanId;
                                          ref.read(execTrainingMenuProvider.notifier).state = ref.read(userTrainingDataProvider)[_selectedPlanId]['training_menu'];
                                        },
                                        child: Container(
                                          width: 180,
                                          child: Column(
                                            children: <Widget>[
                                              ListTile(
                                                // leading: CircleAvatar(foregroundImage: AssetImage("assets/test_user.jpeg")),
                                                title: Text(
                                                  ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['training_plan_name'].toString(),
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                subtitle: ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['training_plan_description'].toString() == ''
                                                    ? Text(
                                                        ref.read(planDescriptionNotFoundProvider) + '\n' + ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['count'].toString() + ' trainings',
                                                        style: TextStyle().copyWith(color: List.from(ref.read(userTrainingDataProvider).keys)[index] == _selectedPlanId ? Colors.white : Colors.white70),
                                                      )
                                                    : Text(
                                                        ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['training_plan_description'].toString() +
                                                            '\n' +
                                                            ref.watch(userTrainingDataProvider)[List.from(ref.read(userTrainingDataProvider).keys)[index]]['count'].toString() +
                                                            ' trainings',
                                                        style: TextStyle().copyWith(color: List.from(ref.read(userTrainingDataProvider).keys)[index] == _selectedPlanId ? Colors.white : Colors.white70),
                                                      ),
                                                trailing: List.from(ref.read(userTrainingDataProvider).keys)[index] == _selectedPlanId ? Icon(Icons.manage_search, color: Colors.white, size: 30) : Icon(Icons.menu),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                                },
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 15.0, top: 20.0),
                                alignment: Alignment.centerLeft, //任意のプロパティ
                                width: double.infinity,
                                child: Text(
                                  'メニュー',
                                  style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                                )),
                            const SizedBox(height: 8),
                            Flexible(
                                child: _user_training_menu.length == 0
                                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('トレーニングプランが未選択です。')]))
                                    : ListView.builder(
                                        itemCount: _user_training_menu.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Column(children: <Widget>[
                                            ListTile(
                                                dense: true,
                                                title: Text('・' + _user_training_menu[List.from(_user_training_menu.keys)[index]]['training_name']),
                                                onTap: () {
                                                  var training = _user_training_menu[List.from(_user_training_menu.keys)[index]];
                                                  showTrainingContentModal(context, training);
                                                })
                                          ]);
                                        })),
                            ElevatedButton(
                                child: Text('ワークアウト開始', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: ref.watch(execPlanIdProvider) == ''
                                    ? null
                                    : () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context_modal) {
                                            return AlertDialog(
                                              title: Text('ワークアウト', style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18)),
                                              content: Text('選択したトレーニングプランを開始します。よろしいですか？'),
                                              actions: [
                                                TextButton(
                                                  child: Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.of(context_modal).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text("開始"),
                                                  onPressed: () {
                                                    ref.read(isDoingWorkoutProvider.notifier).state = true;
                                                    Navigator.of(context_modal).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }),
                          ]))
                : ExecWorkoutMenuScreen() // ワークアウト実施中の場合
        );
  }
}
