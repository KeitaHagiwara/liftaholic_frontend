import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ----------------------------
// トレーニングプランにメニューを追加する
// ----------------------------
Future<void> _addTrainingMenu(training_plan_id, training_no) async {

  await dotenv.load(fileName: '.env');
  //リクエスト先のurl
  Uri url = Uri.parse("http://" +
      dotenv.get('API_HOST') +
      ":" +
      dotenv.get('API_PORT') +
      "/api/training_plan/add_training_menu");

  Map<String, String> headers = {'content-type': 'application/json'};
  String body = json.encode(
      {'training_plan_id': training_plan_id, 'training_no': training_no});

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
// トレーニングメニューのモーダルを作成する
// ----------------------------
void selectTrainingModal(context, uid, plan_id, trainings) {
  // Map<String, dynamic> trainings = {
  //   '腕': {
  //     '1': {
  //       'training_name': '腕トレ１',
  //       'description': '',
  //       'purpose_name': '',
  //       'purpose_comment': '',
  //       'sub_part_name': '',
  //       'type_name': '',
  //       'type_comment': '',
  //       'event_name': '',
  //       'event_comment': ''
  //     },
  // };

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 800,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  'トレーニングを選択',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)
                      .copyWith(color: Colors.white70, fontSize: 18.0),
                ),
              ),
              // // 検索ボックス
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     vertical: 12,
              //     horizontal: 36,
              //   ),
              //   child: TextField(
              //     style: TextStyle(
              //       fontSize: 14,
              //       color: Colors.white,
              //     ),
              //     decoration: InputDecoration(
              //       // ← InputDecorationを渡す
              //       hintText: '検索ワードを入力してください',
              //     ),
              //   ),
              // ),
              SizedBox(
                  child: Column(
                children: [
                  for (int i = 0; i < trainings.length; i++) ...{
                    ExpansionTile(
                      title: Container(
                        child: ListTile(
                          title: Text(
                            List.from(trainings.keys)[i],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      children: [
                        for (int i_c1 = 0;
                            i_c1 <
                                trainings[List.from(trainings.keys)[i]].length;
                            i_c1++) ...{
                          ListTile(
                            title: Text(List.from(
                                    List.from(trainings.values)[i].values)[i_c1]
                                ['training_name']),
                            trailing: Icon(
                              Icons.add_circle,
                              color: Colors.blue,
                            ),
                            onTap: () {
                              // トレーニングIDを取得する
                              var training_no = List.from(
                                  List.from(trainings.values)[i].keys)[i_c1];
                              // プランにトレーニングメニューを追加する
                              _addTrainingMenu(plan_id, training_no);
                            },
                          ),
                        }
                      ],
                    )
                  }
                ],
              )),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the sheet.
                },
                child: Text("閉じる",
                    style:
                        TextStyle(color: Colors.white)), // Add the button text.
              ),
            ]),
          ),
        ),
      );
    },
  );
}
