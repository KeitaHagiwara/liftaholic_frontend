import 'dart:convert';
import 'dart:collection';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:liftaholic_frontend/src/common/default_value.dart';
import 'package:liftaholic_frontend/src/workout/training_contents_modal.dart';

class StatefulBottomSheet extends ConsumerStatefulWidget {
  final Map userTrainingMenu;
  final Map trainingMenuMaster;
  final ValueChanged<Map> valueChanged;
  StatefulBottomSheet({super.key, required this.userTrainingMenu, required this.trainingMenuMaster, required this.valueChanged});

  @override
  _StatefulBottomSheetState createState() => _StatefulBottomSheetState();
}

class _StatefulBottomSheetState extends ConsumerState<StatefulBottomSheet> {
  late Map userTrainingMenu;
  // ・params
  //   - userTrainingMenu: Map<int, dynamic>
  //     exp) {52: {
  //              training_name: ベンチプレス,
  //              description: '',
  //              part_name: '胸',
  //              part_image_file: 'chest.jpg',
  //              type_name: 'プッシュ',
  //              event_name: 'コンパウンド種目',
  //              sets: 3,
  //              reps: 10,
  //              kgs: 41.0,
  //              interval: 01:00
  //            },
  //          }

  late Map trainingMenuMaster;
  //   - trainingMenuMaster: Map<String, dynamic>
  //     exp) '腕': {
  //            '1': {
  //              'is_selected': false,
  //              'training_name': '腕トレ１',
  //              'description': '',
  //              'purpose_name': '',
  //              'purpose_comment': '',
  //              'sub_part_name': '',
  //              'part_image_file': '',
  //              'type_name': '',
  //              'type_comment': '',
  //              'event_name': '',
  //              'event_comment': ''
  //            },
  //          };
  //
  // ・return
  //   - void

  @override
  void initState() {
    userTrainingMenu = widget.userTrainingMenu;
    trainingMenuMaster = widget.trainingMenuMaster;
    super.initState();

    // トレーニングメニューの選択状態を初期化する
    changeSelectedState(userTrainingMenu, trainingMenuMaster);
  }

  void changeSelectedState(userTrainingMenu, trainingMenuMaster) {
    for (int i = 0; i < trainingMenuMaster.length; i++) {
      for (int i2 = 0; i2 < trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]].length; i2++) {
        var training_menu_master_obj = trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]][List.from(List.from(trainingMenuMaster.values)[i].keys)[i2]];
        var training_name = training_menu_master_obj['training_name'];
        for (var i3 = 0; i3 < List.from(userTrainingMenu.keys).length; i3++) {
          // is_selectedをfalse設定で初期化しておく
          trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]][List.from(List.from(trainingMenuMaster.values)[i].keys)[i2]]['is_selected'] = false;
          // ユーザーのトレーニングメニューに含まれていた場合はis_selectedをtrueに変更する
          if (userTrainingMenu[List.from(userTrainingMenu.keys)[i3]]['training_name'] == training_name) {
            trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]][List.from(List.from(trainingMenuMaster.values)[i].keys)[i2]]['is_selected'] = true;
            break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 18),
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
                for (int i = 0; i < trainingMenuMaster.length; i++) ...{
                  ExpansionTile(
                    title: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ListTile(
                        // dense: true,
                        leading: CircleAvatar(foregroundImage: NetworkImage(networkImageDomain + s3Folder + trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]]['0']['part_image_file'])),
                        title: Text(
                          List.from(trainingMenuMaster.keys)[i],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    children: [
                      for (int i_c1 = 0; i_c1 < trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]].length; i_c1++) ...{
                        ListTile(
                          dense: true,
                          leading: IconButton(
                              icon: !trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]][List.from(List.from(trainingMenuMaster.values)[i].keys)[i_c1]]['is_selected'] ? Icon(Icons.radio_button_unchecked, color: Colors.grey) : Icon(Icons.radio_button_checked, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]][List.from(List.from(trainingMenuMaster.values)[i].keys)[i_c1]]['is_selected'] =
                                      !trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]][List.from(List.from(trainingMenuMaster.values)[i].keys)[i_c1]]['is_selected'];
                                });
                              }),
                          title: Text(List.from(List.from(trainingMenuMaster.values)[i].values)[i_c1]['training_name'], style: TextStyle(fontSize: 12)),
                          trailing: IconButton(
                              icon: Icon(Icons.info_outline, color: Colors.grey),
                              onPressed: () {
                                // トレーニングのコンテンツのモーダルを表示する
                                showTrainingContentModal(context, List.from(List.from(trainingMenuMaster.values)[i].values)[i_c1]);
                              }),
                          onTap: () {
                            // // トレーニングのコンテンツのモーダルを表示する
                            // showTrainingContentModal(context, List.from(List.from(trainingMenuMaster.values)[i].values)[i_c1]);
                            setState(() {
                              trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]][List.from(List.from(trainingMenuMaster.values)[i].keys)[i_c1]]['is_selected'] =
                                  !trainingMenuMaster[List.from(trainingMenuMaster.keys)[i]][List.from(List.from(trainingMenuMaster.values)[i].keys)[i_c1]]['is_selected'];
                            });
                          },
                        ),
                      }
                    ],
                  )
                }
              ],
            )),

            // ワークアウトメニューの更新ボタン
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              padding: EdgeInsets.only(left: 64, right: 64),
              width: double.infinity, // 横幅いっぱいに広げる
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  widget.valueChanged(trainingMenuMaster);
                },
                child: Text('更新', style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
