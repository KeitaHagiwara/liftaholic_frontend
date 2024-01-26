import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../workout/add_training_menu.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  // final String title;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // イニシャライザ設定
  bool _loading = false;

  String result = '';

  bool isPressed = false;
  IconData icon = Icons.play_arrow;
  MaterialColor primaryColor = Colors.blue;

  Future<void> getTrainingPlans() async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    // リクエスト先のurl
    Uri url = Uri.parse("http://127.0.0.1:8080/api/workout");

    try {
      //リクエストを投げる
      var response = await http.get(url);
      //リクエスト結果をコンソール出力
      // debugPrint(response.body);

      var jsonResponse = jsonDecode(response.body);

      if (!mounted) return;
      setState(() {
        result = jsonResponse["greeting"];
        print(result);
        // スピナー非表示
        _loading = false;
      });
    } catch (e) {
      //リクエストに失敗した場合は"error"と表示
      print(e);
      debugPrint('error');
    }
  }

  @override
  void initState() {
    super.initState();

    getTrainingPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('ホーム'),
        // ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
            : Center(
                child: Column(
                // children: [
                //   Text(result, style: TextStyle(fontSize: 32.0)),
                //   Container(
                //     width: double.infinity,
                //     child: TextField(
                //       keyboardType: TextInputType.number,
                //       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                //       controller: TextEditingController(text: '1'),
                //     ),
                //   ),
                // ]

                children: <Widget>[
                  Text(
                    // _programMovesGen(program)[index],
                    'バイセップカール',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)
                        .copyWith(color: Colors.white70, fontSize: 18.0),
                  ), // Move name
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // --------
                      // sets
                      // --------
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: TextFormField(
                            // controller: ontrollerSets,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            // decoration: InputDecoration(
                            //   enabledBorder: OutlineInputBorder(
                            //     borderSide: BorderSide(color: Colors.blue)
                            //   ),
                            //   focusedBorder: OutlineInputBorder(
                            //     borderSide: BorderSide(color: Colors.orange)
                            //   )
                            // ),
                          ),
                        ),
                      ),
                      Text(
                        "sets ",
                        textAlign: TextAlign.center,
                        style: TextStyle()
                            .copyWith(color: Colors.white70, fontSize: 18.0),
                      ),
                      // --------
                      // reps
                      // --------
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            // controller: controllerReps,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            // decoration: InputDecoration(
                            //   enabledBorder: OutlineInputBorder(
                            //     borderSide: BorderSide(color: Colors.blue)
                            //   ),
                            //   focusedBorder: OutlineInputBorder(
                            //     borderSide: BorderSide(color: Colors.orange)
                            //   )
                            // ),
                          ),
                        ),
                      ),
                      Text(
                        "reps",
                        textAlign: TextAlign.center,
                        style: TextStyle()
                            .copyWith(color: Colors.white70, fontSize: 18.0),
                      ),
                      // --------
                      // kg
                      // --------
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            // controller: controllerKgs,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            // decoration: InputDecoration(
                            //   enabledBorder: OutlineInputBorder(
                            //     borderSide: BorderSide(color: Colors.blue)
                            //   ),
                            //   focusedBorder: OutlineInputBorder(
                            //     borderSide: BorderSide(color: Colors.orange)
                            //   )
                            // ),
                          ),
                        ),
                      ),
                      Text(
                        "kg",
                        textAlign: TextAlign.center,
                        style: TextStyle()
                            .copyWith(color: Colors.white70, fontSize: 18.0),
                      ),
                      Container(
                          // height: 40,
                          // width: 40,
                          // margin: const EdgeInsets.all(16.0),
                          // decoration: BoxDecoration(
                          //   shape: BoxShape.circle,
                          //   color: Colors.white,
                          //   border: Border.all(
                          //     color: Colors.blue,
                          //     width: 2.0,
                          //   ),
                          // ),
                          child: ElevatedButton.icon(
                            icon: Icon(
                              this.icon,
                              color: Colors.yellow,
                            ),
                            label: Text(''),
                            // style: ElevatedButton.styleFrom(
                            //   primary: this.primaryColor,
                            //   onPrimary: Colors.white,
                            // ),
                            onPressed: () {
                              this.isPressed = !this.isPressed;
                              setState(() {
                                this.icon =
                                this.isPressed ? Icons.stop : Icons.play_arrow;
                                this.primaryColor = this.isPressed ? Colors.orange : Colors.blue;
                              });
                            },
                          )
                          // child: IconButton(
                          //     icon: Icon(
                          //       Icons.play_arrow,
                          //       size: 35,
                          //       color: Colors.blue,
                          //     ),
                          //     onPressed: () => {
                          //       // isPressed = !isPressed,
                          //       isPressed = !isPressed ? true : false,
                          //       print(isPressed),
                          //       setState(() {
                          //         // icon = isPressed ? Icons.stop : Icons.play_arrow;
                          //         // primaryColor = isPressed ? Colors.red : Colors.blue;
                          //         this.icon = Icons.stop;
                          //         this.primaryColor = Colors.red;
                          //       }),
                          //       // print('test'),
                          //       // _saveMove(_programMovesGen(program)[index]),
                          //     })
                      ),
                      ///TODO add to db and previous added move
                    ],
                  ),
                ],
              )));
  }
}
