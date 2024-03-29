import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';

// Paddingの定数を設定する
const padding_vertical = 10;
const padding_horizontal = 70;


// トレーニング内容のモーダルを表示する
void showTrainingContentModal(context, Map training) {
  print(training);
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

              SizedBox(
                  width: double.infinity,
                  child: Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '部位: ' + training['part_name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            'タイプ: ' + training['type_name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            '種目: ' + training['event_name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ))),
              // トレーニング説明文
              SizedBox(
                  width: double.infinity,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text(
                      training['description'],
                      // style: TextStyle(fontWeight: FontWeight.bold)
                      //     .copyWith(color: Colors.white70, fontSize: 18.0),
                    ),
                  )),
              // // 説明用の画像もしくは動画
              // SizedBox(
              //   width: double.infinity,
              //   child: Text(''),
              // ),
            ]),
          ),
        ),
      );
    },
  );
}
