import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../login.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // イニシャライザ設定
  String? email = '';
  String? uid = '';

  Future<void> reload() async {
    final instance = FirebaseAuth.instance;
    final User? user = instance.currentUser;
    await user!.reload();
  }

  @override
  void initState() {
    super.initState();

    reload();
    uid = FirebaseAuth.instance.currentUser?.uid;
    email = FirebaseAuth.instance.currentUser?.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('アカウント'),
      // ),
      body: Center(
          child: ListView(children: [
        UserAccountsDrawerHeader(
          accountName: Text(
            uid!,
            style: TextStyle(fontWeight: FontWeight.bold)
                .copyWith(color: Colors.white, fontSize: 18.0),
          ),
          accountEmail: Text(email!),
          currentAccountPicture: CircleAvatar(
              foregroundImage: AssetImage("assets/images/test_user.jpeg")),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ElevatedButton(
          child: Text(
            'ログアウト',
            style: TextStyle().copyWith(color: Colors.red),
          ),
          onPressed: () {
            // set up the buttons
            Widget cancelButton = TextButton(
              child: Text("キャンセル"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
            Widget continueButton = TextButton(
              child: Text("ログアウト"),
              onPressed: () async {
                // ログアウト処理
                // 内部で保持しているログイン情報等が初期化される
                await FirebaseAuth.instance.signOut();
                // ログイン画面に遷移＋チャット画面を破棄
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) {
                    return LoginScreen();
                  }),
                );
              },
            );
            // set up the AlertDialog
            AlertDialog alert = AlertDialog(
              title: Text("ログアウト"),
              content: Text("ログアウトします。よろしいですか？"),
              actions: [
                cancelButton,
                continueButton,
              ],
            );
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );
          },
        ),
      ])),
    );
  }
}
