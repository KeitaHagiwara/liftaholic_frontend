import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:uuid/v6.dart';

import 'package:liftaholic_frontend/src/common/resources/app_resources.dart';
import 'package:liftaholic_frontend/src/common/dialogs.dart';
import 'package:liftaholic_frontend/src/common/messages.dart';

class BreakdownPieChartScreen extends StatefulWidget {
  const BreakdownPieChartScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BreakdownPieChartScreenState();
}

class _BreakdownPieChartScreenState extends State<BreakdownPieChartScreen> {
  int touchedIndex = 0;

  List pieChartData = [];

  // ユーザーのトレーニング内訳のデータを取得する
  Future<void> _getPieChartData(uid) async {
    // スピナー表示
    // setState(() {
    //   _loading = true;
    // });

    await dotenv.load(fileName: '.env');

    //リクエスト先のurl
    Uri url = Uri.parse("http://" + dotenv.get('API_HOST') + ":" + dotenv.get('API_PORT') + "/api/training_plan/get_user_training_plans/" + uid);

    try {
      //リクエストを投げる
      // var response = await http.get(url).timeout(Duration(seconds: 10));
      //リクエスト結果をコンソール出力
      // debugPrint(response.body);

      // var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      var jsonResponse = {'statusCode': 200};
      if (!mounted) return;
      if (jsonResponse['statusCode'] == 200) {
        setState(() {
          pieChartData = [
            {'value': 40, 'parts': '胸', 'color': AppColors.contentColorBlue, 'img_svg': 'ophthalmology-svgrepo-com.svg'},
            {'value': 30, 'parts': '肩', 'color': AppColors.contentColorYellow, 'img_svg': 'librarian-svgrepo-com.svg'},
            {'value': 20, 'parts': '脚', 'color': AppColors.contentColorPurple, 'img_svg': 'fitness-svgrepo-com.svg'},
            {'value': 10, 'parts': '背中', 'color': AppColors.contentColorGreen, 'img_svg': 'worker-svgrepo-com.svg'},
          ];
        });
      } else {
        //リクエストに失敗した場合はエラーメッセージを表示
        // AlertDialogTemplate(context, ERR_MSG_TITLE, jsonResponse['statusMessage']);
      }
    } catch (e) {
      //リクエストに失敗した場合はエラーメッセージを表示
      AlertDialogTemplate(context, ERR_MSG_TITLE, ERR_MSG_NETWORK);
    } finally {
      // setState(() {
      //   // スピナー非表示
      //   _loading = false;
      // });
    }
  }

  @override
  void initState() {
    super.initState();

    _getPieChartData(FirebaseAuth.instance.currentUser?.uid);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
            sections: showingSections(),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(pieChartData.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 14.0;
      // final radius = isTouched ? 110.0 : 100.0;
      final radius = isTouched ? 130.0 : 120.0;
      final widgetSize = isTouched ? 75.0 : 60.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: pieChartData[i]['color'],
        value: pieChartData[i]['value'].toDouble(),
        title: pieChartData[i]['parts'] + '\n' + pieChartData[i]['value'].toString() + '%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
        badgeWidget: _Badge(
          'assets/icons/' + pieChartData[i]['img_svg'],
          size: widgetSize,
          borderColor: AppColors.contentColorBlack,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.svgAsset, {
    required this.size,
    required this.borderColor,
  });
  final String svgAsset;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: SvgPicture.asset(
          svgAsset,
        ),
      ),
    );
  }
}
