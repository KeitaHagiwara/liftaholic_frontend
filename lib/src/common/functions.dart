
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// ---------------------------
// プログレスの数値を計算する
// ---------------------------
// ・params
//   _user_training_id: String
//   _training_set_list: List
//     exp) [{reps: 3, kgs: 70.0, time: 00:00, is_completed: true}, {reps: 3, kgs: 70.0, time: 00:00, is_completed: false}]
//
// ・return
//   progress: int
//
int calc_progress(String _user_training_id, List _training_set_list) {
  var progress = 0.0;
  var p_unit = 100 / _training_set_list.length;
  for (int i = 0; i < _training_set_list.length; i++) {
    if (_training_set_list[i]['is_completed']) {
      progress += p_unit;
    }
  }
  return progress.ceil();
}


// ********************
//
// トレーニングメニューのモーダルを作成する
//
// ********************
// void selectTrainingModal(context, uid, plan_id, trainings) {
//   // Map<String, dynamic> trainings = {
//   //   '腕': {
//   //     '1': {
//   //       'training_name': '腕トレ１',
//   //       'description': '',
//   //       'purpose_name': '',
//   //       'purpose_comment': '',
//   //       'sub_part_name': '',
//   //       'type_name': '',
//   //       'type_comment': '',
//   //       'event_name': '',
//   //       'event_comment': ''
//   //     },
//   // };

//   showModalBottomSheet(
//     isScrollControlled: true,
//     context: context,
//     builder: (BuildContext context) {
//       return SizedBox(
//         height: 800,
//         width: double.infinity,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(5),
//             child: Column(children: [
//               Align(
//                 alignment: Alignment.topRight,
//                 child: IconButton(
//                     icon: Icon(Icons.cancel),
//                     onPressed: () {
//                       Navigator.of(context).pop(); // Close the sheet.
//                     }),
//               ),
//               Container(
//                 margin: EdgeInsets.only(bottom: 15),
//                 width: double.infinity,
//                 child: Text(
//                   'トレーニングを選択',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
//                 ),
//               ),
//               // // 検索ボックス
//               // Padding(
//               //   padding: const EdgeInsets.symmetric(
//               //     vertical: 12,
//               //     horizontal: 36,
//               //   ),
//               //   child: TextField(
//               //     style: TextStyle(
//               //       fontSize: 14,
//               //       color: Colors.white,
//               //     ),
//               //     decoration: InputDecoration(
//               //       // ← InputDecorationを渡す
//               //       hintText: '検索ワードを入力してください',
//               //     ),
//               //   ),
//               // ),
//               SizedBox(
//                   child: Column(
//                 children: [
//                   for (int i = 0; i < trainings.length; i++) ...{
//                     ExpansionTile(
//                       title: Container(
//                         child: ListTile(
//                           title: Text(
//                             List.from(trainings.keys)[i],
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[700],
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                       ),
//                       children: [
//                         for (int i_c1 = 0; i_c1 < trainings[List.from(trainings.keys)[i]].length; i_c1++) ...{
//                           Slidable(
//                             startActionPane: ActionPane(motion: const ScrollMotion(), children: [
//                               SlidableAction(
//                                   borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
//                                   backgroundColor: Colors.green,
//                                   icon: Icons.add,
//                                   label: '追加',
//                                   onPressed: (context) {
//                                     // // トレーニングIDを取得する
//                                     // var training_no = List.from(List.from(trainings.values)[i].keys)[i_c1];
//                                     // // プランにトレーニングメニューを追加する
//                                     // _addTrainingMenu(plan_id, training_no);
//                                   })
//                             ]),
//                             child: ListTile(
//                               title: Text(List.from(List.from(trainings.values)[i].values)[i_c1]['training_name']),
//                               onTap: () {
//                                 // トレーニングのコンテンツのモーダルを表示する
//                                 showTrainingContentModal(context, List.from(List.from(trainings.values)[i].values)[i_c1]);
//                               },
//                             ),
//                           )
//                         }
//                       ],
//                     )
//                   }
//                 ],
//               )),
//             ]),
//           ),
//         ),
//       );
//     },
//   );
// }