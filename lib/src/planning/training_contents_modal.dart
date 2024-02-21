import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';

// ----------------------------
// トレーニングメニューの回数を設定する
// ----------------------------
Future<void> _customizeUserTrainings(
    context, user_training_id, sets_input, reps_input, kgs_input) async {
  if (sets_input == '' || reps_input == '' || kgs_input == '') {
    AlertDialogTemplate(context, CFM_MSG_TITLE, CFM_MSG_INPUT_NULL);
    return;
  }
  await dotenv.load(fileName: '.env');
  //リクエスト先のurl
  Uri url = Uri.parse("http://" +
      dotenv.get('API_HOST') +
      ":" +
      dotenv.get('API_PORT') +
      "/api/training_plan/customize_user_trainings");

  Map<String, String> headers = {'content-type': 'application/json'};
  Map update_data = {
    'user_training_id': user_training_id,
    'sets': sets_input,
    'reps': reps_input,
    'kgs': kgs_input
  };
  String body = json.encode(update_data);

  // POSTリクエストを投げる
  try {
    http.Response response = await http
        .post(url, headers: headers, body: body)
        .timeout(Duration(seconds: 10));

    var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

    if (jsonResponse['statusCode'] == 200) {
      //リクエストに失敗した場合はエラーメッセージを表示
      await AlertDialogTemplate(context, '更新しました。', jsonResponse['statusMessage']);

    } else {
      //リクエストに失敗した場合はエラーメッセージを表示
      AlertDialogTemplate(
          context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
    }
  } catch (e) {
    //リクエストに失敗した場合はエラーメッセージを表示
    AlertDialogTemplate(context, ERR_MSG_TITLE, ERR_MSG_NETWORK);
  }
}

// トレーニング内容のモーダルを表示する
void showTrainingContentModal(context, Map training, bool is_setting) {
  // テキストフィールドのコントローラーを設定する
  final TextEditingController _controllerSets = training['sets'] == null
      ? TextEditingController()
      : TextEditingController(text: training['sets'].toString());
  final TextEditingController _controllerReps = training['reps'] == null
      ? TextEditingController()
      : TextEditingController(text: training['reps'].toString());
  final TextEditingController _controllerKgs = training['kgs'] == null
      ? TextEditingController()
      : TextEditingController(text: training['kgs'].toString());

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 800,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
            child: Column(children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  training['training_name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)
                      .copyWith(color: Colors.white70, fontSize: 18.0),
                ),
              ),
              if (is_setting) ...[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // --------
                    // sets
                    // --------
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          controller: _controllerSets,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          // decoration: InputDecoration(
                          //   enabledBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(color: Colors.blue)
                          //   ),
                          //   focusedBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(color: Colors.orange)
                          //   )
                          // ),
                        ),
                      ),
                    ),
                    Text(
                      "sets ",
                      textAlign: TextAlign.center,
                      style: TextStyle()
                          .copyWith(color: Colors.white70, fontSize: 18.0),
                    ),
                    // --------
                    // reps
                    // --------
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _controllerReps,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          // decoration: InputDecoration(
                          //   enabledBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(color: Colors.blue)
                          //   ),
                          //   focusedBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(color: Colors.orange)
                          //   )
                          // ),
                        ),
                      ),
                    ),
                    Text(
                      "reps",
                      textAlign: TextAlign.center,
                      style: TextStyle()
                          .copyWith(color: Colors.white70, fontSize: 18.0),
                    ),
                    // --------
                    // kgs
                    // --------
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _controllerKgs,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(3),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          // decoration: InputDecoration(
                          //   enabledBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(color: Colors.blue)
                          //   ),
                          //   focusedBorder: OutlineInputBorder(
                          //     borderSide: BorderSide(color: Colors.orange)
                          //   )
                          // ),
                        ),
                      ),
                    ),
                    Text(
                      "kgs",
                      textAlign: TextAlign.center,
                      style: TextStyle()
                          .copyWith(color: Colors.white70, fontSize: 18.0),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: TextButton(
                        style: TextButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          _customizeUserTrainings(
                              context,
                              training['user_training_id'],
                              _controllerSets.text,
                              _controllerReps.text,
                              _controllerKgs.text);
                        },
                        child: Text("更新",
                            style: TextStyle(
                                color: Colors.white)), // Add the button text.
                      ),
                    ),

                    ///TODO add to db and previous added move
                  ],
                ),
              ],
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.grey),
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
