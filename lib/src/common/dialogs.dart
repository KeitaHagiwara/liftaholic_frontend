import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Future<void> AlertDialogTemplate(BuildContext context, String titleMsg, String contentMsg) async {
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
        title: Text(titleMsg),
        content: Text(contentMsg),
        actions: [okButton(context_modal)],
      );
    },
  );
}

Future<void> ConfirmDialogTemplate(BuildContext context, Widget callbackButton, String titleMsg, String contentMsg) async {
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
        title: Text(titleMsg),
        content: Text(contentMsg),
        actions: [
          cancelButton(context_modal),
          callbackButton,
        ],
      );
    },
  );
}

lottieDialogTemplate(context, String titleMsg, String lottiePath, Map lottieSize, List<Widget> actionButtonList) {
  Widget alertWidget = AlertDialog(
      title: Text(
        textAlign: TextAlign.center,
        titleMsg,
        style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,),
      ),
      content: SizedBox(
        child: Lottie.asset(
          lottiePath,
          width: lottieSize['width'].toDouble(),
          height: lottieSize['height'].toDouble(),
          errorBuilder: (context, error, stackTrace) {
            return const Padding(
              padding: EdgeInsets.all(0),
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      actions: actionButtonList
    );
  return alertWidget;
}
