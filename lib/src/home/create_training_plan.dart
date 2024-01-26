// import 'dart:convert';

// import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class CreateTrainingPlanScreen extends StatefulWidget {
  const CreateTrainingPlanScreen({Key? key}) : super(key: key);

  @override
  _CreateTrainingPlanScreenState createState() =>
      _CreateTrainingPlanScreenState();
}

class _CreateTrainingPlanScreenState extends State<CreateTrainingPlanScreen> {
  bool _loading = false;

  // 入力されたテキストをデータとして持つ
  int _training_count = 0;
  Map<String, String> _createPlanDict = {};

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'トレーニングプラン作成',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold)
              .copyWith(color: Colors.white70, fontSize: 18.0),
        ),
      ),
      body: Container(
        // 余白を付ける
        padding: EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // トレーニングプランのタイトル
            const SizedBox(height: 8),
            // テキスト入力
            TextField(
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
                  _createPlanDict['training_title'] = value;
                  // データを変更
                  // _training_title = value;
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
                  _createPlanDict['training_description'] = value;
                  // データを変更
                  // _training_description = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Container(
              // 横幅いっぱいに広げる
              width: double.infinity,
              // リスト追加ボタン
              child: ElevatedButton(
                onPressed: () {
                  // null & 空白チェック
                  if (_createPlanDict['training_title'] == null ||
                      _createPlanDict['training_title'] == '') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("入力必須"),
                          content: Text('プランタイトルを入力してください。'),
                          actions: [
                            TextButton(
                              child: Text(
                                "OK",
                                style: TextStyle(fontWeight: FontWeight.bold)
                                    .copyWith(
                                        color: Colors.white70, fontSize: 18.0),
                              ),
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
                    // training_countに0を追加する
                    _createPlanDict['training_count'] = _training_count.toString();
                    // "pop"で前の画面に戻る
                    // "pop"の引数から前の画面にデータを渡す
                    Navigator.of(context).pop(_createPlanDict);
                  }
                },
                child: Text('作成', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // background
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
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
