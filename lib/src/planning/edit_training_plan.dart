import 'dart:async';
import 'dart:convert';

// import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../planning/select_training_modal.dart';

class EditTrainingPlanScreen extends StatefulWidget {
  const EditTrainingPlanScreen({Key? key, required this.training_plan_id})
      : super(key: key);

  // 画面遷移元からのデータを受け取る変数
  final int training_plan_id;

  @override
  _EditTrainingPlanScreenState createState() => _EditTrainingPlanScreenState();
}

class _EditTrainingPlanScreenState extends State<EditTrainingPlanScreen> {
  // ********************
  //
  // イニシャライザ設定
  //
  // ********************
  final itemController = TextEditingController();

  late int training_plan_id;

  String? uid = '';

  bool _loading = false;

  // トレーニングプランを作成するときに使用する辞書
  Map<String, String> _createPlanDict = {};

  List trainings_registered = [];

  // List trainings_registered = [
  //   {'training_name': 'ベンチプレス', 'description': 'bench'},
  //   {'training_name': 'プッシュアップ', 'description': 'push-up'},
  //   {'training_name': 'インクラインダンベルプレス', 'description': 'press'}
  // ];

  // トレーニングメニューを入れる辞書
  Map<String, dynamic> training_menu = {};

  // ********************
  //
  // サーバーアクセス処理
  //
  // ********************
  // ----------------------------
  // 全トレーニングメニューを取得する
  // ----------------------------
  Future<void> getAllTrainingMenu() async {
    await dotenv.load(fileName: '.env');

    //リクエスト先のurl
    Uri url = Uri.parse("http://" +
        dotenv.get('API_HOST') +
        ":" +
        dotenv.get('API_PORT') +
        "/api/training_plan/get_all_training_menu");

    try {
      var response = await http.get(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      // print(jsonResponse['training_menu']);
      if (!mounted) return;
      setState(() {
        // --------
        // トレーニングメニューのデータを作成
        // --------
        training_menu = jsonResponse['training_menu'];

        // スピナー非表示
        _loading = false;
      });
    } catch (e) {
      //リクエストに失敗した場合は"error"と表示
      print(e);
      debugPrint('error');
    }
  }

  // ----------------------------
  // トレーニングプランに登録済みのトレーニングを取得する
  // ----------------------------
  Future<void> getRegisteredTrainings(training_plan_id) async {
    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" +
        dotenv.get('API_HOST') +
        ":" +
        dotenv.get('API_PORT') +
        "/api/training_plan/get_registered_trainings/" +
        training_plan_id.toString());

    try {
      var response = await http.get(url).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      // print(jsonResponse['training_menu']);
      if (!mounted) return;
      setState(() {
        // --------
        // トレーニングメニューのデータを作成
        // --------
        trainings_registered = jsonResponse['user_training_menu'];
        print(trainings_registered);

        // スピナー非表示
        _loading = false;
      });
    } catch (e) {
      //リクエストに失敗した場合は"error"と表示
      print(e);
      debugPrint('error');
    }
  }

  // ----------------------------
  // トレーニングプランを作成する
  // ----------------------------
  Future<void> _createTrainingPlan(_createPlanDict) async {
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
        "/api/training_plan/create_training_plan");

    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({
      'user_id': FirebaseAuth.instance.currentUser?.uid,
      'training_title': _createPlanDict['training_title'],
      'training_description': _createPlanDict['training_description'] == null
          ? ''
          : _createPlanDict['training_description']
    });

    // POSTリクエストを投げる
    try {
      http.Response response = await http
          .post(url, headers: headers, body: body)
          .timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print(jsonResponse);
    } catch (e) {
      print(e);
    }
  }

  // ----------------------------
  // アイテムを追加するダイアログ
  // ----------------------------
  void removeTraining(int index, String training_name) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          // title: Text(training_name),
          content: Text(training_name + "をトレーニングプランから削除します。よろしいですか？"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // 受け取ったデータを状態を管理する変数に格納
    training_plan_id = widget.training_plan_id;

    // トレーニングプランに登録済みのトレーニングメニューを取得する
    getRegisteredTrainings(training_plan_id);

    // 登録済みの全トレーニングメニューを取得する
    getAllTrainingMenu();
  }

  // ********************
  //
  // データを元に表示するWidget
  //
  // ********************
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'トレーニングプラン編集',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold)
              .copyWith(color: Colors.white70, fontSize: 18.0),
        ),
      ),
      body: Container(
        // 余白を付ける
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // トレーニングプランに設定されているトレーニング一覧
            const SizedBox(height: 8),
            Flexible(
              // height: 150,
              child: trainings_registered.length == 0
                  ? Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [Text('トレーニングが未登録です。')]))
                  : ListView.builder(
                      itemCount: trainings_registered.length,
                      itemBuilder: (BuildContext context, int index) {
                        final training = trainings_registered[index];
                        return Slidable(
                            endActionPane: ActionPane(
                                motion: const BehindMotion(),
                                children: [
                                  SlidableAction(
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: '削除',
                                      onPressed: (context) {
                                        removeTraining(
                                            index, training['training_name']);
                                      })
                                ]),
                            child: buildTrainingListTile(training));
                      }),
            ),
            // トレーニング追加ボタン
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.only(left: 64, right: 64),
              // 横幅いっぱいに広げる
              width: double.infinity,
              // リスト追加ボタン
              child: ElevatedButton(
                child: Text('追加', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // background
                ),
                onPressed: () {
                  selectTrainingModal(
                      context, uid, training_plan_id, training_menu);
                },
              ),
            ),
            // トレーニングプラン削除ボタン
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.only(left: 64, right: 64),
              // 横幅いっぱいに広げる
              width: double.infinity,
              // リスト追加ボタン
              child: ElevatedButton(
                child: Text('プラン削除', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // background
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ********************
  //
  // トレーニングリストタイル
  //
  // ********************
  Widget buildTrainingListTile(training) => Card(
          child: Column(children: <Widget>[
        ListTile(
          leading: CircleAvatar(
              foregroundImage: AssetImage("assets/images/chest.png")),
          title: Text(training['training_name']),
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return SizedBox(
                  height: 800,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            training['training_name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold)
                                .copyWith(
                                    color: Colors.white70, fontSize: 18.0),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blue),
                          onPressed: () {
                            Navigator.pop(context); // Close the sheet.
                          },
                          // child: Text("閉じる", style: TextStyle(color: Theme.of(context).colorScheme.primary)), // Add the button text.
                          child: Text("閉じる",
                              style: TextStyle(
                                  color: Colors.white)), // Add the button text.
                        ),
                      ]),
                    ),
                  ),
                );
              },
            );
          },
        )
      ]));
}
