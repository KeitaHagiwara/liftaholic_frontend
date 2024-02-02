import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../workout/add_training_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // イニシャライザ設定
  bool _loading = false;

  String result = '';

  bool isPressed = false;
  IconData icon = Icons.play_arrow;
  MaterialColor primaryColor = Colors.blue;

  // Future<void> getTrainingPlans() async {
  //   // スピナー表示
  //   setState(() {
  //     _loading = true;
  //   });

  //   // リクエスト先のurl
  //   Uri url = Uri.parse("http://127.0.0.1:8080/api/workout");

  //   try {
  //     //リクエストを投げる
  //     var response = await http.get(url);
  //     //リクエスト結果をコンソール出力
  //     // debugPrint(response.body);

  //     var jsonResponse = jsonDecode(response.body);

  //     if (!mounted) return;
  //     setState(() {
  //       result = jsonResponse["greeting"];
  //       print(result);
  //       // スピナー非表示
  //       _loading = false;
  //     });
  //   } catch (e) {
  //     //リクエストに失敗した場合は"error"と表示
  //     print(e);
  //     debugPrint('error');
  //   }
  // }

  @override
  void initState() {
    super.initState();

    // getTrainingPlans();
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
                children: <Widget>[
                  Text(
                    // _programMovesGen(program)[index],
                    'ホーム画面',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)
                        .copyWith(color: Colors.white70, fontSize: 18.0),
                  ), // Move name
                ],
            )
          )
    );
  }
}
