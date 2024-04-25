import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/common/resources/app_resources.dart';
import 'package:liftaholic_frontend/src/common/functions.dart';
import 'package:liftaholic_frontend/src/common/default_value.dart';

class TotalVolumeBarChartWidget extends ConsumerStatefulWidget {
  TotalVolumeBarChartWidget({super.key, required this.totalVolumeData, required this.startDateStr, required this.endDateStr});

  final Map totalVolumeData;
  final String startDateStr;
  final String endDateStr;

  @override
  _TotalVolumeBarChartWidgetState createState() => _TotalVolumeBarChartWidgetState();
}

class _TotalVolumeBarChartWidgetState extends ConsumerState<TotalVolumeBarChartWidget> {
  // 棒グラフの棒の横幅
  static const double barWidth = 5.0;

  // グラフタイトルのラベル書式
  // final TextStyle _labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w800);

  bool _loading = false;

  int? selectedPartNo = null;

  late Map totalVolumeData = {};
  late String startDateStr = "";
  late String endDateStr = "";

  List<BarChartGroupData> barDataKg = []; // kgの棒グラフのデータを格納するためのリスト
  List<BarChartGroupData> barDataTime = []; // timeの棒グラフのデータを格納するためのリスト

  int days = 0;
  int epochTimeStart = 0;
  int epochTimeEnd = 0;

  double volumeMax = 120;
  double volumeMin = 0;
  double timeElapsedMax = 60.0;
  double timeElapsedMin = 0.0;

  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  DateFormat displayFormat = DateFormat('MM/dd');

