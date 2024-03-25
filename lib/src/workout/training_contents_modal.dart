import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';

// Paddingの定数を設定する
const padding_vertical = 10;
const padding_horizontal = 70;

// ----------------------------
// トレーニングメニューの回数を設定する
// ----------------------------
Future<void> _customizeUserTrainings(context, user_training_id, sets_input, reps_input, kgs_input) async {
  if (sets_input == '' || reps_input == '' || kgs_input == '') {
    AlertDialogTemplate(context, CFM_MSG_TITLE, CFM_MSG_INPUT_NULL);
    return;
  }
  await dotenv.load(fileName: '.env');
  //リクエスト先のurl
  Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/training_plan/customize_user_trainings");

  Map<String, String> headers = {'content-type': 'application/json'};
  Map update_data = {'user_training_id': user_training_id, 'sets': sets_input, 'reps': reps_input, 'kgs': kgs_input};
  String body = json.encode(update_data);

  // POSTリクエストを投げる
  try {
    http.Response response = await http.post(url, headers: headers, body: body).timeout(Duration(seconds: 10));

    var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

    if (jsonResponse['statusCode'] == 200) {
      //リクエストに失敗した場合はエラーメッセージを表示
      await AlertDialogTemplate(context, '更新しました。', jsonResponse['statusMessage']);
    } else {
      //リクエストに失敗した場合はエラーメッセージを表示
      AlertDialogTemplate(context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
    }
  } catch (e) {
    //リクエストに失敗した場合はエラーメッセージを表示
    AlertDialogTemplate(context, ERR_MSG_TITLE, ERR_MSG_NETWORK);
  }
}

// トレーニング内容のモーダルを表示する
void showTrainingContentModal(context, Map training) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 650,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the sheet.
                    }),
              ),
              // トレーニングタイトル
              SizedBox(
                width: double.infinity,
                child: Text(
                  training['training_name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                ),
              ),
              // トレーニング説明文
              SizedBox(
                width: double.infinity,
                child: Text(
                  training['description'],
                  // style: TextStyle(fontWeight: FontWeight.bold)
                  //     .copyWith(color: Colors.white70, fontSize: 18.0),
                ),
              ),
            ]),
          ),
        ),
      );
    },
  );
}
