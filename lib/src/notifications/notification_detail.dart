import 'dart:async';
import 'dart:convert';

// import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/common/dialogs.dart';
import 'package:liftaholic_frontend/src/common/messages.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({super.key, required this.tabType, required this.notificationContent});

  final String tabType;
  final Map notificationContent;

  @override
  _NotificationDetailScreenState createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends ConsumerState<NotificationDetailScreen> {
  // ********************
  // イニシャライザ設定
  // ********************

  bool _loading = false;

  late String tabType;
  late Map notificationContent;

  // ********************
  // サーバーアクセス処理
  // ********************
  Future<void> _messageReadCheck(notification_id) async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');
    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/notification/message_read_check");

    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({'user_id': FirebaseAuth.instance.currentUser?.uid, 'notification_id': notification_id});

    // POSTリクエストを投げる
    try {
      http.Response response = await http.post(url, headers: headers, body: body).timeout(Duration(seconds: 10));

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['statusCode'] == 200) {
        // setState(() {});
        ref.read(unreadMessageCounterProvider.notifier).state = jsonResponse['unreadCount'];
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

  // @override
  void initState() {
    super.initState();

    tabType = widget.tabType;
    notificationContent = widget.notificationContent;

    // 個人宛のメッセージのみ、既読更新の対象とする
    if (notificationContent['type'] == 1) {
      _messageReadCheck(notificationContent['id']);
    }
  }

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tabType,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
          : Column(children: [
              // Align(
              //   alignment: Alignment.topRight,
              //   child: IconButton(
              //       icon: Icon(Icons.cancel),
              //       onPressed: () {
              //         Navigator.of(context).pop(); // Close the sheet.
              //       }),
              // ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 40),
                child: Column(children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      notificationContent['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 18.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                      width: double.infinity,
                      child: Text(
                        notificationContent['created_at'],
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12.0),
                      )),
                  const SizedBox(height: 20),
                  SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 20.0, 0, 40.0),
                        child: Text(
                          notificationContent['detail'],
                          // style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 18.0),
                        ),
                      )),
                ]),
              )
            ]),
    );
  }
}
