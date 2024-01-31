import 'dart:convert';

// import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../home/create_training_plan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ホームページのイニシャライザ設定
  bool _loading = false;

  String result = "";
  List<String> trainingPlanTitle = ["plan1", "plan2", "plan3"];
  List<String> trainingPlanDescription = ["Bench press", "Dead lift", "Squad"];
  List<int> trainingPlanCount = [3, 4, 5];

  // Todoリストのデータ
  // Map<String, String> createPlanDict = {};
  Map<String, String> createPlanDict = {};

  Future<void> getTrainingPlans() async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    await dotenv.load(fileName: '.env');

    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/home");

    try {
      //リクエストを投げる
      var response = await http.get(url).timeout(Duration(seconds: 10));
      //リクエスト結果をコンソール出力
      // debugPrint(response.body);

      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;
      setState(() {
        result = jsonResponse["greeting"];
        print(result);
        // スピナー非表示
        _loading = false;
      });
    } catch (e) {
      //リクエストに失敗した場合は"error"と表示
      // print(e);
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
      appBar: AppBar(
        title: Text(
          'トレーニングプラン',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold)
              .copyWith(color: Colors.white70, fontSize: 18.0),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
          : Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.network(
                    // 'https://lottie.host/84241c93-f84c-4133-9d2b-4eeff328313a/XPxdU0Zv81.json',
                    // 'https://lottie.host/c40cfa4e-ab6d-4c6e-aa13-2901a6bd5100/dG0o8nAXpc.json',
                    'https://lottie.host/808890fb-72b9-4685-a6c4-e53abb13faeb/A5Pzml6y3B.json',
                    width: 300,
                    errorBuilder: (context, error, stackTrace) {
                      return const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  Flexible(
                    child: ListView.builder(
                    itemCount: trainingPlanTitle.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: CircleAvatar(
                                child: Text((index + 1).toString()),
                                backgroundColor: Colors.blue,
                              ),
                              // leading: CircleAvatar(foregroundImage: AssetImage("assets/test_user.jpeg")),
                              title: Text(trainingPlanTitle[index],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(trainingPlanDescription[index] +
                                  '\n' +
                                  trainingPlanCount[index].toString() +
                                  ' trainings'),
                              trailing: Icon(Icons.arrow_forward_ios_rounded),
                              onTap: () =>
                                  {print(trainingPlanDescription[index])},
                            ),
                          ],
                        ),
                      );
                    },
                  ))
                ])),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100), //角の丸み
        ),
        onPressed: () async {
          // "push"で新規画面に遷移
          // リスト追加画面から渡される値を受け取る
          final newListText = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              // 遷移先の画面としてリスト追加画面を指定
              return CreateTrainingPlanScreen();
            }),
          );
          if (newListText != null) {
            // キャンセルした場合は newListText が null となるので注意
            setState(() {
              // リスト追加
              trainingPlanTitle.add(newListText['training_title']);
              trainingPlanDescription.add(
                  newListText['training_description'] != null
                      ? newListText['training_description']
                      : 'プランの説明はありません');
              trainingPlanCount.add(int.parse(newListText['training_count']));
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
