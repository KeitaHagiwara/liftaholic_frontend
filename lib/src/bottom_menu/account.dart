import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../login.dart';
import '../common/dialogs.dart';
import '../mypage/pie_chart.dart';
import '../mypage/line_chart_1.dart';
import '../mypage/line_chart_2.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  // イニシャライザ設定
  String? uid = '';
  String? email = '';
  String? username = '';
  String? photoURL = '';

  Future<void> reload() async {
    final instance = FirebaseAuth.instance;
    final User? user = instance.currentUser;
    await user!.reload();
  }

  @override
  void initState() {
    super.initState();

    reload();
    uid = FirebaseAuth.instance.currentUser?.uid;
    email = FirebaseAuth.instance.currentUser?.email;
    username = FirebaseAuth.instance.currentUser?.displayName;
    photoURL = FirebaseAuth.instance.currentUser?.photoURL;
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
      body: Center(
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
              'トレーニング内訳',
              style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
            )),
        Container(child: BreakdownPieChartScreen()),

        // 日付ごとの折れ線グラフ
        Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            child: Text(
              '予定と実績',
              style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
            )),
        Container(child: LineChartSample1()),

        // 日付ごとの折れ線グラフ
        Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            child: Text(
              'トレーニング履歴',
              style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
            )),
        Container(child: AchievementLineChartScreen()),
      ])),
    );
  }
}
