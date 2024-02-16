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

