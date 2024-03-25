import 'dart:async';
import 'dart:convert';

// import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:liftaholic_frontend/src/common/provider.dart';

import '../../common/dialogs.dart';
import '../../common/error_messages.dart';

class EditTrainingPlanScreen extends ConsumerStatefulWidget {
  const EditTrainingPlanScreen({super.key, required this.training_plan_id});

  final String training_plan_id;

  @override
  _EditTrainingPlanScreenState createState() => _EditTrainingPlanScreenState();
}

class _EditTrainingPlanScreenState extends ConsumerState<EditTrainingPlanScreen> {
  // ********************
  // イニシャライザ設定
  // ********************
  String? uid = '';

  late String _training_plan_id = '';

  bool _loading = false;

  // 入力されたテキストをデータとして持つ
  Map<String, String> _savePlanDict = {};

  // テキストフィールドのコントローラーを設定する
  final TextEditingController _plan_name_controller = TextEditingController();
  final TextEditingController _plan_desc_controller = TextEditingController();

  // ********************
  // サーバーアクセス処理
  // ********************
  Future<void> _editTrainingPlan(_training_plan_id) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/workout/update_training_plan");

    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({'user_id': FirebaseAuth.instance.currentUser?.uid, 'training_plan_id': _training_plan_id, 'training_title': _savePlanDict['training_title'], 'training_description': _savePlanDict['training_description'] == null ? '' : _savePlanDict['training_description']});

    // POSTリクエストを投げる
    try {
      http.Response response = await http.post(url, headers: headers, body: body).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['statusCode'] == 200) {
        ref.read(userTrainingDataProvider.notifier).state[_training_plan_id]['training_plan_name'] = _savePlanDict['training_title'];
        ref.read(userTrainingDataProvider.notifier).state[_training_plan_id]['training_plan_description'] = _savePlanDict['training_description'];
        await AlertDialogTemplate(context, '更新しました。', jsonResponse['statusMessage']);
        Navigator.of(context).pop();
      } else {
        // エラーになった場合はTextFieldのinputの内容が消えてしまうため、初期値を再設定する
        setState(() {
          _plan_name_controller.text = _savePlanDict['training_title'].toString();
          _plan_desc_controller.text = _savePlanDict['training_description'].toString();
        });
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

    _training_plan_id = widget.training_plan_id;

    _plan_name_controller.text = ref.read(userTrainingDataProvider)[_training_plan_id]['training_plan_name'];
    _plan_desc_controller.text = ref.read(userTrainingDataProvider)[_training_plan_id]['training_plan_description'];
    _savePlanDict['training_title'] = ref.read(userTrainingDataProvider)[_training_plan_id]['training_plan_name'];
    _savePlanDict['training_description'] = ref.read(userTrainingDataProvider)[_training_plan_id]['training_plan_description'];
  }

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'プラン編集',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
          : Container(
              // 余白を付ける
              padding: EdgeInsets.all(64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // トレーニングプランのタイトル
                  const SizedBox(height: 8),
                  // テキスト入力
                  TextField(
                    controller: _plan_name_controller,
                    decoration: InputDecoration(
                      hintText: 'Leg Day',
                      labelText: 'プランタイトル',
                      labelStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
                    onChanged: (String value) {
                      // データが変更したことを知らせる（画面を更新する）
                      setState(() {
                        _savePlanDict['training_title'] = value;
                      });
                    },
                  ),
                  // Text(
                  //   '必須項目',
                  //   textAlign: TextAlign.left,
                  //   style: TextStyle().copyWith(color: Colors.red, fontSize: 12.0),
                  // ),

                  // トレーニングプランの詳細
                  const SizedBox(height: 8),
                  // テキスト入力
                  TextField(
                    controller: _plan_desc_controller,
                    decoration: InputDecoration(
                      hintText: '下半身を重点的に鍛えるプラン',
                      labelText: 'プラン説明',
                      labelStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
                    onChanged: (String value) {
                      // データが変更したことを知らせる（画面を更新する）
                      setState(() {
                        _savePlanDict['training_description'] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    // 横幅いっぱいに広げる
                    width: double.infinity,
                    // リスト追加ボタン
                    child: ElevatedButton(
                      onPressed: () async {
                        // null & 空白チェック
                        if (_savePlanDict['training_title'] == null || _savePlanDict['training_title'] == '') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("入力必須"),
                                content: Text('プランタイトルを入力してください。'),
                                actions: [
                                  TextButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          // チェックOKだった場合
                        } else {
                          // DBにトレーニングプランを登録する
                          _editTrainingPlan(_training_plan_id);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // background
                      ),
                      child: Text('保存', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    // 横幅いっぱいに広げる
                    width: double.infinity,
                    // キャンセルボタン
                    child: TextButton(
                      // ボタンをクリックした時の処理
                      onPressed: () {
                        // "pop"で前の画面に戻る
                        Navigator.of(context).pop();
                      },
                      child: Text('キャンセル'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
