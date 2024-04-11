import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:liftaholic_frontend/src/common/resources/app_resources.dart';

class _LineChart extends StatelessWidget {
  const _LineChart({required this.isShowingMainData, required this.nowDay});

  final bool isShowingMainData;

  final int nowDay;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      // isShowingMainData ? sampleData1 : sampleData2,
      sampleData2,
      duration: const Duration(milliseconds: 250),
    );
  }

  // LineChartData get sampleData1 => LineChartData(
  //       lineTouchData: lineTouchData1,
  //       gridData: gridData,
  //       titlesData: titlesData1,
  //       borderData: borderData,
  //       lineBarsData: lineBarsData1,
  //       minX: 0,
  //       maxX: 14,
  //       maxY: 4,
  //       minY: 0,
  //     );

  LineChartData get sampleData2 => LineChartData(
        lineTouchData: lineTouchData2,
        gridData: gridData,
        titlesData: titlesData2,
        borderData: borderData,
        lineBarsData: lineBarsData2,
        minX: 1,
        maxX: nowDay.toDouble(),
        // maxX: 32,
        maxY: 6,
        minY: 0,
      );

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  // List<LineChartBarData> get lineBarsData1 => [
  //       lineChartBarData1_1,
  //       lineChartBarData1_2,
  //       lineChartBarData1_3,
  //     ];

  LineTouchData get lineTouchData2 => const LineTouchData(
        enabled: false,
      );

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData2 => [
        lineChartBarData2_1,
        lineChartBarData2_2,
        lineChartBarData2_3,
      ];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '1m';
        break;
      case 2:
        text = '2m';
        break;
      case 3:
        text = '3m';
        break;
      case 4:
        text = '5m';
        break;
      case 5:
        text = '6m';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 7:
        text = const Text('7日', style: style);
        break;
      case 14:
        text = const Text('14日', style: style);
        break;
      case 21:
        text = const Text('21日', style: style);
        break;
      case 28:
        text = const Text('28日', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 2),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  // LineChartBarData get lineChartBarData1_1 => LineChartBarData(
  //       isCurved: true,
  //       color: AppColors.contentColorGreen,
  //       barWidth: 8,
  //       isStrokeCapRound: true,
  //       dotData: const FlDotData(show: false),
  //       belowBarData: BarAreaData(show: false),
  //       spots: const [
  //         FlSpot(1, 1),
  //         FlSpot(3, 1.5),
  //         FlSpot(5, 1.4),
  //         FlSpot(7, 3.4),
  //         FlSpot(10, 2),
  //         FlSpot(12, 2.2),
  //         FlSpot(13, 1.8),
  //       ],
  //     );

  // LineChartBarData get lineChartBarData1_2 => LineChartBarData(
  //       isCurved: true,
  //       color: AppColors.contentColorPink,
  //       barWidth: 8,
  //       isStrokeCapRound: true,
  //       dotData: const FlDotData(show: false),
  //       belowBarData: BarAreaData(
  //         show: false,
  //         color: AppColors.contentColorPink.withOpacity(0),
  //       ),
  //       spots: const [
  //         FlSpot(1, 1),
  //         FlSpot(3, 2.8),
  //         FlSpot(7, 1.2),
  //         FlSpot(10, 2.8),
  //         FlSpot(12, 2.6),
  //         FlSpot(13, 3.9),
  //       ],
  //     );

  // LineChartBarData get lineChartBarData1_3 => LineChartBarData(
  //       isCurved: true,
  //       color: AppColors.contentColorCyan,
  //       barWidth: 8,
  //       isStrokeCapRound: true,
  //       dotData: const FlDotData(show: false),
  //       belowBarData: BarAreaData(show: false),
  //       spots: const [
  //         FlSpot(1, 2.8),
  //         FlSpot(3, 1.9),
  //         FlSpot(6, 3),
  //         FlSpot(10, 1.3),
  //         FlSpot(13, 2.5),
  //       ],
  //     );

  LineChartBarData get lineChartBarData2_1 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: AppColors.contentColorGreen.withOpacity(0.5),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 4),
          FlSpot(5, 1.8),
          FlSpot(7, 5),
        ],
      );

  LineChartBarData get lineChartBarData2_2 => LineChartBarData(
        isCurved: true,
        color: AppColors.contentColorPink.withOpacity(0.5),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: AppColors.contentColorPink.withOpacity(0.2),
        ),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 2.8),
          FlSpot(7, 1.2),
        ],
      );

  LineChartBarData get lineChartBarData2_3 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: AppColors.contentColorCyan.withOpacity(0.5),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 3.8),
          FlSpot(3, 1.9),
          FlSpot(6, 5),
        ],
      );
}

class LineChartAchievementScreen extends StatefulWidget {
  const LineChartAchievementScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LineChartAchievementScreenState();
}

class _LineChartAchievementScreenState extends State<LineChartAchievementScreen> {
  late bool isShowingMainData;

  late int nowDay;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;

    // 今日の日付を取得する
    DateTime now = DateTime.now();
    DateFormat format = DateFormat('yyyy-MM-dd');
    String dateStr = format.format(now);
    nowDay = int.parse(dateStr.split('-')[2]);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // const Text(
              //   'Monthly Sales',
              //   style: TextStyle(
              //     color: AppColors.primary,
              //     fontSize: 32,
              //     fontWeight: FontWeight.bold,
              //     letterSpacing: 2,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              Expanded(
                child: Padding(
                  // padding: const EdgeInsets.only(right: 16, left: 6),
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  child: _LineChart(isShowingMainData: isShowingMainData, nowDay: nowDay),
                ),
              ),
              // const SizedBox(
              //   height: 10,
              // ),
            ],
          ),
          // IconButton(
          //   icon: Icon(
          //     Icons.refresh,
          //     color: Colors.white.withOpacity(isShowingMainData ? 1.0 : 0.5),
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       isShowingMainData = !isShowingMainData;
          //     });
          //   },
          // )
        ],
      ),
    );
  }
}