  // 日付の情報を元に棒グラフを生成する
  void _initializeVariant() {
    setState(() {
      var startDateList = startDateStr.toString().split('-');
      var endDateList = endDateStr.toString().split('-');
      Duration differance = DateTime(int.parse(endDateList[0]), int.parse(endDateList[1]), int.parse(endDateList[2])).difference(DateTime(int.parse(startDateList[0]), int.parse(startDateList[1]), int.parse(startDateList[2])));

      epochTimeStart = convertDate2EpochTime(startDateStr);
      epochTimeEnd = convertDate2EpochTime(endDateStr);

      days = differance.inDays;

      // 棒グラフの初期化
      for (var d = 1; d < days + 1; d++) {
        var epochTime = epochTimeStart + secPerDay * d;
        barDataKg.add(
          BarChartGroupData(x: epochTime, barRods: [
            BarChartRodData(toY: 0, width: barWidth),
          ]),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    totalVolumeData = widget.totalVolumeData;
    startDateStr = widget.startDateStr;
    endDateStr = widget.endDateStr;

    _initializeVariant();
  }

  @override
  Widget build(BuildContext context) {
    // 選択された部位
    var selectedPartNo = ref.watch(selectedPartNoProvider);
    // 選択された棒グラフのタイプ
    var selectedBarType = ref.watch(selectedBarTypeProvider);

    if (selectedPartNo != null && selectedPartNo != -1) {
      var _totalVolumeData = totalVolumeData[selectedPartNo.toString()];
      if (_totalVolumeData != null) {
        // リスト初期化
        barDataKg = [];
        barDataTime = [];

        setState(() {
          volumeMax = _totalVolumeData['volume_max'];
          volumeMin = _totalVolumeData['volume_min'];

          timeElapsedMax = _totalVolumeData['time_elapsed_max'];
          timeElapsedMin = _totalVolumeData['time_elapsed_min'];

          // {epochTime: totalVolume}のmapを作成する
          Map volumeMap = {};
          // {epochTime: timeElapsed}のmapを作成する
          Map timeMap = {};
          for (var i = 0; i < _totalVolumeData['volume_data'].length; i++) {
            var volumeData = _totalVolumeData['volume_data'][i]['volume'];
            var timeElapsedData = _totalVolumeData['volume_data'][i]['time_elapsed'];
            var epochData = convertDate2EpochTime(_totalVolumeData['volume_data'][i]['datetime'].toString());
            volumeMap[epochData] = volumeData;
            timeMap[epochData] = timeElapsedData;
          }

          // barGroups: 棒グラフのグループを表す
          // BarChartGroupData: 棒グラフの1つのグループを表す
          // X : 横軸
          // barRods: 棒グラフのデータを含むBarRodクラスのリスト
          // BarChartRodData
          // toY : 高さ
          // width : 棒の幅
          for (var d = 1; d < days + 1; d++) {
            var epochTime = epochTimeStart + secPerDay * d;
            double volume = 0;
            if (volumeMap.containsKey(epochTime)) {
              volume = volumeMap[epochTime];
            }
            barDataKg.add(
              BarChartGroupData(x: epochTime, barRods: [
                BarChartRodData(toY: volume.toDouble(), width: barWidth),
              ]),
            );

            double timeElapsed = 0;
            if (timeMap.containsKey(epochTime)) {
              timeElapsed = timeMap[epochTime];
            }
            barDataTime.add(
              BarChartGroupData(x: epochTime, barRods: [
                BarChartRodData(toY: timeElapsed.toDouble(), width: barWidth),
              ]),
            );
          }
        });
      }
    } else {
      var _totalVolumeData = {'volume_data': [], 'volume_max': 120.0, 'volume_min': 0.0, 'time_elapsed': [], 'time_elapsed_max': 60.0, 'time_elapsed_min': 0.0};
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
                : selectedBarType == 'kg'
                    ? BarChart(kgData())
                    : BarChart(timeData()),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 24, top: 0),
          // width: 60,
          // height: 34,
          child: selectedBarType == 'kg' ? Text('(kg)', style: TextStyle(fontSize: 12, color: Colors.white)) : Text('(min)', style: TextStyle(fontSize: 12, color: Colors.white)),
        ),
      ],
    );
  }

  BarChartData kgData() {
    return BarChartData(
        minY: 0,
        maxY: volumeMax * 1.2,
        // 棒グラフの位置
        alignment: BarChartAlignment.spaceEvenly,

        // 棒グラフタッチ時の動作設定
        barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.black,
        )),

        // グラフタイトルのパラメータ
        titlesData: FlTitlesData(
          show: true,
          //右タイトル
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          //上タイトル
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          //下タイトル
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              // interval: 3600 * 24 * 7,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          // 左タイトル
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: ((volumeMax.toInt() / 4) / 10).ceil() * 10, // ここを変更
              reservedSize: 42,
              // getTitlesWidget: leftTitleWidgets,
            ),
          ),
        ),

        // 外枠表の線を表示/非表示
        borderData: FlBorderData(
            border: const Border(
          top: BorderSide.none,
          right: BorderSide.none,
          left: BorderSide(width: 1),
          bottom: BorderSide(width: 1),
        )),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: ((volumeMax.toInt() / 4) / 10).ceil() * 10, // ここを変更
          verticalInterval: 1, //3600 * 24 * 7, // ここを変更
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
        barGroups: barDataKg);
  }

  BarChartData timeData() {
    return BarChartData(
        minY: 0,
        maxY: timeElapsedMax * 1.2,
        // 棒グラフの位置
        alignment: BarChartAlignment.spaceEvenly,

        // 棒グラフタッチ時の動作設定
        barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.black,
        )),

        // グラフタイトルのパラメータ
        titlesData: FlTitlesData(
          show: true,
          //右タイトル
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          //上タイトル
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          //下タイトル
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              // interval: 3600 * 24 * 7,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          // 左タイトル
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              // interval: ((timeElapsedMax.toInt() / 4) / 10).ceil() * 10, // ここを変更
              // getTitlesWidget: leftTitleWidgets,
            ),
          ),
        ),

        // 外枠表の線を表示/非表示
        borderData: FlBorderData(
            border: const Border(
          top: BorderSide.none,
          right: BorderSide.none,
          left: BorderSide(width: 1),
          bottom: BorderSide(width: 1),
        )),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          // horizontalInterval: ((timeElapsedMax / 4) / 10).ceil() * 10, // ここを変更
          verticalInterval: 1,
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
        barGroups: barDataTime);
  }

  // bottomの目盛りを規格化する
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    var startDateList = startDateStr.toString().split('-');
    var tgtDateList = dateFormat.format(convertEpochTime2Date(value.toInt())).toString().split('-');
    Duration differance = DateTime(int.parse(tgtDateList[0]), int.parse(tgtDateList[1]), int.parse(tgtDateList[2])).difference(DateTime(int.parse(startDateList[0]), int.parse(startDateList[1]), int.parse(startDateList[2])));
    days = differance.inDays;

    Widget text;
    var dateStr = deleteZero(displayFormat.format(convertEpochTime2Date(value.toInt())).toString());
    switch (days.toInt()) {
      case 7:
        text = Text(dateStr, style: style);
        break;
      case 14:
        text = Text(dateStr, style: style);
        break;
      case 21:
        text = Text(dateStr, style: style);
        break;
      case 28:
        text = Text(dateStr, style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }
}
