import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showCalendarModal(context, uid, selectedDay, selectedEvents) {
  // モーダルタイトル用に日付をフォーマットする
  String date = DateFormat.yMMMd('ja').format(selectedDay) +
      ' (${DateFormat.EEEE('ja').format(selectedDay)})';

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 800,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  date,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)
                      .copyWith(color: Colors.white70, fontSize: 18.0),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                // width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.red[300]),
                  onPressed: () {
                    Navigator.pop(context); // Close the sheet.
                  },
                  child: Text("追加",
                      style:
                          TextStyle(color: Colors.white)), // Add the button text.
                ),
              ),
              SizedBox(
                  width: double.infinity,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 20.0, 0, 40.0),
                    child: Text('詳細'),
                    // child: ListView.builder(
                    //   itemCount: selectedEvents.length,
                    //   itemBuilder: (context, index) {
                    //     final event = selectedEvents[index];
                    //     return Card(
                    //       child: ListTile(
                    //         title: Text(event),
                    //         // onTap: () {
                    //         //   print(event);
                    //         // },
                    //       ),
                    //     );
                    //   },
                    // ),
                  )),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  Navigator.pop(context); // Close the sheet.
                },
                // child: Text("閉じる", style: TextStyle(color: Theme.of(context).colorScheme.primary)), // Add the button text.
                child: Text("閉じる",
                    style:
                        TextStyle(color: Colors.white)), // Add the button text.
              ),
            ]),
          ),
        ),
      );
    },
  );
}
