import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:liftaholic_frontend/src/common/provider.dart';
import 'package:liftaholic_frontend/src/common/resources/app_resources.dart';

class BreakdownPieChartWidget extends ConsumerStatefulWidget {
  BreakdownPieChartWidget({super.key, required this.pieChartData});

  final List pieChartData;

  @override
  _BreakdownPieChartWidgetState createState() => _BreakdownPieChartWidgetState();
}

class _BreakdownPieChartWidgetState extends ConsumerState<BreakdownPieChartWidget> {
  // ********************
  // イニシャライザ設定
  // ********************

  bool _loading = false;

  int touchedIndex = 0;

  late List pieChartData = [];

  @override
  void initState() {
    super.initState();

    pieChartData = widget.pieChartData;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: _loading
          ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
          : AspectRatio(
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
                        // 枠外の選択を許可しない
                        if (touchedIndex != -1) {
                          ref.read(selectedPartNoProvider.notifier).state = touchedIndex;
                        }
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
      final radius = isTouched ? 130.0 : 120.0;
      final widgetSize = isTouched ? 75.0 : 65.0;
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
          'assets/images/parts/' + pieChartData[i]['img_file'],
          size: widgetSize,
          borderColor: AppColors.contentColorBlack,
        ),
        badgePositionPercentageOffset: 1.05,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.imgAsset, {
    required this.size,
    required this.borderColor,
  });
  final String imgAsset;
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
        child: Image.asset(
          imgAsset,
        ),
      ),
    );
  }
}
