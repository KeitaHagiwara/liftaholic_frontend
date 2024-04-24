import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:liftaholic_frontend/src/login.dart';
import 'package:liftaholic_frontend/src/common/dialogs.dart';
import 'package:liftaholic_frontend/src/common/messages.dart';
import 'package:liftaholic_frontend/src/common/resources/app_resources.dart';
import 'package:liftaholic_frontend/src/mypage/pie_chart_parts_pct.dart';
// import 'package:liftaholic_frontend/src/mypage/line_chart_training_total_volume.dart';
import 'package:liftaholic_frontend/src/mypage/bar_chart_training_total_volume.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  // イニシャライザ設定
  String? uid = '';
  String? email = '';
  String? username = '';
  String? photoURL = '';

  bool _loading_training_breakdown = false;
  bool _loading_training_volume = false;

  List pieChartData = [];
  Map totalVolumeData = {};

  String startDateStr = "";
  String endDateStr = "";

  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> reload() async {
    final instance = FirebaseAuth.instance;
    final User? user = instance.currentUser;
    await user!.reload();
  }

  // ユーザーのトレーニング内訳データを取得する
  Future<void> _getPieChartData(uid) async {
    // スピナー表示
    setState(() {
      _loading_training_breakdown = true;
    });

    await dotenv.load(fileName: '.env');

    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/mypage/get_user_pie_chart_data/" + uid);

    try {
      //リクエストを投げる
      var response = await http.get(url).timeout(Duration(seconds: 10));
      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;
      if (jsonResponse['statusCode'] == 200) {
        var data = jsonResponse['pie_chart_data'];
        setState(() {
          pieChartData = [];
          for (var i = 0; i < data.length; i++) {
            var img_file_name = data[i]['part_image_file'];
            var chart_color_key = img_file_name.split('.')[0];
            pieChartData.add({
              'value': data[i]['value'],
              'parts': data[i]['part_name'],
              'color': partsColors[chart_color_key],
              'img_file': img_file_name,
            });
          }
        });
      } else {
        // リクエストに失敗した場合はエラーメッセージを表示
        AlertDialogTemplate(context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
      }
    } catch (e) {
      // リクエストに失敗した場合はエラーメッセージを表示
      AlertDialogTemplate(context, ERR_MSG_TITLE, ERR_MSG_NETWORK);
    } finally {
      setState(() {
        // スピナー非表示
        _loading_training_breakdown = false;
      });
    }
  }

  // ユーザーのトレーニング内訳データを取得する
  Future<void> _getTotalVolumeData(uid) async {
    // スピナー表示
    setState(() {
      _loading_training_volume = true;
    });

    await dotenv.load(fileName: '.env');

    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/mypage/get_user_total_volume_data/" + uid);

    try {
      //リクエストを投げる
      var response = await http.get(url).timeout(Duration(seconds: 10));
      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          totalVolumeData = jsonResponse['training_volume_data'];
        });
      } else {
        // リクエストに失敗した場合はエラーメッセージを表示
        AlertDialogTemplate(context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
      }
    } catch (e) {
      // リクエストに失敗した場合はエラーメッセージを表示
      AlertDialogTemplate(context, ERR_MSG_TITLE, ERR_MSG_NETWORK);
    } finally {
      setState(() {
        // スピナー非表示
        _loading_training_volume = false;
      });
    }
  }

  // 日付の変数を初期化する
  void _calcDateTime() {
    DateTime nowDate = DateTime.now();

    // データ抽出期間を設定する
    final prevMonthLastDay = DateTime(nowDate.year, nowDate.month, 0);
    final prevDiff = nowDate.day < prevMonthLastDay.day ? prevMonthLastDay.day : nowDate.day;
    // 基準日と1ヶ月前の日付の間隔。
    // 基本的に1ヶ月前は基準日から前月の月の日数分引けば求められる。
    // 基準日の1ヶ月前の月の日数より基準日の日付が大きい場合は前月の月末にするために基準日の日付を引く。
    final startDate = nowDate.subtract(Duration(days: prevDiff)); // 1ヶ月前
    // subtract()は引数のDuration分時間を戻す関数

    setState(() {
      startDateStr = dateFormat.format(startDate);
      endDateStr = dateFormat.format(nowDate);
    });
  }

  @override
  void initState() {
    super.initState();

    reload();
    uid = FirebaseAuth.instance.currentUser?.uid;
    email = FirebaseAuth.instance.currentUser?.email;
    username = FirebaseAuth.instance.currentUser?.displayName;
    photoURL = FirebaseAuth.instance.currentUser?.photoURL;

    _calcDateTime();
    _getPieChartData(uid);
    _getTotalVolumeData(uid);
  }

  // ----------------------------
  // ポップアップメニューのカスタマイズ
  // ----------------------------
  PopupMenuItem _buildPopupMenuItem(BuildContext context, String title, IconData iconData, Color color, FontWeight fontWeight, int callbackFunctionId, Map payload) {
    return PopupMenuItem(
        child: InkWell(
      onTap: () async {
        // ログアウト処理
        if (callbackFunctionId == 1) {
          Widget callbackButton = TextButton(
            child: Text("ログアウト"),
            onPressed: () async {
              // ログアウト処理
              // 内部で保持しているログイン情報等が初期化される
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移＋チャット画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginScreen();
                }),
              );
            },
          );
          ConfirmDialogTemplate(context, callbackButton, 'ログアウト', 'ログアウトします。よろしいですか？');
        }
      },
      child: Row(
        children: [
          Icon(
            iconData,
            color: color,
          ),
          Text(' '),
          Text(title, style: TextStyle(fontWeight: fontWeight, color: color)),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
      color: Colors.blue, // インジケータの色
      backgroundColor: Colors.white, // インジケータの背景色
      displacement: 50.0, // リストの端から50ピクセル下に表示
      edgeOffset: 10.0, // リストの端を10ピクセル下にオーバーライド
      onRefresh: () async {
        // 日付の情報を更新する
        _calcDateTime();
        // トレーニング内訳のデータを更新する
        _getPieChartData(uid);
        // トレーニングボリュームのデータを更新する
        _getTotalVolumeData(uid);
      },
      child: Center(
          child: ListView(children: [
        // -------------------
        // アカウント用のヘッダー
        // -------------------
        UserAccountsDrawerHeader(
          accountName: Text(
            username!,
            style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white, fontSize: 20),
          ),
          accountEmail: Text(
            email!,
            style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white, fontSize: 14),
          ),
          currentAccountPicture: GestureDetector(
              onTap: () {
                print('icon tapped');
              },
              child: CircleAvatar(
                foregroundImage: AssetImage("assets/images/account/default_icon.png"),
              )),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/images/account/default_account_bg.png",
              ),
              fit: BoxFit.fill,
            ),
          ),
          otherAccountsPictures: [
            PopupMenuButton(
              icon: Icon(Icons.more_vert, size: 25, color: Colors.white),
              itemBuilder: (ctx) => [
                _buildPopupMenuItem(context, 'ログアウト', Icons.logout, Colors.red, FontWeight.bold, 1, {}),
              ],
            ),
          ],
        ),

        // -------------------
        // コンテンツ
        // -------------------
        const SizedBox(height: 15),
        // 内訳の円フラグ
        Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            child: Text(
              '月間のトレーニング内訳',
              style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
            )),
        SizedBox(
            child: _loading_training_breakdown
                ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
                : BreakdownPieChartWidget(
                    pieChartData: pieChartData,
                  )),

        // 日付ごとの折れ線グラフ
        Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            child: Text(
              'トレーニングボリューム',
              style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
            )),
        // SizedBox(child: AchievementLineChartScreen()),
        SizedBox(
            child: _loading_training_volume
                ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
                : TotalVolumeBarChartWidget(
                    totalVolumeData: totalVolumeData,
                    startDateStr: startDateStr,
                    endDateStr: endDateStr,
                  ))
      ])),
    ));
  }
}
