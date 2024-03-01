import 'dart:async';
import 'dart:convert';

// import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinbox/cupertino.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../common/dialogs.dart';
import '../common/error_messages.dart';

class StopWatchScreen extends ConsumerStatefulWidget {
  const StopWatchScreen({Key? key}) : super(key: key);

  @override
  _StopWatchScreenState createState() => _StopWatchScreenState();
}

class _StopWatchScreenState extends ConsumerState<StopWatchScreen> {
  String timeString = "00:00";
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;

  void start() {
    stopwatch.start();
    if (stopwatch.isRunning) {
      setState(() {});
    }
    timer = Timer.periodic(Duration(seconds: 1), update);
  }

  void update(Timer t) {
    if (stopwatch.isRunning) {
      setState(() {
        timeString =
            (stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") +
                ":" +
                (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, "0");

        // millisecond単位
        // timeString =
        //     (stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") + ":" +
        //         (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, "0") + ":" +
        //         (stopwatch.elapsed.inMilliseconds % 1000 / 10).clamp(0, 99).toStringAsFixed(0).padLeft(2, "0");
      });
    }
  }

  void stop() {
    setState(() {
      timer.cancel();
      stopwatch.stop();
    });
  }

  void reset() {
    if (stopwatch.isRunning) {
      Widget callbackButton = TextButton(
        child: Text('リセット'),
        onPressed: () {
          timer.cancel();
          stopwatch.reset();
          setState(() {
            timeString = "00:00";
          });
          stopwatch.stop();
          // モーダルを閉じる
          Navigator.of(context).pop();
        },
      );
      ConfirmDialogTemplate(
          context,
          callbackButton,
          'リセット',
          'トレーニングは実施中です。タイマーをリセットしてもよろしいですか？');
    } else {
      timer.cancel();
      stopwatch.reset();
      setState(() {
        timeString = "00:00";
      });
      stopwatch.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                // set_order.toString() + 'セット目',
                '1セット目',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)
                    .copyWith(color: Colors.white70, fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              // Wrap the Container with Expanded widget
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(10, 10),
                          color: Colors.black38,
                          blurRadius: 15),
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.timer, size: 60, color: Colors.grey.shade800),
                    Text(timeString,
                        style: TextStyle(
                            fontSize: 40, color: Colors.grey.shade900))
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                      onPressed: () {
                        reset();
                      },
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(10, 10),
                                  color: Colors.black38,
                                  blurRadius: 15),
                            ]),
                        child: Icon(Icons.refresh,
                            size: 40, color: Colors.grey.shade800),
                      )),
                  TextButton(
                      onPressed: () {
                        stopwatch.isRunning ? stop() : start();
                      },
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(10, 10),
                                  color: Colors.black38,
                                  blurRadius: 15),
                            ]),
                        child: stopwatch.isRunning
                            ? Icon(Icons.pause,
                                size: 40, color: Colors.yellow[800])
                            : Icon(Icons.play_arrow,
                                size: 40, color: Colors.green),
                      ))
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15),
              child: SizedBox(
                child: Text(
                  "kgs",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold)
                      .copyWith(color: Colors.white70, fontSize: 18.0),
                ),
              ),
              width: double.infinity,
            ),
            SpinBox(
              min: 1,
              max: 500,
              value: 30,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
              ),
              onChanged: (value) => print(value),
            ),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.only(left: 15),
              child: SizedBox(
                child: Text(
                  "reps",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold)
                      .copyWith(color: Colors.white70, fontSize: 18.0),
                ),
              ),
              width: double.infinity,
            ),
            SpinBox(
              min: 1,
              max: 500,
              value: 30,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
              ),
              onChanged: (value) => print(value),
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () {
                if (stopwatch.isRunning){
                  AlertDialogTemplate(context, CFM_MSG_TITLE, 'トレーニング実施中です。タイマーを停止してから閉じてください。');
                } else {
                  Navigator.pop(context); // Close the sheet.
                }
              },
              child: Text("閉じる",
                  style:
                      TextStyle(color: Colors.white)), // Add the button text.
            ),
          ]),
        ),
      ),
    );
  }
}
