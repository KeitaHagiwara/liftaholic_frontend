import 'package:flutter/material.dart';

// トレーニング内容のモーダルを表示する
void showTrainingContentModal(context, Map training) {

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
                  training['training_name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)
                      .copyWith(
                          color: Colors.white70, fontSize: 18.0),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.grey),
                onPressed: () {
                  Navigator.pop(context); // Close the sheet.
                },
                // child: Text("閉じる", style: TextStyle(color: Theme.of(context).colorScheme.primary)), // Add the button text.
                child: Text("閉じる",
                    style: TextStyle(
                        color: Colors.white)), // Add the button text.
              ),
            ]),
          ),
        ),
      );
    },
  );
}