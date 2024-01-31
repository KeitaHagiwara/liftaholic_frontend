import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NortificationScreenState();
}

class _NortificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  // お知らせページのイニシャライザ設定
  bool _loading = false;

  List items = [];

  final List<Tab> tabs = <Tab>[
    Tab(
      text: 'あなた宛',
    ),
    Tab(
      text: 'ニュース',
    ),
  ];
  late TabController _tabController;

  Future<void> getAllNotifications() async {
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
        "/api/notification");

    try {
      //リクエストを投げる
      var response = await http.get(url).timeout(Duration(seconds: 10));
      //リクエスト結果をコンソール出力
      // debugPrint(response.body);

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;
      setState(() {
        items = jsonResponse["result"];
        print(items);

        // スピナー非表示
        _loading = false;
      });
    } catch (e) {
      //リクエストに失敗した場合は"error"と表示
      print(e);
      debugPrint('error');
    }
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);
    getAllNotifications();
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
    // return Center(
    //   child: Text(
    //     "10 min Rest Time",
    //     style: TextStyle(fontSize: 24.0),
    //   ),
    // );
    return ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  // leading: Image.network(
                  //   items[index]['volumeInfo']['imageLinks']['thumbnail'],
                  // ),
                  title: Text(items[index]['title']),
                  subtitle: Text(items[index]['created_at']),
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
                                    items[index]['title'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                        .copyWith(
                                            color: Colors.white70,
                                            fontSize: 18.0),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(items[index]['created_at'],
                                  textAlign: TextAlign.right),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(0, 40.0, 0, 40.0),
                                    child: Text(items[index]['detail']),
                                  )
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue),
                                  onPressed: () {
                                    Navigator.pop(context); // Close the sheet.
                                  },
                                  // child: Text("閉じる", style: TextStyle(color: Theme.of(context).colorScheme.primary)), // Add the button text.
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
