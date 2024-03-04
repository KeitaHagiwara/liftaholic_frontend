import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import '../bottom_menu/planning.dart';

Future<void> AlertDialogTemplate(
    BuildContext context, String title_msg, String content_msg) async {

  Widget okButton(context_modal) {
    return TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context_modal).pop();
      },
    );
  }

  return showDialog(
    context: context,
    builder: (BuildContext context_modal) {
      return AlertDialog(
        title: Text(title_msg),
        content: Text(content_msg),
        actions: [okButton(context_modal)],
      );
    },
  );
}

Future<void> ConfirmDialogTemplate(BuildContext context, Widget callbackButton,
    String title_msg, String content_msg) async {

  Widget cancelButton(context_modal) {
    return TextButton(
      child: Text("キャンセル"),
      onPressed: () {
        Navigator.of(context_modal).pop();
      },
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context_modal) {
      
      return AlertDialog(
        title: Text(title_msg),
        content: Text(content_msg),
        actions: [
          cancelButton(context_modal),
          callbackButton,
        ],
      );
    },
  );
}



// showDialog(
//   context: context,
//   builder: (BuildContext context_modal) {
//     return AlertDialog(
//       title: 'title',
//       content: 'content',
//       actions: [
//         TextButton(
//           child: Text("キャンセル"),
//           onPressed: () {
//             Navigator.of(context_modal).pop();
//           },
//         ),
//         callbackButton,
//       ],
//     );
//   },
// );


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
