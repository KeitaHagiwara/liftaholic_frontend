import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter/material.dart';

class ProgressbarCircleScreen extends ConsumerStatefulWidget {
  const ProgressbarCircleScreen({Key? key, required this.progress})
      : super(key: key);

  final int progress;

  @override
  _ProgressbarCircleScreenState createState() =>
      _ProgressbarCircleScreenState();
}

class _ProgressbarCircleScreenState
    extends ConsumerState<ProgressbarCircleScreen> {

  late int _progress;

  @override
  void initState() {
    super.initState();

    _progress = widget.progress;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: SfRadialGauge(axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100,
          showLabels: false,
          showTicks: false,
          startAngle: 270,
          endAngle: 270,
          axisLineStyle: AxisLineStyle(
            thickness: 1,
            color: Colors.white, //const Color.fromARGB(255, 0, 169, 181),
            thicknessUnit: GaugeSizeUnit.factor,
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: _progress.toDouble(),
              width: 0.2,
              color: _progress == 100 ? Colors.red :Colors.green,
              pointerOffset: 0.1,
              cornerStyle: CornerStyle.bothCurve,
              sizeUnit: GaugeSizeUnit.factor,
            )
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: _progress == 100
                ? Text(
                    '完', // Display the percentage value with 2 decimal places
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(color: Colors.red),
                  )
                : Text(
                    _progress.toString() + '%', // Display the percentage value with 2 decimal places
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(color: Colors.green),
                  ),
              angle: 90,
              positionFactor: 0.5,
            ),
          ],

        )
      ])
    );
  }
}
