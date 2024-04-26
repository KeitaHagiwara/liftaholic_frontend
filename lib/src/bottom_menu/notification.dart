import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:liftaholic_frontend/src/firebase/user_info.dart';
import 'package:liftaholic_frontend/src/common/dialogs.dart';
import 'package:liftaholic_frontend/src/common/messages.dart';
import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/notifications/notification_detail.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NortificationScreenState createState() => _NortificationScreenState();
}

class _NortificationScreenState extends ConsumerState<NotificationScreen> with SingleTickerProviderStateMixin {
  // お知らせページのイニシャライザ設定
  bool _loading = false;

  String? uid = ''; // ユーザーID

  final List<Tab> tabs = <Tab>[
    Tab(
      text: 'あなた宛',
    ),
    Tab(
      text: 'ニュース',
    ),
  ];
  late TabController _tabController;

  Future<void> getAllNotifications(uid) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/notification/" + uid);

    try {
      //リクエストを投げる
      var response = await http.get(url).timeout(Duration(seconds: 10));
      //リクエスト結果をコンソール出力
      // debugPrint(response.body);

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          ref.read(notificationProvider.notifier).state = jsonResponse['result'];
          ref.read(unreadMessageCounterProvider.notifier).state = jsonResponse['unreadCount'];
        });
      } else {
        AlertDialogTemplate(context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
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

    reload();
    uid = FirebaseAuth.instance.currentUser?.uid;
    _tabController = TabController(length: tabs.length, vsync: this);
    getAllNotifications(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
          : DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  flexibleSpace: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TabBar(
                        tabs: tabs,
                        controller: _tabController,
                        unselectedLabelColor: Colors.white70,
                        indicatorColor: Colors.blue,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 2,
                        indicatorPadding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                        labelColor: Colors.white70,
                      )
                    ],
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: tabs.map((tab) {
                    return _createTab(tab);
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget _createTab(Tab tab) {
    var notificationResults = ref.read(notificationProvider);
    return RefreshIndicator(
        color: Colors.blue, // インジケータの色
        backgroundColor: Colors.white, // インジケータの背景色
        displacement: 50.0, // リストの端から50ピクセル下に表示
        edgeOffset: 10.0, // リストの端を10ピクセル下にオーバーライド
        onRefresh: () async {
          getAllNotifications(uid);
        },
        child: ListView.builder(
            itemCount: notificationResults[tab.text].length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 0.5, color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                    title: Text(notificationResults[tab.text][index]['title']),
                    subtitle: Text(
                      notificationResults[tab.text][index]['created_at'],
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
                    ),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return NotificationDetailScreen(tabType: tab.text.toString(), notificationContent: notificationResults[tab.text][index]);
                        }),
                      );
                      // showModalBottomSheet(
                      //   showDragHandle: true,
                      //   isScrollControlled: true,
                      //   context: context,
                      //   builder: (BuildContext context) {
                      //     return SizedBox(
                      //       height: 800,
                      //       width: double.infinity,
                      //       child: SingleChildScrollView(
                      //         child: Padding(
                      //           padding: EdgeInsets.all(5),
                      //           child: Column(children: [
                      //             Align(
                      //               alignment: Alignment.topRight,
                      //               child: IconButton(
                      //                   icon: Icon(Icons.cancel),
                      //                   onPressed: () {
                      //                     Navigator.of(context).pop(); // Close the sheet.
                      //                   }),
                      //             ),
                      //             Padding(
                      //               padding: EdgeInsets.symmetric(vertical: 0, horizontal: 40),
                      //               child: Column(children: [
                      //                 SizedBox(
                      //                   width: double.infinity,
                      //                   child: Text(
                      //                     results[tab.text][index]['title'],
                      //                     textAlign: TextAlign.center,
                      //                     style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
                      //                   ),
                      //                 ),
                      //                 SizedBox(
                      //                   width: double.infinity,
                      //                   child: Text(results[tab.text][index]['created_at'], textAlign: TextAlign.right),
                      //                 ),
                      //                 const SizedBox(height: 20),
                      //                 SizedBox(
                      //                     width: double.infinity,
                      //                     child: Container(
                      //                       margin: EdgeInsets.fromLTRB(0, 20.0, 0, 40.0),
                      //                       child: Text(results[tab.text][index]['detail']),
                      //                     )),
                      //               ]),
                      //             )
                      //           ]),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // );
                    },
                  ));
            }));
  }
}
