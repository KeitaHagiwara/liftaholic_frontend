import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';

// import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/workout/training_contents_modal.dart';

// ---------------------------
// プログレスの数値を計算する
// ---------------------------
// ・params
//   - trainingSetList: List
//     exp) [{reps: 3, kgs: 70.0, time: 00:00, is_completed: true}, {reps: 3, kgs: 70.0, time: 00:00, is_completed: false}]
//
// ・return
//   - progress: int
//
int calcProgress(List trainingSetList) {
  var progress = 0.0;
  var p_unit = 100 / trainingSetList.length;
  for (int i = 0; i < trainingSetList.length; i++) {
    if (trainingSetList[i]['is_completed']) {
      progress += p_unit;
    }
  }
  return progress.ceil();
}

// ---------------------------
// Durationの時間を分と秒に分ける
// ---------------------------
// ・params
//   - intervalStr: String
//
// ・return
//   - result: Map
//
Map getIntervalDuration(intervalStr) {
  // 先頭が0だったら除外する
  return {'interval_min': trimZero(intervalStr.split(':')[0]), 'interval_sec': trimZero(intervalStr.split(':')[1])};
}

// ---------------------------
// 先頭文字が0だった場合はトリムする
// ---------------------------
// ・params
//   - intervalStr: String
//
// ・return
//   - int.parse(trimStr): int
//
int trimZero(intervalStr) {
  var trimStr = intervalStr;
  if (trimStr[0] == '0') {
    trimStr = intervalStr[1];
  }
  return int.parse(trimStr);
}

// ---------------------------
// トレーニングメニューのモーダルを作成する
// ---------------------------
// ・params
//   - uid: String
//   - plan_id: String
//   - training_menu_master: Map<String, dynamic>
//     exp) '腕': {
//            '1': {
//              'training_name': '腕トレ１',
//              'description': '',
//              'purpose_name': '',
//              'purpose_comment': '',
//              'sub_part_name': '',
//              'type_name': '',
//              'type_comment': '',
//              'event_name': '',
//              'event_comment': ''
//            },
//          };
//
// ・return
//   - void
//
void selectTrainingModal(context, uid, plan_id, training_menu_master) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 800,
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
              Container(
                margin: EdgeInsets.only(bottom: 15),
                width: double.infinity,
                child: Text(
                  'トレーニングを選択',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
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
                  for (int i = 0; i < training_menu_master.length; i++) ...{
                    ExpansionTile(
                      title: Container(
                        child: ListTile(
                          dense: true,
                          title: Text(
                            List.from(training_menu_master.keys)[i],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      children: [
                        for (int i_c1 = 0; i_c1 < training_menu_master[List.from(training_menu_master.keys)[i]].length; i_c1++) ...{
                          Slidable(
                            startActionPane: ActionPane(motion: const ScrollMotion(), children: [
                              SlidableAction(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                  backgroundColor: Colors.green,
                                  icon: Icons.add,
                                  label: '追加',
                                  onPressed: (context) {
                                    // トレーニングIDを取得する
                                    var training_no = List.from(List.from(training_menu_master.values)[i].keys)[i_c1];
                                    // プランにトレーニングメニューを追加する
                                    // _addTrainingMenu(plan_id, training_no);
                                  })
                            ]),
                            child: ListTile(
                              dense: true,
                              title: Text(List.from(List.from(training_menu_master.values)[i].values)[i_c1]['training_name'], style: TextStyle(fontSize: 12)),
                              trailing: IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    print('pressed');
                                  }),
                              onTap: () {
                                // トレーニングのコンテンツのモーダルを表示する
                                showTrainingContentModal(context, List.from(List.from(training_menu_master.values)[i].values)[i_c1]);
                              },
                            ),
                          )
                        }
                      ],
                    )
                  }
                ],
              )),
            ]),
          ),
        ),
      );
    },
  );
}
