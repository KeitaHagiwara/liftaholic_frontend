import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/workout/select_training_menu_modal.dart';
import 'package:liftaholic_frontend/src/bottom_menu/workout.dart';

void showCalendarModal(context, uid, selectedDay, selectedEvents) {
  // モーダルタイトル用に日付をフォーマットする
  String date = DateFormat.MMMd('ja').format(selectedDay) + ' ${DateFormat.EEEE('ja').format(selectedDay)}';

  print(selectedEvents);
  List calendarData = [
    {'plan_name': 'test1', 'plan_description': 'description1', 'trainings': []},
    {'plan_name': 'test2', 'plan_description': 'description2', 'trainings': []},
    {'plan_name': 'test3', 'plan_description': 'description3', 'trainings': []},
  ];

  Widget calendarCard(String planName, String planDescription) {
    return InkWell(
      onTap: () {
        print('schedule tapped');
      },
      // height: 100,
      child: Card(
        elevation: 9,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: ListTile(
          dense: false,
          leading: FlutterLogo(),
          title: Text(
            planName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            planDescription,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }

  showModalBottomSheet(
    showDragHandle: true,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, child) {
          return SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal:15),
                      child: Text(
                        date,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle),
                      onPressed: () {
                        // トレーニングプラン一覧のモーダルを開く
                        // showModalBottomSheet(
                        //   context: context,
                        //   builder: (BuildContext context) {
                        //     return StatefulBottomSheet(
                        //       userTrainingMenu: ref.read(userTrainingDataProvider)[ref.read(execPlanIdProvider)]['training_menu'],
                        //       trainingMenuMaster: ref.read(trainingMenuMasterProvider),
                        //       valueChanged: updateUserTrainingMenu,
                        //     );
                        //   });
                      }
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ---------------------
                // ここに広告を入れる
                // ---------------------
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final data in calendarData) ...{
                          calendarCard(data['plan_name'], data['plan_description']),
                        }
                      ],
                    ),
                  )
                ),

                // スケジュール開始
                Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 64),
                    width: double.infinity, // 横幅いっぱいに広げる
                    child: SlideAction(
                      text: 'スライドして開始',
                      textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                      animationDuration: const Duration(milliseconds: 500),
                      sliderButtonIcon: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.green,
                      ),
                      outerColor: Colors.green,
                      height: 50,
                      sliderButtonIconSize: 60,
                      sliderButtonIconPadding: 8,
                      onSubmit: () {
                        // スライドした時に実行したい処理を記載
                        // ref.read(isDoingWorkoutProvider.notifier).state = true;
                      },
                    )),
              ]),
            ),
          );
        },
      );
    },
  );
}
