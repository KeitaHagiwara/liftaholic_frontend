import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

Future<void> AlertDialogTemplate(BuildContext context, String title_msg, String content_msg) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title_msg),
        content: Text(content_msg),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


Future<void> ConfirmDialogTemplate(BuildContext context, Widget callbackButton, String title_msg, String content_msg) async {
  Widget cancelButton = TextButton(
    child: Text("キャンセル"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title_msg),
    content: Text(content_msg),
    actions: [
      cancelButton,
      callbackButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );


}

// Widget continueButton = TextButton(
//   child: Text("ログアウト"),
//   onPressed: () async {
//     // ログアウト処理
//     // 内部で保持しているログイン情報等が初期化される
//     await FirebaseAuth.instance.signOut();
//     // ログイン画面に遷移＋チャット画面を破棄
//     await Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) {
//         return LoginScreen();
//       }),
//     );
//   },
// );
