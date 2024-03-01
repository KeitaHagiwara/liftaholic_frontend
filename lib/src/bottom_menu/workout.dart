import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';
import '../common/provider.dart';
import '../workout/exec_workout_menu.dart';
import '../planning/training_contents_modal.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  // イニシャライザ設定
  bool _loading = false;

  List _registeredPlanList = [];
  int _selectedPlan = 0;

  Map _trainings_registered = {};

  bool isPressed = false;
  IconData icon = Icons.play_arrow;
  MaterialColor primaryColor = Colors.blue;

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
          // トレーニングメニューのデータを作成
          _trainings_registered = jsonResponse['user_training_menu'];

          // Providerに値を保存する
          ref.read(selectedPlanProvider.notifier).state = training_plan_id;
          ref.read(selectedTrainingMenuProvider.notifier).state =
              _trainings_registered;
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

  @override
  void initState() {
    super.initState();

    // Providerの値をローカル変数に格納する
    _registeredPlanList = ref.read(registeredPlanProvider.notifier).state;
    _selectedPlan = ref.read(selectedPlanProvider.notifier).state;
    _trainings_registered =
        ref.read(selectedTrainingMenuProvider.notifier).state;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _loading
            ? const Center(
                child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
            : !ref.watch(isDoingWorkoutProvider) // ワークアウト実施中ではない場合
                ? Container(
                    child: _registeredPlanList.length == 0
                        ? Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Icon(Icons.public_off, size: 50)]))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Container(
                                    margin: EdgeInsets.only(left: 15),
                                    alignment: Alignment.centerLeft, //任意のプロパティ
                                    width: double.infinity,
                                    child: Text(
                                      'トレーニングプラン',
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold)
                                              .copyWith(
                                                  color: Colors.white70,
                                                  fontSize: 18.0),
                                    )),
                                SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _registeredPlanList.length - 1,
                                    itemBuilder: (context, index) {
                                      return Card(
                                          color: _registeredPlanList[index]
                                                      ['plan_id'] ==
                                                  _selectedPlan
                                              ? Colors.blue
                                              : null,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                var training_plan_id =
                                                    _registeredPlanList[index]
                                                        ['plan_id'];
                                                _selectedPlan =
                                                    training_plan_id;
                                                _getRegisteredTrainings(
                                                    training_plan_id);
                                              });
                                            },
                                            child: Container(
                                              width: 180,
                                              child: Column(
                                                children: <Widget>[
                                                  ListTile(
                                                    // leading: CircleAvatar(foregroundImage: AssetImage("assets/test_user.jpeg")),
                                                    title: Text(
                                                      _registeredPlanList[index]
                                                              ['plan_title']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    subtitle: Text(
                                                      _registeredPlanList[index]
                                                                  [
                                                                  'plan_description']
                                                              .toString() +
                                                          '\n' +
                                                          _registeredPlanList[
                                                                      index][
                                                                  'plan_counts']
                                                              .toString() +
                                                          ' trainings',
                                                      style: TextStyle().copyWith(
                                                          color: _registeredPlanList[
                                                                          index]
                                                                      [
                                                                      'plan_id'] ==
                                                                  _selectedPlan
                                                              ? Colors.white
                                                              : Colors.white70),
                                                    ),
                                                    trailing: _registeredPlanList[
                                                                    index]
                                                                ['plan_id'] ==
                                                            _selectedPlan
                                                        ? Icon(
                                                            Icons.manage_search,
                                                            color: Colors.white,
                                                            size: 30)
                                                        : Icon(Icons.menu),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                                Container(
                                    margin:
                                        EdgeInsets.only(left: 15.0, top: 20.0),
                                    alignment: Alignment.centerLeft, //任意のプロパティ
                                    width: double.infinity,
                                    child: Text(
                                      'メニュー',
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold)
                                              .copyWith(
                                                  color: Colors.white70,
                                                  fontSize: 18.0),
                                    )),
                                const SizedBox(height: 8),
                                Flexible(
                                    child: _trainings_registered.length == 0
                                        ? Center(
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                Text('トレーニングプランが未選択です。')
                                              ]))
                                        : ListView.builder(
                                            itemCount:
                                                _trainings_registered.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Column(children: <Widget>[
                                                ListTile(
                                                    dense: true,
                                                    title: Text('・' +
                                                        _trainings_registered[List.from(
                                                                _trainings_registered
                                                                    .keys)[index]]
                                                            ['training_name']),
                                                    onTap: () {
                                                      var is_setting = false;
                                                      var user_training_id = List.from(_trainings_registered.keys)[index];
                                                      showTrainingContentModal(
                                                          context,
                                                          user_training_id,
                                                          _trainings_registered[user_training_id],
                                                          is_setting);
                                                    })
                                              ]);
                                            })),
                                ElevatedButton(
                                    child: Text('ワークアウト開始',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.green, // background
                                    ),
                                    onPressed: _selectedPlan == 0
                                        ? null
                                        : () {
                                            Widget callbackButton = TextButton(
                                              child: Text('開始'),
                                              onPressed: () {
                                                ref
                                                    .read(isDoingWorkoutProvider
                                                        .notifier)
                                                    .state = true;
                                                ref
                                                    .read(execPlanIdProvider
                                                        .notifier)
                                                    .state = _selectedPlan;
                                                // モーダルを閉じる
                                                Navigator.of(context).pop();
                                              },
                                            );
                                            ConfirmDialogTemplate(
                                                context,
                                                callbackButton,
                                                'ワークアウト',
                                                '選択したトレーニングプランを開始します。よろしいですか？');
                                          }),
                              ]))
                : ExecWorkoutMenuScreen() // ワークアウト実施中の場合
        );
  }
}
