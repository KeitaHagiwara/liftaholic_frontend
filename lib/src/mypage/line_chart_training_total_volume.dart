import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/common/resources/app_resources.dart';
import 'package:liftaholic_frontend/src/common/dialogs.dart';
import 'package:liftaholic_frontend/src/common/messages.dart';
import 'package:liftaholic_frontend/src/common/functions.dart';

class AchievementLineChartScreen extends ConsumerStatefulWidget {
  const AchievementLineChartScreen({super.key});

  @override
  _AchievementLineChartScreenState createState() => _AchievementLineChartScreenState();
}

class _AchievementLineChartScreenState extends ConsumerState<AchievementLineChartScreen> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  bool _loading = false;

  int? selectedPartNo = null;

  Map totalVolumeData = {};
  List<FlSpot> spotData = [];

  String startDateStr = "";
  String endDateStr = "";

  int days = 0;
  int epochTimeStart = 0;
  int epochTimeEnd = 0;

  double volumeMax = 100;
  double volumeMin = 0;

  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  DateFormat displayFormat = DateFormat('MM/dd');

  // 日付の変数を初期化する
  void _initializeVariant() {
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

      var startDateList = startDateStr.toString().split('-');
      var endDateList = endDateStr.toString().split('-');
      Duration differance = DateTime(int.parse(endDateList[0]), int.parse(endDateList[1]), int.parse(endDateList[2])).difference(DateTime(int.parse(startDateList[0]), int.parse(startDateList[1]), int.parse(startDateList[2])));

      epochTimeStart = convertDate2EpochTime(startDateStr);
      epochTimeEnd = convertDate2EpochTime(endDateStr);

      days = differance.inDays;
    });
  }

  // ユーザーのトレーニング内訳データを取得する
  Future<void> _getTotalVolumeData(uid) async {
    // スピナー表示
    setState(() {
      _loading = true;
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
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _initializeVariant();

    _getTotalVolumeData(FirebaseAuth.instance.currentUser?.uid);
  }

  @override
  Widget build(BuildContext context) {
    var selectedPartNo = ref.watch(selectedPartNoProvider);
    var _totalVolumeData = {'volume_data': [], 'volume_max': 100.0, 'volume_min': 0.0};

    if (selectedPartNo != null && selectedPartNo != -1) {
      var _totalVolumeData = totalVolumeData[selectedPartNo.toString()];
      if (_totalVolumeData != null) {
        spotData = []; // リスト初期化
        setState(() {
          volumeMax = _totalVolumeData['volume_max'];
          volumeMin = _totalVolumeData['volume_min'];
          for (var i = 0; i < _totalVolumeData['volume_data'].length; i++) {
            var volume = _totalVolumeData['volume_data'][i]['volume'];
            var epoch = convertDate2EpochTime(_totalVolumeData['volume_data'][i]['datetime'].toString());
            spotData.add(FlSpot(epoch.toDouble(), volume.toDouble()));
          }
          // spotData = [
          //   FlSpot(5, 2000),
          //   FlSpot(8, 5000),
          //   FlSpot(10, 3000),
          //   FlSpot(14, 4000),
          //   FlSpot(18, 3000),
          //   FlSpot(20, 4000),
          //   FlSpot(23, 4000),
          //   FlSpot(26, 4000),
          //   FlSpot(30, 4000),
          // ];
        });
      }
    }

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
                : LineChart(
                    mainData(spotData),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 24, top: 5),
          // width: 60,
          // height: 34,
          child: Text(
            '(kg)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    var dateStr = deleteZero(displayFormat.format(convertEpochTime2Date(value.toInt())).toString());

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(dateStr, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    if (value.toInt().toString().length == 4) {}
    switch (value.toInt().toString().length) {
      case 4:
        text = value.toInt().toString()[0] + ' K';
        break;
      case 8:
        text = value.toInt().toString()[0] + ' M';
        break;
      default:
        text = value.toInt().toString();
      // return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  LineChartData mainData(List<FlSpot> spotData) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 250, // ここを変更
        verticalInterval: 3600 * 24 * 7, // ここを変更
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 3600 * 24 * 7, // ここを変更
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 250, // ここを変更
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: epochTimeStart.toDouble(),
      maxX: epochTimeEnd.toDouble(),
      minY: volumeMin,
      maxY: volumeMax,
      lineBarsData: [
        LineChartBarData(
          spots: spotData,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.5)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // LineChartData avgData() {
  //   return LineChartData(
  //     lineTouchData: const LineTouchData(enabled: false),
  //     gridData: FlGridData(
  //       show: true,
  //       drawHorizontalLine: true,
  //       verticalInterval: 1,
  //       horizontalInterval: 1,
  //       getDrawingVerticalLine: (value) {
  //         return const FlLine(
  //           color: Color(0xff37434d),
  //           strokeWidth: 1,
  //         );
  //       },
  //       getDrawingHorizontalLine: (value) {
  //         return const FlLine(
  //           color: Color(0xff37434d),
  //           strokeWidth: 1,
  //         );
  //       },
  //     ),
  //     titlesData: FlTitlesData(
  //       show: true,
  //       bottomTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           reservedSize: 30,
  //           getTitlesWidget: bottomTitleWidgets,
  //           interval: 1,
  //         ),
  //       ),
  //       leftTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           getTitlesWidget: leftTitleWidgets,
  //           reservedSize: 42,
  //           interval: 1,
  //         ),
  //       ),
  //       topTitles: const AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //       rightTitles: const AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //     ),
  //     borderData: FlBorderData(
  //       show: true,
  //       border: Border.all(color: const Color(0xff37434d)),
  //     ),
  //     minX: 0,
  //     maxX: 11,
  //     minY: 0,
  //     maxY: 6,
  //     lineBarsData: [
  //       LineChartBarData(
  //         spots: const [
  //           FlSpot(0, 3.44),
  //           FlSpot(2.6, 3.44),
  //           FlSpot(4.9, 3.44),
  //           FlSpot(6.8, 3.44),
  //           FlSpot(8, 3.44),
  //           FlSpot(9.5, 3.44),
  //           FlSpot(11, 3.44),
  //         ],
  //         isCurved: true,
  //         gradient: LinearGradient(
  //           colors: [
  //             ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
  //             ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
  //           ],
  //         ),
  //         barWidth: 5,
  //         isStrokeCapRound: true,
  //         dotData: const FlDotData(
  //           show: false,
  //         ),
  //         belowBarData: BarAreaData(
  //           show: true,
  //           gradient: LinearGradient(
  //             colors: [
  //               ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!.withOpacity(0.1),
  //               ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!.withOpacity(0.1),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
