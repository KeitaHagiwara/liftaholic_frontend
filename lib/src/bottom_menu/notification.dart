import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import '../firebase/user_info.dart';
import '../common/dialogs.dart';
import '../common/error_messages.dart';
import '../common/provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NortificationScreenState createState() => _NortificationScreenState();
}

class _NortificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  // お知らせページのイニシャライザ設定
  bool _loading = false;

  String? uid = ''; // ユーザーID

  Map results = {'あなた宛': [], 'ニュース': []};

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
    Uri url = Uri.parse("http://" +
        dotenv.get('API_HOST') +
        ":" +
        dotenv.get('API_PORT') +
        "/api/notification/" +
        uid);

    try {
      //リクエストを投げる
      var response = await http.get(url).timeout(Duration(seconds: 10));
      //リクエスト結果をコンソール出力
      // debugPrint(response.body);

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          results = jsonResponse['result'];
        });
      } else {
        AlertDialogTemplate(
            context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
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
          ? const Center(
              child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
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
                        indicatorPadding:
                            EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
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
    return ListView.builder(
        itemCount: results[tab.text].length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(results[tab.text][index]['title']),
                  subtitle: Text(results[tab.text][index]['created_at']),
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: 800,
                          width: double.infinity,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Column(children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    results[tab.text][index]['title'],
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)
                                            .copyWith(
                                                color: Colors.white70,
                                                fontSize: 18.0),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                      results[tab.text][index]['created_at'],
                                      textAlign: TextAlign.right),
                                ),
                                // default: 'https://lottie.host/13f1ca31-c177-4ebc-a64a-28f82a15c786/BmrjCFDPXQ.json',
                                // custom1 : 'https://lottie.host/c40cfa4e-ab6d-4c6e-aa13-2901a6bd5100/dG0o8nAXpc.json',
                                if (results[tab.text][index]
                                        ['animation_width'] !=
                                    null) ...[
                                  Lottie.network(
                                    results[tab.text][index]['animation_link'],
                                    width: double.parse(results[tab.text][index]
                                        ['animation_width']),
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Padding(
                                        padding: EdgeInsets.all(0.0),
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                ] else ...[
                                  Lottie.network(
                                    results[tab.text][index]['animation_link'],
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Padding(
                                        padding: EdgeInsets.all(0.0),
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                ],

                                SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      margin:
                                          EdgeInsets.fromLTRB(0, 20.0, 0, 40.0),
                                      child: Text(
                                          results[tab.text][index]['detail']),
                                    )),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.grey),
                                  onPressed: () {
                                    Navigator.pop(context); // Close the sheet.
                                  },
                                  child: Text("閉じる",
                                      style: TextStyle(
                                          color: Colors
                                              .white)), // Add the button text.
                                ),
                              ]),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        });
  }
}
