import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../login.dart';
import '../common/dialogs.dart';
import '../common/error_messages.dart';
import '../common/provider.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  // イニシャライザ設定
  String? uid = '';
  String? email = '';
  String? username = '';
  String? photoURL = '';

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
    username = FirebaseAuth.instance.currentUser?.displayName;
    photoURL = FirebaseAuth.instance.currentUser?.photoURL;
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
            username!,
            style: TextStyle(fontWeight: FontWeight.bold)
                .copyWith(color: Colors.white, fontSize: 18.0),
          ),
          accountEmail: Text(email!),
          currentAccountPicture: CircleAvatar(
              foregroundImage: AssetImage("assets/images/default_icon.png")),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
        ),
        ElevatedButton(
          child: Text(
            'ログアウト',
            style: TextStyle().copyWith(color: Colors.red),
          ),
          onPressed: () {
            // ログアウト処理
            Widget callbackButton = TextButton(
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
            ConfirmDialogTemplate(
                context, callbackButton, 'ログアウト', 'ログアウトします。よろしいですか？');
          },
        ),
      ])),
    );
  }
}
